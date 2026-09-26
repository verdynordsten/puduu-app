// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puduu_db.dart';

// ignore_for_file: type=lint
class $DbTasksTable extends DbTasks with TableInfo<$DbTasksTable, DbTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMinMeta = const VerificationMeta(
    'durationMin',
  );
  @override
  late final GeneratedColumn<int> durationMin = GeneratedColumn<int>(
    'duration_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorIndexMeta = const VerificationMeta(
    'colorIndex',
  );
  @override
  late final GeneratedColumn<int> colorIndex = GeneratedColumn<int>(
    'color_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('inbox'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    note,
    durationMin,
    scheduledAt,
    colorIndex,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('duration_min')) {
      context.handle(
        _durationMinMeta,
        durationMin.isAcceptableOrUnknown(
          data['duration_min']!,
          _durationMinMeta,
        ),
      );
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    }
    if (data.containsKey('color_index')) {
      context.handle(
        _colorIndexMeta,
        colorIndex.isAcceptableOrUnknown(data['color_index']!, _colorIndexMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbTask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      durationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_min'],
      ),
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      ),
      colorIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_index'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $DbTasksTable createAlias(String alias) {
    return $DbTasksTable(attachedDatabase, alias);
  }
}

class DbTask extends DataClass implements Insertable<DbTask> {
  final String id;
  final String title;
  final String? note;
  final int? durationMin;
  final DateTime? scheduledAt;
  final int colorIndex;
  final String status;
  const DbTask({
    required this.id,
    required this.title,
    this.note,
    this.durationMin,
    this.scheduledAt,
    required this.colorIndex,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || durationMin != null) {
      map['duration_min'] = Variable<int>(durationMin);
    }
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    }
    map['color_index'] = Variable<int>(colorIndex);
    map['status'] = Variable<String>(status);
    return map;
  }

  DbTasksCompanion toCompanion(bool nullToAbsent) {
    return DbTasksCompanion(
      id: Value(id),
      title: Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      durationMin: durationMin == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMin),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      colorIndex: Value(colorIndex),
      status: Value(status),
    );
  }

  factory DbTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbTask(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      durationMin: serializer.fromJson<int?>(json['durationMin']),
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
      colorIndex: serializer.fromJson<int>(json['colorIndex']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String?>(note),
      'durationMin': serializer.toJson<int?>(durationMin),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
      'colorIndex': serializer.toJson<int>(colorIndex),
      'status': serializer.toJson<String>(status),
    };
  }

  DbTask copyWith({
    String? id,
    String? title,
    Value<String?> note = const Value.absent(),
    Value<int?> durationMin = const Value.absent(),
    Value<DateTime?> scheduledAt = const Value.absent(),
    int? colorIndex,
    String? status,
  }) => DbTask(
    id: id ?? this.id,
    title: title ?? this.title,
    note: note.present ? note.value : this.note,
    durationMin: durationMin.present ? durationMin.value : this.durationMin,
    scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
    colorIndex: colorIndex ?? this.colorIndex,
    status: status ?? this.status,
  );
  DbTask copyWithCompanion(DbTasksCompanion data) {
    return DbTask(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      durationMin: data.durationMin.present
          ? data.durationMin.value
          : this.durationMin,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      colorIndex: data.colorIndex.present
          ? data.colorIndex.value
          : this.colorIndex,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbTask(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('durationMin: $durationMin, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('colorIndex: $colorIndex, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    note,
    durationMin,
    scheduledAt,
    colorIndex,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbTask &&
          other.id == this.id &&
          other.title == this.title &&
          other.note == this.note &&
          other.durationMin == this.durationMin &&
          other.scheduledAt == this.scheduledAt &&
          other.colorIndex == this.colorIndex &&
          other.status == this.status);
}

class DbTasksCompanion extends UpdateCompanion<DbTask> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> note;
  final Value<int?> durationMin;
  final Value<DateTime?> scheduledAt;
  final Value<int> colorIndex;
  final Value<String> status;
  final Value<int> rowid;
  const DbTasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.colorIndex = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbTasksCompanion.insert({
    required String id,
    required String title,
    this.note = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.colorIndex = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title);
  static Insertable<DbTask> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? note,
    Expression<int>? durationMin,
    Expression<DateTime>? scheduledAt,
    Expression<int>? colorIndex,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (durationMin != null) 'duration_min': durationMin,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (colorIndex != null) 'color_index': colorIndex,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbTasksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? note,
    Value<int?>? durationMin,
    Value<DateTime?>? scheduledAt,
    Value<int>? colorIndex,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return DbTasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      durationMin: durationMin ?? this.durationMin,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      colorIndex: colorIndex ?? this.colorIndex,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (durationMin.present) {
      map['duration_min'] = Variable<int>(durationMin.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (colorIndex.present) {
      map['color_index'] = Variable<int>(colorIndex.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbTasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('durationMin: $durationMin, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('colorIndex: $colorIndex, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbSubtasksTable extends DbSubtasks
    with TableInfo<$DbSubtasksTable, DbSubtask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbSubtasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES db_tasks (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timerMinMeta = const VerificationMeta(
    'timerMin',
  );
  @override
  late final GeneratedColumn<int> timerMin = GeneratedColumn<int>(
    'timer_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, taskId, title, timerMin, done];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_subtasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbSubtask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('timer_min')) {
      context.handle(
        _timerMinMeta,
        timerMin.isAcceptableOrUnknown(data['timer_min']!, _timerMinMeta),
      );
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbSubtask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbSubtask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      timerMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timer_min'],
      ),
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
    );
  }

  @override
  $DbSubtasksTable createAlias(String alias) {
    return $DbSubtasksTable(attachedDatabase, alias);
  }
}

class DbSubtask extends DataClass implements Insertable<DbSubtask> {
  final String id;
  final String taskId;
  final String title;
  final int? timerMin;
  final bool done;
  const DbSubtask({
    required this.id,
    required this.taskId,
    required this.title,
    this.timerMin,
    required this.done,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || timerMin != null) {
      map['timer_min'] = Variable<int>(timerMin);
    }
    map['done'] = Variable<bool>(done);
    return map;
  }

  DbSubtasksCompanion toCompanion(bool nullToAbsent) {
    return DbSubtasksCompanion(
      id: Value(id),
      taskId: Value(taskId),
      title: Value(title),
      timerMin: timerMin == null && nullToAbsent
          ? const Value.absent()
          : Value(timerMin),
      done: Value(done),
    );
  }

  factory DbSubtask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbSubtask(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      title: serializer.fromJson<String>(json['title']),
      timerMin: serializer.fromJson<int?>(json['timerMin']),
      done: serializer.fromJson<bool>(json['done']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'title': serializer.toJson<String>(title),
      'timerMin': serializer.toJson<int?>(timerMin),
      'done': serializer.toJson<bool>(done),
    };
  }

  DbSubtask copyWith({
    String? id,
    String? taskId,
    String? title,
    Value<int?> timerMin = const Value.absent(),
    bool? done,
  }) => DbSubtask(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    title: title ?? this.title,
    timerMin: timerMin.present ? timerMin.value : this.timerMin,
    done: done ?? this.done,
  );
  DbSubtask copyWithCompanion(DbSubtasksCompanion data) {
    return DbSubtask(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      title: data.title.present ? data.title.value : this.title,
      timerMin: data.timerMin.present ? data.timerMin.value : this.timerMin,
      done: data.done.present ? data.done.value : this.done,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbSubtask(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('timerMin: $timerMin, ')
          ..write('done: $done')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, title, timerMin, done);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbSubtask &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.title == this.title &&
          other.timerMin == this.timerMin &&
          other.done == this.done);
}

class DbSubtasksCompanion extends UpdateCompanion<DbSubtask> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> title;
  final Value<int?> timerMin;
  final Value<bool> done;
  final Value<int> rowid;
  const DbSubtasksCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.title = const Value.absent(),
    this.timerMin = const Value.absent(),
    this.done = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbSubtasksCompanion.insert({
    required String id,
    required String taskId,
    required String title,
    this.timerMin = const Value.absent(),
    this.done = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       title = Value(title);
  static Insertable<DbSubtask> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? title,
    Expression<int>? timerMin,
    Expression<bool>? done,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (title != null) 'title': title,
      if (timerMin != null) 'timer_min': timerMin,
      if (done != null) 'done': done,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbSubtasksCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<String>? title,
    Value<int?>? timerMin,
    Value<bool>? done,
    Value<int>? rowid,
  }) {
    return DbSubtasksCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      timerMin: timerMin ?? this.timerMin,
      done: done ?? this.done,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (timerMin.present) {
      map['timer_min'] = Variable<int>(timerMin.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbSubtasksCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('timerMin: $timerMin, ')
          ..write('done: $done, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbRoutinesTable extends DbRoutines
    with TableInfo<$DbRoutinesTable, DbRoutine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbRoutinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepTitlesMeta = const VerificationMeta(
    'stepTitles',
  );
  @override
  late final GeneratedColumn<String> stepTitles = GeneratedColumn<String>(
    'step_titles',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _rruleMeta = const VerificationMeta('rrule');
  @override
  late final GeneratedColumn<String> rrule = GeneratedColumn<String>(
    'rrule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, stepTitles, rrule];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_routines';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbRoutine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('step_titles')) {
      context.handle(
        _stepTitlesMeta,
        stepTitles.isAcceptableOrUnknown(data['step_titles']!, _stepTitlesMeta),
      );
    }
    if (data.containsKey('rrule')) {
      context.handle(
        _rruleMeta,
        rrule.isAcceptableOrUnknown(data['rrule']!, _rruleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbRoutine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbRoutine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      stepTitles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}step_titles'],
      )!,
      rrule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rrule'],
      )!,
    );
  }

  @override
  $DbRoutinesTable createAlias(String alias) {
    return $DbRoutinesTable(attachedDatabase, alias);
  }
}

class DbRoutine extends DataClass implements Insertable<DbRoutine> {
  final String id;
  final String name;
  final String stepTitles;
  final String rrule;
  const DbRoutine({
    required this.id,
    required this.name,
    required this.stepTitles,
    required this.rrule,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['step_titles'] = Variable<String>(stepTitles);
    map['rrule'] = Variable<String>(rrule);
    return map;
  }

  DbRoutinesCompanion toCompanion(bool nullToAbsent) {
    return DbRoutinesCompanion(
      id: Value(id),
      name: Value(name),
      stepTitles: Value(stepTitles),
      rrule: Value(rrule),
    );
  }

  factory DbRoutine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbRoutine(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      stepTitles: serializer.fromJson<String>(json['stepTitles']),
      rrule: serializer.fromJson<String>(json['rrule']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'stepTitles': serializer.toJson<String>(stepTitles),
      'rrule': serializer.toJson<String>(rrule),
    };
  }

  DbRoutine copyWith({
    String? id,
    String? name,
    String? stepTitles,
    String? rrule,
  }) => DbRoutine(
    id: id ?? this.id,
    name: name ?? this.name,
    stepTitles: stepTitles ?? this.stepTitles,
    rrule: rrule ?? this.rrule,
  );
  DbRoutine copyWithCompanion(DbRoutinesCompanion data) {
    return DbRoutine(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      stepTitles: data.stepTitles.present
          ? data.stepTitles.value
          : this.stepTitles,
      rrule: data.rrule.present ? data.rrule.value : this.rrule,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbRoutine(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stepTitles: $stepTitles, ')
          ..write('rrule: $rrule')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, stepTitles, rrule);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbRoutine &&
          other.id == this.id &&
          other.name == this.name &&
          other.stepTitles == this.stepTitles &&
          other.rrule == this.rrule);
}

class DbRoutinesCompanion extends UpdateCompanion<DbRoutine> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> stepTitles;
  final Value<String> rrule;
  final Value<int> rowid;
  const DbRoutinesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.stepTitles = const Value.absent(),
    this.rrule = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbRoutinesCompanion.insert({
    required String id,
    required String name,
    this.stepTitles = const Value.absent(),
    this.rrule = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<DbRoutine> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? stepTitles,
    Expression<String>? rrule,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (stepTitles != null) 'step_titles': stepTitles,
      if (rrule != null) 'rrule': rrule,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbRoutinesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? stepTitles,
    Value<String>? rrule,
    Value<int>? rowid,
  }) {
    return DbRoutinesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      stepTitles: stepTitles ?? this.stepTitles,
      rrule: rrule ?? this.rrule,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (stepTitles.present) {
      map['step_titles'] = Variable<String>(stepTitles.value);
    }
    if (rrule.present) {
      map['rrule'] = Variable<String>(rrule.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbRoutinesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stepTitles: $stepTitles, ')
          ..write('rrule: $rrule, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbMoodsTable extends DbMoods with TableInfo<$DbMoodsTable, DbMood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbMoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [day, score, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_moods';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbMood> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  DbMood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbMood(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}day'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $DbMoodsTable createAlias(String alias) {
    return $DbMoodsTable(attachedDatabase, alias);
  }
}

class DbMood extends DataClass implements Insertable<DbMood> {
  final DateTime day;
  final int score;
  final String? note;
  const DbMood({required this.day, required this.score, this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<DateTime>(day);
    map['score'] = Variable<int>(score);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  DbMoodsCompanion toCompanion(bool nullToAbsent) {
    return DbMoodsCompanion(
      day: Value(day),
      score: Value(score),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory DbMood.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbMood(
      day: serializer.fromJson<DateTime>(json['day']),
      score: serializer.fromJson<int>(json['score']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<DateTime>(day),
      'score': serializer.toJson<int>(score),
      'note': serializer.toJson<String?>(note),
    };
  }

  DbMood copyWith({
    DateTime? day,
    int? score,
    Value<String?> note = const Value.absent(),
  }) => DbMood(
    day: day ?? this.day,
    score: score ?? this.score,
    note: note.present ? note.value : this.note,
  );
  DbMood copyWithCompanion(DbMoodsCompanion data) {
    return DbMood(
      day: data.day.present ? data.day.value : this.day,
      score: data.score.present ? data.score.value : this.score,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbMood(')
          ..write('day: $day, ')
          ..write('score: $score, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, score, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbMood &&
          other.day == this.day &&
          other.score == this.score &&
          other.note == this.note);
}

class DbMoodsCompanion extends UpdateCompanion<DbMood> {
  final Value<DateTime> day;
  final Value<int> score;
  final Value<String?> note;
  final Value<int> rowid;
  const DbMoodsCompanion({
    this.day = const Value.absent(),
    this.score = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbMoodsCompanion.insert({
    required DateTime day,
    required int score,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       score = Value(score);
  static Insertable<DbMood> custom({
    Expression<DateTime>? day,
    Expression<int>? score,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (score != null) 'score': score,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbMoodsCompanion copyWith({
    Value<DateTime>? day,
    Value<int>? score,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return DbMoodsCompanion(
      day: day ?? this.day,
      score: score ?? this.score,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbMoodsCompanion(')
          ..write('day: $day, ')
          ..write('score: $score, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$PuduuDb extends GeneratedDatabase {
  _$PuduuDb(QueryExecutor e) : super(e);
  $PuduuDbManager get managers => $PuduuDbManager(this);
  late final $DbTasksTable dbTasks = $DbTasksTable(this);
  late final $DbSubtasksTable dbSubtasks = $DbSubtasksTable(this);
  late final $DbRoutinesTable dbRoutines = $DbRoutinesTable(this);
  late final $DbMoodsTable dbMoods = $DbMoodsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    dbTasks,
    dbSubtasks,
    dbRoutines,
    dbMoods,
  ];
}

typedef $$DbTasksTableCreateCompanionBuilder = DbTasksCompanion Function({
  required String id,
  required String title,
  Value<String?> note,
  Value<int?> durationMin,
  Value<DateTime?> scheduledAt,
  Value<int> colorIndex,
  Value<String> status,
  Value<int> rowid,
});
typedef $$DbTasksTableUpdateCompanionBuilder = DbTasksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> note,
  Value<int?> durationMin,
  Value<DateTime?> scheduledAt,
  Value<int> colorIndex,
  Value<String> status,
  Value<int> rowid,
});

final class $$DbTasksTableReferences
    extends BaseReferences<_$PuduuDb, $DbTasksTable, DbTask> {
  $$DbTasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DbSubtasksTable, List<DbSubtask>>
  _dbSubtasksRefsTable(_$PuduuDb db) => MultiTypedResultKey.fromTable(
    db.dbSubtasks,
    aliasName: 'db_tasks__id__db_subtasks__task_id',
  );

  $$DbSubtasksTableProcessedTableManager get dbSubtasksRefs {
    final manager = $$DbSubtasksTableTableManager(
      $_db,
      $_db.dbSubtasks,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_dbSubtasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DbTasksTableFilterComposer extends Composer<_$PuduuDb, $DbTasksTable> {
  $$DbTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorIndex => $composableBuilder(
    column: $table.colorIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dbSubtasksRefs(
    Expression<bool> Function($$DbSubtasksTableFilterComposer f) f,
  ) {
    final $$DbSubtasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbSubtasks,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbSubtasksTableFilterComposer(
            $db: $db,
            $table: $db.dbSubtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DbTasksTableOrderingComposer
    extends Composer<_$PuduuDb, $DbTasksTable> {
  $$DbTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorIndex => $composableBuilder(
    column: $table.colorIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbTasksTableAnnotationComposer
    extends Composer<_$PuduuDb, $DbTasksTable> {
  $$DbTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colorIndex => $composableBuilder(
    column: $table.colorIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  Expression<T> dbSubtasksRefs<T extends Object>(
    Expression<T> Function($$DbSubtasksTableAnnotationComposer a) f,
  ) {
    final $$DbSubtasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbSubtasks,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbSubtasksTableAnnotationComposer(
            $db: $db,
            $table: $db.dbSubtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DbTasksTableTableManager
    extends
        RootTableManager<
          _$PuduuDb,
          $DbTasksTable,
          DbTask,
          $$DbTasksTableFilterComposer,
          $$DbTasksTableOrderingComposer,
          $$DbTasksTableAnnotationComposer,
          $$DbTasksTableCreateCompanionBuilder,
          $$DbTasksTableUpdateCompanionBuilder,
          (DbTask, $$DbTasksTableReferences),
          DbTask,
          PrefetchHooks Function({bool dbSubtasksRefs})
        > {
  $$DbTasksTableTableManager(_$PuduuDb db, $DbTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> durationMin = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<int> colorIndex = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbTasksCompanion(
                id: id,
                title: title,
                note: note,
                durationMin: durationMin,
                scheduledAt: scheduledAt,
                colorIndex: colorIndex,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> note = const Value.absent(),
                Value<int?> durationMin = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<int> colorIndex = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbTasksCompanion.insert(
                id: id,
                title: title,
                note: note,
                durationMin: durationMin,
                scheduledAt: scheduledAt,
                colorIndex: colorIndex,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbTasksTable, DbTask>(table),
                  $$DbTasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dbSubtasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (dbSubtasksRefs) db.dbSubtasks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dbSubtasksRefs)
                    await $_getPrefetchedData<DbTask, $DbTasksTable, DbSubtask>(
                      currentTable: table,
                      referencedTable: $$DbTasksTableReferences
                          ._dbSubtasksRefsTable(db),
                      managerFromTypedResult: (p0) => $$DbTasksTableReferences(
                        db,
                        table,
                        p0,
                      ).dbSubtasksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.taskId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DbTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$PuduuDb,
      $DbTasksTable,
      DbTask,
      $$DbTasksTableFilterComposer,
      $$DbTasksTableOrderingComposer,
      $$DbTasksTableAnnotationComposer,
      $$DbTasksTableCreateCompanionBuilder,
      $$DbTasksTableUpdateCompanionBuilder,
      (DbTask, $$DbTasksTableReferences),
      DbTask,
      PrefetchHooks Function({bool dbSubtasksRefs})
    >;
typedef $$DbSubtasksTableCreateCompanionBuilder = DbSubtasksCompanion Function({
  required String id,
  required String taskId,
  required String title,
  Value<int?> timerMin,
  Value<bool> done,
  Value<int> rowid,
});
typedef $$DbSubtasksTableUpdateCompanionBuilder = DbSubtasksCompanion Function({
  Value<String> id,
  Value<String> taskId,
  Value<String> title,
  Value<int?> timerMin,
  Value<bool> done,
  Value<int> rowid,
});

final class $$DbSubtasksTableReferences
    extends BaseReferences<_$PuduuDb, $DbSubtasksTable, DbSubtask> {
  $$DbSubtasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DbTasksTable _taskIdTable(_$PuduuDb db) =>
      db.dbTasks.createAlias('db_subtasks__task_id__db_tasks__id');

  $$DbTasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$DbTasksTableTableManager(
      $_db,
      $_db.dbTasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DbSubtasksTableFilterComposer
    extends Composer<_$PuduuDb, $DbSubtasksTable> {
  $$DbSubtasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timerMin => $composableBuilder(
    column: $table.timerMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  $$DbTasksTableFilterComposer get taskId {
    final $$DbTasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.dbTasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbTasksTableFilterComposer(
            $db: $db,
            $table: $db.dbTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbSubtasksTableOrderingComposer
    extends Composer<_$PuduuDb, $DbSubtasksTable> {
  $$DbSubtasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timerMin => $composableBuilder(
    column: $table.timerMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  $$DbTasksTableOrderingComposer get taskId {
    final $$DbTasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.dbTasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbTasksTableOrderingComposer(
            $db: $db,
            $table: $db.dbTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbSubtasksTableAnnotationComposer
    extends Composer<_$PuduuDb, $DbSubtasksTable> {
  $$DbSubtasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get timerMin =>
      $composableBuilder(column: $table.timerMin, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  $$DbTasksTableAnnotationComposer get taskId {
    final $$DbTasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.dbTasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbTasksTableAnnotationComposer(
            $db: $db,
            $table: $db.dbTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbSubtasksTableTableManager
    extends
        RootTableManager<
          _$PuduuDb,
          $DbSubtasksTable,
          DbSubtask,
          $$DbSubtasksTableFilterComposer,
          $$DbSubtasksTableOrderingComposer,
          $$DbSubtasksTableAnnotationComposer,
          $$DbSubtasksTableCreateCompanionBuilder,
          $$DbSubtasksTableUpdateCompanionBuilder,
          (DbSubtask, $$DbSubtasksTableReferences),
          DbSubtask,
          PrefetchHooks Function({bool taskId})
        > {
  $$DbSubtasksTableTableManager(_$PuduuDb db, $DbSubtasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbSubtasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbSubtasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbSubtasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int?> timerMin = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbSubtasksCompanion(
                id: id,
                taskId: taskId,
                title: title,
                timerMin: timerMin,
                done: done,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required String title,
                Value<int?> timerMin = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbSubtasksCompanion.insert(
                id: id,
                taskId: taskId,
                title: title,
                timerMin: timerMin,
                done: done,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbSubtasksTable, DbSubtask>(table),
                  $$DbSubtasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.taskId,
                        referencedTable: $$DbSubtasksTableReferences
                            ._taskIdTable(db),
                        referencedColumn: $$DbSubtasksTableReferences
                            ._taskIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DbSubtasksTableProcessedTableManager =
    ProcessedTableManager<
      _$PuduuDb,
      $DbSubtasksTable,
      DbSubtask,
      $$DbSubtasksTableFilterComposer,
      $$DbSubtasksTableOrderingComposer,
      $$DbSubtasksTableAnnotationComposer,
      $$DbSubtasksTableCreateCompanionBuilder,
      $$DbSubtasksTableUpdateCompanionBuilder,
      (DbSubtask, $$DbSubtasksTableReferences),
      DbSubtask,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$DbRoutinesTableCreateCompanionBuilder = DbRoutinesCompanion Function({
  required String id,
  required String name,
  Value<String> stepTitles,
  Value<String> rrule,
  Value<int> rowid,
});
typedef $$DbRoutinesTableUpdateCompanionBuilder = DbRoutinesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> stepTitles,
  Value<String> rrule,
  Value<int> rowid,
});

class $$DbRoutinesTableFilterComposer
    extends Composer<_$PuduuDb, $DbRoutinesTable> {
  $$DbRoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stepTitles => $composableBuilder(
    column: $table.stepTitles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rrule => $composableBuilder(
    column: $table.rrule,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbRoutinesTableOrderingComposer
    extends Composer<_$PuduuDb, $DbRoutinesTable> {
  $$DbRoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stepTitles => $composableBuilder(
    column: $table.stepTitles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rrule => $composableBuilder(
    column: $table.rrule,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbRoutinesTableAnnotationComposer
    extends Composer<_$PuduuDb, $DbRoutinesTable> {
  $$DbRoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get stepTitles => $composableBuilder(
    column: $table.stepTitles,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rrule =>
      $composableBuilder(column: $table.rrule, builder: (column) => column);
}

class $$DbRoutinesTableTableManager
    extends
        RootTableManager<
          _$PuduuDb,
          $DbRoutinesTable,
          DbRoutine,
          $$DbRoutinesTableFilterComposer,
          $$DbRoutinesTableOrderingComposer,
          $$DbRoutinesTableAnnotationComposer,
          $$DbRoutinesTableCreateCompanionBuilder,
          $$DbRoutinesTableUpdateCompanionBuilder,
          (DbRoutine, BaseReferences<_$PuduuDb, $DbRoutinesTable, DbRoutine>),
          DbRoutine,
          PrefetchHooks Function()
        > {
  $$DbRoutinesTableTableManager(_$PuduuDb db, $DbRoutinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbRoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbRoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbRoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> stepTitles = const Value.absent(),
                Value<String> rrule = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbRoutinesCompanion(
                id: id,
                name: name,
                stepTitles: stepTitles,
                rrule: rrule,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> stepTitles = const Value.absent(),
                Value<String> rrule = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbRoutinesCompanion.insert(
                id: id,
                name: name,
                stepTitles: stepTitles,
                rrule: rrule,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbRoutinesTable, DbRoutine>(table),
                  BaseReferences<_$PuduuDb, $DbRoutinesTable, DbRoutine>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbRoutinesTableProcessedTableManager =
    ProcessedTableManager<
      _$PuduuDb,
      $DbRoutinesTable,
      DbRoutine,
      $$DbRoutinesTableFilterComposer,
      $$DbRoutinesTableOrderingComposer,
      $$DbRoutinesTableAnnotationComposer,
      $$DbRoutinesTableCreateCompanionBuilder,
      $$DbRoutinesTableUpdateCompanionBuilder,
      (DbRoutine, BaseReferences<_$PuduuDb, $DbRoutinesTable, DbRoutine>),
      DbRoutine,
      PrefetchHooks Function()
    >;
typedef $$DbMoodsTableCreateCompanionBuilder = DbMoodsCompanion Function({
  required DateTime day,
  required int score,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$DbMoodsTableUpdateCompanionBuilder = DbMoodsCompanion Function({
  Value<DateTime> day,
  Value<int> score,
  Value<String?> note,
  Value<int> rowid,
});

class $$DbMoodsTableFilterComposer extends Composer<_$PuduuDb, $DbMoodsTable> {
  $$DbMoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbMoodsTableOrderingComposer
    extends Composer<_$PuduuDb, $DbMoodsTable> {
  $$DbMoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbMoodsTableAnnotationComposer
    extends Composer<_$PuduuDb, $DbMoodsTable> {
  $$DbMoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$DbMoodsTableTableManager
    extends
        RootTableManager<
          _$PuduuDb,
          $DbMoodsTable,
          DbMood,
          $$DbMoodsTableFilterComposer,
          $$DbMoodsTableOrderingComposer,
          $$DbMoodsTableAnnotationComposer,
          $$DbMoodsTableCreateCompanionBuilder,
          $$DbMoodsTableUpdateCompanionBuilder,
          (DbMood, BaseReferences<_$PuduuDb, $DbMoodsTable, DbMood>),
          DbMood,
          PrefetchHooks Function()
        > {
  $$DbMoodsTableTableManager(_$PuduuDb db, $DbMoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbMoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbMoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbMoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> day = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbMoodsCompanion(
                day: day,
                score: score,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime day,
                required int score,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbMoodsCompanion.insert(
                day: day,
                score: score,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbMoodsTable, DbMood>(table),
                  BaseReferences<_$PuduuDb, $DbMoodsTable, DbMood>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbMoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$PuduuDb,
      $DbMoodsTable,
      DbMood,
      $$DbMoodsTableFilterComposer,
      $$DbMoodsTableOrderingComposer,
      $$DbMoodsTableAnnotationComposer,
      $$DbMoodsTableCreateCompanionBuilder,
      $$DbMoodsTableUpdateCompanionBuilder,
      (DbMood, BaseReferences<_$PuduuDb, $DbMoodsTable, DbMood>),
      DbMood,
      PrefetchHooks Function()
    >;

class $PuduuDbManager {
  final _$PuduuDb _db;
  $PuduuDbManager(this._db);
  $$DbTasksTableTableManager get dbTasks =>
      $$DbTasksTableTableManager(_db, _db.dbTasks);
  $$DbSubtasksTableTableManager get dbSubtasks =>
      $$DbSubtasksTableTableManager(_db, _db.dbSubtasks);
  $$DbRoutinesTableTableManager get dbRoutines =>
      $$DbRoutinesTableTableManager(_db, _db.dbRoutines);
  $$DbMoodsTableTableManager get dbMoods =>
      $$DbMoodsTableTableManager(_db, _db.dbMoods);
}
