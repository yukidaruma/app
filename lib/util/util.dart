import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:salmon_stats_app/config.dart';
import 'package:salmon_stats_app/repository/splatnet_repository.dart';
import 'package:salmon_stats_app/ui/typedefs.dart';

CookieJar createCookieJar(String iksmSession) {
  final CookieJar cookieJar = CookieJar();
  cookieJar.saveFromResponse(Uri.parse(Config.SPLATNET_ORIGIN), <Cookie>[
    Cookie('iksm_session', iksmSession),
  ]);

  return cookieJar;
}

Map<String, dynamic> jsonDecodeMap(String source) {
  return jsonDecode(source) as Map<String, dynamic>;
}

Future<IksmStatus> validateIksmSession(CookieJar cookieJar) {
  return SplatnetAPIRepository(cookieJar)
      .fetchNSAId()
      .then(
        (_) => IksmStatus.valid,
      )
      .catchError(
        (dynamic _) => IksmStatus.expired,
        test: (dynamic error) => error is DioError && error.response?.statusCode == 403,
      )
      .catchError(
        (dynamic _) => IksmStatus.error,
      );
}
