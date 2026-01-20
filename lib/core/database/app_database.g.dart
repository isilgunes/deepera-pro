// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PomodoroSessionsTable extends PomodoroSessions
    with TableInfo<$PomodoroSessionsTable, PomodoroSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PomodoroSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _taskTitleMeta =
      const VerificationMeta('taskTitle');
  @override
  late final GeneratedColumn<String> taskTitle = GeneratedColumn<String>(
      'task_title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, durationSeconds, taskTitle, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pomodoro_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<PomodoroSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('task_title')) {
      context.handle(_taskTitleMeta,
          taskTitle.isAcceptableOrUnknown(data['task_title']!, _taskTitleMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PomodoroSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PomodoroSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
      taskTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_title']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
    );
  }

  @override
  $PomodoroSessionsTable createAlias(String alias) {
    return $PomodoroSessionsTable(attachedDatabase, alias);
  }
}

class PomodoroSession extends DataClass implements Insertable<PomodoroSession> {
  final int id;
  final DateTime date;
  final int durationSeconds;
  final String? taskTitle;
  final String type;
  const PomodoroSession(
      {required this.id,
      required this.date,
      required this.durationSeconds,
      this.taskTitle,
      required this.type});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    if (!nullToAbsent || taskTitle != null) {
      map['task_title'] = Variable<String>(taskTitle);
    }
    map['type'] = Variable<String>(type);
    return map;
  }

  PomodoroSessionsCompanion toCompanion(bool nullToAbsent) {
    return PomodoroSessionsCompanion(
      id: Value(id),
      date: Value(date),
      durationSeconds: Value(durationSeconds),
      taskTitle: taskTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(taskTitle),
      type: Value(type),
    );
  }

  factory PomodoroSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PomodoroSession(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      taskTitle: serializer.fromJson<String?>(json['taskTitle']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'taskTitle': serializer.toJson<String?>(taskTitle),
      'type': serializer.toJson<String>(type),
    };
  }

  PomodoroSession copyWith(
          {int? id,
          DateTime? date,
          int? durationSeconds,
          Value<String?> taskTitle = const Value.absent(),
          String? type}) =>
      PomodoroSession(
        id: id ?? this.id,
        date: date ?? this.date,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        taskTitle: taskTitle.present ? taskTitle.value : this.taskTitle,
        type: type ?? this.type,
      );
  PomodoroSession copyWithCompanion(PomodoroSessionsCompanion data) {
    return PomodoroSession(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      taskTitle: data.taskTitle.present ? data.taskTitle.value : this.taskTitle,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PomodoroSession(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('taskTitle: $taskTitle, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, durationSeconds, taskTitle, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PomodoroSession &&
          other.id == this.id &&
          other.date == this.date &&
          other.durationSeconds == this.durationSeconds &&
          other.taskTitle == this.taskTitle &&
          other.type == this.type);
}

class PomodoroSessionsCompanion extends UpdateCompanion<PomodoroSession> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> durationSeconds;
  final Value<String?> taskTitle;
  final Value<String> type;
  const PomodoroSessionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.taskTitle = const Value.absent(),
    this.type = const Value.absent(),
  });
  PomodoroSessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int durationSeconds,
    this.taskTitle = const Value.absent(),
    required String type,
  })  : date = Value(date),
        durationSeconds = Value(durationSeconds),
        type = Value(type);
  static Insertable<PomodoroSession> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? durationSeconds,
    Expression<String>? taskTitle,
    Expression<String>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (taskTitle != null) 'task_title': taskTitle,
      if (type != null) 'type': type,
    });
  }

  PomodoroSessionsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? date,
      Value<int>? durationSeconds,
      Value<String?>? taskTitle,
      Value<String>? type}) {
    return PomodoroSessionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      taskTitle: taskTitle ?? this.taskTitle,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (taskTitle.present) {
      map['task_title'] = Variable<String>(taskTitle.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PomodoroSessionsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('taskTitle: $taskTitle, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PomodoroSessionsTable pomodoroSessions =
      $PomodoroSessionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [pomodoroSessions];
}

typedef $$PomodoroSessionsTableCreateCompanionBuilder
    = PomodoroSessionsCompanion Function({
  Value<int> id,
  required DateTime date,
  required int durationSeconds,
  Value<String?> taskTitle,
  required String type,
});
typedef $$PomodoroSessionsTableUpdateCompanionBuilder
    = PomodoroSessionsCompanion Function({
  Value<int> id,
  Value<DateTime> date,
  Value<int> durationSeconds,
  Value<String?> taskTitle,
  Value<String> type,
});

class $$PomodoroSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $PomodoroSessionsTable> {
  $$PomodoroSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskTitle => $composableBuilder(
      column: $table.taskTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));
}

class $$PomodoroSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PomodoroSessionsTable> {
  $$PomodoroSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskTitle => $composableBuilder(
      column: $table.taskTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));
}

class $$PomodoroSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PomodoroSessionsTable> {
  $$PomodoroSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<String> get taskTitle =>
      $composableBuilder(column: $table.taskTitle, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$PomodoroSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PomodoroSessionsTable,
    PomodoroSession,
    $$PomodoroSessionsTableFilterComposer,
    $$PomodoroSessionsTableOrderingComposer,
    $$PomodoroSessionsTableAnnotationComposer,
    $$PomodoroSessionsTableCreateCompanionBuilder,
    $$PomodoroSessionsTableUpdateCompanionBuilder,
    (
      PomodoroSession,
      BaseReferences<_$AppDatabase, $PomodoroSessionsTable, PomodoroSession>
    ),
    PomodoroSession,
    PrefetchHooks Function()> {
  $$PomodoroSessionsTableTableManager(
      _$AppDatabase db, $PomodoroSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PomodoroSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PomodoroSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PomodoroSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<String?> taskTitle = const Value.absent(),
            Value<String> type = const Value.absent(),
          }) =>
              PomodoroSessionsCompanion(
            id: id,
            date: date,
            durationSeconds: durationSeconds,
            taskTitle: taskTitle,
            type: type,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime date,
            required int durationSeconds,
            Value<String?> taskTitle = const Value.absent(),
            required String type,
          }) =>
              PomodoroSessionsCompanion.insert(
            id: id,
            date: date,
            durationSeconds: durationSeconds,
            taskTitle: taskTitle,
            type: type,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PomodoroSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PomodoroSessionsTable,
    PomodoroSession,
    $$PomodoroSessionsTableFilterComposer,
    $$PomodoroSessionsTableOrderingComposer,
    $$PomodoroSessionsTableAnnotationComposer,
    $$PomodoroSessionsTableCreateCompanionBuilder,
    $$PomodoroSessionsTableUpdateCompanionBuilder,
    (
      PomodoroSession,
      BaseReferences<_$AppDatabase, $PomodoroSessionsTable, PomodoroSession>
    ),
    PomodoroSession,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PomodoroSessionsTableTableManager get pomodoroSessions =>
      $$PomodoroSessionsTableTableManager(_db, _db.pomodoroSessions);
}
