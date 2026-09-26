import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../core/theme/puduu_theme.dart';
import '../core/models.dart';
import '../main.dart' show HelloHead, SectionHead, TaskCard;

const _pad = EdgeInsets.fromLTRB(20, 18, 20, 110);

// ---------- Routines (Tiimo parity: repeating checklists) ----------
final routineProvider = StateProvider<List<PuduuRoutine>>((_) => [
      const PuduuRoutine(id: 'r1', name: 'Morning reset', stepTitles: ['Meds', 'Water', 'Tidy 5 min'], rrule: 'FREQ=DAILY;BYHOUR=8'),
      const PuduuRoutine(id: 'r2', name: 'Wind down', stepTitles: ['Dim lights', 'No screens', 'Read'], rrule: 'FREQ=DAILY;BYHOUR=22'),
    ]);

class RoutinesPage extends ConsumerWidget {
  const RoutinesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routineProvider);
    return ListView(
      padding: _pad,
      children: [
        const HelloHead(hello: 'Routines', sub: '◉ Repeatable calm'),
        const SizedBox(height: 12),
        const SearchField2(hint: 'Search a routine'),
        const SectionHead(label: 'YOUR ROUTINES', action: '+ New'),
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
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: PuduuColors.tealWash, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.refresh_outlined, size: 19, color: PuduuColors.soft),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.name, style: PuduuType.strong),
                            Text('${r.stepTitles.length} steps · ${_rruleLabel(r.rrule)}', style: PuduuType.meta),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: PuduuColors.mute),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < r.stepTitles.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: PuduuColors.line, width: 1.6)),
                            child: const Icon(Icons.check, size: 13, color: Colors.transparent),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(r.stepTitles[i], style: PuduuType.body)),
                          Text('${(i + 1) * 5} min', style: PuduuType.meta),
                        ],
                      ),
                    ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow, size: 17),
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
        const TaskCard(dot: PuduuColors.teal, title: 'Study sprint', detail: '25 min focus · 5 min break ×4', side: '+ Add', icon: PuduuIcons.focus, tile: PuduuColors.tealWash),
      ],
    );
  }
}

String _rruleLabel(String r) {
  if (r.contains('BYHOUR=8')) return 'daily · 08:00';
  if (r.contains('BYHOUR=22')) return 'daily · 22:00';
  return 'repeats';
}

// ---------- Calendar (Tiimo parity: week view) ----------
class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});
  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: _pad,
      children: [
        const HelloHead(hello: 'Calendar', sub: '◉ Week 39 · synced'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: i == 2 ? PuduuColors.dark : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(_days[i], style: TextStyle(fontFamily: 'Work Sans', fontSize: 10, fontWeight: FontWeight.w700, color: i == 2 ? Colors.white : PuduuColors.mute)),
                          Text('${21 + i}', style: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w700, color: i == 2 ? Colors.white : PuduuColors.ink)),
                          if (i == 2 || i == 4)
                            Container(width: 5, height: 5, margin: const EdgeInsets.only(top: 3), decoration: const BoxDecoration(shape: BoxShape.circle, color: PuduuColors.teal)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SectionHead(label: 'WEDNESDAY', action: 'Sync calendars'),
        const _TimeBlock(time: '09:00', title: 'Deep work: portfolio', detail: '50 min · timer ready', color: PuduuColors.teal),
        const _TimeBlock(time: '11:00', title: 'Walk outside', detail: '15 min · no podcast', color: PuduuColors.moss),
        const _TimeBlock(time: '13:00', title: 'Admin batch', detail: '30 min · bills + inbox', color: PuduuColors.amber),
        const _TimeBlock(time: '15:00', title: 'Dentist call', detail: '10 min · from inbox', color: PuduuColors.tealDeep, dashed: true),
      ],
    );
  }
}

class _TimeBlock extends StatelessWidget {
  final String time, title, detail;
  final Color color;
  final bool dashed;
  const _TimeBlock({required this.time, required this.title, required this.detail, required this.color, this.dashed = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 46, child: Text(time, style: PuduuType.meta)),
          Container(width: 3, height: 58, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

// ---------- Library (Tiimo parity: activity presets) ----------
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});
  static const _groups = [
    (Icons.water_drop_outlined, 'Body', PuduuColors.tealWash, ['Drink water · 2 min', 'Stretch · 5 min', 'Walk outside · 15 min']),
    (Icons.bolt_outlined, 'Reset', PuduuColors.amberWash, ['Clear one surface · 2 min', 'Cold splash · 1 min', 'Box breathing · 3 min']),
    (Icons.timer_outlined, 'Focus', Color(0xFFE8F1F6), ['Study sprint · 25 min', 'Email batch · 15 min', 'Deep work · 50 min']),
    (Icons.nightlight_outlined, 'Evening', PuduuColors.mossWash, ['Dim lights · 2 min', 'Journal · 10 min', 'Lay out clothes · 5 min']),
  ];
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: _pad,
      children: [
        const HelloHead(hello: 'Library', sub: '◉ Ready-made calm'),
        const SizedBox(height: 12),
        const SearchField2(hint: 'Search activities'),
        for (final g in _groups) ...[
          SectionHead(label: g.$2.toUpperCase()),
          for (final a in g.$4)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TaskCard(dot: PuduuColors.teal, title: a.split(' · ')[0], detail: a, side: '+ Add', icon: g.$1, tile: g.$3),
            ),
        ],
      ],
    );
  }
}

// ---------- Mood (Tiimo parity: check-in + patterns) ----------
final moodProvider = StateProvider<List<MoodEntry>>((_) => [
      MoodEntry(day: DateTime.now().subtract(const Duration(days: 1)), score: 4, note: 'Good walk'),
      MoodEntry(day: DateTime.now().subtract(const Duration(days: 2)), score: 3),
      MoodEntry(day: DateTime.now().subtract(const Duration(days: 3)), score: 5, note: 'Shipped a thing'),
    ]);

class MoodPage extends ConsumerStatefulWidget {
  const MoodPage({super.key});
  @override
  ConsumerState<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends ConsumerState<MoodPage> {
  int picked = 4;
  static const _faces = ['Very low', 'Low', 'Okay', 'Good', 'Great'];
  static const _icons = [Icons.sentiment_very_dissatisfied, Icons.sentiment_dissatisfied, Icons.sentiment_neutral, Icons.sentiment_satisfied, Icons.sentiment_very_satisfied];
  @override
  Widget build(BuildContext context) {
    final moods = ref.watch(moodProvider);
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
                Text(_faces[picked - 1], style: PuduuType.title.copyWith(fontSize: 19)),
                const SizedBox(height: 4),
                const Text('Tap how today felt overall', style: PuduuType.meta),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var i = 1; i <= 5; i++)
                      GestureDetector(
                        onTap: () => setState(() => picked = i),
                        child: Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == picked ? PuduuColors.teal : Colors.transparent,
                            border: Border.all(color: i == picked ? PuduuColors.teal : PuduuColors.line, width: 1.4),
                          ),
                          child: Icon(_icons[i - 1], size: 26, color: i == picked ? Colors.white : PuduuColors.mute),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      ref.read(moodProvider.notifier).state = [...moods, MoodEntry(day: DateTime.now(), score: picked)];
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final m in moods.reversed)
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: (m.score * 16).toDouble(),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(color: m.score >= 4 ? PuduuColors.teal : m.score == 3 ? PuduuColors.amber : PuduuColors.danger, borderRadius: BorderRadius.circular(6)),
                        ),
                        const SizedBox(height: 6),
                        Text('${m.day.day}', style: PuduuType.meta),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const TaskCard(dot: PuduuColors.teal, title: 'Mornings win', detail: 'Good days start before 09:00 · 5 of 7', side: 'Insight', icon: Icons.insights_outlined, tile: PuduuColors.tealWash),
      ],
    );
  }
}

// ---------- Paywall Pro (Tiimo parity: monthly/yearly, web = premium) ----------
class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});
  static const _perks = [
    (Icons.auto_awesome_outlined, 'AI Co-Planner', 'Brain-dump to schedule in one tap'),
    (Icons.language_outlined, 'Web planner', 'Plan on desktop, synced everywhere'),
    (Icons.calendar_month_outlined, 'Calendar sync', 'Apple, Google, Outlook import'),
    (Icons.notifications_outlined, 'Unlimited nudges', 'Gentle reminders, zero fatigue'),
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
          decoration: BoxDecoration(color: PuduuColors.dark, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PUDUU PRO', style: TextStyle(fontFamily: 'Outfit', fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1.6, color: Color(0xFF7DD3C7))),
              const SizedBox(height: 5),
              const Text('Unlimited calm', style: TextStyle(fontFamily: 'Outfit', fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, height: 1.15)),
              const SizedBox(height: 2),
              const Text('7 days free, then your pick below', style: TextStyle(fontFamily: 'Work Sans', fontSize: 12, color: Color(0xFFB9CDC9))),
              const SizedBox(height: 14),
              for (final p in _perks)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(p.$1, size: 18, color: const Color(0xFF7DD3C7)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.$2, style: const TextStyle(fontFamily: 'Work Sans', fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.white)),
                            Text(p.$3, style: const TextStyle(fontFamily: 'Work Sans', fontSize: 11.5, color: Color(0xFFB9CDC9))),
                          ],
                        ),
                      ),
                      const Icon(Icons.check, size: 17, color: Color(0xFF7DD3C7)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _PlanTile(tag: 'YEARLY · SAVE 30%', title: '\$49.99 / year', detail: '\$4.17/mo · billed yearly', picked: true),
        const SizedBox(height: 8),
        const _PlanTile(tag: 'MONTHLY', title: '\$6.99 / month', detail: 'Cancel anytime', picked: false),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: () {}, child: const Text('Start 7-day free trial'))),
        const SizedBox(height: 6),
        const Center(child: Text('Restore purchase · Terms · Privacy', style: PuduuType.meta)),
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  final String tag, title, detail;
  final bool picked;
  const _PlanTile({required this.tag, required this.title, required this.detail, required this.picked});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: picked ? BoxDecoration(border: Border.all(color: PuduuColors.teal, width: 1.6), borderRadius: BorderRadius.circular(16)) : null,
        child: Row(
          children: [
            Icon(picked ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: picked ? PuduuColors.teal : PuduuColors.mute, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tag, style: const TextStyle(fontFamily: 'Outfit', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: PuduuColors.tealDeep)),
                  Text(title, style: PuduuType.strong),
                  Text(detail, style: PuduuType.meta),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Onboarding (3 steps) ----------
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int step = 0;
  static const _steps = [
    ('See your day', 'A visual timeline built for busy brains — one block at a time.', Icons.calendar_month_outlined),
    ('Start tiny', 'Two-minute resets thaw frozen days. Done beats perfect.', Icons.bolt_outlined),
    ('Stay gentle', 'Max 6 nudges a day. Quiet 22:00–07:00. You stay in charge.', Icons.notifications_outlined),
  ];
  @override
  Widget build(BuildContext context) {
    final s = _steps[step];
    return ListView(
      padding: _pad,
      children: [
        const SizedBox(height: 24),
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(color: PuduuColors.tealWash, borderRadius: BorderRadius.circular(22)),
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
              Container(width: i == step ? 24 : 8, height: 8, margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(color: i == step ? PuduuColors.teal : PuduuColors.line, borderRadius: BorderRadius.circular(4))),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => setState(() => step = (step + 1).clamp(0, 2)),
            child: Text(step == 2 ? 'Start planning' : 'Next'),
          ),
        ),
        if (step > 0) TextButton(onPressed: () => setState(() => step = 0), child: const Text('Back')),
      ],
    );
  }
}

// ---------- shared search (no controller variant) ----------
class SearchField2 extends StatelessWidget {
  final String hint;
  const SearchField2({super.key, required this.hint});
  @override
  Widget build(BuildContext context) {
    return TextField(decoration: InputDecoration(hintText: hint, prefixIcon: const Icon(PuduuIcons.search, color: PuduuColors.mute)));
  }
}
