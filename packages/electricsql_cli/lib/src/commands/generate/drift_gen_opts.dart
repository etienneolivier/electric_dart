import 'package:code_builder/code_builder.dart';

abstract class ElectricDriftGenOpts {
  /// Customize the way the Drift Table class is generated
  /// Returning null means use the default
  /// [sqlTableName] is the name of the table in the database
  DriftTableGenOpts? tableGenOpts(String sqlTableName) {
    return null;
  }

  /// Customize the way the Drift Table class is generated
  /// Returning null means use the default
  /// [sqlTableName] is the name of the table in the database
  /// [sqlColumnName] is the name of the column in the database
  DriftColumnGenOpts? columnGenOpts(String sqlTableName, String sqlColumnName) {
    return null;
  }
}

class DriftTableGenOpts {
  /// Customize the way the Drift table name class is generated
  /// Returning null means use the default
  final String? driftTableName;

  /// Customize the way the Drift data class is generated
  /// Returning null means use the default
  final DataClassNameInfo? dataClassName;

  DriftTableGenOpts({
    this.driftTableName,
    this.dataClassName,
  });
}

/// A function that takes a [ColumnBuilder] expression from drift and returns a modified
/// [ColumnBuilder] expression.
typedef ColumnBuilderModifier = Expression Function(Expression columnBuilder);

class DriftColumnGenOpts {
  /// Customize the way the Drift column name class is generated
  /// Returning null means use the default
  final String? driftColumnName;

  /// Customize the way the Drift column definition is generated
  /// Returning null means use the default
  ///
  /// One common use case could be including a `.clientDefault(() => DateTime.now())` in your
  /// drift schema.
  /// That can be defined as follows:
  ///
  /// ```dart
  /// (baseColumnBuilder) => clientDefaultExpression(
  ///   baseColumnBuilder,
  ///   value: dateTimeNowExpression,
  /// )
  /// ```
  final ColumnBuilderModifier? columnBuilderModifier;

  DriftColumnGenOpts({
    this.driftColumnName,
    this.columnBuilderModifier,
  });
}

/// Options to customize how the [DataClassName] from drift annotation is generated
class DataClassNameInfo {
  /// The name of the data class
  final String name;

  /// The [code_builder] [Reference] to the parent type of the data class generated by drift.
  /// For example: `refer('BaseModel', 'package:myapp/base_model.dart')`
  final Reference? extending;

  DataClassNameInfo(
    this.name, {
    this.extending,
  });
}