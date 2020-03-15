import 'dart:convert';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:salmonia_android/config.dart';

abstract class _APIProvider<T, U> {
  _APIProvider([this.cookieJar]) {
    final Dio dio = Dio();

    if (cookieJar != null) {
      dio.interceptors.add(CookieManager(cookieJar));
    }

    _dio = dio;
  }

  Dio _dio;
  final CookieJar cookieJar;

  U parseResponse(Response<T> response);

  Future<U> get(String url, [RequestOptions options]) async {
    final Response<T> response = await _dio.get<T>(url, options: options);
    return parseResponse(response);
  }
}

class SalmonStatsAPIProvider extends _APIProvider<String, Map<String, dynamic>> {
  @override
  // ignore: avoid_renaming_method_parameters
  Future<Map<String, dynamic>> get(String path, [_]) => super.get(Config.SALMON_STATS_API_ORIGIN + path);

  @override
  Map<String, dynamic> parseResponse(Response<String> response) {
    switch (response.statusCode) {
      case 200:
        return Map<String, dynamic>.from(json.decode(response.data) as Map<dynamic, dynamic>);
      default:
        throw APIException.salmonStats('Status Code ${response.statusCode}');
    }
  }
}

class SplatnetAPIProvider extends _APIProvider<String, Map<String, dynamic>> {
  SplatnetAPIProvider(CookieJar cookieJar) : super(cookieJar);

  @override
  // ignore: avoid_renaming_method_parameters
  Future<Map<String, dynamic>> get(String path, [RequestOptions options]) => super.get(Config.SPLATNET_API_ORIGIN + path, options);

  @override
  Map<String, dynamic> parseResponse(Response<String> response) {
    switch (response.statusCode) {
      case 200:
        return Map<String, dynamic>.from(json.decode(response.data) as Map<dynamic, dynamic>);
      default:
        throw APIException.splatnet('Status Code ${response.statusCode}');
    }
  }
}

class APIException implements Exception {
  const APIException(this._source, [dynamic message]) : _message = message;

  factory APIException.salmonStats(String message) {
    return APIException('Salmon Stats', message);
  }

  factory APIException.splatnet(String message) {
    return APIException('Splatnet', message);
  }

  final dynamic _message;
  final String _source;

  @override
  String toString() => 'Faield to connect to $_source' + (': $_message' ?? '');
}
