// ignore_for_file: always_specify_types

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../lib/ui/extensions/iterable_extension.dart';

enum States {
  foundDelimiter,
  foundFirstLine,
  readingBody,
}

// The order of enum members should be the order of how they appear in generated
// release notes.
enum CommitType {
  /// Feature, fix commits has own section in generated release notes.
  feature,
  fix,

  /// Chore commits are commented out in generated release notes.
  /// Pick up manually if necessary (otherwise just remove them).
  chore,

  /// Documentation, internal (such as refactor) and meta commits (such as merge commit) are excluded
  /// from generated release notes.
  documentation,
  internal,
  meta,
}

const ignoreCommitTypes = <CommitType>[CommitType.documentation, CommitType.meta];
const metaCommits = <Pattern>['Merge'];
final RegExp scopePattern = RegExp(r'^(\w+)(?:\((\w+)\))?: ');

CommitType commitClassifier(String summary) {
  if (metaCommits.any(summary.startsWith)) {
    return CommitType.meta;
  }

  //  Pre-0.1.0 commit message support
  if (summary.startsWith('Fix')) {
    return CommitType.fix;
  } else if (summary.startsWith('Add')) {
    return CommitType.feature;
  }

  // message is a part of commit summary after ':'
  final match = scopePattern.firstMatch(summary);
  if (match == null) {
    return CommitType.chore;
  }

  final prefix = match.group(1);
  final scope = match.group(2);

  switch (prefix) {
    case 'chore':
      return CommitType.chore;
    case 'docs':
      return CommitType.documentation;
    case 'feature':
      return CommitType.feature;
    case 'fix':
      return CommitType.fix;
    case 'refactor':
      return CommitType.internal;
  }

  if (scope == 'internal') {
    // Treat chore(internal) as internal commit
    return CommitType.internal;
  }

  return CommitType.chore;
}

class Commit {
  Commit(this.summary, this.type);

  final String summary;
  final CommitType type;
  final body = <String>[];

  @override
  String toString() => '$type: $summary\n$body';
}

const splitter = LineSplitter();
const ignoreCommitBody = <Pattern>['Part of', 'Close'];

Future<void> main(List<String> args) async {
  final version = args.isEmpty ? '???' : args.first;
  final input = await stdin.transform(const Utf8Decoder()).single.timeout(const Duration(seconds: 1));
  final commits = <Commit>[];

  Commit commit;
  var state = States.foundDelimiter;

  for (final line in splitter.convert(input)) {
    switch (state) {
      case States.foundDelimiter:
        if (commit != null) {
          commits.add(commit);
        }

        commit = Commit(line, commitClassifier(line));
        state = States.foundFirstLine;

        break;

      case States.foundFirstLine:
        if (line.isEmpty) {
          continue;
        }

        state = States.readingBody;
        continue READING_BODY;

      READING_BODY:
      case States.readingBody:
        if (line.startsWith('----')) {
          state = States.foundDelimiter;
          continue;
        }

        if (ignoreCommitBody.any(line.startsWith)) {
          continue;
        }

        commit.body.add(line);
        break;
    }
  }

  print(_generateReleaseNotes(version, commits));
}

extension _ZeroPadExtension on int {
  String zeroPad(int digits) => toString().padLeft(digits, '0');
}

String _generateReleaseNotes(String version, List<Commit> commits) {
  final buf = StringBuffer();
  final now = DateTime.now();
  final date = '${now.year}-${now.month.zeroPad(2)}-${now.day.zeroPad(2)}';
  buf.write('# Version $version ($date)\n\n');

  const sectionHeadings = <CommitType, String>{
    CommitType.feature: 'Feature updates',
    CommitType.fix: 'Bug fixes',
    CommitType.chore: 'Other updates',
  };

  final groupedCommits = commits.where((commit) => sectionHeadings.containsKey(commit.type)).groupBy<CommitType>((commit) => commit.type);

  for (final entry in groupedCommits.entries.sortBy<num>((entry) => entry.key.index)) {
    final type = entry.key;
    final commits = entry.value;

    if (ignoreCommitTypes.contains(type) || commits.isEmpty) {
      continue;
    }

    buf.write('## ${sectionHeadings[type]}\n\n');

    for (final commit in commits) {
      final summary = commit.summary.replaceFirst(scopePattern, '').replaceFirst(':', '').trimLeft();
      // buf.write('* **${commit.summary}**  ${commit.body.join('  ')}\n');
      buf.write('* ${<String>[summary, ...commit.body].join('  ')}\n');
    }

    buf.write('\n');
  }

  return buf.toString().trimRight();
}
