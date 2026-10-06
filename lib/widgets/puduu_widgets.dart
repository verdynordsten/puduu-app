import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme/puduu_theme.dart';
import 'package:drift/drift.dart' show Value;
import '../core/models.dart';
import '../core/db/repo.dart';
import '../main.dart' show syncProvider, syncLiveProvider, bumpTasks;

// =====================================================================
// Aurora Gloss primitives
// =====================================================================

/// Soft radial color wash, no blur filter needed (cheap + soft).
class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob(this.color, this.size);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withAlpha(0)],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

/// Page background: base color + three aurora washes.
class AuroraBackground extends StatelessWidget {
  final Widget child;
  const AuroraBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: PuduuColors.bg),
        const Positioned(
            top: -90, left: -70, child: _Blob(PuduuGloss.blobMint, 300)),
        const Positioned(
            top: 140, right: -80, child: _Blob(PuduuGloss.blobPeach, 250)),
        const Positioned(
            bottom: -70, left: 30, child: _Blob(PuduuGloss.blobLilac, 270)),
        child,
      ],
    );
  }
}

/// Glossy white card: sheen gradient, hairline glass border, tinted shadow.
class GlossCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color tint;
  final VoidCallback? onTap;
  const GlossCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.tint = PuduuColors.teal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: PuduuGloss.cardSheen,
        borderRadius: BorderRadius.circular(PuduuGloss.rCard),
        border: Border.all(color: PuduuGloss.glassBorder),
        boxShadow: PuduuGloss.cardShadow(tint),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PuduuGloss.rCard - 2),
        child: Stack(
          children: [
            child,
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: PuduuGloss.topSheen,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(PuduuGloss.rCard),
      onTap: onTap,
      child: card,
    );
  }
}

/// Gradient pill button with gloss + glow. Set [ghost] for the glass
/// secondary style, [light] for the white pill used on dark heroes.
class GlossButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool ghost;
  final bool light;
  final bool expanded;
  const GlossButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.ghost = false,
    this.light = false,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final labelColor = light
        ? PuduuColors.tealDeep
        : (ghost ? Colors.white : Colors.white);
    final body = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: light
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Color(0xFFE6F4F1)],
              )
            : ghost
                ? null
                : (enabled
                    ? PuduuGloss.btnTeal
                    : const LinearGradient(
                        colors: [Color(0xFFB9CDC9), Color(0xFF9DB5B1)])),
        color: ghost && !light ? Colors.white.withAlpha(38) : null,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(light ? 140 : 70)),
        boxShadow: (ghost && !light) || !enabled
            ? null
            : [
                BoxShadow(
                  color: (light ? Colors.white : PuduuColors.teal)
                      .withAlpha(light ? 90 : 110),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Stack(
        children: [
          Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: labelColor),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: enabled ? labelColor : labelColor.withAlpha(180),
                  ),
                ),
              ),
            ],
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: PuduuGloss.topSheen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    final btn = expanded
        ? SizedBox(width: double.infinity, child: body)
        : body;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: btn,
        ),
      ),
    );
  }
}

/// Glossy gradient icon tile (category tiles, nav rows, task icons).
class GlossTile extends StatelessWidget {
  final IconData icon;
  final Gradient gradient;
  final double size;
  final Color shadowTint;
  const GlossTile({
    super.key,
    required this.icon,
    required this.gradient,
    this.size = 44,
    this.shadowTint = PuduuColors.teal,
  });

  /// Build a glossy tile from a flat wash color (keeps old call-sites alive).
  factory GlossTile.fromColor({
    Key? key,
    required IconData icon,
    required Color color,
    double size = 44,
  }) {
    final light = Color.lerp(color, Colors.white, 0.35) ?? color;
    return GlossTile(
      key: key,
      icon: icon,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color, light],
      ),
      size: size,
      shadowTint: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(PuduuGloss.rTile),
        border: Border.all(color: Colors.white.withAlpha(90)),
        boxShadow: [
          BoxShadow(
            color: shadowTint.withAlpha(70),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(child: Icon(icon, size: size * 0.44, color: Colors.white)),
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: PuduuGloss.topSheen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient progress bar with a glowing tip.
class GlossBar extends StatelessWidget {
  final double value;
  final double height;
  final Gradient gradient;
  final Color track;
  const GlossBar({
    super.key,
    required this.value,
    this.height = 8,
    this.gradient = PuduuGloss.barTeal,
    this.track = const Color(0x29FFFFFF),
  });
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: Stack(
        children: [
          Container(height: height, color: track),
          FractionallySizedBox(
            widthFactor: value.clamp(0.02, 1.0),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(99),
                boxShadow: [
                  BoxShadow(
                    color: PuduuColors.mint.withAlpha(120),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Frosted glass pill (tags, search, nav).
class GlassPill extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const GlassPill({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
  });
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(PuduuGloss.rPill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: PuduuGloss.glassWhite,
            borderRadius: BorderRadius.circular(PuduuGloss.rPill),
            border: Border.all(color: PuduuGloss.glassBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ---------- cloud status line: green dot + CLOUD / grey dot + LOCAL ----------

class SyncLine extends ConsumerWidget {
  const SyncLine({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(syncLiveProvider);
    final dot = live == true ? PuduuColors.mint : PuduuColors.mute;
    final label = live == null
        ? 'Syncing…'
        : live
            ? '◉ Morning plan · Cloud'
            : '◉ Morning plan · Local';
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
      child: GlassPill(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dot,
                    boxShadow: [
                      BoxShadow(
                          color: dot.withAlpha(140),
                          blurRadius: 6)
                    ])),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Work Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: PuduuColors.tealDeep)),
          ],
        ),
      ),
    );
  }
}

class HelloHead extends ConsumerWidget {
  final String hello;
  final String sub;
  final bool showBell;
  final bool showSync;
  const HelloHead(
      {super.key,
      required this.hello,
      required this.sub,
      this.showBell = false,
      this.showSync = false});
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
                  style: PuduuType.display.copyWith(fontSize: 26)),
              const SizedBox(height: 4),
              if (!showSync)
                Text(sub,
                    style: const TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: PuduuColors.tealDeep)),
              if (showSync) const SyncLine(),
            ],
          ),
        ),
        if (showBell) ...[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: PuduuGloss.cardSheen,
              border: Border.all(color: PuduuGloss.glassBorder),
              shape: BoxShape.circle,
              boxShadow: PuduuGloss.cardShadow(),
            ),
            child: const Badge(
              isLabelVisible: true,
              backgroundColor: PuduuColors.danger,
              smallSize: 8,
              child: Icon(PuduuIcons.bell,
                  size: 20, color: PuduuColors.soft),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: PuduuGloss.btnTeal,
            boxShadow: PuduuGloss.glow(PuduuColors.teal),
          ),
          child: Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: PuduuGloss.btnTeal,
            ),
            child: const Text('A',
                style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ),
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
        borderRadius: BorderRadius.circular(PuduuGloss.rInput),
        boxShadow: PuduuGloss.cardShadow(),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon:
              const Icon(PuduuIcons.search, color: PuduuColors.teal),
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
        borderRadius: BorderRadius.circular(PuduuGloss.rInput),
        boxShadow: PuduuGloss.cardShadow(),
      ),
      child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
              hintText: hint,
              prefixIcon:
                  const Icon(PuduuIcons.search, color: PuduuColors.teal))),
    );
  }
}

class SectionHead extends StatelessWidget {
  final String label;
  final String? action;
  final VoidCallback? onAction;
  const SectionHead(
      {super.key, required this.label, this.action, this.onAction});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
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

/// Aurora hero: deep teal gradient + light blobs + glass sheen + glow.
class DarkHero extends StatelessWidget {
  final String tag;
  final String title;
  final String meta;
  final double progress;
  final String primary;
  final String secondary;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  const DarkHero(
      {super.key,
      required this.tag,
      required this.title,
      required this.meta,
      required this.progress,
      required this.primary,
      required this.secondary,
      this.onPrimary,
      this.onSecondary});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        gradient: PuduuGloss.heroTeal,
        borderRadius: BorderRadius.circular(PuduuGloss.rHero),
        border: Border.all(color: Colors.white.withAlpha(70)),
        boxShadow: PuduuGloss.glow(PuduuColors.teal),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PuduuGloss.rHero),
        child: Stack(
          children: [
            const Positioned(
                top: -50, right: -30, child: _Blob(Color(0x402DD4BF), 190)),
            const Positioned(
                bottom: -60,
                left: -40,
                child: _Blob(Color(0x300B6B5F), 200)),
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: PuduuGloss.topSheen,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(36),
                      borderRadius:
                          BorderRadius.circular(PuduuGloss.rPill),
                      border:
                          Border.all(color: Colors.white.withAlpha(80)),
                    ),
                    child: Text(tag,
                        style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.6,
                            color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  Text(title,
                      style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                          letterSpacing: -0.3)),
                  const SizedBox(height: 4),
                  Text(meta,
                      style: TextStyle(
                          fontFamily: 'Work Sans',
                          fontSize: 12.5,
                          color: Colors.white.withAlpha(200))),
                  const SizedBox(height: 14),
                  GlossBar(
                    value: progress,
                    height: 8,
                    gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFF2DD4BF)]),
                    track: Colors.white.withAlpha(48),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GlossButton(
                          label: primary,
                          icon: PuduuIcons.play,
                          onPressed: onPrimary,
                          light: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GlossButton(
                          label: secondary,
                          onPressed: onSecondary,
                          ghost: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
  const TaskCard(
      {super.key,
      required this.dot,
      required this.title,
      required this.detail,
      this.side,
      this.sideDone = false,
      this.icon,
      this.tile,
      this.onTap,
      this.onSideTap});
  @override
  Widget build(BuildContext context) {
    final card = GlossCard(
      tint: icon != null ? (tile ?? PuduuColors.teal) : dot,
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          if (icon != null)
            GlossTile.fromColor(
                icon: icon, color: tile ?? PuduuColors.teal, size: 42)
          else
            Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [
                      Color.lerp(dot, Colors.white, 0.25) ?? dot,
                      dot
                    ]),
                    boxShadow: [
                      BoxShadow(
                          color: dot.withAlpha(110), blurRadius: 8)
                    ])),
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
          if (side != null)
            GestureDetector(
              onTap: onSideTap ?? onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  gradient: sideDone
                      ? const LinearGradient(colors: [
                          Color(0xFF65A30D),
                          Color(0xFF4D7C0F)
                        ])
                      : PuduuGloss.btnTeal,
                  borderRadius:
                      BorderRadius.circular(PuduuGloss.rPill),
                  border:
                      Border.all(color: Colors.white.withAlpha(70)),
                  boxShadow: [
                    BoxShadow(
                      color: (sideDone
                              ? PuduuColors.moss
                              : PuduuColors.teal)
                          .withAlpha(80),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(side!,
                    style: const TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
        ],
      ),
    );
    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(PuduuGloss.rCard),
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
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(8, 8, 16, 4),
                child: Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () =>
                            Navigator.of(context).pop()),
                    Expanded(
                      child: Text(title,
                          style: PuduuType.title
                              .copyWith(fontSize: 18)),
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
  final String title, detail;
  final Widget page;
  const NavRow(
      {super.key,
      required this.icon,
      required this.title,
      required this.detail,
      required this.page});
  @override
  Widget build(BuildContext context) {
    return GlossCard(
      padding: const EdgeInsets.all(13),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SubShell(title: title, child: page))),
      child: Row(
        children: [
          GlossTile.fromColor(
              icon: icon, color: PuduuColors.teal, size: 42),
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
          const Icon(Icons.chevron_right, color: PuduuColors.mute),
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
    builder: (ctx) => _TaskSheet(repo: repo, task: task, onChanged: onChanged),
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
    PuduuColors.teal,
    PuduuColors.amber,
    PuduuColors.moss,
    PuduuColors.tealDeep,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: PuduuGloss.cardSheen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: PuduuGloss.glassBorder)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          Color(0xFF2DD4BF),
                          Color(0xFF0E9384)
                        ]),
                        borderRadius: BorderRadius.circular(3))),
              ),
              const SizedBox(height: 14),
              TextField(
                  controller: _titleCtl,
                  style: PuduuType.title.copyWith(fontSize: 19),
                  decoration:
                      const InputDecoration(hintText: 'Task title')),
              const SizedBox(height: 8),
              TextField(
                  controller: _noteCtl,
                  style: PuduuType.body,
                  decoration:
                      const InputDecoration(hintText: 'Note (optional)')),
              const SizedBox(height: 14),
              Text('DURATION', style: PuduuType.label()),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final m in [5, 10, 15, 25, 50])
                    ChoiceChip(
                      label: Text('${m}m'),
                      selected: _minutes == m,
                      selectedColor: PuduuColors.teal,
                      labelStyle: TextStyle(
                          color: _minutes == m
                              ? Colors.white
                              : PuduuColors.soft,
                          fontWeight: FontWeight.w600),
                      onSelected: (_) => setState(() => _minutes = m),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text('CLOCK TIME', style: PuduuType.label()),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.schedule, size: 17),
                      label: Text(_at == null
                          ? 'No time — inbox'
                          : DateFormat('EEE HH:mm').format(_at!)),
                      onPressed: () async {
                        final now = DateTime.now();
                        final t = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                                _at ?? now));
                        if (t == null) return;
                        setState(() => _at = DateTime(
                            now.year, now.month, now.day, t.hour, t.minute));
                      },
                    ),
                  ),
                  if (_at != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.clear,
                          color: PuduuColors.mute),
                      onPressed: () => setState(() => _at = null),
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
                        width: 38,
                        height: 38,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [
                            Color.lerp(_dots[i], Colors.white, 0.25) ??
                                _dots[i],
                            _dots[i]
                          ]),
                          border: Border.all(
                              color: _color == i
                                  ? PuduuColors.dark
                                  : Colors.white.withAlpha(90),
                              width: _color == i ? 2.4 : 1.2),
                          boxShadow: [
                            BoxShadow(
                                color: _dots[i].withAlpha(80),
                                blurRadius: 10)
                          ],
                        ),
                        child: _color == i
                            ? const Icon(Icons.check,
                                size: 17, color: Colors.white)
                            : null,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text('SUBTASKS (${_subs.where((s) => s.done).length}/${_subs.length})',
                  style: PuduuType.label()),
              const SizedBox(height: 8),
              for (final s in _subs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await _repo.toggleSubtask(s.id, !s.done);
                          setState(() {
                            final i = _subs
                                .indexWhere((e) => e.id == s.id);
                            _subs[i] = PuduuSubtask(
                                id: s.id,
                                title: s.title,
                                timerMin: s.timerMin,
                                done: !s.done);
                          });
                          await widget.onChanged();
                        },
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: s.done
                                ? const LinearGradient(colors: [
                                    Color(0xFF2DD4BF),
                                    Color(0xFF0E9384)
                                  ])
                                : null,
                            color: s.done ? null : Colors.white,
                            border: Border.all(
                                color: s.done
                                    ? Colors.transparent
                                    : PuduuColors.line,
                                width: 1.6),
                            boxShadow: s.done
                                ? [
                                    BoxShadow(
                                        color: PuduuColors.teal
                                            .withAlpha(90),
                                        blurRadius: 8)
                                  ]
                                : null,
                          ),
                          child: s.done
                              ? const Icon(Icons.check,
                                  size: 15, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(s.title,
                              style: s.done
                                  ? PuduuType.meta.copyWith(
                                      decoration:
                                          TextDecoration.lineThrough)
                                  : PuduuType.body)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 19, color: PuduuColors.mute),
                        onPressed: () async {
                          await _repo.deleteSubtask(s.id);
                          setState(() => _subs
                              .removeWhere((e) => e.id == s.id));
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
                  GlossTile.fromColor(
                      icon: PuduuIcons.plus,
                      color: PuduuColors.teal,
                      size: 42),
                ],
              ),
              const SizedBox(height: 16),
              GlossButton(
                  label: 'Save changes',
                  expanded: true,
                  onPressed: _save),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.check, size: 17),
                      label: const Text('Mark done'),
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
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: PuduuColors.danger),
                      icon: const Icon(Icons.delete_outline, size: 17),
                      label: const Text('Delete'),
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
