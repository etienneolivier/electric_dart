// Generates the drift_schema.dart file from the prisma schema.
// This is part of the process that electricsql_cli does, but
// for the e2e, we start from the prisma schema instead of from
// the Postgres schema.

import 'dart:io';

import 'package:electricsql_cli/electricsql_cli.dart';
import 'package:path/path.dart';

final Directory projectDir =
    Directory(join(File(Platform.script.toFilePath()).parent.path, ".."))
        .absolute;

Future<void> main() async {
  final prismaSchemaFile = File(join(projectDir.path, "prisma/schema.prisma"));

  final prismaSchemaContent = prismaSchemaFile.readAsStringSync();

  final schemaInfo = extractInfoFromPrismaSchema(
    prismaSchemaContent,
    genOpts: null,
  );

  final driftSchemaFile =
      File(join(projectDir.path, "lib/generated/electric/drift_schema.dart"));
  await buildDriftSchemaDartFile(schemaInfo, driftSchemaFile);
}
