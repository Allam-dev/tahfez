import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:tahfez/core/data/sources/remote/api/interceptors/cache_interceptor.dart';
import 'restful_api_base_urls.dart';

class DioFactory {
  DioFactory._();
  static final instance = DioFactory._();
  Dio? _dio;

  Dio get dio {
    assert(
      _dio != null,
      'Dio must be initialized first, Call `DioFactory.instance.init()` in your main function before `runApp()` function',
    );
    return _dio!;
  }

  Future<void> init() async {
    _dio = Dio(
      BaseOptions(
        sendTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 5),
        connectTimeout: Duration(seconds: 5),
        baseUrl: RestfulApiBaseUrls.production,
        extra: {'reload': false},
        validateStatus: (statusCode) =>
            statusCode != null && statusCode >= 200 && statusCode < 300,
      ),
    );
    _dio!.interceptors.addAll([
      PrettyDioLogger(requestBody: true, requestHeader: true),
      CacheInterceptor(),
      // AuthInterceptor(tokenHandler),
    ]);
  }
}
