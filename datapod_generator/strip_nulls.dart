import 'dart:io';

void main() {
  final files = [
    'lib/src/database_context_generator.dart',
    'lib/src/entity_generator.dart',
    'lib/src/initializer_generator.dart',
    'lib/src/repository_generator.dart',
    'lib/src/sql_generator.dart'
  ];

  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) continue;
    String content = file.readAsStringSync();

    // 1. Remove if (element != null && ...)
    content = content.replaceAll(RegExp(r'if \((element|method|p|param|field|classElement|returnType) \!= null \&\& '), 'if (');

    // 2. Remove ! from variable names
    content = content.replaceAll(RegExp(r'(\$relationshipContext|database|mapper|ops|row|ann)\!'), r'\1');
    content = content.replaceAll(RegExp(r'ann\?'), 'ann');
    
    // 3. Remove other dead null ops
    content = content.replaceAll(RegExp(r'\&\& (\$[a-zA-Z0-9_]+|[a-zA-Z0-9_]+) \!= null'), '');

    file.writeAsStringSync(content);
  }
}
