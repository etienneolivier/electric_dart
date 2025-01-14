/// electricsql_cli, A Very Good Project created by Very Good CLI.
///
/// ```sh
/// # activate electricsql_cli
/// dart pub global activate electricsql_cli
///
/// # see usage
/// electricsql_cli --help
/// ```
library electricsql_cli;

export 'package:code_builder/code_builder.dart';
export 'package:electricsql_cli/src/commands/generate/builder.dart'
    show buildDriftSchemaDartFile;
export 'package:electricsql_cli/src/commands/generate/command.dart'
    show runElectricCodeGeneration;
export 'package:electricsql_cli/src/commands/generate/drift_gen_opts.dart'
    show
        DataClassNameInfo,
        DriftColumnGenOpts,
        DriftTableGenOpts,
        ElectricDriftGenOpts;
export 'package:electricsql_cli/src/commands/generate/drift_schema.dart';
export 'package:electricsql_cli/src/commands/generate/prisma.dart'
    show extractInfoFromPrismaSchema;
export 'package:electricsql_cli/src/drift_gen_util.dart'
    show clientDefaultExpression, dateTimeNowExpression;
