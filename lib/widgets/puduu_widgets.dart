import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme/puduu_theme.dart';
import '../main.dart' show syncProvider, syncLiveProvider, bumpTasks;

// ---------- cloud status line: green dot + CLOUD / grey dot + LOCAL ----------

class SyncLine extends ConsumerWidget {
  const SyncLine({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(syncLiveProvider);
    final dot = live == true ? PuduuColors.teal : PuduuColors.mute;
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
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: dot)),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: PuduuColors.tealDeep)),
        ],
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
                  style: PuduuType.display.copyWith(fontSize: 23)),
              const SizedBox(height: 2),
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

/// Controller-less search box (used on pages without a stateful controller).
class SearchField2 extends StatelessWidget {
  final String hint;
  const SearchField2({super.key, required this.hint});
  @override
  Widget build(BuildContext context) {
    return TextField(
        decoration: InputDecoration(
            hintText: hint,
            prefixIcon:
                const Icon(PuduuIcons.search, color: PuduuColors.mute)));
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
                  onPressed: onSecondary ?? () {},
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
    final card = Card(
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
              TextButton(
                onPressed: onSideTap ?? onTap ?? () {},
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(side!,
                    style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: sideDone
                            ? PuduuColors.moss
                            : PuduuColors.tealDeep)),
              ),
          ],
        ),
      ),
    );
    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
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
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop()),
        title: Text(title, style: PuduuType.title.copyWith(fontSize: 17)),
      ),
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: child))),
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
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => SubShell(title: title, child: page))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: PuduuColors.tealWash,
                    borderRadius: BorderRadius.circular(12)),
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
