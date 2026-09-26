import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models.dart';
import '../../core/theme/puduu_theme.dart';
import '../../widgets/puduu_widgets.dart';
import '../../main.dart'
    show repoProvider, todayProvider, timedProvider, bumpTasks;
import 'sub_pages.dart'
    show
        RoutinesPageBody,
        CalendarPageBody,
        LibraryPageBody,
        MoodPageBody,
        PaywallPageBody;

// ---------- Focus: live countdown against the first timed task ----------

class FocusPage extends ConsumerStatefulWidget {
  const FocusPage({super.key});
  @override
  ConsumerState<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends ConsumerState<FocusPage> {
  Timer? _ticker;
  Duration _left = const Duration(minutes: 25);
  bool _running = false;
  bool _seeded = false;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _seedFromTask(PuduuTask t) {
    if (_seeded) return;
    _seeded = true;
    _left = Duration(minutes: t.durationMin ?? 25);
  }

  void _toggle() {
    if (_running) {
      _ticker?.cancel();
      setState(() => _running = false);
      return;
    }
    setState(() => _running = true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_left.inSeconds <= 1) {
        _ticker?.cancel();
        setState(() {
          _left = Duration.zero;
          _running = false;
        });
        return;
      }
      setState(() => _left = _left - const Duration(seconds: 1));
    });
  }

  Future<void> _endEarly(String? taskId) async {
    _ticker?.cancel();
    setState(() {
      _running = false;
    });
    if (taskId != null) {
      await ref.read(repoProvider).setTaskStatus(taskId, 'done');
      _seeded = false;
      bumpTasks(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timedAsync = ref.watch(timedProvider);
    final timed =
        timedAsync.maybeWhen(data: (v) => v, orElse: () => <PuduuTask>[]);
    final timedTodo = timed.where((t) => t.status != 'done').toList();
    final current = timedTodo.isEmpty ? null : timedTodo.first;
    if (current != null) _seedFromTask(current);
    final totalMin = current?.durationMin ?? 25;
    final totalSec = (totalMin * 60).clamp(1, 1 << 30);
    final progress =
        (1 - _left.inSeconds / totalSec).clamp(0.0, 1.0).toDouble();
    final clock =
        '${_left.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(_left.inSeconds.remainder(60)).toString().padLeft(2, '0')}';
    final steps = current?.subtasks ?? const <PuduuSubtask>[];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      children: [
        HelloHead(
            hello: 'Stay with it',
            sub: current == null
                ? '◷ No timed task — plan one first'
                : '◷ Focus session · ${current.title}'),
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          decoration: BoxDecoration(
            color: PuduuColors.dark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(clock,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 58,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.0)),
              const SizedBox(height: 6),
              const Text('MINUTES LEFT · GENTLE CHIME AT END',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Color(0xFF7DD3C7))),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: const Color(0x29FFFFFF),
                  valueColor:
                      const AlwaysStoppedAnimation(Color(0xFF2DD4BF)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                current?.note?.isNotEmpty == true
                    ? current!.note!
                    : (current == null
                        ? 'Add a timed task on Today, then come back.'
                        : 'Phone in another room. One block at a time.'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Work Sans',
                    fontSize: 12,
                    color: Color(0xFFB9CDC9))),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: current == null ? null : _toggle,
                      icon: Icon(
                          _running ? PuduuIcons.pause : PuduuIcons.play,
                          size: 18),
                      label: Text(_running ? 'Pause' : 'Start'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white.withAlpha(28),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: current == null
                          ? null
                          : () => _endEarly(current.id),
                      child: const Text('End early'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SectionHead(label: 'SESSION STEPS'),
        if (steps.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                  'No subtasks on this block — split it from Today for step-by-step calm.',
                  style: PuduuType.meta),
            ),
          )
        else
          for (final s in steps) ...[
            TaskCard(
              dot: s.done ? PuduuColors.moss : PuduuColors.line,
              title: s.title,
              detail: s.done
                  ? 'Done${s.timerMin != null ? ' · ${s.timerMin} min' : ''}'
                  : 'Next${s.timerMin != null ? ' · ${s.timerMin} min' : ''}',
              side: s.done ? '✓' : '${s.timerMin ?? 5} min',
              sideDone: s.done,
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

// ---------- Rescue: presets write real inbox tasks ----------

class RescuePage extends ConsumerWidget {
  const RescuePage({super.key});
  static const rows = [
    (PuduuIcons.drop, PuduuColors.tealWash, 'Drink a glass of water',
        'Stand up, sip slowly, look far away.', 2),
    (PuduuIcons.reset, PuduuColors.amberWash, 'Clear one surface',
        'Just the desk corner. Nothing more.', 2),
    (PuduuIcons.mail, PuduuColors.mossWash, 'Open the difficult email',
        'Read it only. Reply comes later.', 2),
    (PuduuIcons.sort, Color(0xFFE8F1F6), 'Sort the inbox',
        'Rule-based now, assisted later.', 3),
  ];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      children: [
        const HelloHead(
            hello: 'Hit a wall?', sub: '✦ Two minutes counts'),
        const SizedBox(height: 12),
        const SearchField2(hint: 'Search a reset'),
        const SectionHead(label: 'PICK THE SMALLEST ONE'),
        for (final r in rows) ...[
          TaskCard(
              dot: PuduuColors.teal,
              title: r.$3,
              detail: '${r.$4} · ${r.$5} min',
              side: 'Start · ${r.$5}m',
              icon: r.$1,
              tile: r.$2,
              onTap: () async {
                await ref.read(repoProvider).addTask(PuduuTask(
                    id: DateTime.now()
                        .microsecondsSinceEpoch
                        .toString(),
                    title: r.$3,
                    note: r.$4,
                    durationMin: r.$5));
                bumpTasks(ref);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Added "${r.$3}" to inbox'),
                      duration: const Duration(seconds: 2)));
                }
              }),
          const SizedBox(height: 8),
        ],
        const Card(
          color: PuduuColors.tealWash,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Slow is still moving.',
                    style: PuduuType.strong),
                SizedBox(height: 2),
                Text('Skipping is allowed — Puduu waits.',
                    style: PuduuType.meta),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------- Progress: real counts from drift ----------

final _statsProvider =
    FutureProvider<({int doneTotal, int doneToday, int streak})>(
        (ref) async {
  ref.watch(todayProvider);
  final repo = ref.watch(repoProvider);
  return (
    doneTotal: await repo.doneCount(),
    doneToday: await repo.doneCount(todayOnly: true),
    streak: await repo.doneStreakDays(),
  );
});

final _weekMoodProvider = FutureProvider<List<MoodEntry>>((ref) async {
  ref.watch(todayProvider);
  return ref.watch(repoProvider).moods();
});

class GrowsPage extends ConsumerWidget {
  const GrowsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(_statsProvider);
    final stats =
        statsAsync.maybeWhen(data: (v) => v, orElse: () => null);
    final moodsAsync = ref.watch(_weekMoodProvider);
    final moods =
        moodsAsync.maybeWhen(data: (v) => v, orElse: () => <MoodEntry>[]);
    final doneToday = stats?.doneToday ?? 0;
    final doneTotal = stats?.doneTotal ?? 0;
    final streak = stats?.streak ?? 0;
    final avgMood = moods.isEmpty
        ? 0.0
        : moods.map((m) => m.score).reduce((a, b) => a + b) /
            moods.length;
    final chips = [
      ('$doneToday', 'done today'),
      ('×$streak', 'day streak'),
      (avgMood == 0.0 ? '—' : avgMood.toStringAsFixed(1), 'avg mood'),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      children: [
        HelloHead(
            hello: 'Keep growing',
            sub: '▥ $doneTotal done · streak $streak'),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final c in chips)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          Text(c.$1,
                              style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: PuduuColors.ink)),
                          Text(c.$2, style: PuduuType.meta),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SectionHead(label: 'TROPHIES'),
        Row(
          children: [
            for (final t in [
              ('×$streak', 'Streak', Icons.wb_sunny_outlined,
                  PuduuColors.amberWash),
              ('×$doneToday', 'Today', Icons.bolt_outlined,
                  PuduuColors.tealWash),
              ('×$doneTotal', 'All time', Icons.timer_outlined,
                  PuduuColors.mossWash)
            ])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                                color: t.$4, shape: BoxShape.circle),
                            child: Icon(t.$3,
                                size: 19, color: PuduuColors.soft),
                          ),
                          const SizedBox(height: 4),
                          Text(t.$1,
                              style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: PuduuColors.ink)),
                          Text(t.$2, style: PuduuType.meta),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SectionHead(label: 'THIS WEEK'),
        TaskCard(
            dot: PuduuColors.teal,
            title: 'Done this week',
            detail:
                '$doneTotal finished all time · $doneToday today · streak $streak',
            side: 'W${_weekNo()}',
            icon: PuduuIcons.grows,
            tile: PuduuColors.tealWash),
        const SizedBox(height: 8),
        TaskCard(
            dot: PuduuColors.teal,
            title: 'Mood trend',
            detail: moods.isEmpty
                ? 'Log your first mood to see the pattern'
                : 'Avg ${avgMood.toStringAsFixed(1)} across ${moods.length} check-ins',
            side: moods.isEmpty
                ? '—'
                : '+${moods.first.score}',
            icon: PuduuIcons.focus,
            tile: PuduuColors.amberWash),
        const SizedBox(height: 8),
        const Card(
          color: PuduuColors.dark,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Done is a direction.',
                    style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                SizedBox(height: 2),
                Text('Not a streak. Never resets to zero.',
                    style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 11.5,
                        color: Color(0xFFB9CDC9))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _weekNo() {
  final now = DateTime.now();
  final first = DateTime(now.year, 1, 1);
  return (((now.difference(first).inDays + first.weekday - 1) / 7)
              .ceil())
          .toString()
          .padLeft(2, '0');
}

// ---------- Yours: settings hub ----------

class YoursPage extends StatelessWidget {
  const YoursPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      children: [
        const HelloHead(
            hello: 'Make it yours',
            sub: '⚙ Plan, sounds, reminders'),
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PuduuColors.teal,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PUDUU PRO · \$6.99/MO',
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                      color: Color(0xFFDDF3F0))),
              const SizedBox(height: 5),
              const Text('Unlimited resets',
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(height: 2),
              Text(
                  'Yearly \$49.99 · calm history · backup · synced ${DateFormat('d MMM').format(DateTime.now())}',
                  style: const TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 12,
                      color: Color(0xFFDDF3F0))),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: PuduuColors.tealDeep,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const SubShell(
                            title: 'Puduu Pro',
                            child: PaywallPageBody())));
                  },
                  child: const Text('Upgrade'),
                ),
              ),
            ],
          ),
        ),
        const SectionHead(label: 'MORE'),
        const NavRow(
            icon: Icons.refresh_outlined,
            title: 'Routines',
            detail: 'Repeatable calm',
            page: RoutinesPageBody()),
        const SizedBox(height: 8),
        const NavRow(
            icon: Icons.calendar_month_outlined,
            title: 'Calendar',
            detail: 'Week view · sync',
            page: CalendarPageBody()),
        const SizedBox(height: 8),
        const NavRow(
            icon: Icons.auto_awesome_outlined,
            title: 'Library',
            detail: 'Ready-made activities',
            page: LibraryPageBody()),
        const SizedBox(height: 8),
        const NavRow(
            icon: Icons.sentiment_satisfied_outlined,
            title: 'Mood',
            detail: 'Check-ins + patterns',
            page: MoodPageBody()),
        const SizedBox(height: 8),
        const SectionHead(label: 'SETTINGS'),
        const TaskCard(
            dot: PuduuColors.teal,
            title: 'Gentle nudges',
            detail: 'Max 6 per day · quiet 22:00–07:00',
            side: 'On',
            icon: PuduuIcons.bell,
            tile: PuduuColors.amberWash),
        const SizedBox(height: 8),
        const TaskCard(
            dot: PuduuColors.teal,
            title: 'Sounds and haptics',
            detail: 'Calm chime · soft vibration',
            side: 'On',
            icon: PuduuIcons.sound,
            tile: PuduuColors.tealWash),
        const SizedBox(height: 8),
        const TaskCard(
            dot: PuduuColors.teal,
            title: 'Backup and export',
            detail: 'Weekly backup · CSV export',
            side: '›',
            icon: PuduuIcons.shield,
            tile: Color(0xFFE8F1F6)),
      ],
    );
  }
}
