import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/satellite/client.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:test/test.dart';

void main() {
  test('serialize/deserialize row data', () {
    final rel = Relation(
      id: 1,
      schema: 'schema',
      table: 'table',
      tableType: SatRelation_RelationType.TABLE,
      columns: [
        RelationColumn(name: 'name1', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'name2', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'name3', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'int1', type: 'INTEGER', isNullable: true),
        RelationColumn(name: 'int2', type: 'INTEGER', isNullable: true),
        RelationColumn(name: 'float1', type: 'FLOAT4', isNullable: true),
        RelationColumn(name: 'float2', type: 'FLOAT4', isNullable: true),
      ],
    );

    final record = <String, Object?>{
      'name1': 'Hello',
      'name2': 'World!',
      'name3': null,
      'int1': 1,
      'int2': -30,
      'float1': 1.1,
      'float2': -30.3,
    };
    final sRow = serializeRow(record, rel);
    final dRow = deserializeRow(sRow, rel);

    expect(record, dRow);
  });

  test('Null mask uses bits as if they were a list', () {
    final rel = Relation(
      id: 1,
      schema: 'schema',
      table: 'table',
      tableType: SatRelation_RelationType.TABLE,
      columns: [
        RelationColumn(name: 'bit0', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'bit1', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'bit2', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'bit3', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'bit4', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'bit5', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'bit6', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'bit7', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'bit8', type: 'TEXT', isNullable: true),
      ],
    );

    final record = {
      'bit0': null,
      'bit1': null,
      'bit2': 'Filled',
      'bit3': null,
      'bit4': 'Filled',
      'bit5': 'Filled',
      'bit6': 'Filled',
      'bit7': 'Filled',
      'bit8': null,
    };
    final sRow = serializeRow(record, rel);

    final mask = [...sRow.nullsBitmask].map((x) => x.toRadixString(2)).join('');

    expect(mask, '1101000010000000');
  });
}