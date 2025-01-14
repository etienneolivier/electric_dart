/// Parses the Prisma schema and returns all models.
/// @param prismaSchema The Prisma schema to parse
/// @returns Array of models.
List<Model> parseModels(String prismaSchema) {
  // Remove comments
  // matches // until end of the line (also matches field validators added with ///)
  final commentRegex = RegExp(r'\/\/.*$', multiLine: true);
  final schema = prismaSchema.replaceAll(commentRegex, '');

  // Match models defined in the schema
  final modelRegex =
      RegExp(r'^\s*model\s+(?<name>\w+)\s*{(?<body>[^}]*)}', multiLine: true);
  final matches = [...modelRegex.allMatches(schema)];
  final modelBodies = matches.map((match) {
    final name = match.namedGroup('name')!.trim();
    final body = match.namedGroup('body')!;

    return (
      name: name,
      body: body,
    );
  });

  // Match fields in the body of the models
  return modelBodies
      .map(
        (model) => Model(
          name: model.name,
          fields: parseFields(model.body),
          attributes: _parseModelAttributes(model.body),
        ),
      )
      .toList();
}

/// Takes the body of a model and returns
/// an array of fields defined by the model.
/// @param body Body of a model
/// @returns Fields defined by the model
List<Field> parseFields(String body) {
  // The regex below matches the fields of a model (it assumes there are no comments at the end of the line)
  // It uses named captured groups to capture the field name, its type, and optional attributes
  // the type can be `type` or `type?` or `type[]`
  final fieldRegex = RegExp(
    r'^\s*(?<field>\w+)\s+(?<type>[\w]+(\?|(\[]))?)\s*(?<attributes>((@[\w.]+\s*)|(@[\w.]+\(.*\)+\s*))+)?\s*$',
    multiLine: true,
  );
  final fieldMatches = [...fieldRegex.allMatches(body)];
  final fs = fieldMatches.map((match) {
    final field = match.namedGroup('field')!.trim();
    final type = match.namedGroup('type')!.trim();
    final String? attributes = match.namedGroup('attributes');

    return (
      field: field,
      type: type,
      attributes: attributes,
    );
  });

  return fs.map((f) {
    return Field(
      field: f.field,
      type: f.type,
      attributes:
          _parseAttributes(f.attributes, attrType: _AttributeType.field),
    );
  }).toList();
}

List<Attribute> _parseModelAttributes(String body) {
  final attrsRegex = RegExp(
    r'^\s*(?<attribute>(@@[\w.]+\(.*\)+\s*))\s*$',
    multiLine: true,
  );
  final modelAttrsMatches = [...attrsRegex.allMatches(body)];
  final attrs = modelAttrsMatches.map((match) {
    final String attribute = match.namedGroup('attribute')!;

    final parsed = _parseAttributes(attribute, attrType: _AttributeType.model);
    assert(parsed.length == 1, 'Expected exactly @@ attribute');
    return parsed[0];
  }).toList();

  return attrs;
}

enum _AttributeType {
  field,
  model,
}

/// Takes a string of attributes, e.g. `@id @db.Timestamp(2)`,
/// and returns an array of attributes, e.g. `['@id', '@db.Timestamp(2)]`.
/// @param attributes String of attributes
/// @returns Array of attributes.
List<Attribute> _parseAttributes(
  String? attributes, {
  required _AttributeType attrType,
}) {
  if (attributes == null) return [];

  final prefix = switch (attrType) {
    _AttributeType.field => '@',
    _AttributeType.model => '@@',
  };

  // Matches each attribute in a string of attributes
  // e.g. @id @db.Timestamp(2)
  // The optional args capture group matches anything
  // but not @or newline because that would be the start of a new attribute
  final attributeRegex = RegExp(
    // ignore: unnecessary_raw_strings
    r'(?<type>' + prefix + r'[\w\.]+)(?<args>\([^@\n\r]+\))?',
  );
  final matches = [...attributeRegex.allMatches(attributes)];
  return matches.map((m) {
    final type = m.namedGroup('type')!.trim();
    final String? args = m.namedGroup('args');

    List<String> parsedArgs = [];
    if (args != null && args.length > 2) {
      final noParens = args.substring(
        1,
        args.length - 1,
      ); // arguments without starting '(' and closing ')'
      parsedArgs = noParens.split(',').map((arg) => arg.trim()).toList();
    }

    assert(
      type.startsWith(prefix),
      'The attribute type is expected to start with $prefix',
    );
    return Attribute(
      type: type,
      args: parsedArgs,
    );
  }).toList();
}

class Attribute {
  // With the format @{string} or @@{string} if it is a model attribute
  final String type;
  final List<String> args;

  Attribute({required this.type, required this.args});

  @override
  String toString() {
    return "Attribute(type: '$type', args: ${args.map((s) => "'$s'").toList()})";
  }
}

class Field {
  final String field;
  final String type;
  final List<Attribute> attributes;

  Field({required this.field, required this.type, required this.attributes});

  @override
  String toString() {
    return "Field(field: '$field', type: '$type', attributes: $attributes)";
  }
}

class Model {
  final String name;
  final List<Field> fields;
  final List<Attribute> attributes;

  Model({
    required this.name,
    required this.fields,
    required this.attributes,
  });

  @override
  String toString() {
    return 'Model(name: $name, fields: $fields, attributes: $attributes)';
  }
}
