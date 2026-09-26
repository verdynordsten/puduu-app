import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/models.dart';
import '../../core/theme/puduu_theme.dart';
import '../../widgets/puduu_widgets.dart';
import '../../main.dart'
    show
        repoProvider,
        inboxProvider,
        todayProvider,
        timedProvider,
        aiProvider,
        bumpTasks;
import 'sub_pages.dart' show LibraryPageBody;

const _uuid = Uuid();

const _dotPalette = [
  PuduuColors.teal,
  PuduuColors.amber,
  PuduuColors.moss,
  PuduuColors.tealDeep,
];

String _clock(DateTime? dt) =>
    dt == null ? '—' : DateFormat('HH:mm').format(dt);

/// Visual timeline: real planned tasks with clock times, earliest first.
class TimelineStrip extends ConsumerWidget {
  const TimelineStrip({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timedAsync = ref.watch(timedProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: timedAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(
                child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4))),
          ),
          error: (_, _) =>
              const Text('Could not load timeline.', style: PuduuType.meta),
          data: (items) {
            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                    'Nothing scheduled yet — add a task with a time below.',
                    style: PuduuType.meta),
              );
            }
            return Column(
              children: [
                for (final t in items.take(6))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                            width: 40,
                            child: Text(_clock(t.scheduledAt),
                                style: PuduuType.meta)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Text(t.title,
                                          style: PuduuType.strong,
                                          overflow:
                                              TextOverflow.ellipsis)),
                                  if (t.status == 'done')
                                    const Text('✓',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: PuduuColors.moss,
                                            fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: t.status == 'done' ? 1.0 : 0.04,
                                  minHeight: 7,
                                  backgroundColor: PuduuColors.bg,
                                  valueColor: AlwaysStoppedAnimation(
                                      _dotPalette[t.colorIndex %
                                          _dotPalette.length]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class TodayPage extends ConsumerStatefulWidget {
  const TodayPage({super.key});
  @override
  ConsumerState<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends ConsumerState<TodayPage> {
  late final TextEditingController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = TextEditingController();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    final text = _ctl.text.trim();
    if (text.isEmpty) return;
    await ref.read(repoProvider).addTask(PuduuTask(id: _uuid.v4(), title: text));
    bumpTasks(ref);
    _ctl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final inboxAsync = ref.watch(inboxProvider);
    final inbox = inboxAsync.maybeWhen(data: (v) => v, orElse: () => <PuduuTask>[]);
    final todayAsync = ref.watch(todayProvider);
    final today = todayAsync.maybeWhen(data: (v) => v, orElse: () => <PuduuTask>[]);
    final timedAsync = ref.watch(timedProvider);
    final timed =
        timedAsync.maybeWhen(data: (v) => v, orElse: () => <PuduuTask>[]);
    const cats = [
      (PuduuIcons.focus, 'Focus', PuduuColors.tealWash),
      (PuduuIcons.reset, 'Reset', PuduuColors.amberWash),
      (PuduuIcons.check, 'Habits', PuduuColors.mossWash),
      (PuduuIcons.sort, 'More', Color(0xFFE8F1F6)),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      children: [
        HelloHead(
            hello: dayGreeting(), sub: daySubline(), showBell: true, showSync: true),
        const SizedBox(height: 12),
        SearchField(hint: 'Search a task or ritual', controller: _ctl),
        // NOW hero: first timed task with a clock, else empty-state card.
        if (timed.isNotEmpty)
          DarkHero(
            tag:
                'NOW · ${_clock(timed.first.scheduledAt)} · ${timed.first.durationMin ?? 25} MIN',
            title: timed.first.title,
            meta: timed.first.note?.isNotEmpty == true
                ? timed.first.note!
                : '${timed.length} scheduled today',
            progress: timed.where((t) => t.status == 'done').length /
                timed.length.clamp(1, 1 << 30),
            primary: 'Begin session',
            secondary: 'Skip',
            onSecondary: () async {
              await ref
                  .read(repoProvider)
                  .setTaskStatus(timed.first.id, 'done');
              bumpTasks(ref);
            },
          )
        else
          const DarkHero(
            tag: 'NO PLAN YET',
            title: 'Add your first block',
            meta: 'Capture below, then sort into your day',
            progress: 0.04,
            primary: 'Begin session',
            secondary: 'Skip',
          ),
        const SectionHead(label: 'TIMELINE'),
        const TimelineStrip(),
        SectionHead(
            label: 'CATEGORIES',
            action: 'See all ›',
            onAction: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    const SubShell(title: 'Library', child: LibraryPage())))),
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
            action: today.isEmpty ? null : '${today.length} today'),
        // UP NEXT: real planned tasks from drift, tap Begin to start.
        if (today.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text('Nothing planned yet — sort your inbox into today.',
                  style: PuduuType.meta),
            ),
          )
        else
          for (final t in today.take(4)) ...[
            TaskCard(
              dot: _dotPalette[t.colorIndex % _dotPalette.length],
              title: t.title,
              detail:
                  '${_clock(t.scheduledAt)} · ${t.note?.isNotEmpty == true ? t.note! : '${t.durationMin ?? 25} min'}',
              side: t.status == 'done' ? '✓ Done' : 'Begin',
              sideDone: t.status == 'done',
              onTap: () async {
                await ref.read(repoProvider).setTaskStatus(t.id, 'done');
                bumpTasks(ref);
              },
            ),
            const SizedBox(height: 8),
          ],
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
                        controller: _ctl,
                        decoration: const InputDecoration(
                            hintText:
                                'Capture a task, idea, or reminder…'),
                        onSubmitted: (_) => _addTask(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _addTask,
                      icon: const Icon(PuduuIcons.plus, size: 17),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                if (inbox.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  for (final t in inbox.take(5))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: TaskCard(
                        dot: _dotPalette[
                            t.colorIndex % _dotPalette.length],
                        title: t.title,
                        detail: t.note?.isNotEmpty == true
                            ? t.note!
                            : 'From inbox · tap ✓ to plan',
                        side: '✓',
                        onTap: () async {
                          await ref
                              .read(repoProvider)
                              .setTaskStatus(t.id, 'planned');
                          bumpTasks(ref);
                        },
                      ),
                    ),
                ],
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
                      await ref
                          .read(repoProvider)
                          .moveAllToToday(planned);
                      bumpTasks(ref);
                    },
                    icon: const Icon(PuduuIcons.sort, size: 17),
                    label: Text(inbox.isEmpty
                        ? 'Inbox empty — nothing to sort'
                        : 'Sort ${inbox.length} into my day'),
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

// Library lives in sub_pages.dart (shared Today/Yours).
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const LibraryPageBody();
}

