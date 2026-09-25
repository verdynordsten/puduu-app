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
      PuduuTask(
          id: _uuid.v4(),
          title: 'Deep work: portfolio hero',
          durationMin: 50,
          colorIndex: 1),
    ]);
final todayProvider = StateProvider<List<PuduuTask>>((_) => [
      PuduuTask(
          id: _uuid.v4(),
          title: 'Morning reset',
          note: 'Meds, water, 5-min tidy',
          durationMin: 25,
          colorIndex: 0,
          status: 'planned'),
      PuduuTask(
          id: _uuid.v4(),
          title: 'Deep work: portfolio',
          note: 'Timer ready, step 2 of 4',
          durationMin: 50,
          colorIndex: 1,
          status: 'planned'),
      PuduuTask(
          id: _uuid.v4(),
          title: 'Walk outside',
          durationMin: 15,
          colorIndex: 3,
          status: 'done'),
      PuduuTask(
          id: _uuid.v4(),
          title: 'Admin batch',
          note: 'Bills and inbox',
          durationMin: 30,
          colorIndex: 2,
          status: 'planned'),
    ]);
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
  static const titles = ['Today', 'Focus', 'Reset', 'Grows', 'Yours'];
  static const icons = [
    PuduuIcons.today,
    PuduuIcons.focus,
    PuduuIcons.reset,
    PuduuIcons.grows,
    PuduuIcons.yours,
  ];
  @override
  Widget build(BuildContext context) {
    const pages = [
      TodayPage(),
      FocusPage(),
      RescuePage(),
      GrowsPage(),
      YoursPage()
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Puduu - ${titles[tab]}',
            style: const TextStyle(fontFamily: 'Fredoka')),
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: [
          for (var i = 0; i < titles.length; i++)
            NavigationDestination(
                icon: Icon(icons[i]), label: titles[i]),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(text.toUpperCase(),
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: PuduuColors.slate)),
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
        Text('Good morning',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontFamily: 'Fredoka')),
        const Text('Thursday, 4 blocks. Small steps count.',
            style: TextStyle(color: PuduuColors.slate)),
        const SectionLabel("Today's timeline"),
        for (final t in today)
          Card(
            color: PuduuColors.timelineHues[t.colorIndex % 6],
            child: ListTile(
              leading: Icon(
                  t.status == 'done'
                      ? PuduuIcons.checkCircle
                      : PuduuIcons.chevron,
                  color: Colors.white),
              title: Text(t.title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
              subtitle: Text(
                  '${t.durationMin ?? 25} min - ${t.status}',
                  style: const TextStyle(color: Colors.white70)),
            ),
          ),
        const SectionLabel('Inbox - brain dump'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                    controller: ctl,
                    decoration: const InputDecoration(
                        hintText: 'Capture it here... e.g. call dentist')),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () {
                          if (ctl.text.trim().isEmpty) return;
                          ref.read(inboxProvider.notifier).state = [
                            ...inbox,
                            PuduuTask(id: _uuid.v4(), title: ctl.text.trim()),
                          ];
                          ctl.clear();
                        },
                        child: const Text('Add'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          final planned =
                              await ref.read(aiProvider).plan(inbox);
                          ref.read(todayProvider.notifier).state = planned;
                          ref.read(inboxProvider.notifier).state = [];
                        },
                        icon: const Icon(PuduuIcons.sort, size: 18),
                        label: const Text('Sort for me'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        for (final t in inbox) Card(child: ListTile(title: Text(t.title))),
        const SizedBox(height: 6),
        Card(
          color: PuduuColors.accentSoft,
          child: ListTile(
            leading: const Icon(PuduuIcons.reset, color: PuduuColors.accent),
            title: const Text('Feeling stuck?',
                style: TextStyle(fontWeight: FontWeight.w800)),
            subtitle: const Text('Get one tiny step. Two minutes counts.'),
            trailing: const Icon(PuduuIcons.chevron),
            onTap: () {},
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
    return const Center(
        child: Text('Focus timer - M2 (visual countdown, subtask timers)'));
  }
}

class RescuePage extends StatelessWidget {
  const RescuePage({super.key});
  static const options = [
    ('Drink a glass of water', '2 min - raises energy', PuduuIcons.water),
    ('Clear one surface', '2 min - just the desk corner', PuduuIcons.steps),
    ('Open the difficult email', 'Just open it. Reply later.', PuduuIcons.mail),
    ('Sort my inbox', 'Rule-based now, assisted later.', PuduuIcons.sort),
  ];
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Feeling stuck?',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontFamily: 'Fredoka')),
        const Text('Pick the tiniest step. Two minutes counts.',
            style: TextStyle(color: PuduuColors.slate)),
        const SectionLabel('Tiny steps'),
        for (final o in options)
          Card(
            child: ListTile(
                leading: Icon(o.$3, color: PuduuColors.secondary),
                title: Text(o.$1,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(o.$2)),
          ),
      ],
    );
  }
}

class GrowsPage extends StatelessWidget {
  const GrowsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Grows - M3 (mood, streak 5 of 7)'));
  }
}

class YoursPage extends StatelessWidget {
  const YoursPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
            child: ListTile(
                leading: Icon(PuduuIcons.crown, color: PuduuColors.accent),
                title: Text('Puduu Pro - \$6.99/mo',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(
                    'Unlimited resets, assisted planning (soon), yearly \$49.99'))),
        Card(
            child: ListTile(
                leading: Icon(PuduuIcons.bell),
                title: Text('Gentle nudges'),
                subtitle: Text('Max 6 per day, quiet 22:00-07:00 on'))),
        Card(
            child: ListTile(
                leading: Icon(PuduuIcons.sound),
                title: Text('Sounds and haptics'),
                subtitle: Text('Calm chime, soft vibration on'))),
      ],
    );
  }
}
