import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:tahfez/core/data/sources/local/hive/hive_helper.dart';

class CacheInterceptor extends Interceptor {
  final Box box = Hive.box(HiveBoxes.httpCache.name);

  String _keyFor(RequestOptions options) {
    return options.uri.toString();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method == 'GET') {
      final bool isReload = options.extra['reload'] == true;
      final key = _keyFor(options);
      if (!isReload) {
        final cached = box.get(key);
        if (cached != null) {
          final response = Response(
            requestOptions: options,
            data: jsonDecode(cached['data']),
            statusCode: cached['statusCode'],
          );
          return handler.resolve(response);
        }
      }
    }
    return handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    if (response.requestOptions.method == 'GET' && response.statusCode == 200) {
      final key = _keyFor(response.requestOptions);
      await box.put(key, {
        'data': jsonEncode(response.data),
        'statusCode': response.statusCode,
      });
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.requestOptions.method == 'GET') {
      final key = _keyFor(err.requestOptions);
      final cached = box.get(key);
      if (cached != null) {
        final response = Response(
          requestOptions: err.requestOptions,
          data: jsonDecode(cached['data']),
          statusCode: cached['statusCode'],
        );
        return handler.resolve(response);
      }
    }
    return handler.next(err);
  }
}
