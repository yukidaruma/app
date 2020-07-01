import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

const List<String> validResolutions = <String>['major', 'minor', 'patch', 'build'];

void main(List<String> args) {
  final String resolution = args.isEmpty ? validResolutions.last : args.first;
  if (!validResolutions.contains(resolution)) {
    throw ArgumentError('Resolution must be one of: ${validResolutions.join(', ')}');
  }

  final String cwd = Directory.current.path;
  final File pubspec = File(join(cwd, 'pubspec.yaml'));
  if (!pubspec.existsSync()) {
    print('Error: No pubspec.yaml found in current working directory.');
    exit(1);
  }

  const LineSplitter splitter = LineSplitter();
  final StringBuffer buffer = StringBuffer();
  final List<String> lines = splitter.convert(pubspec.readAsStringSync());
  final RegExp versionPattern = RegExp(r'^version:\s*(\d+\.\d+\.\d+\+\d+)$');

  for (final String line in lines) {
    final Match match = versionPattern.firstMatch(line);

    if (match == null) {
      buffer.write(line);
    } else {
      final String currentVersion = match.group(1);
      final RegExp semverPattern = RegExp(r'^(\d+)\.(\d+).(\d+)\+(\d+)$');
      final Match semverMatch = semverPattern.firstMatch(currentVersion);

      int major = int.parse(semverMatch.group(1));
      int minor = int.parse(semverMatch.group(2));
      int patch = int.parse(semverMatch.group(3));
      final int build = int.parse(semverMatch.group(4));

      switch (resolution) {
        case 'major':
          major += 1;
          minor = 0;
          patch = 0;
          break;

        case 'minor':
          minor += 1;
          patch = 0;
          break;

        case 'patch':
          patch += 1;
          break;

        case 'build':
          // Only touches build number.
          break;
      }

      final String newSemver = '$major.$minor.$patch+${build + 1}';
      buffer.write('version: $newSemver');

      stdout.write(newSemver);
    }

    buffer.write('\n');
  }

  pubspec.writeAsStringSync(buffer.toString());
}
