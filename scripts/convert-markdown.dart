// ignore_for_file: always_specify_types

import 'dart:convert';
import 'dart:io';

import 'package:markdown/markdown.dart';

Future<void> main() async {
  final input = await stdin.transform(const Utf8Decoder()).single.timeout(const Duration(seconds: 1));

  stdout.write(markdownToHtml(input));
}
