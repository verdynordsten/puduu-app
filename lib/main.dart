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
          note: 'Meds, water, five-minute tidy',
          durationMin: 25,
          colorIndex: 0,
          status: 'planned'),
      PuduuTask(
          id: _uuid.v4(),
          title: 'Deep work: portfolio',
          note: 'Hero section, timer on, phone away',
          durationMin: 50,
          colorIndex: 1,
          status: 'planned'),
      PuduuTask(
          id: _uuid.v4(),
          title: 'Walk outside',
          note: 'Fifteen minutes, no podcast',
          durationMin: 15,
          colorIndex: 3,
          status: 'done'),
      PuduuTask(
          id: _uuid.v4(),
          title: 'Admin batch',
          note: 'Bills and inbox, one pass',
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

// ---------- shell: rail on wide screens, tabs on phones ----------

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
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 900;
        if (wide) {
          return Scaffold(
            body: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SideRail(tab: tab, onGo: _go),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: 640),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(child: pages[tab]),
                            const SizedBox(width: 40),
                            const _MarginNotes(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: pages[tab],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border:
                  Border(top: BorderSide(color: PuduuColors.line)),
            ),
            child: NavigationBar(
              selectedIndex: tab,
              height: 68,
              onDestinationSelected: _go,
              destinations: [
                for (var i = 0; i < titles.length; i++)
                  NavigationDestination(
                    icon: Badge(
                      isLabelVisible:
                          i == 0 && ref.watch(inboxProvider).isNotEmpty,
                      label: Text(
                          '${ref.watch(inboxProvider).length}',
                          style: const TextStyle(fontSize: 10)),
                      backgroundColor: PuduuColors.ember,
                      textColor: Colors.white,
                      smallSize: 16,
                      largeSize: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(icons[i], size: 24),
                    ),
                    selectedIcon: Badge(
                      isLabelVisible:
                          i == 0 && ref.watch(inboxProvider).isNotEmpty,
                      label: Text(
                          '${ref.watch(inboxProvider).length}',
                          style: const TextStyle(fontSize: 10)),
                      backgroundColor: PuduuColors.ember,
                      textColor: Colors.white,
                      smallSize: 16,
                      largeSize: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(iconsFill[i], size: 24),
                    ),
                    label: titles[i],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SideRail extends ConsumerWidget {
  final int tab;
  final ValueChanged<int> onGo;
  const _SideRail({required this.tab, required this.onGo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const items = [
      (PuduuIcons.today, PuduuIcons.todayFill, 'Today'),
      (PuduuIcons.focus, PuduuIcons.focusFill, 'Focus'),
      (PuduuIcons.reset, PuduuIcons.resetFill, 'Reset'),
      (PuduuIcons.grows, PuduuIcons.growsFill, 'Progress'),
      (PuduuIcons.yours, PuduuIcons.yoursFill, 'Yours'),
    ];
    final inboxCount = ref.watch(inboxProvider).length;
    return Container(
      width: 232,
      padding: const EdgeInsets.fromLTRB(20, 26, 16, 20),
      decoration: const BoxDecoration(
        border: Border(
            right: BorderSide(color: PuduuColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              _Wordmark(),
              SizedBox(width: 9),
              Text('Puduu',
                  style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      color: PuduuColors.ink)),
            ],
          ),
          const SizedBox(height: 30),
          for (var i = 0; i < items.length; i++)
            _RailItem(
              icon: tab == i ? items[i].$2 : items[i].$1,
              label: items[i].$3,
              active: tab == i,
              badge: i == 0 ? inboxCount : 0,
              onTap: () => onGo(i),
            ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PuduuColors.card,
              border: Border.all(color: PuduuColors.line),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(PuduuIcons.crown,
                        size: 16, color: PuduuColors.emberDeep),
                    SizedBox(width: 6),
                    Text('Puduu Pro',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: PuduuColors.ink)),
                  ],
                ),
                SizedBox(height: 5),
                Text('Unlimited plans, calm history, yearly \$49.99.',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        height: 1.5,
                        color: PuduuColors.mute)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final int badge;
  final VoidCallback onTap;
  const _RailItem(
      {required this.icon,
      required this.label,
      required this.active,
      this.badge = 0,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: active ? PuduuColors.emberWash : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                Badge(
                  isLabelVisible: badge > 0,
                  label: Text('$badge',
                      style: const TextStyle(fontSize: 10)),
                  backgroundColor: PuduuColors.ember,
                  textColor: Colors.white,
                  smallSize: 14,
                  largeSize: 16,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(icon,
                      size: 22,
                      color: active
                          ? PuduuColors.emberDeep
                          : PuduuColors.mute),
                ),
                const SizedBox(width: 11),
                Text(label,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight:
                            active ? FontWeight.w700 : FontWeight.w500,
                        color: active
                            ? PuduuColors.ink
                            : PuduuColors.mute)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: PuduuColors.ink,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text('P',
            style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFFFDF8))),
      ),
    );
  }
}

/// Margin notes column: fills wide screens with intent, ledger-style.
class _MarginNotes extends StatelessWidget {
  const _MarginNotes();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Padding(
        padding: const EdgeInsets.only(top: 118),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: PuduuColors.card,
            border: Border.all(color: PuduuColors.line),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('MARGIN NOTES',
                  style: PuduuType.eyebrow()),
              const SizedBox(height: 10),
              _note('Energy peaks before noon. Heavy work goes first.'),
              const Divider(height: 24),
              _note('One reset beats one more scroll. Two minutes counts.'),
              const Divider(height: 24),
              _note('Done is a direction, not a streak.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _note(String s) => Text(s,
      style: const TextStyle(
          fontFamily: 'Fraunces',
          fontSize: 13.5,
          fontStyle: FontStyle.italic,
          height: 1.5,
          color: PuduuColors.mute));
}

// ---------- editorial primitives (v5: ledger, not cards) ----------

class LedgerHead extends StatelessWidget {
  final String eyebrow;
  final String headline;
  final String standfirst;
  const LedgerHead(
      {super.key,
      required this.eyebrow,
      required this.headline,
      required this.standfirst});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow.toUpperCase(), style: PuduuType.eyebrow()),
        const SizedBox(height: 7),
        Text(headline,
            style: PuduuType.display
                .copyWith(fontSize: 30, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(standfirst,
            style: PuduuType.meta.copyWith(fontSize: 13.5)),
        const SizedBox(height: 14),
        const Divider(height: 1),
      ],
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
      padding: const EdgeInsets.only(top: 24, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(label.toUpperCase(), style: PuduuType.eyebrow()),
          if (action != null)
            TextButton(onPressed: onAction ?? () {}, child: Text(action!)),
        ],
      ),
    );
  }
}

/// The "now" panel: one ruled panel, hairline progress, single ink button.
class NowPanel extends StatelessWidget {
  const NowPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: PuduuColors.card,
        border: Border.all(color: PuduuColors.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('NOW', style: PuduuType.eyebrow(PuduuColors.emberDeep)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('09:00 · 50 min · step 2 of 4',
                    style: PuduuType.meta)),
            ],
          ),
          const SizedBox(height: 7),
          const Text('Deep work: portfolio',
              style: TextStyle(
                  fontFamily: 'Fraunces',
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                  color: PuduuColors.ink,
                  height: 1.25)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: const LinearProgressIndicator(
              value: 0.61,
              minHeight: 4,
              backgroundColor: PuduuColors.paperDeep,
              valueColor:
                  AlwaysStoppedAnimation(PuduuColors.ember),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PuduuColors.ink,
                    backgroundColor: PuduuColors.emberWash,
                    side: const BorderSide(
                        color: PuduuColors.emberDeep, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    textStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                  onPressed: () {},
                  icon: const Icon(PuduuIcons.play, size: 18),
                  label: const Text('Begin session'),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Skip'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One ledger line: tabular time gutter, hairline marker, text, status.
class DayLine extends StatelessWidget {
  final String hour;
  final String span;
  final PuduuTask task;
  final bool current;
  const DayLine(
      {super.key,
      required this.hour,
      required this.span,
      required this.task,
      this.current = false});
  @override
  Widget build(BuildContext context) {
    final done = task.status == 'done';
    final timeStyle = PuduuType.tabular.copyWith(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: done ? PuduuColors.faint : PuduuColors.ink,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(hour, style: timeStyle),
                const SizedBox(height: 2),
                Text(span,
                    style: PuduuType.tabular.copyWith(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: PuduuColors.faint)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              const SizedBox(height: 3),
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? PuduuColors.moss
                      : current
                          ? PuduuColors.ember
                          : Colors.transparent,
                  border: Border.all(
                    color: done
                        ? PuduuColors.moss
                        : current
                            ? PuduuColors.ember
                            : PuduuColors.faint,
                    width: 1.6,
                  ),
                ),
              ),
              Container(
                  width: 2.5,
                  height: 34,
                  color: PuduuColors.paperDeep),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: done
                            ? PuduuColors.faint
                            : PuduuColors.ink,
                        decoration:
                            done ? TextDecoration.lineThrough : null,
                        decorationColor: PuduuColors.faint,
                        height: 1.35)),
                if (task.note != null) ...[
                  const SizedBox(height: 2),
                  Text(task.note!,
                      style: PuduuType.meta
                          .copyWith(color: PuduuColors.faint)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: done
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PuduuIcons.check,
                          size: 15, color: PuduuColors.moss),
                      SizedBox(width: 4),
                      Text('Done',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: PuduuColors.moss)),
                    ],
                  )
                : current
                    ? TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {},
                        child: const Text('Begin'),
                      )
                    : Text('${task.durationMin ?? 25} min',
                        style: PuduuType.tabular.copyWith(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: PuduuColors.faint)),
          ),
        ],
      ),
    );
  }
}

/// Ruled option row for Reset / Progress / Yours (replaces pastel cards).
class RuleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final String? trailing;
  final VoidCallback? onTap;
  const RuleRow(
      {super.key,
      required this.icon,
      required this.title,
      required this.detail,
      this.trailing,
      this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon, size: 20, color: PuduuColors.inkSoft),
            ),
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
            const SizedBox(width: 8),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(trailing!,
                    style: PuduuType.tabular.copyWith(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: PuduuColors.faint)),
              ),
          ],
        ),
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
    const spans = ['25m', '50m', '15m', '30m'];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
      children: [
        const LedgerHead(
          eyebrow: 'Thursday · September 25',
          headline: 'Good morning, Alex.',
          standfirst: 'Four blocks planned. One thing at a time.',
        ),
        const NowPanel(),
        const SectionHead(label: 'The day', action: 'See all'),
        for (var i = 0; i < today.length; i++) ...[
          DayLine(
            hour: hours[i % hours.length],
            span: spans[i % spans.length],
            task: today[i],
            current: i == 1 && today[i].status != 'done',
          ),
          if (i < today.length - 1) const Divider(height: 1),
        ],
        SectionHead(
            label: 'Inbox',
            action: inbox.isEmpty ? null : '${inbox.length} waiting'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                          controller: ctl,
                          decoration: const InputDecoration(
                              hintText:
                                  'Capture a task, idea, or reminder…')),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: PuduuColors.ember,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (ctl.text.trim().isEmpty) return;
                        ref.read(inboxProvider.notifier).state = [
                          ...inbox,
                          PuduuTask(
                              id: _uuid.v4(),
                              title: ctl.text.trim()),
                        ];
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
                      foregroundColor: PuduuColors.emberDeep,
                      side: const BorderSide(
                          color: PuduuColors.emberDeep, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 13),
                      textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700),
                    ),
                    onPressed: () async {
                      final planned =
                          await ref.read(aiProvider).plan(inbox);
                      ref.read(todayProvider.notifier).state =
                          planned;
                      ref.read(inboxProvider.notifier).state = [];
                    },
                    icon: const Icon(PuduuIcons.sort, size: 17),
                    label: const Text('Sort into my day'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        for (final t in inbox) ...[
          RuleRow(
              icon: PuduuIcons.calendar,
              title: t.title,
              detail: '${t.durationMin ?? 10} min · unsorted'),
          const Divider(height: 1),
        ],
        const SectionHead(label: 'If you stall'),
        const RuleRow(
            icon: PuduuIcons.reset,
            title: 'Take a two-minute reset',
            detail: 'Water, air, one small surface.',
            trailing: '2 min'),
      ],
    );
  }
}

class FocusPage extends StatelessWidget {
  const FocusPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
      children: [
        const LedgerHead(
          eyebrow: 'Focus session',
          headline: 'Stay with it.',
          standfirst: 'Deep work: portfolio · step 2 of 4.',
        ),
        const SizedBox(height: 26),
        Center(
          child: Column(
            children: [
              const Text('32:10',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 76,
                      fontWeight: FontWeight.w600,
                      fontFeatures: [
                        FontFeature.tabularFigures()
                      ],
                      color: PuduuColors.ink,
                      height: 1.0)),
              const SizedBox(height: 8),
              Text('MINUTES LEFT · GENTLE CHIME AT THE END',
                  textAlign: TextAlign.center,
                  style: PuduuType.eyebrow()),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: const LinearProgressIndicator(
                  value: 0.36,
                  minHeight: 4,
                  backgroundColor: PuduuColors.paperDeep,
                  valueColor: AlwaysStoppedAnimation(
                      PuduuColors.ember),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Sketch the hero section. Phone in another room.',
                  textAlign: TextAlign.center,
                  style: PuduuType.meta),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(PuduuIcons.pause, size: 18),
                    label: const Text('Pause'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PuduuColors.ink,
                      side: const BorderSide(
                          color: PuduuColors.line),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {},
                    child: const Text('End early'),
                  ),
                ],
              ),
            ],
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
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
      children: const [
        LedgerHead(
            eyebrow: 'Freeze reset',
            headline: 'Hit a wall?',
            standfirst: 'Two minutes counts. Pick the smallest one.'),
        SizedBox(height: 10),
        RuleRow(
            icon: PuduuIcons.drop,
            title: 'Drink a glass of water',
            detail: 'Stand up, sip slowly, look far away.',
            trailing: '2 min'),
        Divider(height: 1),
        RuleRow(
            icon: PuduuIcons.walk,
            title: 'Clear one surface',
            detail: 'Just the desk corner. Nothing more.',
            trailing: '2 min'),
        Divider(height: 1),
        RuleRow(
            icon: PuduuIcons.mail,
            title: 'Open the difficult email',
            detail: 'Read it only. Reply comes later.',
            trailing: '2 min'),
        Divider(height: 1),
        RuleRow(
            icon: PuduuIcons.sort,
            title: 'Sort the inbox',
            detail: 'Rule-based now, assisted later.',
            trailing: '3 min'),
      ],
    );
  }
}

class GrowsPage extends StatelessWidget {
  const GrowsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
      children: const [
        LedgerHead(
            eyebrow: 'Progress',
            headline: 'Keep growing.',
            standfirst: 'Good days: 5 of 7. Never resets to zero.'),
        SizedBox(height: 10),
        RuleRow(
            icon: PuduuIcons.grows,
            title: 'Weekly shelf',
            detail: 'Early starter ×3 · Reset used ×5 · Focus 25m ×8.',
            trailing: 'W39'),
        Divider(height: 1),
        RuleRow(
            icon: PuduuIcons.focus,
            title: 'Focus trend',
            detail: 'Up 20% vs last week. Mornings work best.',
            trailing: '+20%'),
        Divider(height: 1),
        RuleRow(
            icon: PuduuIcons.reset,
            title: 'Resets that worked',
            detail: 'Water first, then air. Evenings stay hard.',
            trailing: '×5'),
      ],
    );
  }
}

class YoursPage extends StatelessWidget {
  const YoursPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
      children: const [
        LedgerHead(
            eyebrow: 'Settings',
            headline: 'Make it yours.',
            standfirst: 'Plan, sounds, reminders, and backup.'),
        SizedBox(height: 10),
        RuleRow(
            icon: PuduuIcons.crown,
            title: 'Puduu Pro · \$6.99/mo',
            detail: 'Unlimited resets · yearly \$49.99.'),
        Divider(height: 1),
        RuleRow(
            icon: PuduuIcons.bell,
            title: 'Gentle nudges',
            detail: 'Max 6 per day · quiet 22:00–07:00.',
            trailing: 'On'),
        Divider(height: 1),
        RuleRow(
            icon: PuduuIcons.sound,
            title: 'Sounds and haptics',
            detail: 'Calm chime · soft vibration.',
            trailing: 'On'),
      ],
    );
  }
}
