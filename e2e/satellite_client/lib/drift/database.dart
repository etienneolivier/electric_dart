import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:electricsql/drivers/drift.dart';

part 'database.g.dart';

class Items extends Table {
  TextColumn get id => text()();
  TextColumn get content => text()();
  TextColumn get contentTextNull =>
      text().named('content_text_null').nullable()();
  TextColumn get contentTextNullDefault =>
      text().named('content_text_null_default').nullable()();
  IntColumn get intValueNull => integer().named('intvalue_null').nullable()();
  IntColumn get intValueNullDefault =>
      integer().named('intvalue_null_default').nullable()();

  @override
  String? get tableName => 'Items';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class OtherItems extends Table {
  TextColumn get id => text()();
  TextColumn get content => text()();
  TextColumn get itemId =>
      text().named('item_id').nullable().unique().references(Items, #id)();

  @override
  String? get tableName => 'OtherItems';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Timestamps extends Table {
  TextColumn get id => text()();
  Column<DateTime> get createdAt =>
      customType(ElectricTypes.timestamp).named('created_at')();
  Column<DateTime> get updatedAt =>
      customType(ElectricTypes.timestampTZ).named('updated_at')();

  @override
  String? get tableName => 'Timestamps';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Datetimes extends Table {
  TextColumn get id => text()();
  Column<DateTime> get d => customType(ElectricTypes.date)();
  Column<DateTime> get t => customType(ElectricTypes.time)();

  @override
  String? get tableName => 'Datetimes';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Bools extends Table {
  TextColumn get id => text()();
  BoolColumn get b => boolean().nullable()();

  @override
  String? get tableName => 'Bools';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Uuids extends Table {
  TextColumn get id => customType(ElectricTypes.uuid)();

  @override
  String? get tableName => 'Uuids';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Ints extends Table {
  TextColumn get id => text()();
  IntColumn get i2 => customType(ElectricTypes.int2).nullable()();
  IntColumn get i4 => customType(ElectricTypes.int4).nullable()();

  @override
  String? get tableName => 'Ints';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Floats extends Table {
  TextColumn get id => text()();
  RealColumn get f8 => customType(ElectricTypes.float8).nullable()();

  @override
  String? get tableName => 'Floats';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@DriftDatabase(tables: [
  Items,
  OtherItems,
  Timestamps,
  Datetimes,
  Bools,
  Uuids,
  Ints,
  Floats,
])
class ClientDatabase extends _$ClientDatabase {
  ClientDatabase(super.e);

  factory ClientDatabase.memory() {
    return ClientDatabase(
      NativeDatabase.memory(
        setup: (db) {
          db.config.doubleQuotedStringLiterals = false;
        },
      ),
    );
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          // Empty on create, we don't need it with Electric
        },
      );

  @override
  int get schemaVersion => 1;
}