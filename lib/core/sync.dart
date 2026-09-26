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
      // pull subtasks (scoped per task; drift insertOrReplace keeps id stable)
      final remoteSubs = await c
          .from('subtasks')
          .select()
          .order('updated_at', ascending: false)
          .limit(1000);
      var downSubs = 0;
      for (final row in (remoteSubs as List)) {
        final m = row as Map<String, dynamic>;
        await repo.addSubtask(
            m['task_id'] as String,
            PuduuSubtask(
              id: m['id'] as String,
              title: (m['title'] as String?) ?? '',
              timerMin: m['timer_min'] as int?,
              done: (m['done'] as bool?) ?? false,
            ));
        downSubs++;
      }
      // pull routines
      final remoteRoutines =
          await c.from('routines').select().limit(200);
      var downRoutines = 0;
      for (final row in (remoteRoutines as List)) {
        final m = row as Map<String, dynamic>;
        final rawSteps = m['step_titles'];
        await repo.addRoutine(PuduuRoutine(
          id: m['id'] as String,
          name: (m['name'] as String?) ?? 'Routine',
          stepTitles: rawSteps is List
              ? rawSteps.map((e) => '$e').toList()
              : decodeSteps('${rawSteps ?? '[]'}'),
          rrule: (m['rrule'] as String?) ?? '',
        ));
        downRoutines++;
      }
      // pull moods
      final remoteMoods = await c.from('moods').select().limit(400);
      var downMoods = 0;
      for (final row in (remoteMoods as List)) {
        final m = row as Map<String, dynamic>;
        final dayRaw = m['day'];
        DateTime? day;
        if (dayRaw is String) {
          day = DateTime.tryParse(dayRaw);
        }
        if (day == null) continue;
        await repo.logMoodAt(
            DateTime(day.year, day.month, day.day),
            (m['score'] as int?) ?? 3,
            note: m['note'] as String?);
        downMoods++;
      }
      return SyncResult.ok(
          up: up,
          down: down,
          downSubs: downSubs,
          downRoutines: downRoutines,
          downMoods: downMoods);
    } catch (_) {
      return const SyncResult.offline();
    }
  }
}

class SyncResult {
  final bool live;
  final int up;
  final int down;
  final int downSubs;
  final int downRoutines;
  final int downMoods;
  const SyncResult.ok(
      {required this.up,
      required this.down,
      this.downSubs = 0,
      this.downRoutines = 0,
      this.downMoods = 0})
      : live = true;
  const SyncResult.offline()
      : live = false,
        up = 0,
        down = 0,
        downSubs = 0,
        downRoutines = 0,
        downMoods = 0;

  /// One-line human summary for the manual-sync snackbar.
  String describe() {
    if (!live) return 'Offline — kept local';
    final parts = <String>['↑$up'];
    if (down > 0) parts.add('↓$down tasks');
    if (downSubs > 0) parts.add('$downSubs steps');
    if (downRoutines > 0) parts.add('$downRoutines routines');
    if (downMoods > 0) parts.add('$downMoods moods');
    if (parts.length == 1) return 'Synced ↑$up · already up to date';
    return 'Synced ${parts.join(' · ')}';
  }
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
