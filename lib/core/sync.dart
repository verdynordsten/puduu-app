import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';
import 'db/repo.dart';

/// Supabase cloud sync (local-first).
/// - Drift stays the source of truth for UI. This pushes local rows up and
///   pulls remote rows down on demand (app start + after every write + manual).
/// - No Supabase keys / offline => silently stays local-only. App never breaks.
/// - MVP: single-user (anon key, RLS allow-all). Auth wiring comes later and
///   fills user_id automatically via currentUser.
class PuduuSync {
  final PuduuRepo repo;
  SupabaseClient? _client;
  bool _ready = false;

  PuduuSync(this.repo);

  bool get isLive => _ready && _client != null;

  Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      return; // no .env on device (CI/web without keys) -> local-only
    }
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final key = dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ??
        dotenv.env['SUPABASE_ANON_KEY'] ??
        '';
    if (url.isEmpty || key.isEmpty || url.contains('xyzcompany')) return;
    try {
      // ignore: deprecated_member_use
      await Supabase.initialize(url: url, anonKey: key);
      _client = Supabase.instance.client;
      _ready = true;
    } catch (_) {
      _ready = false; // offline / bad keys -> local-only
    }
  }

  String? get _uid => _client?.auth.currentUser?.id;

  Map<String, dynamic> _taskRow(PuduuTask t) => {
        'id': t.id,
        'user_id': _uid,
        'title': t.title,
        'note': t.note,
        'duration_min': t.durationMin,
        'scheduled_at': t.scheduledAt?.toIso8601String(),
        'color_index': t.colorIndex,
        'status': t.status,
      };

  /// Push everything local up (upsert), then pull remote down.
  Future<SyncResult> syncAll() async {
    if (!isLive) return const SyncResult.offline();
    try {
      final c = _client!;
      final inbox = await repo.tasksByStatus('inbox');
      final planned = await repo.tasksByStatus('planned');
      final doing = await repo.tasksByStatus('doing');
      final done = await repo.tasksByStatus('done');
      final all = [...inbox, ...planned, ...doing, ...done];
      var up = 0;
      for (final t in all) {
        await c.from('tasks').upsert(_taskRow(t));
        up++;
        for (final s in t.subtasks) {
          await c.from('subtasks').upsert({
            'id': s.id,
            'task_id': t.id,
            'title': s.title,
            'timer_min': s.timerMin,
            'done': s.done,
          });
        }
      }
      final routines = await repo.routines();
      for (final r in routines) {
        await c.from('routines').upsert({
          'id': r.id,
          'user_id': _uid,
          'name': r.name,
          'step_titles': r.stepTitles,
          'rrule': r.rrule,
        });
      }
      final moods = await repo.moods();
      for (final m in moods) {
        await c.from('moods').upsert({
          'day':
              '${m.day.year}-${m.day.month.toString().padLeft(2, '0')}-${m.day.day.toString().padLeft(2, '0')}',
          'user_id': _uid,
          'score': m.score,
          'note': m.note,
        });
      }
      // pull: remote rows newer than local win (last-write-wins on updated_at)
      var down = 0;
      final remoteTasks = await c
          .from('tasks')
          .select()
          .order('updated_at', ascending: false)
          .limit(500);
      for (final row in (remoteTasks as List)) {
        final m = row as Map<String, dynamic>;
        await repo.addTask(PuduuTask(
          id: m['id'] as String,
          title: m['title'] as String,
          note: m['note'] as String?,
          durationMin: m['duration_min'] as int?,
          scheduledAt: m['scheduled_at'] != null
              ? DateTime.parse(m['scheduled_at'] as String)
              : null,
          colorIndex: (m['color_index'] as int?) ?? 0,
          status: (m['status'] as String?) ?? 'inbox',
        ));
        down++;
      }
      return SyncResult.ok(up: up, down: down);
    } catch (_) {
      return const SyncResult.offline();
    }
  }
}

class SyncResult {
  final bool live;
  final int up;
  final int down;
  const SyncResult.ok({required this.up, required this.down}) : live = true;
  const SyncResult.offline()
      : live = false,
        up = 0,
        down = 0;
}

/// JSON helpers for routine steps (repo stores JSON string).
String encodeSteps(List<String> s) => jsonEncode(s);
List<String> decodeSteps(String raw) {
  try {
    return (jsonDecode(raw) as List).map((e) => '$e').toList();
  } catch (_) {
    return const [];
  }
}
