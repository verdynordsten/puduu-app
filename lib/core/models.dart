/// Puduu domain models (MVP). Mirrors future Supabase tables 1:1.
class PuduuTask {
  final String id;
  final String title;
  final String? note;
  final int? durationMin;
  final DateTime? scheduledAt;
  final int colorIndex;
  final String status; // inbox | planned | doing | done | moved | dropped
  final List<PuduuSubtask> subtasks;
  const PuduuTask({
    required this.id,
    required this.title,
    this.note,
    this.durationMin,
    this.scheduledAt,
    this.colorIndex = 0,
    this.status = 'inbox',
    this.subtasks = const [],
  });
}

class PuduuSubtask {
  final String id;
  final String title;
  final int? timerMin;
  final bool done;
  const PuduuSubtask({required this.id, required this.title, this.timerMin, this.done = false});
}

class PuduuRoutine {
  final String id;
  final String name;
  final List<String> stepTitles;
  final String rrule; // e.g. FREQ=DAILY;BYHOUR=8
  const PuduuRoutine({required this.id, required this.name, this.stepTitles = const [], this.rrule = ''});
}

class RescueOption {
  final String id;
  final String title;
  final String detail;
  final int minutes;
  const RescueOption({required this.id, required this.title, required this.detail, this.minutes = 2});
}

class MoodEntry {
  final DateTime day;
  final int score; // 1..5
  final String? note;
  const MoodEntry({required this.day, required this.score, this.note});
}
