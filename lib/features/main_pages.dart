import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                : '◷ Focus session · ${current.title}',
            accent: PuduuColors.sun),
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: PopCard(
            color: PuduuColors.grape,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: Column(
              children: [
                const Sticker(
                    text: 'FOCUS MODE',
                    color: PuduuColors.sun,
                    rotate: -0.07),
                const SizedBox(height: 16),
                Text(clock,
                    textAlign: TextAlign.center,
                    style: PuduuType.display.copyWith(
                        fontSize: 72,
                        color: Colors.white,
                        height: 1.0)),
                const SizedBox(height: 10),
                const Sticker(
                    text: 'MINUTES LEFT · GENTLE CHIME AT END',
                    color: PuduuColors.sun,
                    rotate: 0.04),
                const SizedBox(height: 18),
                PopBar(
                    value: progress,
                    fill: PuduuColors.sun,
                    height: 20),
                const SizedBox(height: 12),
                Text(
                  current?.note?.isNotEmpty == true
                      ? current!.note!
                      : (current == null
                          ? 'Add a timed task on Today, then come back.'
                          : 'Phone in another room. One block at a time.'),
                  textAlign: TextAlign.center,
                  style: PuduuType.body
                      .copyWith(color: Colors.white)),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: PopButton(
                        icon: _running
                            ? PuduuIcons.pause
                            : PuduuIcons.play,
                        label: _running ? 'Pause' : 'Start',
                        color: PuduuColors.paper,
                        textColor: PuduuColors.ink,
                        onPressed:
                            current == null ? null : _toggle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PopButton(
                        label: 'End early',
                        color: PuduuColors.ink,
                        textColor: Colors.white,
                        onPressed: current == null
                            ? null
                            : () => _endEarly(current.id),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SectionHead(
            label: 'SESSION STEPS', accent: PuduuColors.sun),
        if (steps.isEmpty)
          const PopCard(
            padding: EdgeInsets.all(14),
            child: Text(
                'No subtasks on this block — split it from Today for step-by-step calm.',
                style: PuduuType.meta),
          )
        else
          for (final s in steps) ...[
            TaskCard(
              dot: s.done ? PuduuColors.mint : PuduuColors.clay,
              title: s.title,
              detail: s.done
                  ? 'Done${s.timerMin != null ? ' · ${s.timerMin} min' : ''} · tap to uncheck'
                  : 'Next${s.timerMin != null ? ' · ${s.timerMin} min' : ''} · tap to check',
              side: s.done ? '✓' : '${s.timerMin ?? 5} min',
              sideDone: s.done,
              onTap: () async {
                await ref
                    .read(repoProvider)
                    .toggleSubtask(s.id, !s.done);
                bumpTasks(ref);
              },
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

// ---------- Rescue: presets write real inbox tasks ----------

class RescuePage extends ConsumerStatefulWidget {
  const RescuePage({super.key});
  @override
  ConsumerState<RescuePage> createState() => _RescuePageState();
}

class _RescuePageState extends ConsumerState<RescuePage> {
  String _query = '';
  static const rows = [
    (PuduuIcons.drop, PuduuColors.sky, 'Drink a glass of water',
        'Stand up, sip slowly, look far away.', 2),
    (PuduuIcons.reset, PuduuColors.grape, 'Clear one surface',
        'Just the desk corner. Nothing more.', 2),
    (PuduuIcons.mail, PuduuColors.sun, 'Open the difficult email',
        'Read it only. Reply comes later.', 2),
    (PuduuIcons.sort, PuduuColors.coral, 'Sort the inbox',
        'Rule-based now, assisted later.', 3),
  ];
  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      children: [
        const HelloHead(
            hello: 'Hit a wall?',
            sub: '✦ Two minutes counts',
            accent: PuduuColors.grape),
        const SizedBox(height: 12),
        SearchField2(
            hint: 'Search resets',
            onChanged: (v) =>
                setState(() => _query = v.trim().toLowerCase())),
        const SectionHead(
            label: 'PICK THE SMALLEST ONE',
            accent: PuduuColors.grape),
        for (final r in rows.where((r) =>
            _query.isEmpty ||
            r.$3.toLowerCase().contains(_query) ||
            r.$4.toLowerCase().contains(_query))) ...[
          TaskCard(
              dot: PuduuColors.grape,
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
          const SizedBox(height: 10),
        ],
        const PopCard(
          color: PuduuColors.butter,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Sticker(
                  text: 'YOU GOT THIS',
                  color: PuduuColors.sun,
                  rotate: -0.06),
              SizedBox(height: 10),
              Text('Slow is still moving.',
                  style: PuduuType.strong),
              SizedBox(height: 2),
              Text('Skipping is allowed — Puduu waits.',
                  style: PuduuType.meta),
            ],
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
      ('$doneToday', 'done today', PuduuColors.sun),
      ('×$streak', 'day streak', PuduuColors.coral),
      (
        avgMood == 0.0 ? '—' : avgMood.toStringAsFixed(1),
        'avg mood',
        PuduuColors.grape
      ),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      children: [
        HelloHead(
            hello: 'Keep growing',
            sub: '▥ $doneTotal done · streak $streak',
            accent: PuduuColors.mint),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final c in chips)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: PopCard(
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      children: [
                        Text(c.$1,
                            style: PuduuType.display
                                .copyWith(fontSize: 26)),
                        const SizedBox(height: 8),
                        Sticker(
                            text: c.$2.toUpperCase(),
                            color: c.$3,
                            rotate: 0,
                            textColor: c.$3 == PuduuColors.sun
                                ? PuduuColors.ink
                                : Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SectionHead(
            label: 'TROPHIES', accent: PuduuColors.mint),
        Row(
          children: [
            for (final t in [
              ('×$streak', 'Streak', Icons.wb_sunny_rounded,
                  PuduuColors.sun),
              ('×$doneToday', 'Today', Icons.bolt_rounded,
                  PuduuColors.grape),
              ('×$doneTotal', 'All time', Icons.timer_rounded,
                  PuduuColors.mint)
            ])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: PopCard(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        PopTile(
                            icon: t.$3, color: t.$4, size: 42),
                        const SizedBox(height: 6),
                        Text(t.$1,
                            style: PuduuType.display
                                .copyWith(fontSize: 18)),
                        Text(t.$2, style: PuduuType.meta),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SectionHead(
            label: 'THIS WEEK', accent: PuduuColors.mint),
        TaskCard(
            dot: PuduuColors.mint,
            title: 'Done this week',
            detail:
                '$doneTotal finished all time · $doneToday today · streak $streak',
            side: 'W${_weekNo()}',
            icon: PuduuIcons.grows,
            tile: PuduuColors.mint),
        const SizedBox(height: 10),
        TaskCard(
            dot: PuduuColors.mint,
            title: 'Mood trend',
            detail: moods.isEmpty
                ? 'Log your first mood to see the pattern'
                : 'Avg ${avgMood.toStringAsFixed(1)} across ${moods.length} check-ins',
            side: moods.isEmpty
                ? '—'
                : '+${moods.first.score}',
            icon: PuduuIcons.focus,
            tile: PuduuColors.sun),
        const SizedBox(height: 10),
        PopCard(
          color: PuduuColors.ink,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Sticker(
                  text: 'MANTRA',
                  color: PuduuColors.mint,
                  rotate: -0.05),
              const SizedBox(height: 10),
              Text('Done is a direction.',
                  style: PuduuType.title.copyWith(
                      color: Colors.white, fontSize: 19)),
              const SizedBox(height: 2),
              Text('Not a streak. Never resets to zero.',
                  style: PuduuType.body
                      .copyWith(color: Colors.white)),
            ],
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

// ---------- Yours: settings hub (toggles persist via SharedPreferences) ----------

/// Persisted toggles backing the SETTINGS section.
class SettingsState {
  static const _kNudges = 'puduu_set_nudges';
  static const _kSounds = 'puduu_set_sounds';
  static const _kQuiet = 'puduu_set_quiet';

  static final nudgesProvider = StateProvider<bool>((_) => true);
  static final soundsProvider = StateProvider<bool>((_) => true);
  static final quietProvider = StateProvider<bool>((_) => true);

  static Future<void> load(Ref ref) async {
    final prefs = await SharedPreferences.getInstance();
    ref.read(nudgesProvider.notifier).state =
        prefs.getBool(_kNudges) ?? true;
    ref.read(soundsProvider.notifier).state =
        prefs.getBool(_kSounds) ?? true;
    ref.read(quietProvider.notifier).state = prefs.getBool(_kQuiet) ?? true;
  }

  static Future<void> saveBool(String key, bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, v);
  }
}

class YoursPage extends ConsumerWidget {
  const YoursPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      children: [
        const HelloHead(
            hello: 'Make it yours',
            sub: '⚙ Plan, sounds, reminders',
            accent: PuduuColors.sky),
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: PopCard(
            color: PuduuColors.ink,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Sticker(
                    text: 'PUDUU PRO · \$6.99/MO',
                    color: PuduuColors.sun,
                    rotate: -0.05),
                const SizedBox(height: 12),
                Text('Unlimited resets',
                    style: PuduuType.display.copyWith(
                        fontSize: 26, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                    'Yearly \$49.99 · calm history · backup · synced ${DateFormat('d MMM').format(DateTime.now())}',
                    style: PuduuType.body
                        .copyWith(color: Colors.white)),
                const SizedBox(height: 16),
                PopButton(
                  expanded: true,
                  label: 'Upgrade',
                  icon: PuduuIcons.crown,
                  color: PuduuColors.paper,
                  textColor: PuduuColors.ink,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const SubShell(
                            title: 'Puduu Pro',
                            child: PaywallPageBody())));
                  },
                ),
              ],
            ),
          ),
        ),
        const SectionHead(label: 'MORE', accent: PuduuColors.sky),
        const NavRow(
            icon: Icons.refresh_rounded,
            iconColor: PuduuColors.grape,
            title: 'Routines',
            detail: 'Repeatable calm',
            page: RoutinesPageBody()),
        const SizedBox(height: 10),
        const NavRow(
            icon: Icons.calendar_month_rounded,
            iconColor: PuduuColors.sky,
            title: 'Calendar',
            detail: 'Week view · sync',
            page: CalendarPageBody()),
        const SizedBox(height: 10),
        const NavRow(
            icon: Icons.auto_awesome_rounded,
            iconColor: PuduuColors.sun,
            title: 'Library',
            detail: 'Ready-made activities',
            page: LibraryPageBody()),
        const SizedBox(height: 10),
        const NavRow(
            icon: Icons.sentiment_satisfied_rounded,
            iconColor: PuduuColors.coral,
            title: 'Mood',
            detail: 'Check-ins + patterns',
            page: MoodPageBody()),
        const SizedBox(height: 10),
        const SectionHead(label: 'SETTINGS', accent: PuduuColors.sky),
        _SettingTile(
          icon: PuduuIcons.bell,
          tile: PuduuColors.butter,
          title: 'Gentle nudges',
          detail: 'Max 6 per day · quiet 22:00–07:00',
          value: ref.watch(SettingsState.nudgesProvider),
          onFlip: (v) async {
            ref.read(SettingsState.nudgesProvider.notifier).state = v;
            await SettingsState.saveBool(SettingsState._kNudges, v);
          },
        ),
        const SizedBox(height: 10),
        _SettingTile(
          icon: PuduuIcons.sound,
          tile: PuduuColors.frost,
          title: 'Sounds and haptics',
          detail: 'Calm chime · soft vibration',
          value: ref.watch(SettingsState.soundsProvider),
          onFlip: (v) async {
            ref.read(SettingsState.soundsProvider.notifier).state = v;
            await SettingsState.saveBool(SettingsState._kSounds, v);
          },
        ),
        const SizedBox(height: 10),
        _SettingTile(
          icon: PuduuIcons.shield,
          tile: PuduuColors.lilac,
          title: 'Quiet hours',
          detail: 'Mute 22:00–07:00 · calm only',
          value: ref.watch(SettingsState.quietProvider),
          onFlip: (v) async {
            ref.read(SettingsState.quietProvider.notifier).state = v;
            await SettingsState.saveBool(SettingsState._kQuiet, v);
          },
        ),
      ],
    );
  }
}

/// Settings row with a real working Switch.
class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color tile;
  final String title, detail;
  final bool value;
  final ValueChanged<bool> onFlip;
  const _SettingTile(
      {required this.icon,
      required this.tile,
      required this.title,
      required this.detail,
      required this.value,
      required this.onFlip});
  @override
  Widget build(BuildContext context) {
    return PopCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          PopTile(icon: icon, color: tile, size: 44),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: PuduuType.strong),
                const SizedBox(height: 2),
                Text(detail, style: PuduuType.meta),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: PuduuColors.mint,
            onChanged: onFlip,
          ),
        ],
      ),
    );
  }
}
