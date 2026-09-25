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
          id: _uuid.v4(), title: 'Morning reset', durationMin: 25, colorIndex: 0, status: 'planned'),
      PuduuTask(
          id: _uuid.v4(), title: 'Deep work: portfolio', durationMin: 50, colorIndex: 1, status: 'planned'),
      PuduuTask(
          id: _uuid.v4(), title: 'Walk outside', durationMin: 15, colorIndex: 3, status: 'done'),
      PuduuTask(
          id: _uuid.v4(), title: 'Admin batch', durationMin: 30, colorIndex: 2, status: 'planned'),
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
    const pages = [TodayPage(), FocusPage(), RescuePage(), GrowsPage(), YoursPage()];
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

// ---------- editorial primitives (v4) ----------

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
            const Row(
              children: [
                // mascot mark would sit here (asset) — wordmark only on web
                Text('Puduu',
                    style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontWeight: FontWeight.w600,
                        fontSize: 17)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: PuduuColors.line)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(PuduuIcons.calendarCheck, size: 15),
                  SizedBox(width: 6),
                  Text('Thu Sep 25',
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
                fontFamily: 'Fredoka', fontSize: 26, fontWeight: FontWeight.w600)),
        Text(sub, style: const TextStyle(fontSize: 13, color: PuduuColors.slate)),
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

class TimelineRow extends StatelessWidget {
  final String hour;
  final String mins;
  final PuduuTask task;
  const TimelineRow(
      {super.key, required this.hour, required this.mins, required this.task});
  @override
  Widget build(BuildContext context) {
    final rail = PuduuColors.rails[task.colorIndex % 4];
    final done = task.status == 'done';
    final icon = done
        ? PuduuIcons.checkCircle
        : task.colorIndex == 1
            ? PuduuIcons.focus
            : task.colorIndex == 2
                ? PuduuIcons.bolt
                : PuduuIcons.sunSoft;
    final tint = done
        ? PuduuColors.greenSoft
        : task.colorIndex == 1
            ? PuduuColors.tealSoft
            : task.colorIndex == 2
                ? PuduuColors.amberSoft
                : PuduuColors.pale;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(hour,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: done ? PuduuColors.slate : PuduuColors.ink)),
                  Text(mins.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: PuduuColors.faint)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                    color: rail, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: tint, borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: done ? PuduuColors.green : rail, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: done ? FontWeight.w700 : FontWeight.w800,
                          color: done ? PuduuColors.slate : PuduuColors.ink)),
                  Text(done ? 'Done' : '${task.durationMin ?? 25} min · ${task.status}',
                      style: const TextStyle(fontSize: 12, color: PuduuColors.slate)),
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
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(detail),
        onTap: onTap,
      ),
    );
  }
}

class FocusHero extends StatelessWidget {
  const FocusHero({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [PuduuColors.heroA, PuduuColors.heroB],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: PuduuColors.heroA.withValues(alpha: 0.22),
              blurRadius: 28,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("TODAY'S FOCUS",
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Colors.white70)),
          const SizedBox(height: 3),
          const Text('Deep work: portfolio',
              style: TextStyle(
                  fontFamily: 'Fredoka', fontSize: 20, color: Colors.white)),
          const Text('09:00 · 50 min · step 2 of 4',
              style: TextStyle(fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: 0.61,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(PuduuColors.primary),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: PuduuColors.primary),
              onPressed: () {},
              icon: const Icon(PuduuIcons.play, size: 20),
              label: const Text('Start focus'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- screens ----------

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(inboxProvider);
    final today = ref.watch(todayProvider);
    final ctl = TextEditingController();
    const hours = ['08:00', '09:00', '11:00', '13:00'];
    const mins = ['25 min', '50 min', '15 min', '30 min'];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
      children: [
        const AppHead(
            greet: 'Good morning, Alex',
            sub: 'Thursday, Sep 25 · 4 blocks planned.'),
        const FocusHero(),
        const SecRow(label: 'Up next', action: 'See all'),
        for (var i = 0; i < today.length; i++)
          TimelineRow(
              hour: hours[i % hours.length],
              mins: mins[i % mins.length],
              task: today[i]),
        SecRow(label: 'Inbox', action: '${inbox.length} waiting'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                    controller: ctl,
                    decoration: const InputDecoration(
                        hintText: 'Capture a task, idea, or reminder…')),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final planned = await ref.read(aiProvider).plan(inbox);
                      ref.read(todayProvider.notifier).state = planned;
                      ref.read(inboxProvider.notifier).state = [];
                    },
                    icon: const Icon(PuduuIcons.sort, size: 18),
                    label: const Text('Sort into my day'),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: () {
                      if (ctl.text.trim().isEmpty) return;
                      ref.read(inboxProvider.notifier).state = [
                        ...inbox,
                        PuduuTask(id: _uuid.v4(), title: ctl.text.trim()),
                      ];
                      ctl.clear();
                    },
                    child: const Text('Add to inbox'),
                  ),
                ),
              ],
            ),
          ),
        ),
        for (final t in inbox) Card(child: ListTile(title: Text(t.title))),
        const OptCard(
            icon: PuduuIcons.reset,
            color: PuduuColors.amber,
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
      children: [
        const AppHead(
            greet: 'Stay with it.', sub: 'Deep work: portfolio · step 2 of 4.'),
        Card(
          margin: const EdgeInsets.only(top: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
            child: Column(
              children: [
                const Text('FOCUS SESSION',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: PuduuColors.slate)),
                const SizedBox(height: 12),
                Container(
                  width: 160,
                  height: 160,
                  decoration: const BoxDecoration(
                      color: PuduuColors.tealSoft, shape: BoxShape.circle),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('32:10',
                          style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 34,
                              fontWeight: FontWeight.w600,
                              fontFeatures: [FontFeature.tabularFigures()])),
                      Text('LEFT',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              color: PuduuColors.slate)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Sketch hero section · gentle chime at end',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 13, color: PuduuColors.slate)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RescuePage extends StatelessWidget {
  const RescuePage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
      children: const [
        AppHead(greet: 'Hit a wall?', sub: 'Freeze reset · two minutes counts.'),
        OptCard(
            icon: PuduuIcons.water,
            color: PuduuColors.teal,
            title: 'Drink a glass of water',
            detail: '2 min · raises energy.'),
        OptCard(
            icon: PuduuIcons.steps,
            color: PuduuColors.green,
            title: 'Clear one surface',
            detail: '2 min · just the desk corner.'),
        OptCard(
            icon: PuduuIcons.mail,
            color: PuduuColors.purple,
            title: 'Open the difficult email',
            detail: 'Just open it. Reply later.'),
        OptCard(
            icon: PuduuIcons.sort,
            color: PuduuColors.primary,
            title: 'Sort my inbox',
            detail: 'Rule-based now · assisted later.'),
      ],
    );
  }
}

class GrowsPage extends StatelessWidget {
  const GrowsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
      children: const [
        AppHead(
            greet: 'Keep growing.',
            sub: 'Good days: 5 of 7 · never resets to zero.'),
        OptCard(
            icon: PuduuIcons.grows,
            color: PuduuColors.amber,
            title: 'Weekly shelf',
            detail: 'Early starter ×3 · Reset used ×5 · Focus 25m ×8.'),
        OptCard(
            icon: PuduuIcons.trend,
            color: PuduuColors.green,
            title: 'Focus trend',
            detail: 'Up 20% vs last week · mornings work best.'),
      ],
    );
  }
}

class YoursPage extends StatelessWidget {
  const YoursPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
      children: const [
        AppHead(greet: 'Make it yours.', sub: 'Settings, plan, and backup.'),
        Card(
            color: PuduuColors.heroA,
            child: ListTile(
                leading: Icon(PuduuIcons.crown, color: Colors.white),
                title: Text('Puduu Pro · \$6.99/mo',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800)),
                subtitle: Text('Unlimited resets · yearly \$49.99',
                    style: TextStyle(color: Colors.white70)))),
        OptCard(
            icon: PuduuIcons.bell,
            color: PuduuColors.amber,
            title: 'Gentle nudges',
            detail: 'Max 6 per day · quiet 22:00–07:00 on.'),
        OptCard(
            icon: PuduuIcons.sound,
            color: PuduuColors.teal,
            title: 'Sounds and haptics',
            detail: 'Calm chime · soft vibration on.'),
      ],
    );
  }
}
