import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme/puduu_theme.dart';
import 'package:drift/drift.dart' show Value;
import '../core/models.dart';
import '../core/db/repo.dart';
import '../main.dart' show syncProvider, syncLiveProvider, bumpTasks;

// =====================================================================
// Candy Pop primitives
// =====================================================================

/// Cream canvas with a subtle dot grid + a few floating candy shapes.
class PopBackground extends StatelessWidget {
  final Widget child;
  const PopBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: PuduuColors.cream),
        const Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: _DotPainter())),
        ),
        const Positioned(
            top: -40, right: -30, child: _CandyShape(PuduuColors.blush, 120)),
        const Positioned(
            top: 220, left: -50, child: _CandyShape(PuduuColors.butter, 150)),
        const Positioned(
            bottom: -40,
            right: 60,
            child: _CandyShape(PuduuColors.lilac, 130)),
        child,
      ],
    );
  }
}

class _DotPainter extends CustomPainter {
  const _DotPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = PuduuColors.clay.withAlpha(38);
    const gap = 34.0;
    for (var y = gap / 2; y < size.height; y += gap) {
      for (var x = gap / 2; x < size.width; x += gap) {
        canvas.drawCircle(Offset(x, y), 2.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CandyShape extends StatelessWidget {
  final Color color;
  final double size;
  const _CandyShape(this.color, this.size);
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.35,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withAlpha(130),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(
              color: PuduuColors.ink.withAlpha(40), width: 3),
        ),
      ),
    );
  }
}

/// Chunky card: paper white, 3px ink border, hard offset shadow.
class PopCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final VoidCallback? onTap;
  const PopCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = PuduuColors.paper,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(PopStyle.rCard),
        border: PopStyle.inkBorder(),
        boxShadow: PopStyle.hardShadow(),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(PopStyle.rCard),
      onTap: onTap,
      child: card,
    );
  }
}

/// Chunky button: bold color, 3px ink border, hard shadow, Baloo 2 label.
class PopButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final bool expanded;
  final bool small;
  const PopButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color = PuduuColors.coral,
    this.textColor = Colors.white,
    this.expanded = false,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final iconData = icon;
    final body = Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 14 : 22, vertical: small ? 9 : 14),
      decoration: BoxDecoration(
        color: enabled ? color : PuduuColors.clay.withAlpha(120),
        borderRadius: BorderRadius.circular(small ? 14 : 20),
        border: PopStyle.inkBorder(small ? 2.5 : 3),
        boxShadow:
            enabled ? PopStyle.hardShadow(dx: 4, dy: 4) : null,
      ),
      child: Row(
        mainAxisSize:
            expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconData != null) ...[
            Icon(iconData,
                size: small ? 16 : 20, color: textColor),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Baloo2',
                fontSize: small ? 13 : 15,
                fontWeight: FontWeight.w800,
                color: enabled
                    ? textColor
                    : Colors.white.withAlpha(200),
              ),
            ),
          ),
        ],
      ),
    );
    final btn =
        expanded ? SizedBox(width: double.infinity, child: body) : body;
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(small ? 14 : 20),
          onTap: onPressed,
          child: btn,
        ),
      ),
    );
  }
}

/// Chunky icon tile: loud color, ink border, mini hard shadow.
class PopTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const PopTile({
    super.key,
    required this.icon,
    required this.color,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(PopStyle.rTile),
        border: PopStyle.inkBorder(2.5),
        boxShadow: PopStyle.hardShadow(dx: 3, dy: 3),
      ),
      child: Icon(icon, size: size * 0.46, color: Colors.white),
    );
  }
}

/// Thick striped progress bar — pure Duolingo energy.
class PopBar extends StatelessWidget {
  final double value;
  final Color fill;
  final double height;
  const PopBar({
    super.key,
    required this.value,
    this.fill = PuduuColors.sun,
    this.height = 18,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: PuduuColors.paper,
        borderRadius: BorderRadius.circular(PopStyle.rPill),
        border: Border.all(color: PuduuColors.ink, width: 2.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PopStyle.rPill),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: value.clamp(0.03, 1.0),
              child: Container(color: fill),
            ),
            const Positioned.fill(
              child: IgnorePointer(
                  child: CustomPaint(painter: _StripePainter())),
            ),
          ],
        ),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  const _StripePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(70)
      ..strokeWidth = 7;
    for (var x = -size.height; x < size.width + size.height; x += 22) {
      canvas.drawLine(Offset(x, size.height + 4),
          Offset(x + size.height, -4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Rotated sticker badge — the playful signature element.
class Sticker extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final double rotate;
  /// When true, the sticker fills the available width and the label
  /// shrinks to fit (never grows the sticker). Use for labels of
  /// varying length that must look uniform side by side.
  final bool expand;
  const Sticker({
    super.key,
    required this.text,
    this.color = PuduuColors.sun,
    this.textColor = PuduuColors.ink,
    this.rotate = -0.1,
    this.expand = false,
  });
  @override
  Widget build(BuildContext context) {
    final label = Text(text,
        textAlign: TextAlign.center,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontFamily: 'Baloo2',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: textColor));
    return Transform.rotate(
      angle: rotate,
      child: Container(
        width: expand ? double.infinity : null,
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(PopStyle.rPill),
          border: Border.all(color: PuduuColors.ink, width: 2.5),
          boxShadow: PopStyle.hardShadow(dx: 3, dy: 3),
        ),
        child: expand
            ? FittedBox(fit: BoxFit.scaleDown, child: label)
            : label,
      ),
    );
  }
}

// ---------- cloud status: chunky sticker ----------

class SyncLine extends ConsumerWidget {
  const SyncLine({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(syncLiveProvider);
    final label = live == null
        ? 'SYNCING…'
        : live
            ? '● CLOUD'
            : '● LOCAL';
    return GestureDetector(
      onTap: () async {
        final r = await ref.read(syncProvider).syncAll();
        ref.read(syncLiveProvider.notifier).state = r.live;
        bumpTasks(ref);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(r.describe()),
              duration: const Duration(seconds: 2)));
        }
      },
      child: Sticker(
        text: label,
        color: live == true ? PuduuColors.frost : PuduuColors.butter,
        rotate: -0.06,
      ),
    );
  }
}

class HelloHead extends ConsumerWidget {
  final String hello;
  final String sub;
  final bool showBell;
  final bool showSync;
  final Color accent;
  const HelloHead({
    super.key,
    required this.hello,
    required this.sub,
    this.showBell = false,
    this.showSync = false,
    this.accent = PuduuColors.coral,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(hello,
                  style:
                      PuduuType.display.copyWith(fontSize: 30)),
              const SizedBox(height: 6),
              if (!showSync)
                Sticker(
                    text: sub.toUpperCase(),
                    color: PuduuColors.butter,
                    rotate: -0.04)
              else
                const SyncLine(),
            ],
          ),
        ),
        if (showBell) ...[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: PuduuColors.paper,
              border: PopStyle.inkBorder(2.5),
              shape: BoxShape.circle,
              boxShadow: PopStyle.hardShadow(dx: 3, dy: 3),
            ),
            child: const Badge(
              isLabelVisible: true,
              backgroundColor: PuduuColors.coral,
              smallSize: 9,
              child: Icon(PuduuIcons.bell,
                  size: 21, color: PuduuColors.ink),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ],
    );
  }
}

/// Time-aware greeting: Good morning / afternoon / evening + today's date.
String dayGreeting([DateTime? now]) {
  final h = (now ?? DateTime.now()).hour;
  if (h < 11) return 'Good morning';
  if (h < 15) return 'Good afternoon';
  if (h < 19) return 'Good evening';
  return 'Good night';
}

String daySubline([DateTime? now]) {
  final n = now ?? DateTime.now();
  return DateFormat('EEEE, d MMM').format(n);
}

class SearchField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  const SearchField(
      {super.key, required this.hint, this.controller, this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PopStyle.rInput),
        boxShadow: PopStyle.hardShadow(dx: 4, dy: 4),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(PuduuIcons.search,
              color: PuduuColors.coral),
        ),
      ),
    );
  }
}

/// Controller-less search box (used on pages without a stateful controller).
class SearchField2 extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  const SearchField2({super.key, required this.hint, this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PopStyle.rInput),
        boxShadow: PopStyle.hardShadow(dx: 4, dy: 4),
      ),
      child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Icon(PuduuIcons.search,
                  color: PuduuColors.coral))),
    );
  }
}

class SectionHead extends StatelessWidget {
  final String label;
  final String? action;
  final VoidCallback? onAction;
  final Color accent;
  const SectionHead({
    super.key,
    required this.label,
    this.action,
    this.onAction,
    this.accent = PuduuColors.coral,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 22,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: PuduuColors.ink, width: 2),
                ),
              ),
              const SizedBox(width: 8),
              Text(label.toUpperCase(),
                  style: PuduuType.label()),
            ],
          ),
          if (action != null)
            TextButton(
                onPressed: onAction ?? () {},
                child: Text(action!)),
        ],
      ),
    );
  }
}

/// Big loud hero: solid candy color, ink border, hard shadow, sticker tag.
class PopHero extends StatelessWidget {
  final String tag;
  final String title;
  final String meta;
  final double progress;
  final Color progressFill;
  final String primary;
  final String secondary;
  final IconData? primaryIcon;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final Color color;
  final Color tagColor;
  const PopHero({
    super.key,
    required this.tag,
    required this.title,
    required this.meta,
    required this.progress,
    this.progressFill = PuduuColors.sun,
    required this.primary,
    required this.secondary,
    this.primaryIcon,
    this.onPrimary,
    this.onSecondary,
    this.color = PuduuColors.coral,
    this.tagColor = PuduuColors.sun,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(PopStyle.rHero),
        border: PopStyle.inkBorder(),
        boxShadow: PopStyle.hardShadow(dx: 6, dy: 6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Sticker(text: tag.toUpperCase(), color: tagColor),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  fontFamily: 'Baloo2',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.08,
                  letterSpacing: -0.3)),
          const SizedBox(height: 6),
          Text(meta,
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withAlpha(235))),
          const SizedBox(height: 14),
          PopBar(value: progress, fill: progressFill, height: 20),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PopButton(
                  label: primary,
                  icon: primaryIcon,
                  onPressed: onPrimary,
                  color: PuduuColors.paper,
                  textColor: PuduuColors.ink,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PopButton(
                  label: secondary,
                  onPressed: onSecondary,
                  color: PuduuColors.ink,
                  textColor: Colors.white,
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
  final VoidCallback? onTap;
  final VoidCallback? onSideTap;
  const TaskCard({
    super.key,
    required this.dot,
    required this.title,
    required this.detail,
    this.side,
    this.sideDone = false,
    this.icon,
    this.tile,
    this.onTap,
    this.onSideTap,
  });
  @override
  Widget build(BuildContext context) {
    final iconData = icon;
    final sideText = side;
    final card = PopCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          if (iconData != null)
            PopTile(
                icon: iconData,
                color: tile ?? PuduuColors.coral,
                size: 46)
          else
            Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dot,
                    border: Border.all(
                        color: PuduuColors.ink, width: 2.5))),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: PuduuType.strong),
                const SizedBox(height: 3),
                Text(detail, style: PuduuType.meta),
              ],
            ),
          ),
          if (sideText != null)
            GestureDetector(
              onTap: onSideTap ?? onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sideDone
                      ? PuduuColors.mint
                      : PuduuColors.sun,
                  borderRadius:
                      BorderRadius.circular(PopStyle.rPill),
                  border: Border.all(
                      color: PuduuColors.ink, width: 2.5),
                  boxShadow: PopStyle.hardShadow(dx: 3, dy: 3),
                ),
                child: Text(sideText,
                    style: const TextStyle(
                        fontFamily: 'Baloo2',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: PuduuColors.ink)),
              ),
            ),
        ],
      ),
    );
    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(PopStyle.rCard),
      onTap: onTap,
      child: card,
    );
  }
}

class SubShell extends StatelessWidget {
  final String title;
  final Widget child;
  const SubShell({super.key, required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PopBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(8, 8, 16, 4),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: PuduuColors.paper,
                        shape: BoxShape.circle,
                        border: PopStyle.inkBorder(2.5),
                        boxShadow:
                            PopStyle.hardShadow(dx: 3, dy: 3),
                      ),
                      child: IconButton(
                          icon: const Icon(
                              Icons.arrow_back_rounded),
                          onPressed: () =>
                              Navigator.of(context).pop()),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(title,
                          style: PuduuType.title
                              .copyWith(fontSize: 21)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: 560),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, detail;
  final Widget page;
  const NavRow({
    super.key,
    required this.icon,
    this.iconColor = PuduuColors.coral,
    required this.title,
    required this.detail,
    required this.page,
  });
  @override
  Widget build(BuildContext context) {
    return PopCard(
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SubShell(title: title, child: page))),
      child: Row(
        children: [
          PopTile(icon: icon, color: iconColor, size: 46),
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
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: PuduuColors.sun,
              shape: BoxShape.circle,
              border:
                  Border.all(color: PuduuColors.ink, width: 2.5),
            ),
            child: const Icon(PuduuIcons.chevron,
                color: PuduuColors.ink, size: 18),
          ),
        ],
      ),
    );
  }
}

/// ---------- task detail sheet ----------
///
/// Bottom sheet opened from any TaskCard tap: edit title/note/duration/
/// clock time, toggle subtasks, add subtask, mark done, delete.
/// Every action writes drift immediately and calls [onChanged] so the
/// caller refreshes its providers (bumpTasks).
/// drift helpers: Value.absent() = leave unchanged, Value(null) = clear.
Value<String?> driftWrap(String s) => s.isEmpty ? const Value(null) : Value(s);
Value<T?> driftVal<T>(T? v) => v == null ? const Value(null) : Value(v);

Future<void> showTaskSheet(BuildContext context, PuduuRepo repo,
    PuduuTask task, Future<void> Function() onChanged) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) =>
        _TaskSheet(repo: repo, task: task, onChanged: onChanged),
  );
}

class _TaskSheet extends ConsumerStatefulWidget {
  final PuduuRepo repo;
  final PuduuTask task;
  final Future<void> Function() onChanged;
  const _TaskSheet(
      {required this.repo, required this.task, required this.onChanged});
  @override
  ConsumerState<_TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends ConsumerState<_TaskSheet> {
  late final TextEditingController _titleCtl;
  late final TextEditingController _noteCtl;
  late int _minutes;
  late DateTime? _at;
  late int _color;
  late List<PuduuSubtask> _subs;
  final _subCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleCtl = TextEditingController(text: widget.task.title);
    _noteCtl = TextEditingController(text: widget.task.note ?? '');
    _minutes = widget.task.durationMin ?? 25;
    _at = widget.task.scheduledAt;
    _color = widget.task.colorIndex;
    _subs = [...widget.task.subtasks];
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _noteCtl.dispose();
    _subCtl.dispose();
    super.dispose();
  }

  PuduuRepo get _repo => widget.repo;

  Future<void> _save() async {
    final title = _titleCtl.text.trim();
    if (title.isEmpty) return;
    final repo = widget.repo;
    await repo.updateTask(widget.task.id,
        title: title,
        note: driftWrap(_noteCtl.text.trim()),
        durationMin: driftVal(_minutes),
        scheduledAt: driftVal(_at),
        colorIndex: _color);
    await widget.onChanged();
    if (mounted) Navigator.of(context).pop();
  }

  static const _dots = [
    PuduuColors.coral,
    PuduuColors.sun,
    PuduuColors.grape,
    PuduuColors.mint,
    PuduuColors.sky,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PuduuColors.cream,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(32)),
        border: const Border(
          top: BorderSide(color: PuduuColors.ink, width: 3),
          left: BorderSide(color: PuduuColors.ink, width: 3),
          right: BorderSide(color: PuduuColors.ink, width: 3),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 56,
                    height: 10,
                    decoration: BoxDecoration(
                        color: PuduuColors.ink,
                        borderRadius: BorderRadius.circular(6))),
              ),
              const SizedBox(height: 14),
              TextField(
                  controller: _titleCtl,
                  style:
                      PuduuType.title.copyWith(fontSize: 21),
                  decoration: const InputDecoration(
                      hintText: 'Task title')),
              const SizedBox(height: 8),
              TextField(
                  controller: _noteCtl,
                  style: PuduuType.body,
                  decoration: const InputDecoration(
                      hintText: 'Note (optional)')),
              const SizedBox(height: 14),
              Text('DURATION', style: PuduuType.label()),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in [5, 10, 15, 25, 50])
                    GestureDetector(
                      onTap: () => setState(() => _minutes = m),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: _minutes == m
                              ? PuduuColors.sun
                              : PuduuColors.paper,
                          borderRadius: BorderRadius.circular(
                              PopStyle.rPill),
                          border: Border.all(
                              color: PuduuColors.ink,
                              width: 2.5),
                          boxShadow: _minutes == m
                              ? PopStyle.hardShadow(dx: 3, dy: 3)
                              : null,
                        ),
                        child: Text('${m}m',
                            style: const TextStyle(
                                fontFamily: 'Baloo2',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: PuduuColors.ink)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text('CLOCK TIME', style: PuduuType.label()),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: PopButton(
                      label: _at == null
                          ? 'No time — inbox'
                          : DateFormat('EEE HH:mm').format(_at!),
                      icon: Icons.schedule_rounded,
                      color: PuduuColors.paper,
                      textColor: PuduuColors.ink,
                      small: true,
                      onPressed: () async {
                        final now = DateTime.now();
                        final t = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                                _at ?? now));
                        if (t == null) return;
                        setState(() => _at = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            t.hour,
                            t.minute));
                      },
                    ),
                  ),
                  if (_at != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _at = null),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: PuduuColors.paper,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: PuduuColors.ink, width: 2.5),
                        ),
                        child: const Icon(Icons.clear_rounded,
                            color: PuduuColors.ink),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              Text('COLOR', style: PuduuType.label()),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (var i = 0; i < _dots.length; i++)
                    GestureDetector(
                      onTap: () => setState(() => _color = i),
                      child: Container(
                        width: 40,
                        height: 40,
                        margin:
                            const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _dots[i],
                          border: Border.all(
                              color: PuduuColors.ink,
                              width: _color == i ? 3.5 : 2.5),
                          boxShadow: _color == i
                              ? PopStyle.hardShadow(dx: 3, dy: 3)
                              : null,
                        ),
                        child: _color == i
                            ? const Icon(Icons.check_rounded,
                                size: 18,
                                color: Colors.white)
                            : null,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                  'SUBTASKS (${_subs.where((s) => s.done).length}/${_subs.length})',
                  style: PuduuType.label()),
              const SizedBox(height: 8),
              for (final s in _subs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final done = !s.done;
                          await _repo.toggleSubtask(s.id, done);
                          setState(() {
                            final i = _subs.indexWhere(
                                (e) => e.id == s.id);
                            _subs[i] = PuduuSubtask(
                                id: s.id,
                                title: s.title,
                                timerMin: s.timerMin,
                                done: done);
                          });
                          await widget.onChanged();
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: s.done
                                ? PuduuColors.mint
                                : PuduuColors.paper,
                            border: Border.all(
                                color: PuduuColors.ink,
                                width: 2.5),
                            boxShadow: s.done
                                ? PopStyle.hardShadow(dx: 2, dy: 2)
                                : null,
                          ),
                          child: s.done
                              ? const Icon(Icons.check_rounded,
                                  size: 16,
                                  color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(s.title,
                              style: s.done
                                  ? PuduuType.meta.copyWith(
                                      decoration: TextDecoration
                                          .lineThrough)
                                  : PuduuType.body)),
                      IconButton(
                        icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: PuduuColors.cocoa),
                        onPressed: () async {
                          await _repo.deleteSubtask(s.id);
                          setState(() => _subs.removeWhere(
                              (e) => e.id == s.id));
                          await widget.onChanged();
                        },
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subCtl,
                      decoration: const InputDecoration(
                          hintText: 'Add a subtask…'),
                      onSubmitted: (_) => _addSub(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopTile(
                      icon: PuduuIcons.plus,
                      color: PuduuColors.grape,
                      size: 46),
                ],
              ),
              const SizedBox(height: 16),
              PopButton(
                  label: 'Save changes',
                  expanded: true,
                  onPressed: _save),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: PopButton(
                      label: 'Mark done',
                      icon: Icons.check_rounded,
                      color: PuduuColors.mint,
                      textColor: PuduuColors.ink,
                      small: true,
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        await _repo.setTaskStatus(
                            widget.task.id, 'done');
                        await widget.onChanged();
                        nav.pop();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: PopButton(
                      label: 'Delete',
                      icon: Icons.delete_outline_rounded,
                      color: PuduuColors.paper,
                      textColor: PuduuColors.danger,
                      small: true,
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        await _repo.deleteTask(widget.task.id);
                        await widget.onChanged();
                        nav.pop();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addSub() async {
    final text = _subCtl.text.trim();
    if (text.isEmpty) return;
    final s = PuduuSubtask(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: text,
        timerMin: 5);
    await _repo.addSubtask(widget.task.id, s);
    setState(() {
      _subs.add(s);
      _subCtl.clear();
    });
    await widget.onChanged();
  }
}
