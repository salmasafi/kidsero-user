import 'dart:convert';
import 'dart:io';

void main() async {
  final dir = Directory('lib/l10n');
  if (!await dir.exists()) {
    print('lib/l10n directory not found');
    exit(2);
  }

  final arbFiles = await dir
      .list()
      .where((f) => f is File && f.path.endsWith('.arb'))
      .cast<File>()
      .toList();

  if (arbFiles.isEmpty) {
    print('No .arb files found in lib/l10n');
    exit(0);
  }

  // Load maps
  final Map<String, Set<String>> localeKeys = {};

  for (final file in arbFiles) {
    final content = await file.readAsString();
    try {
      final jsonMap = json.decode(content) as Map<String, dynamic>;
      final keys = jsonMap.keys
          .where((k) => !k.startsWith('@'))
          .map((k) => k.trim())
          .toSet();
      final locale = file.uri.pathSegments.last.replaceAll('.arb', '');
      localeKeys[locale] = keys;
    } catch (e) {
      print('Failed to parse ${file.path}: $e');
    }
  }

  // Choose english as canonical if available, otherwise union
  final canonical = localeKeys.containsKey('app_en')
      ? localeKeys['app_en']!
      : localeKeys.values.fold<Set<String>>({}, (a, b) => a..addAll(b));

  print(
    '\nLocalization keys check (canonical = ${localeKeys.containsKey('app_en') ? 'app_en' : 'union'})',
  );
  print('Total canonical keys: ${canonical.length}\n');

  var issuesFound = false;
  for (final entry in localeKeys.entries) {
    final locale = entry.key;
    final keys = entry.value;
    final missing = canonical.difference(keys);
    final extra = keys.difference(canonical);
    if (missing.isEmpty && extra.isEmpty) {
      print('- $locale: OK (${keys.length} keys)');
    } else {
      issuesFound = true;
      print('- $locale: ${keys.length} keys');
      if (missing.isNotEmpty) {
        print('  Missing ${missing.length} keys:');
        for (final k in missing) {
          print('    - $k');
        }
      }
      if (extra.isNotEmpty) {
        print('  Extra ${extra.length} keys:');
        for (final k in extra) {
          print('    - $k');
        }
      }
    }
    print('');
  }

  if (!issuesFound) {
    print('All localization files contain the same keys.');
  } else {
    print('Differences detected. Please review the missing/extra keys above.');
  }
}
