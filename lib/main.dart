import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'core/theme/puduu_theme.dart';
import 'core/models.dart';
import 'core/db/puduu_db.dart';
import 'core/db/repo.dart';
import 'core/sync.dart';
import 'core/ai_slot/ai_planner.dart';
import 'features/today_page.dart' show TodayPage;
import 'features/main_pages.dart'
    show FocusPage, RescuePage, GrowsPage, YoursPage, SettingsState;
import 'features/sub_pages.dart' show OnboardingFlowCompat;
import 'package:shared_preferences/shared_preferences.dart';

final dbProvider = Provider<PuduuDb>((_) => PuduuDb());
final repoProvider =
    Provider<PuduuRepo>((ref) => PuduuRepo(ref.watch(dbProvider)));

final inboxProvider = FutureProvider<List<PuduuTask>>((ref) async {
  ref.watch(_inboxTickProvider);
  return ref.watch(repoProvider).tasksByStatus('inbox');
});
final todayProvider = FutureProvider<List<PuduuTask>>((ref) async {
  ref.watch(_inboxTickProvider);
  return ref.watch(repoProvider).tasksByStatus('planned');
});
final timedProvider = FutureProvider<List<PuduuTask>>((ref) async {
  ref.watch(_inboxTickProvider);
  return ref.watch(repoProvider).plannedWithTime();
});

/// bump to refresh inbox+today after any write
final _inboxTickProvider = StateProvider<int>((_) => 0);
void bumpTasks(WidgetRef ref) {
  ref.read(_inboxTickProvider.notifier).state++;
  // background cloud push; never blocks UI, never throws
  Future(() async {
    final r = await ref.read(syncProvider).syncAll();
    ref.read(syncLiveProvider.notifier).state = r.live;
  });
}

final aiProvider = Provider<AiPlannerProvider>((_) => RuleBasedProvider());

final syncProvider =
    Provider<PuduuSync>((ref) => PuduuSync(ref.watch(repoProvider)));

/// null = not synced yet, true = live, false = local-only
final syncLiveProvider = StateProvider<bool?>((_) => null);

/// DB-ready gate: seed on first run, init Supabase, first sync, then release UI.
final dbReadyProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(repoProvider);
  await repo.seedIfEmpty();
  await SettingsState.load(ref);
  final sync = ref.watch(syncProvider);
  await sync.init();
  final r = await sync.syncAll();
  ref.read(syncLiveProvider.notifier).state = r.live;
  return true;
});

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
            child: OnboardingFlowCompat(
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

/// Tab jump bus: pages request Shell to switch tabs (e.g. Begin hero -> Focus).
final tabJumpProvider = StateProvider<int?>((_) => null);

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
    ref.listen<int?>(tabJumpProvider, (_, next) {
      if (next != null) {
        _go(next);
        ref.read(tabJumpProvider.notifier).state = null;
      }
    });
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
