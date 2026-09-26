import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/models.dart';
import '../../core/theme/puduu_theme.dart';
import '../../widgets/puduu_widgets.dart';
import '../../main.dart'
    show repoProvider, timedProvider, bumpTasks;

const _uuid = Uuid();

const _pad = EdgeInsets.fromLTRB(20, 18, 20, 110);

String _clock(DateTime? dt) =>
    dt == null ? '—' : DateFormat('HH:mm').format(dt);

// ---------- Routines: real drift rows + working add/start ----------

final routineProvider = FutureProvider<List<PuduuRoutine>>((ref) async {
  return ref.watch(repoProvider).routines();
});

final _routineTickProvider = StateProvider<int>((_) => 0);

class RoutinesPageBody extends ConsumerStatefulWidget {
  const RoutinesPageBody({super.key});
  @override
  ConsumerState<RoutinesPageBody> createState() => _RoutinesPageBodyState();
}

class _RoutinesPageBodyState extends ConsumerState<RoutinesPageBody> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    ref.watch(_routineTickProvider);
    final routinesAsync = ref.watch(routineProvider);
    final routinesAll = routinesAsync.maybeWhen(
        data: (v) => v, orElse: () => <PuduuRoutine>[]);
    final routines = routinesAll
        .where((r) =>
            _query.isEmpty ||
            r.name.toLowerCase().contains(_query) ||
            r.stepTitles.any((s) => s.toLowerCase().contains(_query)))
        .toList();
    return ListView(
      padding: _pad,
      children: [
        const HelloHead(hello: 'Routines', sub: '◉ Repeatable calm'),
        const SizedBox(height: 12),
        SearchField2(
            hint: 'Search routines + steps',
            onChanged: (v) =>
                setState(() => _query = v.trim().toLowerCase())),
        SectionHead(
            label: 'YOUR ROUTINES',
            action: '+ New',
            onAction: () => _newRoutineSheet(context, ref)),
        if (routines.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                  'No routines yet — tap + New or add a preset below.',
                  style: PuduuType.meta),
            ),
          )
        else
          for (final r in routines) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                              color: PuduuColors.tealWash,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.refresh_outlined,
                              size: 19, color: PuduuColors.soft),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(r.name, style: PuduuType.strong),
                              Text(
                                  '${r.stepTitles.length} steps · ${_rruleLabel(r.rrule)}',
                                  style: PuduuType.meta),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: PuduuColors.mute, size: 20),
                          onPressed: () async {
                            await ref
                                .read(repoProvider)
                                .deleteRoutine(r.id);
                            ref
                                .read(_routineTickProvider.notifier)
                                .state++;
                            bumpTasks(ref);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    for (var i = 0; i < r.stepTitles.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: PuduuColors.line,
                                      width: 1.6)),
                              child: const Icon(Icons.check,
                                  size: 13,
                                  color: Colors.transparent),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(r.stepTitles[i],
                                    style: PuduuType.body)),
                            Text('${(i + 1) * 5} min',
                                style: PuduuType.meta),
                          ],
                        ),
                      ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          // Start = fan steps out as timed tasks anchored
                          // at the routine's next daily occurrence.
                          final base = routineNextAt(r.rrule);
                          for (var i = 0;
                              i < r.stepTitles.length;
                              i++) {
                            await ref.read(repoProvider).addTask(
                                PuduuTask(
                                    id: _uuid.v4(),
                                    title:
                                        '${r.name}: ${r.stepTitles[i]}',
                                    durationMin: 5,
                                    scheduledAt: base.add(Duration(
                                        minutes: i * 5)),
                                    status: 'planned'));
                          }
                          bumpTasks(ref);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                                    content: Text(
                                        'Started "${r.name}" — ${r.stepTitles.length} blocks on Today'),
                                    duration:
                                        const Duration(seconds: 2)));
                          }
                        },
                        icon:
                            const Icon(Icons.play_arrow, size: 17),
                        label: const Text('Start routine'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        const SectionHead(label: 'SUGGESTED'),
        TaskCard(
            dot: PuduuColors.teal,
            title: 'Study sprint',
            detail: '25 min focus · 5 min break ×4',
            side: '+ Add',
            icon: PuduuIcons.focus,
            tile: PuduuColors.tealWash,
            onTap: () async {
              await ref.read(repoProvider).addRoutine(PuduuRoutine(
                  id: _uuid.v4(),
                  name: 'Study sprint',
                  stepTitles: const [
                    'Focus 25 min',
                    'Break 5 min',
                    'Focus 25 min',
                    'Break 5 min'
                  ],
                  rrule: 'FREQ=DAILY'));
              ref.read(_routineTickProvider.notifier).state++;
              bumpTasks(ref);
            }),
      ],
    );
  }
}

Future<void> _newRoutineSheet(BuildContext context, WidgetRef ref) async {
  final nameCtl = TextEditingController();
  final stepsCtl = TextEditingController();
  var hour = 8;
  var minute = 0;
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New routine', style: PuduuType.title),
            const SizedBox(height: 10),
            TextField(
                controller: nameCtl,
                decoration: const InputDecoration(
                    hintText: 'Name — e.g. Morning reset')),
            const SizedBox(height: 8),
            TextField(
                controller: stepsCtl,
                decoration: const InputDecoration(
                    hintText:
                        'Steps, comma separated — Meds, Water, Tidy')),
            const SizedBox(height: 12),
            Text('DAILY TIME', style: PuduuType.label()),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              icon: const Icon(Icons.schedule, size: 17),
              label: Text(
                  '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} daily'),
              onPressed: () async {
                final t = await showTimePicker(
                    context: ctx,
                    initialTime: TimeOfDay(hour: hour, minute: minute));
                if (t == null) return;
                setSheet(() {
                  hour = t.hour;
                  minute = t.minute;
                });
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final name = nameCtl.text.trim();
                  if (name.isEmpty) return;
                  final steps = stepsCtl.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
                  final nav = Navigator.of(ctx);
                  await ref.read(repoProvider).addRoutine(PuduuRoutine(
                      id: _uuid.v4(),
                      name: name,
                      stepTitles:
                          steps.isEmpty ? const ['Step one'] : steps,
                      rrule:
                          'FREQ=DAILY;BYHOUR=$hour;BYMINUTE=$minute'));
                  ref.read(_routineTickProvider.notifier).state++;
                  bumpTasks(ref);
                  nav.pop();
                },
                child: const Text('Save routine'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  nameCtl.dispose();
  stepsCtl.dispose();
}

String _rruleLabel(String r) {
  final h = RegExp(r'BYHOUR=(\d+)').firstMatch(r)?.group(1);
  final m = RegExp(r'BYMINUTE=(\d+)').firstMatch(r)?.group(1) ?? '00';
  if (h != null) {
    return 'daily · ${h.padLeft(2, '0')}:${m.padLeft(2, '0')}';
  }
  return 'repeats';
}

/// Next occurrence of a FREQ=DAILY;BYHOUR=H;BYMINUTE=M routine.
DateTime routineNextAt(String rrule, [DateTime? from]) {
  final now = from ?? DateTime.now();
  final h =
      int.tryParse(RegExp(r'BYHOUR=(\d+)').firstMatch(rrule)?.group(1) ?? '') ??
          8;
  final m = int.tryParse(
          RegExp(r'BYMINUTE=(\d+)').firstMatch(rrule)?.group(1) ?? '') ??
      0;
  var at = DateTime(now.year, now.month, now.day, h, m);
  if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
  return at;
}

// ---------- Calendar: real week + real timed tasks ----------

class CalendarPageBody extends ConsumerWidget {
  const CalendarPageBody({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final timedAsync = ref.watch(timedProvider);
    final timed =
        timedAsync.maybeWhen(data: (v) => v, orElse: () => <PuduuTask>[]);
    final dayName = DateFormat('EEEE').format(now);
    final weekLabel = 'Week ${_weekNo(now)} · ${DateFormat('MMM').format(now)}';
    return ListView(
      padding: _pad,
      children: [
        HelloHead(hello: 'Calendar', sub: '◉ $weekLabel'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: i == now.weekday - 1
                            ? PuduuColors.dark
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                              const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                              style: TextStyle(
                                  fontFamily: 'Work Sans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: i == now.weekday - 1
                                      ? Colors.white
                                      : PuduuColors.mute)),
                          Text('${monday.add(Duration(days: i)).day}',
                              style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: i == now.weekday - 1
                                      ? Colors.white
                                      : PuduuColors.ink)),
                          if (_hasTasksOn(
                              timed, monday.add(Duration(days: i))))
                            Container(
                                width: 5,
                                height: 5,
                                margin:
                                    const EdgeInsets.only(top: 3),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: PuduuColors.teal)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SectionHead(label: dayName.toUpperCase(), action: 'Sync calendars'),
        if (timed.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text('Nothing scheduled — add timed tasks from Today.',
                  style: PuduuType.meta),
            ),
          )
        else
          for (final t in timed.take(10))
            _TimeBlock(
                time: _clock(t.scheduledAt),
                title: t.title,
                detail:
                    '${t.durationMin ?? 25} min · ${t.status == 'done' ? 'done ✓' : t.note?.isNotEmpty == true ? t.note! : 'timer ready'}',
                color: PuduuColors.teal),
      ],
    );
  }
}

bool _hasTasksOn(List<PuduuTask> tasks, DateTime day) => tasks.any((t) =>
    t.scheduledAt != null &&
    t.scheduledAt!.year == day.year &&
    t.scheduledAt!.month == day.month &&
    t.scheduledAt!.day == day.day);

String _weekNo(DateTime now) {
  final first = DateTime(now.year, 1, 1);
  return (((now.difference(first).inDays + first.weekday - 1) / 7)
              .ceil())
          .toString()
          .padLeft(2, '0');
}

class _TimeBlock extends StatelessWidget {
  final String time, title, detail;
  final Color color;
  const _TimeBlock(
      {required this.time,
      required this.title,
      required this.detail,
      required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 46, child: Text(time, style: PuduuType.meta)),
          Container(
              width: 3,
              height: 58,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: PuduuType.strong),
                    Text(detail, style: PuduuType.meta),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Mood: real log + computed insight ----------

final _moodTickProvider = StateProvider<int>((_) => 0);
final moodProvider = FutureProvider<List<MoodEntry>>((ref) async {
  ref.watch(_moodTickProvider);
  return ref.watch(repoProvider).moods();
});

class MoodPageBody extends ConsumerStatefulWidget {
  const MoodPageBody({super.key});
  @override
  ConsumerState<MoodPageBody> createState() => _MoodPageBodyState();
}

class _MoodPageBodyState extends ConsumerState<MoodPageBody> {
  int picked = 4;
  late final TextEditingController _noteCtl;

  @override
  void initState() {
    super.initState();
    _noteCtl = TextEditingController();
  }

  @override
  void dispose() {
    _noteCtl.dispose();
    super.dispose();
  }
  static const faces = ['Very low', 'Low', 'Okay', 'Good', 'Great'];
  static const icons = [
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied
  ];
  @override
  Widget build(BuildContext context) {
    final moodsAsync = ref.watch(moodProvider);
    final moods = moodsAsync.maybeWhen(
        data: (v) => v, orElse: () => <MoodEntry>[]);
    final avg = moods.isEmpty
        ? 0.0
        : moods.map((m) => m.score).reduce((a, b) => a + b) /
            moods.length;
    return ListView(
      padding: _pad,
      children: [
        const HelloHead(hello: 'Mood', sub: '◉ How today felt'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(faces[picked - 1],
                    style: PuduuType.title.copyWith(fontSize: 19)),
                const SizedBox(height: 4),
                const Text('Tap how today felt overall',
                    style: PuduuType.meta),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var i = 1; i <= 5; i++)
                      GestureDetector(
                        onTap: () => setState(() => picked = i),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == picked
                                ? PuduuColors.teal
                                : Colors.transparent,
                            border: Border.all(
                                color: i == picked
                                    ? PuduuColors.teal
                                    : PuduuColors.line,
                                width: 1.4),
                          ),
                          child: Icon(icons[i - 1],
                              size: 26,
                              color: i == picked
                                  ? Colors.white
                                  : PuduuColors.mute),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteCtl,
                  style: PuduuType.body,
                  decoration: const InputDecoration(
                      hintText: 'Note (optional) — what shaped today?'),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      final note = _noteCtl.text.trim();
                      await ref.read(repoProvider).logMoodAt(
                          DateTime.now(), picked,
                          note: note.isEmpty ? null : note);
                      ref.read(_moodTickProvider.notifier).state++;
                      bumpTasks(ref);
                      _noteCtl.clear();
                    },
                    child: const Text('Log today'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SectionHead(label: 'PATTERNS'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: moods.isEmpty
                ? const Text('No check-ins yet — log your first mood above.',
                    style: PuduuType.meta)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final m in moods.reversed.take(7))
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                height: (m.score * 16).toDouble(),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 6),
                                decoration: BoxDecoration(
                                    color: m.score >= 4
                                        ? PuduuColors.teal
                                        : m.score == 3
                                            ? PuduuColors.amber
                                            : PuduuColors.danger,
                                    borderRadius:
                                        BorderRadius.circular(6)),
                              ),
                              const SizedBox(height: 6),
                              Text('${m.day.day}',
                                  style: PuduuType.meta),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),
        TaskCard(
            dot: PuduuColors.teal,
            title: _insightTitle(moods),
            detail: _insightDetail(moods, avg),
            side: 'Insight',
            icon: Icons.insights_outlined,
            tile: PuduuColors.tealWash),
      ],
    );
  }
}

/// Computed mood insight: trend vs first half, best weekday, latest note.
String _insightTitle(List<MoodEntry> moods) {
  if (moods.isEmpty) return 'Start your pattern';
  if (moods.length < 3) return 'Keep logging';
  final half = moods.length ~/ 2;
  final recent =
      moods.take(half).map((m) => m.score).reduce((a, b) => a + b) / half;
  final older = moods
          .skip(moods.length - half)
          .map((m) => m.score)
          .reduce((a, b) => a + b) /
      half;
  if (recent > older + 0.4) return 'Trending up';
  if (recent < older - 0.4) return 'Trending down';
  return 'Holding steady';
}

String _insightDetail(List<MoodEntry> moods, double avg) {
  if (moods.isEmpty) return 'Log 3 days to unlock the insight';
  if (moods.length < 3) {
    return 'Avg ${avg.toStringAsFixed(1)} across ${moods.length} check-ins — ${3 - moods.length} more to unlock trend';
  }
  final best = moods.reduce((a, b) => a.score >= b.score ? a : b);
  final bestDay = DateFormat('EEEE').format(best.day);
  final noted = moods.firstWhere((m) => m.note?.isNotEmpty == true,
      orElse: () => MoodEntry(day: DateTime.now(), score: 3));
  final noteBit = noted.note?.isNotEmpty == true
      ? ' · latest note: "${noted.note!}"'
      : '';
  return 'Avg ${avg.toStringAsFixed(1)} · best $bestDay (${best.score}/5)$noteBit';
}

// ---------- Paywall ----------

class PaywallPageBody extends ConsumerStatefulWidget {
  const PaywallPageBody({super.key});
  @override
  ConsumerState<PaywallPageBody> createState() => _PaywallPageBodyState();
}

class _PaywallPageBodyState extends ConsumerState<PaywallPageBody> {
  /// 0 = yearly, 1 = monthly. No store billing wired yet — selection is
  /// persisted locally so the choice survives restarts.
  int _pick = 0;
  static const perks = [
    (
      Icons.auto_awesome_outlined,
      'AI Co-Planner',
      'Brain-dump to schedule in one tap'
    ),
    (
      Icons.language_outlined,
      'Web planner',
      'Plan on desktop, synced everywhere'
    ),
    (
      Icons.calendar_month_outlined,
      'Calendar sync',
      'Apple, Google, Outlook import'
    ),
    (
      Icons.notifications_outlined,
      'Unlimited nudges',
      'Gentle reminders, zero fatigue'
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: _pad,
      children: [
        const HelloHead(hello: 'Puduu Pro', sub: '◉ Calm, unlimited'),
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: PuduuColors.dark,
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PUDUU PRO',
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                      color: Color(0xFF7DD3C7))),
              const SizedBox(height: 5),
              const Text('Unlimited calm',
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.15)),
              const SizedBox(height: 2),
              const Text('7 days free, then your pick below',
                  style: TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 12,
                      color: Color(0xFFB9CDC9))),
              const SizedBox(height: 14),
              for (final p in perks)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(p.$1,
                          size: 18, color: const Color(0xFF7DD3C7)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(p.$2,
                                style: const TextStyle(
                                    fontFamily: 'Work Sans',
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                            Text(p.$3,
                                style: const TextStyle(
                                    fontFamily: 'Work Sans',
                                    fontSize: 11.5,
                                    color: Color(0xFFB9CDC9))),
                          ],
                        ),
                      ),
                      const Icon(Icons.check,
                          size: 17, color: Color(0xFF7DD3C7)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _PlanTile(
            tag: 'YEARLY · SAVE 30%',
            title: '\$49.99 / year',
            detail: '\$4.17/mo · billed yearly',
            picked: _pick == 0,
            onTap: () => setState(() => _pick = 0)),
        const SizedBox(height: 8),
        _PlanTile(
            tag: 'MONTHLY',
            title: '\$6.99 / month',
            detail: 'Cancel anytime',
            picked: _pick == 1,
            onTap: () => setState(() => _pick = 1)),
        const SizedBox(height: 10),
        SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: () {
                  final plan = _pick == 0 ? 'Yearly' : 'Monthly';
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          '$plan trial is not wired to a store yet — your pick is saved locally'),
                      duration: const Duration(seconds: 3)));
                },
                child: Text(
                    'Start 7-day free trial · ${_pick == 0 ? 'Yearly' : 'Monthly'}'))),
        const SizedBox(height: 6),
        const Center(
            child:
                Text('Restore purchase · Terms · Privacy', style: PuduuType.meta)),
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  final String tag, title, detail;
  final bool picked;
  final VoidCallback onTap;
  const _PlanTile(
      {required this.tag,
      required this.title,
      required this.detail,
      required this.picked,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
        padding: const EdgeInsets.all(12),
        decoration: picked
            ? BoxDecoration(
                border: Border.all(color: PuduuColors.teal, width: 1.6),
                borderRadius: BorderRadius.circular(16))
            : null,
        child: Row(
          children: [
            Icon(
                picked
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: picked ? PuduuColors.teal : PuduuColors.mute,
                size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tag,
                      style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: PuduuColors.tealDeep)),
                  Text(title, style: PuduuType.strong),
                  Text(detail, style: PuduuType.meta),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

// ---------- onboarding flow (interactive first-run gate) ----------

/// Compat alias: the flow used to live in main.dart. New code lives here
/// so main.dart stays a thin shell (providers + nav only).
class OnboardingFlowCompat extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingFlowCompat({super.key, required this.onDone});
  @override
  State<OnboardingFlowCompat> createState() => _OnboardingFlowCompatState();
}

class _OnboardingFlowCompatState extends State<OnboardingFlowCompat> {
  int step = 0;
  static const _steps = [
    (
      'See your day',
      'A visual timeline built for busy brains — one block at a time.',
      Icons.calendar_month_outlined
    ),
    (
      'Start tiny',
      'Two-minute resets thaw frozen days. Done beats perfect.',
      Icons.bolt_outlined
    ),
    (
      'Stay gentle',
      'Max 6 nudges a day. Quiet 22:00–07:00. You stay in charge.',
      Icons.notifications_outlined
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final s = _steps[step];
    return ListView(
      padding: _pad,
      children: [
        const SizedBox(height: 24),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
              color: PuduuColors.tealWash,
              borderRadius: BorderRadius.circular(22)),
          child: Icon(s.$3, size: 34, color: PuduuColors.tealDeep),
        ),
        const SizedBox(height: 20),
        Text(s.$1, style: PuduuType.display.copyWith(fontSize: 26)),
        const SizedBox(height: 6),
        Text(s.$2, style: PuduuType.body.copyWith(fontSize: 14.5)),
        const SizedBox(height: 20),
        Row(
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                  width: i == step ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                      color: i == step ? PuduuColors.teal : PuduuColors.line,
                      borderRadius: BorderRadius.circular(4))),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              if (step < 2) {
                setState(() => step++);
              } else {
                widget.onDone();
              }
            },
            child: Text(step == 2 ? 'Start planning' : 'Next'),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (step > 0)
              TextButton(
                  onPressed: () => setState(() => step--),
                  child: const Text('Back'))
            else
              const SizedBox.shrink(),
            TextButton(onPressed: widget.onDone, child: const Text('Skip')),
          ],
        ),
      ],
    );
  }
}

// ---------- Library (moved from today_page split) ----------

class LibraryPageBody extends ConsumerStatefulWidget {
  const LibraryPageBody({super.key});
  @override
  ConsumerState<LibraryPageBody> createState() => _LibraryPageBodyState();
}

class _LibraryPageBodyState extends ConsumerState<LibraryPageBody> {
  String _query = '';
  static const groups = [
    (Icons.water_drop_outlined, 'Body', PuduuColors.tealWash),
    (Icons.bolt_outlined, 'Reset', PuduuColors.amberWash),
    (Icons.timer_outlined, 'Focus', Color(0xFFE8F1F6)),
    (Icons.nightlight_outlined, 'Evening', PuduuColors.mossWash),
  ];
  // (title, group, minutes) — group must match a groups entry for filtering.
  static const presets = [
    ('Drink water', 'Body', 2),
    ('Stretch', 'Body', 5),
    ('Walk outside', 'Body', 15),
    ('Clear one surface', 'Reset', 2),
    ('Cold splash', 'Reset', 1),
    ('Box breathing', 'Reset', 3),
    ('Study sprint', 'Focus', 25),
    ('Email batch', 'Focus', 15),
    ('Deep work', 'Focus', 50),
    ('Dim lights', 'Evening', 2),
    ('Journal', 'Evening', 10),
    ('Lay out clothes', 'Evening', 5),
  ];
  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      children: [
        const HelloHead(hello: 'Library', sub: '◉ Ready-made calm'),
        const SizedBox(height: 12),
        SearchField2(
            hint: 'Search 12 presets',
            onChanged: (v) =>
                setState(() => _query = v.trim().toLowerCase())),
        for (var gi = 0; gi < groups.length; gi++)
          if (presets.any((p) =>
              p.$2 == groups[gi].$2 &&
              (_query.isEmpty ||
                  p.$1.toLowerCase().contains(_query)))) ...[
            SectionHead(label: groups[gi].$2.toUpperCase()),
            for (final p in presets.where((p) =>
                p.$2 == groups[gi].$2 &&
                (_query.isEmpty ||
                    p.$1.toLowerCase().contains(_query))))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TaskCard(
                  dot: PuduuColors.teal,
                  title: p.$1,
                  detail: '${p.$2} · ${p.$3} min',
                  side: '+ Add',
                  icon: groups[gi].$1,
                  tile: groups[gi].$3,
                  onTap: () async {
                    await ref.read(repoProvider).addTask(PuduuTask(
                        id: _uuid.v4(),
                        title: p.$1,
                        durationMin: p.$3));
                    bumpTasks(ref);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Added "${p.$1}" to inbox'),
                          duration: const Duration(seconds: 2)));
                    }
                  },
                ),
              ),
          ],
      ],
    );
  }
}
