import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import 'core/theme/puduu_theme.dart';
import 'core/models.dart';
import 'core/ai_slot/ai_planner.dart';

const _uuid = Uuid();

final inboxProvider = StateProvider<List<PuduuTask>>((_) => [
      PuduuTask(id: _uuid.v4(), title: 'Call dentist', durationMin: 10),
      PuduuTask(id: _uuid.v4(), title: 'Pay electricity bill', durationMin: 15),
      PuduuTask(id: _uuid.v4(), title: 'Deep work: portfolio hero', durationMin: 50, colorIndex: 1),
    ]);
final todayProvider = StateProvider<List<PuduuTask>>((_) => []);
final aiProvider = Provider<AiPlannerProvider>((_) => RuleBasedProvider());

void main() => runApp(const ProviderScope(child: PuduuApp()));

class PuduuApp extends StatelessWidget {
  const PuduuApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puduu',
      theme: puduuTheme(),
      home: const Shell(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Shell extends ConsumerStatefulWidget {
  const Shell({super.key});
  @override
  ConsumerState<Shell> createState() => _ShellState();
}

class _ShellState extends ConsumerState<Shell> {
  int tab = 0;
  static const titles = ['Today', 'Focus', 'Stuck', 'Grows', 'Yours'];
  @override
  Widget build(BuildContext context) {
    final pages = [const TodayPage(), const FocusPage(), const RescuePage(), const GrowsPage(), const YoursPage()];
    return Scaffold(
      appBar: AppBar(title: Text('Puduu 🦌 · ${titles[tab]}', style: const TextStyle(fontFamily: 'Fredoka'))),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.wb_sunny_outlined), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.timer_outlined), label: 'Focus'),
          NavigationDestination(icon: Icon(Icons.ac_unit), label: 'Stuck'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), label: 'Grows'),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Yours'),
        ],
      ),
    );
  }
}

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(inboxProvider);
    final today = ref.watch(todayProvider);
    final ctl = TextEditingController();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Good morning ☀️', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontFamily: 'Fredoka')),
        const Text('Small steps count.'),
        const SizedBox(height: 12),
        for (final t in today)
          Card(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: PuduuColors.timelineHues[t.colorIndex % 6], child: const Icon(Icons.check, color: Colors.white)),
              title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${t.durationMin ?? 25}m · ${t.status}'),
            ),
          ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('INBOX — BRAIN DUMP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PuduuColors.mutedFg)),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: TextField(controller: ctl, decoration: const InputDecoration(hintText: 'Dump it here… e.g. call dentist'))),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    if (ctl.text.trim().isEmpty) return;
                    ref.read(inboxProvider.notifier).state = [
                      ...inbox,
                      PuduuTask(id: _uuid.v4(), title: ctl.text.trim()),
                    ];
                    ctl.clear();
                  },
                  child: const Text('+ Add'),
                ),
              ],
            ),
          ),
        ),
        for (final t in inbox) Card(child: ListTile(title: Text(t.title))),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () async {
            final planned = await ref.read(aiProvider).plan(inbox);
            ref.read(todayProvider.notifier).state = planned;
            ref.read(inboxProvider.notifier).state = [];
          },
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Sort for me (rule-based · AI slot ready)'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.ac_unit),
          label: const Text("I'm Stuck — rescue me"),
          style: OutlinedButton.styleFrom(
            foregroundColor: PuduuColors.accent,
            side: const BorderSide(color: PuduuColors.accent, width: 2),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}

class FocusPage extends StatelessWidget {
  const FocusPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Focus timer → M2 (visual countdown + subtask timers + Switch Ritual)'));
  }
}

class RescuePage extends StatelessWidget {
  const RescuePage({super.key});
  static const options = [
    RescueOption(id: 'r1', title: 'Drink a glass of water', detail: '2 min · energy +1'),
    RescueOption(id: 'r2', title: 'Clear one surface', detail: '2 min · just the desk corner'),
    RescueOption(id: 'r3', title: 'Open the scary email', detail: 'just open it. Reply later.'),
  ];
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("Frozen? Let's thaw. 🧊", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontFamily: 'Fredoka')),
        const Text('Pick the tiniest one. 2 minutes counts.'),
        const SizedBox(height: 12),
        for (final o in options)
          Card(child: ListTile(leading: const Icon(Icons.ac_unit, color: PuduuColors.accent), title: Text(o.title, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(o.detail))),
      ],
    );
  }
}

class GrowsPage extends StatelessWidget {
  const GrowsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Grows → M3 (mood + shame-free streak 5/7 + trophies)'));
  }
}

class YoursPage extends StatelessWidget {
  const YoursPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(child: ListTile(title: Text('Puduu Pro — \$6.99/mo', style: TextStyle(fontWeight: FontWeight.w700)), subtitle: Text('Unlimited rescue · magic AI (soon) · widgets · yearly \$49.99'))),
        Card(child: ListTile(title: Text('Gentle nudges'), subtitle: Text('Max 6/day · quiet hours 22:00–07:00 ON'))),
        Card(child: ListTile(title: Text('Sounds & haptics'), subtitle: Text('Calm chime · soft vibration ON'))),
      ],
    );
  }
}
