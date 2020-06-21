import 'dart:convert';

import 'package:flutter/services.dart';

bool _isNumeric(String string) => num.tryParse(string) != null;

Future<String> _loadStringAsset(String filename) {
  return rootBundle.loadString('assets/$filename');
}

Future<Map<String, dynamic>> loadEnv(String envPath) async {
  const LineSplitter splitter = LineSplitter();
  final Map<String, dynamic> env = <String, dynamic>{};

  String content;
  try {
    content = await _loadStringAsset(envPath);
  } catch (_) {
    return env;
  }

  final List<String> lines = splitter.convert(content);

  for (final String line in lines) {
    if (line.startsWith('#') || line.trim().isEmpty) {
      continue;
    }

    final List<String> pair = line.split('=');
    final String key = pair[0];
    final String value = pair[1];

    if (value == 'true' || value == 'false') {
      env[key] = value == 'true';
    } else if (_isNumeric(value)) {
      env[key] = num.parse(value);
    } else {
      env[key] = value;
    }
  }

  return env;
}
