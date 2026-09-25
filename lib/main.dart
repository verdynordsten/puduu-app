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
  static const titles = ['Today', 'Focus', 'Reset', 'Progress', 'Yours'];
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
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: [
          for (var i = 0; i < titles.length; i++)
            NavigationDestination(icon: Icon(icons[i]), label: titles[i]),
        ],
      ),
    );
  }
}

/// Premium primitives (mirror the .pen v3 system).

class AppHead extends StatelessWidget {
  final String greet;
  final String sub;
  const AppHead({super.key, required this.greet, required this.sub});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('PUDUU',
                style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 2,
                    color: PuduuColors.primary)),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: PuduuColors.line)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(PuduuIcons.calendar, size: 14),
                  SizedBox(width: 6),
                  Text('Thu, Sep 25',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: PuduuColors.slate)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(greet,
            style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 24,
                fontWeight: FontWeight.w600)),
        Text(sub,
            style:
                const TextStyle(fontSize: 13, color: PuduuColors.slate)),
      ],
    );
  }
}

class SecRow extends StatelessWidget {
  final String label;
  final String action;
  const SecRow({super.key, required this.label, this.action = ''});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: PuduuColors.slate)),
          if (action.isNotEmpty)
            Text(action,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: PuduuColors.primary)),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final PuduuTask task;
  final String hour;
  const TaskCard({super.key, required this.task, required this.hour});
  @override
  Widget build(BuildContext context) {
    final rail = PuduuColors.timelineHues[task.colorIndex % 6];
    final done = task.status == 'done';
    final icon = done
        ? PuduuIcons.checkCircle
        : task.colorIndex == 1
            ? PuduuIcons.focus
            : task.colorIndex == 2
                ? PuduuIcons.bolt
                : PuduuIcons.today;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
                width: 5,
                height: 60,
                decoration: BoxDecoration(
                    color: rail, borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 10),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                  color: rail.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: rail, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hour.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: PuduuColors.slate)),
                  Text(task.title,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: done ? PuduuColors.slate : PuduuColors.foreground)),
                  Text(
                      task.note ??
                          '${task.durationMin ?? 25} min - ${task.status}',
                      style: const TextStyle(
                          fontSize: 12, color: PuduuColors.slate)),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class OptCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String detail;
  final VoidCallback? onTap;
  const OptCard(
      {super.key,
      required this.icon,
      required this.color,
      required this.title,
      required this.detail,
      this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(detail),
        trailing: const Icon(PuduuIcons.chevron),
        onTap: onTap,
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
    const hours = ['08:00 - 25 min', '09:00 - 50 min', '11:00 - 15 min', '13:00 - 30 min'];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const AppHead(
            greet: 'Good morning, Alex',
            sub: 'Thursday, Sep 25 - 4 blocks planned.'),
        Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("TODAY'S FOCUS",
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              color: Colors.white70)),
                      SizedBox(height: 2),
                      Text('Deep work: portfolio',
                          style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 19,
                              color: Colors.white)),
                      Text('09:00 - 50 min - step 2 of 4',
                          style:
                              TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: PuduuColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  onPressed: () {},
                  icon: const Icon(PuduuIcons.play, size: 20),
                  label: const Text('Start'),
                ),
              ],
            ),
          ),
        ),
        const SecRow(label: 'Up next', action: 'See all'),
        for (var i = 0; i < today.length; i++)
          TaskCard(task: today[i], hour: hours[i % hours.length]),
        SecRow(label: 'Inbox', action: '${inbox.length} waiting'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                    controller: ctl,
                    decoration: const InputDecoration(
                        hintText: 'Capture a task, idea, or reminder...')),
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
                        label: const Text('Sort into my day'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        for (final t in inbox) Card(child: ListTile(title: Text(t.title))),
        const OptCard(
            icon: PuduuIcons.reset,
            color: PuduuColors.accent,
            title: 'Stalling?',
            detail: 'Take a 2-minute reset.'),
      ],
    );
  }
}

class FocusPage extends StatelessWidget {
  const FocusPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        AppHead(
            greet: 'Stay with it',
            sub: 'Deep work: portfolio - step 2 of 4.'),
        Card(
            child: ListTile(
                leading: Icon(PuduuIcons.focus),
                title: Text('Focus timer ships in M2'),
                subtitle: Text('Visual ring, subtask timers, ritual link.'))),
      ],
    );
  }
}

class RescuePage extends StatelessWidget {
  const RescuePage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        AppHead(
            greet: 'Hit a wall?',
            sub: 'Freeze reset - two minutes counts.'),
        OptCard(
            icon: PuduuIcons.water,
            color: PuduuColors.secondary,
            title: 'Drink a glass of water',
            detail: '2 min - raises energy.'),
        OptCard(
            icon: PuduuIcons.steps,
            color: PuduuColors.success,
            title: 'Clear one surface',
            detail: '2 min - just the desk corner.'),
        OptCard(
            icon: PuduuIcons.mail,
            color: Color(0xFF7C3AED),
            title: 'Open the difficult email',
            detail: 'Just open it. Reply later.'),
        OptCard(
            icon: PuduuIcons.sort,
            color: PuduuColors.primary,
            title: 'Sort my inbox',
            detail: 'Rule-based now, assisted later.'),
      ],
    );
  }
}

class GrowsPage extends StatelessWidget {
  const GrowsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        AppHead(
            greet: 'Keep growing',
            sub: 'Good days: 5 of 7 - never resets to zero.'),
        OptCard(
            icon: PuduuIcons.grows,
            color: PuduuColors.accent,
            title: 'Weekly shelf',
            detail: 'Early starter x3 - Reset used x5 - Focus 25m x8.'),
        OptCard(
            icon: PuduuIcons.trend,
            color: PuduuColors.success,
            title: 'Focus trend',
            detail: 'Up 20 percent vs last week.'),
      ],
    );
  }
}

class YoursPage extends StatelessWidget {
  const YoursPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        AppHead(greet: 'Make it yours', sub: 'Settings, plan, and backup.'),
        Card(
            color: PuduuColors.primary,
            child: ListTile(
                leading: Icon(PuduuIcons.crown, color: Colors.white),
                title: Text('Puduu Pro - \$6.99/mo',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800)),
                subtitle: Text(
                    'Unlimited resets, assisted planning (soon), yearly \$49.99',
                    style: TextStyle(color: Colors.white70)))),
        OptCard(
            icon: PuduuIcons.bell,
            color: PuduuColors.accent,
            title: 'Gentle nudges',
            detail: 'Max 6 per day, quiet 22:00-07:00 on.'),
        OptCard(
            icon: PuduuIcons.sound,
            color: PuduuColors.secondary,
            title: 'Sounds and haptics',
            detail: 'Calm chime, soft vibration on.'),
      ],
    );
  }
}
