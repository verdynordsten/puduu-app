import 'package:drift/drift.dart';
// ignore: deprecated_member_use
import 'package:drift/web.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'puduu_db.g.dart';

// ---------- tables (mirror models.dart 1:1) ----------

class DbTasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  IntColumn get durationMin => integer().nullable()();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  IntColumn get colorIndex => integer().withDefault(const Constant(0))();
  TextColumn get status =>
      text().withDefault(const Constant('inbox'))(); // inbox|planned|doing|done|moved|dropped
  @override
  Set<Column> get primaryKey => {id};
}

class DbSubtasks extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().references(DbTasks, #id)();
  TextColumn get title => text()();
  IntColumn get timerMin => integer().nullable()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class DbRoutines extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get stepTitles =>
      text().withDefault(const Constant('[]'))(); // JSON array
  TextColumn get rrule => text().withDefault(const Constant(''))();
  @override
  Set<Column> get primaryKey => {id};
}

class DbMoods extends Table {
  DateTimeColumn get day => dateTime()();
  IntColumn get score => integer()(); // 1..5
  TextColumn get note => text().nullable()();
  @override
  Set<Column> get primaryKey => {day};
}

@DriftDatabase(tables: [DbTasks, DbSubtasks, DbRoutines, DbMoods])
class PuduuDb extends _$PuduuDb {
  PuduuDb() : super(_open());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _open() {
    if (kIsWeb) {
      // sql.js via CDN (web/index.html) + IndexedDB persist. WASM worker
      // path needs hosted sqlite3.wasm which we don't ship — sql.js it is.
      // ignore: experimental_member_use
      return WebDatabase.withStorage(DriftWebStorage.indexedDb('puduu'));
    }
    return driftDatabase(name: 'puduu');
  }
}
