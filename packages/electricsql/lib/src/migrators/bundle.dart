import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/migrators/migrators.dart';
import 'package:electricsql/src/migrators/schema.dart';
import 'package:electricsql/src/util/debug/debug.dart';
import 'package:electricsql/src/util/types.dart';

const kElectricMigrationsTable = '_electric_migrations';

final kValidVersionExp = RegExp(r'^[0-9_]+$');

class BundleMigrator implements Migrator {
  final DatabaseAdapter adapter;
  late final List<StmtMigration> migrations;

  late final String tableName;

  BundleMigrator({
    required this.adapter,
    required List<Migration> migrations,
    String? tableName,
  }) {
    this.migrations = [...kBaseMigrations, ...migrations]
        .map((migration) => makeStmtMigration(migration))
        .toList();
    this.tableName = tableName ?? kElectricMigrationsTable;
  }

  @override
  Future<int> up() async {
    final existing = await queryApplied();
    final unapplied = await validateApplied(migrations, existing);

    for (int i = 0; i < unapplied.length; i++) {
      final migration = unapplied[i];
      logger.info('applying migration: ${migration.version}');
      await apply(migration);
    }

    return unapplied.length;
  }

  Future<bool> migrationsTableExists() async {
    // If this is the first time we're running migrations, then the
    // migrations table won't exist.
    const tableExists = '''
      SELECT 1 FROM sqlite_master
        WHERE type = 'table'
          AND name = ?
    ''';
    final resTables = await adapter.query(
      Statement(
        tableExists,
        [tableName],
      ),
    );

    return resTables.isNotEmpty;
  }

  Future<List<MigrationRecord>> queryApplied() async {
    if (!(await migrationsTableExists())) {
      return [];
    }

    final existingRecords = '''
      SELECT version FROM $tableName
        ORDER BY id ASC
    ''';
    final rows = await adapter.query(Statement(existingRecords));
    return rows
        .map(
          (r) => MigrationRecord(
            version: r['version']! as String,
          ),
        )
        .toList();
  }

  // Returns the version of the most recently applied migration
  @override
  Future<String?> querySchemaVersion() async {
    if (!(await migrationsTableExists())) {
      return null;
    }

    // The hard-coded version '0' below corresponds to the version of the internal migration defined in `schema.ts`.
    // We're ignoring it because this function is supposed to return the application schema version.
    final schemaVersion = '''
      SELECT version FROM $tableName
        WHERE version != '0'
        ORDER BY version DESC
        LIMIT 1
    ''';
    final rows = await adapter.query(Statement(schemaVersion));
    if (rows.isEmpty) {
      return null;
    }

    return rows.first['version']! as String;
  }

  Future<List<StmtMigration>> validateApplied(
    List<StmtMigration> migrations,
    List<MigrationRecord> existing,
  ) async {
    // First we validate that the existing records are the first migrations.
    for (var i = 0; i < existing.length; i++) {
      final migrationRecord = existing[i];
      final version = migrationRecord.version;

      final migration = migrations[i];

      if (migration.version != version) {
        throw Exception(
          'Local migrations $version does not match server version ${migration.version}. '
          'This is an unrecoverable error. Please clear your local storage and try again. '
          'Check documentation (https://electric-sql.com/docs/reference/limitations) to learn more.',
        );
      }
    }

    // Then we can confidently slice and return the non-existing.
    final localMigrations = [...migrations];
    localMigrations.removeRange(0, existing.length);
    return localMigrations;
  }

  @override
  Future<void> apply(StmtMigration migration) async {
    final statements = migration.statements;
    final version = migration.version;

    if (!kValidVersionExp.hasMatch(version)) {
      throw Exception(
        'Invalid migration version, must match $kValidVersionExp',
      );
    }

    final applied = '''
    INSERT INTO $tableName
        ('version', 'applied_at') VALUES (?, ?)
        ''';

    await adapter.runInTransaction([
      ...statements,
      Statement(applied, [version, DateTime.now().millisecondsSinceEpoch]),
    ]);
  }

  /// Applies the provided migration only if it has not yet been applied.
  /// `migration`: The migration to apply.
  /// Returns A future that resolves to a boolean
  /// that indicates if the migration was applied.
  @override
  Future<bool> applyIfNotAlready(StmtMigration migration) async {
    final versionExists = '''
      SELECT 1 FROM $tableName
        WHERE version = ?
    ''';
    final rows = await adapter.query(
      Statement(
        versionExists,
        [migration.version],
      ),
    );

    final shouldApply = rows.isEmpty;

    if (shouldApply) {
      // This is a new migration because its version number
      // is not in our migrations table.
      await apply(migration);
    }

    return shouldApply;
  }
}