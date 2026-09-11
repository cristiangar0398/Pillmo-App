import 'package:dio/dio.dart';

class AppHeadersInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept'] = 'application/json';
    if (options.data != null && options.data is! FormData) {
      options.headers['Content-Type'] = 'application/json';
    }
    handler.next(options);
  }
}

class AppLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('➡️ REQUEST: ${options.method} ${options.uri}');
    print('Headers: ${options.headers}');
    if (options.data != null) {
      print('Body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('⬅️ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    print('Body: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERROR: ${err.response?.statusCode} ${err.requestOptions.uri}');
    print('Message: ${err.message}');
    handler.next(err);
  }
}
