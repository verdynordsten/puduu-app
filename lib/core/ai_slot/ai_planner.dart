import '../models.dart';

/// Slot for the future AI planner. MVP binds [RuleBasedProvider];
/// P1 adds an LLM provider without touching UI code.
abstract class AiPlannerProvider {
  String get name;
  Future<List<PuduuTask>> plan(List<PuduuTask> inbox, {int? energyLevel});
  Future<List<PuduuSubtask>> breakdown(PuduuTask task);
}

/// MVP: deterministic, offline, zero-cost smart templates.
class RuleBasedProvider implements AiPlannerProvider {
  @override
  String get name => 'rule-based';

  static const _verbs = ['email', 'call', 'book', 'pay', 'clean', 'write', 'fix', 'plan', 'send', 'review'];

  @override
  Future<List<PuduuTask>> plan(List<PuduuTask> inbox, {int? energyLevel}) async {
    final sorted = [...inbox];
    sorted.sort((a, b) {
      int score(PuduuTask t) {
        var s = 0;
        final tl = t.title.toLowerCase();
        if (tl.contains('urgent') || tl.contains('today')) s -= 10;
        if ((t.durationMin ?? 30) <= 15) s -= 3; // tiny first: thaw effect
        if (energyLevel != null && energyLevel <= 2 && (t.durationMin ?? 30) > 30) s += 5;
        return s;
      }
      return score(a).compareTo(score(b));
    });
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day, 9);
    return [
      for (final t in sorted)
        PuduuTask(
          id: t.id,
          title: t.title,
          note: t.note,
          durationMin: t.durationMin ?? _guessMinutes(t.title),
          scheduledAt: cursor = cursor.add(Duration(minutes: (t.durationMin ?? 25) + 5)),
          colorIndex: t.colorIndex,
          status: 'planned',
          subtasks: t.subtasks,
        ),
    ];
  }

  @override
  Future<List<PuduuSubtask>> breakdown(PuduuTask task) async {
    final tl = task.title.toLowerCase();
    final verb = _verbs.firstWhere(tl.contains, orElse: () => 'start');
    return [
      PuduuSubtask(id: '${task.id}-s1', title: 'Open everything for "$verb"', timerMin: 2),
      PuduuSubtask(id: '${task.id}-s2', title: 'Do the smallest slice', timerMin: 10),
      PuduuSubtask(id: '${task.id}-s3', title: 'Wrap & note next step', timerMin: 3),
    ];
  }

  int _guessMinutes(String title) {
    final l = title.toLowerCase();
    if (l.contains('quick') || l.contains('tiny')) return 5;
    if (l.contains('meeting') || l.contains('call')) return 30;
    if (l.contains('deep') || l.contains('project')) return 50;
    return 25;
  }
}
