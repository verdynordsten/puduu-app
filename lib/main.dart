import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import 'core/theme/puduu_theme.dart';
import 'core/models.dart';
import 'core/db/puduu_db.dart';
import 'core/db/repo.dart';
import 'core/ai_slot/ai_planner.dart';
import 'features/more_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _uuid = Uuid();

final dbProvider = Provider<PuduuDb>((_) => PuduuDb());
final repoProvider = Provider<PuduuRepo>((ref) => PuduuRepo(ref.watch(dbProvider)));

/// DB-ready gate: seed on first run, then release UI.
final dbReadyProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(repoProvider);
  await repo.seedIfEmpty();
  return true;
});

final inboxProvider =
    FutureProvider<List<PuduuTask>>((ref) async {
  ref.watch(_inboxTickProvider);
  return ref.watch(repoProvider).tasksByStatus('inbox');
});
final todayProvider =
    FutureProvider<List<PuduuTask>>((ref) async {
  ref.watch(_inboxTickProvider);
  return ref.watch(repoProvider).tasksByStatus('planned');
});
/// bump to refresh inbox+today after any write
final _inboxTickProvider = StateProvider<int>((_) => 0);
void bumpTasks(WidgetRef ref) =>
    ref.read(_inboxTickProvider.notifier).state++;

final aiProvider = Provider<AiPlannerProvider>((_) => RuleBasedProvider());

final onboardedProvider = StateProvider<bool>((_) => false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final seen = prefs.getBool('puduu_onboarded') ?? false;
  runApp(ProviderScope(
    overrides: [onboardedProvider.overrideWith((_) => seen)],
    child: const PuduuApp(),
  ));
}

Future<void> completeOnboarding(WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('puduu_onboarded', true);
  ref.read(onboardedProvider.notifier).state = true;
}

class PuduuApp extends StatelessWidget {
  const PuduuApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puduu',
      theme: puduuTheme(),
      home: const _Root(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ---------- root: onboarding gate -> shell ----------
class _Root extends ConsumerWidget {
  const _Root();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ready = ref.watch(dbReadyProvider);
    if (ready.isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    final seen = ref.watch(onboardedProvider);
    if (!seen) return const OnboardingGate();
    return const Shell();
  }
}

class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: OnboardingFlow(
              onDone: () => completeOnboarding(ref),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- shell: dark pill nav on phones ----------

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
  static const iconsFill = [
    PuduuIcons.todayFill,
    PuduuIcons.focusFill,
    PuduuIcons.resetFill,
    PuduuIcons.growsFill,
    PuduuIcons.yoursFill,
  ];

  void _go(int i) => setState(() => tab = i);

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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: pages[tab],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Container(
          decoration: BoxDecoration(
            color: PuduuColors.dark,
            borderRadius: BorderRadius.circular(26),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            children: [
              for (var i = 0; i < titles.length; i++)
                Expanded(
                  child: _PillTab(
                    label: titles[i],
                    icon: tab == i ? iconsFill[i] : icons[i],
                    active: tab == i,
                    badge: i == 0
                        ? ref
                            .watch(inboxProvider)
                            .maybeWhen(
                                data: (v) => v.length, orElse: () => 0)
                        : 0,
                    onTap: () => _go(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final int badge;
  final VoidCallback onTap;
  const _PillTab(
      {required this.label,
      required this.icon,
      required this.active,
      this.badge = 0,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Badge(
              isLabelVisible: badge > 0,
              label: Text('$badge',
                  style: const TextStyle(fontSize: 10)),
              backgroundColor: PuduuColors.teal,
              textColor: Colors.white,
              smallSize: 14,
              largeSize: 16,
              child: Icon(icon,
                  size: 22,
                  color: active
                      ? PuduuColors.dark
                      : const Color(0xFF8FA3A1)),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Work Sans',
                    fontSize: 10,
                    fontWeight:
                        active ? FontWeight.w700 : FontWeight.w500,
                    color: active
                        ? PuduuColors.dark
                        : const Color(0xFF8FA3A1))),
          ],
        ),
      ),
    );
  }
}

// ---------- shared DocSpot-class primitives ----------

class HelloHead extends StatelessWidget {
  final String hello;
  final String sub;
  final bool showBell;
  const HelloHead(
      {super.key,
      required this.hello,
      required this.sub,
      this.showBell = false});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(hello,
                  style: PuduuType.display.copyWith(fontSize: 23)),
              const SizedBox(height: 2),
              Text(sub,
                  style: const TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: PuduuColors.tealDeep)),
            ],
          ),
        ),
        if (showBell)
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: PuduuColors.card,
              border: Border.all(color: PuduuColors.line),
              shape: BoxShape.circle,
            ),
            child: const Badge(
              isLabelVisible: true,
              backgroundColor: PuduuColors.danger,
              smallSize: 8,
              child: Icon(PuduuIcons.bell,
                  size: 19, color: PuduuColors.soft),
            ),
          ),
        const SizedBox(width: 8),
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              PuduuColors.teal,
              PuduuColors.tealDeep,
            ]),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Text('A',
              style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ),
      ],
    );
  }
}

class SearchField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  const SearchField({super.key, required this.hint, this.controller});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon:
            const Icon(PuduuIcons.search, color: PuduuColors.mute),
      ),
    );
  }
}

class SectionHead extends StatelessWidget {
  final String label;
  final String? action;
  final VoidCallback? onAction;
  const SectionHead({super.key, required this.label, this.action, this.onAction});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: PuduuType.label()),
          if (action != null)
            TextButton(onPressed: onAction ?? () {}, child: Text(action!)),
        ],
      ),
    );
  }
}

class DarkHero extends StatelessWidget {
  final String tag;
  final String title;
  final String meta;
  final double progress;
  final String primary;
  final String secondary;
  final VoidCallback? onPrimary;
  const DarkHero(
      {super.key,
      required this.tag,
      required this.title,
      required this.meta,
      required this.progress,
      required this.primary,
      required this.secondary,
      this.onPrimary});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PuduuColors.dark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tag,
              style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  color: Color(0xFF7DD3C7))),
          const SizedBox(height: 5),
          Text(title,
              style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2)),
          const SizedBox(height: 2),
          Text(meta,
              style: const TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 12,
                  color: Color(0xFFB9CDC9))),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withAlpha(28),
              valueColor:
                  const AlwaysStoppedAnimation(Color(0xFF2DD4BF)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onPrimary ?? () {},
                  icon: const Icon(PuduuIcons.play, size: 18),
                  label: Text(primary),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha(28),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {},
                  child: Text(secondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Color dot;
  final String title;
  final String detail;
  final String? side;
  final bool sideDone;
  final IconData? icon;
  final Color? tile;
  const TaskCard(
      {super.key,
      required this.dot,
      required this.title,
      required this.detail,
      this.side,
      this.sideDone = false,
      this.icon,
      this.tile});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (icon != null)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tile ?? PuduuColors.tealWash,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 19, color: PuduuColors.soft),
              )
            else
              Container(
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: dot)),
            const SizedBox(width: 12),
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
            if (side != null)
              Text(side!,
                  style: TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: sideDone
                          ? PuduuColors.moss
                          : PuduuColors.tealDeep)),
          ],
        ),
      ),
    );
  }
}

// ---------- 5 screens ----------

// ---------- visual timeline strip (Tiimo parity) ----------
class TimelineStrip extends StatelessWidget {
  const TimelineStrip({super.key});
  static const _blocks = [
    ('09:00', 'Deep work', PuduuColors.teal, 0.61),
    ('11:00', 'Walk', PuduuColors.moss, 1.0),
    ('13:00', 'Admin', PuduuColors.amber, 0.0),
    ('15:00', 'Call', PuduuColors.tealDeep, 0.0),
  ];
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            for (final b in _blocks)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(width: 40, child: Text(b.$1, style: PuduuType.meta)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(b.$2, style: PuduuType.strong),
                              if (b.$4 == 1.0)
                                const Text('✓', style: TextStyle(fontSize: 12, color: PuduuColors.moss, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: b.$4 == 0.0 ? 0.04 : b.$4,
                              minHeight: 7,
                              backgroundColor: PuduuColors.bg,
                              valueColor: AlwaysStoppedAnimation(b.$3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const _SubShell(title: 'Calendar', child: CalendarPage()))),
                child: const Text('Open full calendar ›')),
          ],
        ),
      ),
    );
  }
}

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxAsync = ref.watch(inboxProvider);
    final inbox = inboxAsync.maybeWhen(data: (v) => v, orElse: () => <PuduuTask>[]);
    final ctl = TextEditingController();
    const cats = [
      (PuduuIcons.focus, 'Focus', PuduuColors.tealWash),
      (PuduuIcons.reset, 'Reset', PuduuColors.amberWash),
      (PuduuIcons.check, 'Habits', PuduuColors.mossWash),
      (PuduuIcons.sort, 'More', Color(0xFFE8F1F6)),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      children: [
        const HelloHead(
            hello: 'Hello, Alex',
            sub: '◉ Morning plan ▾',
            showBell: true),
        const SizedBox(height: 12),
        SearchField(hint: 'Search a task or ritual', controller: ctl),
        const DarkHero(
          tag: 'NOW · 09:00 · 50 MIN',
          title: 'Deep work: portfolio',
          meta: 'Step 2 of 4 · timer ready',
          progress: 0.61,
          primary: 'Begin session',
          secondary: 'Skip',
        ),
        const SectionHead(label: 'TIMELINE'),
        const TimelineStrip(),
        SectionHead(
            label: 'CATEGORIES',
            action: 'See all ›',
            onAction: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const _SubShell(title: 'Library', child: LibraryPage())))),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.86,
          children: [
            for (final c in cats)
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: c.$3,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(c.$1,
                            size: 18, color: PuduuColors.soft),
                      ),
                      const SizedBox(height: 6),
                      Text(c.$2,
                          style: const TextStyle(
                              fontFamily: 'Work Sans',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: PuduuColors.ink)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        SectionHead(
            label: 'UP NEXT',
            action: inbox.isEmpty ? null : '${inbox.length} waiting'),
        const TaskCard(
            dot: PuduuColors.teal,
            title: 'Deep work: portfolio',
            detail: '09:00 · Hero section, phone away',
            side: 'Begin'),
        const SizedBox(height: 8),
        const TaskCard(
            dot: PuduuColors.moss,
            title: 'Walk outside',
            detail: '11:00 · Fifteen minutes, no podcast',
            side: '✓ Done',
            sideDone: true),
        const SectionHead(label: 'INBOX'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ctl,
                        decoration: const InputDecoration(
                            hintText:
                                'Capture a task, idea, or reminder…'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () async {
                        if (ctl.text.trim().isEmpty) return;
                        await ref.read(repoProvider).addTask(PuduuTask(
                            id: _uuid.v4(), title: ctl.text.trim()));
                        bumpTasks(ref);
                        ctl.clear();
                      },
                      icon: const Icon(PuduuIcons.plus, size: 17),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PuduuColors.tealDeep,
                      side: const BorderSide(
                          color: PuduuColors.tealDeep, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: () async {
                      final planned =
                          await ref.read(aiProvider).plan(inbox);
                      await ref.read(repoProvider).moveAllToToday(planned);
                      bumpTasks(ref);
                    },
                    icon: const Icon(PuduuIcons.sort, size: 17),
                    label: const Text('Sort into my day'),
                  ),
                ),
              ],
            ),
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      children: [
        const HelloHead(
            hello: 'Stay with it',
            sub: '◷ Focus session · step 2 of 4'),
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          decoration: BoxDecoration(
            color: PuduuColors.dark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Text('32:10',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
                child: const LinearProgressIndicator(
                  value: 0.36,
                  minHeight: 6,
                  backgroundColor: Color(0x29FFFFFF),
                  valueColor:
                      AlwaysStoppedAnimation(Color(0xFF2DD4BF)),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                  'Sketch the hero section. Phone in another room.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 12,
                      color: Color(0xFFB9CDC9))),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon:
                          const Icon(PuduuIcons.pause, size: 18),
                      label: const Text('Pause'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            Colors.white.withAlpha(28),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {},
                      child: const Text('End early'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SectionHead(label: 'SESSION STEPS'),
        const TaskCard(
            dot: PuduuColors.moss,
            title: 'Open the file',
            detail: 'Done · 2 min',
            side: '✓',
            sideDone: true),
        const SizedBox(height: 8),
        const TaskCard(
            dot: PuduuColors.teal,
            title: 'Sketch hero section',
            detail: 'Now · 25 min',
            side: '25 min'),
        const SizedBox(height: 8),
        const TaskCard(
            dot: PuduuColors.line,
            title: 'Review + save',
            detail: 'Next · 10 min',
            side: '10 min'),
      ],
    );
  }
}

class RescuePage extends StatelessWidget {
  const RescuePage({super.key});
  @override
  Widget build(BuildContext context) {
    const rows = [
      (PuduuIcons.drop, PuduuColors.tealWash, 'Drink a glass of water',
          'Stand up, sip slowly, look far away.', '2 min'),
      (PuduuIcons.reset, PuduuColors.amberWash, 'Clear one surface',
          'Just the desk corner. Nothing more.', '2 min'),
      (PuduuIcons.mail, PuduuColors.mossWash, 'Open the difficult email',
          'Read it only. Reply comes later.', '2 min'),
      (PuduuIcons.sort, Color(0xFFE8F1F6), 'Sort the inbox',
          'Rule-based now, assisted later.', '3 min'),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      children: [
        const HelloHead(
            hello: 'Hit a wall?',
            sub: '✦ Two minutes counts'),
        const SizedBox(height: 12),
        const SearchField(hint: 'Search a reset'),
        const SectionHead(label: 'PICK THE SMALLEST ONE'),
        for (final r in rows) ...[
          TaskCard(
              dot: PuduuColors.teal,
              title: r.$3,
              detail: r.$4,
              side: r.$5,
              icon: r.$1,
              tile: r.$2),
          const SizedBox(height: 8),
        ],
        Card(
          color: PuduuColors.tealWash,
          child: const Padding(
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

class GrowsPage extends StatelessWidget {
  const GrowsPage({super.key});
  @override
  Widget build(BuildContext context) {
    const chips = [('5/7', 'good days'), ('+20%', 'focus'), ('×5', 'resets')];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      children: [
        const HelloHead(
            hello: 'Keep growing', sub: '▥ Good days: 5 of 7'),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final c in chips)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10),
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
            for (final t in [('×3', 'Early bird', Icons.wb_sunny_outlined, PuduuColors.amberWash), ('×5', 'Resetter', Icons.bolt_outlined, PuduuColors.tealWash), ('×8', 'Focused', Icons.timer_outlined, PuduuColors.mossWash)])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: t.$4, shape: BoxShape.circle),
                            child: Icon(t.$3, size: 19, color: PuduuColors.soft),
                          ),
                          const SizedBox(height: 4),
                          Text(t.$1, style: const TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w700, color: PuduuColors.ink)),
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
        const TaskCard(
            dot: PuduuColors.teal,
            title: 'Weekly shelf',
            detail: 'Early starter ×3 · Reset ×5 · Focus 25m ×8',
            side: 'W39',
            icon: PuduuIcons.grows,
            tile: PuduuColors.tealWash),
        const SizedBox(height: 8),
        const TaskCard(
            dot: PuduuColors.teal,
            title: 'Focus trend',
            detail: 'Up 20% vs last week. Mornings win',
            side: '+20%',
            icon: PuduuIcons.focus,
            tile: PuduuColors.amberWash),
        const SizedBox(height: 8),
        const TaskCard(
            dot: PuduuColors.teal,
            title: 'Resets that worked',
            detail: 'Water first, then air. Evenings hard',
            side: '×5',
            icon: PuduuIcons.reset,
            tile: PuduuColors.mossWash),
        const SizedBox(height: 8),
        Card(
          color: PuduuColors.dark,
          child: const Padding(
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

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String title, detail;
  final Widget page;
  const _NavRow({required this.icon, required this.title, required this.detail, required this.page});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _SubShell(title: title, child: page))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: PuduuColors.tealWash, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 19, color: PuduuColors.soft),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: PuduuType.strong),
                    Text(detail, style: PuduuType.meta),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: PuduuColors.mute),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubShell extends StatelessWidget {
  final String title;
  final Widget child;
  const _SubShell({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: Text(title, style: PuduuType.title.copyWith(fontSize: 17)),
      ),
      body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: child))),
    );
  }
}

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
              const Text('Yearly \$49.99 · calm history · backup',
                  style: TextStyle(
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
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallPage()));
                  },
                  child: const Text('Upgrade'),
                ),
              ),
            ],
          ),
        ),
        const SectionHead(label: 'MORE'),
        _NavRow(icon: Icons.refresh_outlined, title: 'Routines', detail: 'Repeatable calm', page: const RoutinesPage()),
        const SizedBox(height: 8),
        _NavRow(icon: Icons.calendar_month_outlined, title: 'Calendar', detail: 'Week view · sync', page: const CalendarPage()),
        const SizedBox(height: 8),
        _NavRow(icon: Icons.auto_awesome_outlined, title: 'Library', detail: 'Ready-made activities', page: const LibraryPage()),
        const SizedBox(height: 8),
        _NavRow(icon: Icons.sentiment_satisfied_outlined, title: 'Mood', detail: 'Check-ins + patterns', page: const MoodPage()),
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
