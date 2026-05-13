import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../config/app_config.dart';
import 'api_exception.dart';

@lazySingleton
class ApiClient {
  ApiClient() : _dio = _buildDio();

  final Dio _dio;

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'x-apisports-key': AppConfig.apiKey,
          'Accept': 'application/json',
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          requestBody: false,
          responseBody: true,
          logPrint: (obj) => debugPrint('[API] $obj'),
        ),
      );
    }

    return dio;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw ParseException(e.toString());
    }
  }

  Map<String, dynamic> _parseResponse(Response<Map<String, dynamic>> response) {
    final data = response.data;
    if (data == null) throw const ParseException('Resposta vazia do servidor.');

    // API Football envolve dados em { "response": [...], "errors": {} }
    final errors = data['errors'];
    if (errors is Map && errors.isNotEmpty) {
      throw ServerException(errors.values.first.toString(), response.statusCode ?? 0);
    }

    return data;
  }

  ApiException _mapDioException(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const TimeoutException(),
      DioExceptionType.connectionError => const NetworkException(),
      DioExceptionType.badResponse => _mapStatusCode(e.response?.statusCode ?? 0, e.message ?? ''),
      DioExceptionType.cancel => const NetworkException(),
      _ => const NetworkException(),
    };
  }

  ApiException _mapStatusCode(int statusCode, String message) {
    return switch (statusCode) {
      401 || 403 => const UnauthorizedException(),
      404 => const NotFoundException(),
      _ => ServerException('Erro no servidor ($statusCode)', statusCode),
    };
  }
}
