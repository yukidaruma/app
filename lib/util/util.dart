import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:salmonia_android/config.dart';

CookieJar createCookieJar(String iksmSession) {
  final CookieJar cookieJar = CookieJar();
  cookieJar.saveFromResponse(Uri.parse(Config.SPLATNET_ORIGIN), <Cookie>[
    Cookie('iksm_session', iksmSession),
  ]);

  return cookieJar;
}
