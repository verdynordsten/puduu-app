import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../models.dart';
import 'puduu_db.dart';

const _uuid = Uuid();

/// Single door to the local DB. Providers talk to this, never to drift directly.
class PuduuRepo {
  final PuduuDb db;
  PuduuRepo(this.db);

  // ---------- tasks ----------
  Future<List<PuduuTask>> tasksByStatus(String status) async {
    final rows = await (db.select(db.dbTasks)
          ..where((t) => t.status.equals(status))
          ..orderBy([(t) => OrderingTerm(expression: t.rowId)]))
        .get();
    final out = <PuduuTask>[];
    for (final r in rows) {
      final subs = await (db.select(db.dbSubtasks)
            ..where((s) => s.taskId.equals(r.id)))
          .get();
      out.add(PuduuTask(
        id: r.id,
        title: r.title,
        note: r.note,
        durationMin: r.durationMin,
        scheduledAt: r.scheduledAt,
        colorIndex: r.colorIndex,
        status: r.status,
        subtasks: [
          for (final s in subs)
            PuduuSubtask(
                id: s.id, title: s.title, timerMin: s.timerMin, done: s.done),
        ],
      ));
    }
    return out;
  }

  Future<void> addTask(PuduuTask t) async {
    await db.into(db.dbTasks).insert(
          DbTasksCompanion(
            id: Value(t.id),
            title: Value(t.title),
            note: Value(t.note),
            durationMin: Value(t.durationMin),
            scheduledAt: Value(t.scheduledAt),
            colorIndex: Value(t.colorIndex),
            status: Value(t.status),
          ),
          mode: InsertMode.insertOrReplace,
        );
    for (final s in t.subtasks) {
      await db.into(db.dbSubtasks).insert(
            DbSubtasksCompanion(
              id: Value(s.id),
              taskId: Value(t.id),
              title: Value(s.title),
              timerMin: Value(s.timerMin),
              done: Value(s.done),
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  Future<void> setTaskStatus(String id, String status) async {
    await (db.update(db.dbTasks)..where((t) => t.id.equals(id)))
        .write(DbTasksCompanion(status: Value(status)));
  }

  Future<void> moveAllToToday(List<PuduuTask> planned) async {
    for (final t in planned) {
      await addTask(PuduuTask(
        id: t.id,
        title: t.title,
        note: t.note,
        durationMin: t.durationMin,
        scheduledAt: t.scheduledAt,
        colorIndex: t.colorIndex,
        status: 'planned',
        subtasks: t.subtasks,
      ));
    }
    await (db.delete(db.dbTasks)..where((t) => t.status.equals('inbox')))
        .go();
  }

  Future<void> clearToday() async {
    await (db.delete(db.dbTasks)..where((t) => t.status.equals('planned')))
        .go();
  }

  // ---------- routines ----------
  Future<List<PuduuRoutine>> routines() async {
    final rows = await db.select(db.dbRoutines).get();
    return [
      for (final r in rows)
        PuduuRoutine(
          id: r.id,
          name: r.name,
          stepTitles:
              (jsonDecode(r.stepTitles) as List).map((e) => '$e').toList(),
          rrule: r.rrule,
        ),
    ];
  }

  // ---------- moods ----------
  Future<List<MoodEntry>> moods() async {
    final rows = await (db.select(db.dbMoods)
          ..orderBy(
              [(m) => OrderingTerm(expression: m.day, mode: OrderingMode.desc)]))
        .get();
    return [
      for (final r in rows)
        MoodEntry(day: r.day, score: r.score, note: r.note),
    ];
  }

  Future<void> logMood(int score) async {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    await db.into(db.dbMoods).insert(
          DbMoodsCompanion(
              day: Value(day), score: Value(score), note: const Value(null)),
          mode: InsertMode.insertOrReplace,
        );
  }

  // ---------- seed (first run only) ----------
  Future<void> seedIfEmpty() async {
    final n = await db.select(db.dbTasks).get();
    if (n.isNotEmpty) return;
    final now = DateTime.now();
    final day9 = DateTime(now.year, now.month, now.day, 9);
    await addTask(PuduuTask(
        id: _uuid.v4(), title: 'Call dentist', durationMin: 10));
    await addTask(PuduuTask(
        id: _uuid.v4(), title: 'Pay electricity bill', durationMin: 15));
    await addTask(PuduuTask(
        id: _uuid.v4(),
        title: 'Deep work: portfolio hero',
        durationMin: 50,
        colorIndex: 1));
    await addTask(PuduuTask(
        id: _uuid.v4(),
        title: 'Morning reset',
        note: 'Meds, water, five-minute tidy',
        durationMin: 25,
        scheduledAt: day9,
        status: 'planned'));
    await addTask(PuduuTask(
        id: _uuid.v4(),
        title: 'Deep work: portfolio',
        note: 'Hero section, timer on, phone away',
        durationMin: 50,
        scheduledAt: day9.add(const Duration(minutes: 55)),
        colorIndex: 1,
        status: 'planned'));
    await addTask(PuduuTask(
        id: _uuid.v4(),
        title: 'Walk outside',
        note: 'Fifteen minutes, no podcast',
        durationMin: 15,
        scheduledAt: day9.add(const Duration(minutes: 110)),
        colorIndex: 3,
        status: 'done'));
    await addTask(PuduuTask(
        id: _uuid.v4(),
        title: 'Admin batch',
        note: 'Bills and inbox, one pass',
        durationMin: 30,
        scheduledAt: day9.add(const Duration(minutes: 130)),
        colorIndex: 2,
        status: 'planned'));
    await db.into(db.dbRoutines).insert(DbRoutinesCompanion(
      id: Value(_uuid.v4()),
      name: const Value('Morning reset'),
      stepTitles: Value(jsonEncode(['Meds', 'Water', 'Tidy 5 min'])),
      rrule: const Value('FREQ=DAILY;BYHOUR=8'),
    ));
    await db.into(db.dbRoutines).insert(DbRoutinesCompanion(
      id: Value(_uuid.v4()),
      name: const Value('Wind down'),
      stepTitles: Value(jsonEncode(['Dim lights', 'No screens', 'Read'])),
      rrule: const Value('FREQ=DAILY;BYHOUR=22'),
    ));
    for (var i = 1; i <= 3; i++) {
      await db.into(db.dbMoods).insert(DbMoodsCompanion(
        day: Value(DateTime(now.year, now.month, now.day - i)),
        score: Value([4, 3, 5][i - 1]),
      ));
    }
  }
}
