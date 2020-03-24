import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/widgets.dart' show mustCallSuper;
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

  @mustCallSuper
  Future<U> get(String url, [RequestOptions options]) async {
    final Response<T> response = await _dio.get<T>(url, options: options);
    return parseResponse(response);
  }

  @mustCallSuper
  Future<U> postJson(String url, Map<String, dynamic> payload, [RequestOptions options]) async {
    final Response<T> response = await _dio.post<T>(
      url,
      data: payload,
      options: options..contentType = 'application/json',
    );
    return parseResponse(response);
  }
}

class SalmonStatsAPIProvider extends _APIProvider<String, String> {
  @override
  // ignore: avoid_renaming_method_parameters
  Future<String> get(String path, [_]) => super.get(Config.SALMON_STATS_API_ORIGIN + path);

  @override
  // ignore: avoid_renaming_method_parameters
  Future<String> postJson(String path, Map<String, dynamic> payload, [RequestOptions options]) => super.postJson(Config.SALMON_STATS_API_ORIGIN + path, payload, options);

  @override
  String parseResponse(Response<String> response) {
    switch (response.statusCode) {
      case 200:
        return response.data;
      default:
        throw APIException.salmonStats('Status Code ${response.statusCode}');
    }
  }
}

class SplatnetAPIProvider extends _APIProvider<String, String> {
  SplatnetAPIProvider(CookieJar cookieJar) : super(cookieJar);

  @override
  // ignore: avoid_renaming_method_parameters
  Future<String> get(String path, [RequestOptions options]) => super.get(Config.SPLATNET_API_ORIGIN + path, options);

  @override
  String parseResponse(Response<String> response) {
    switch (response.statusCode) {
      case 200:
        return response.data;
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
