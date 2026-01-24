import 'package:dio/dio.dart';
import 'package:gms_flutter_windows/Remote/Interceptor.dart';
import 'package:gms_flutter_windows/Shared/Constant.dart';

class Dio_Linker {
  static late Dio dio;
  static const Duration globalTimeout = Duration(seconds: 15);

  static void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: Constant.baseAppURL,
        connectTimeout: globalTimeout,
        receiveTimeout: globalTimeout,
        sendTimeout: globalTimeout,
      ),
    );
    dio.interceptors.add(AuthInterceptor(dio));
  }

  static Future<Response> postData({
    required String url,
    dynamic data,
    Map<String, dynamic>? params,
  }) {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    return dio.post(
      url,
      data: data,
      options: Options(responseType: ResponseType.json, headers: headers),
    );
  }

  static Future<Response> putData({
    required String url,
    dynamic data,
    Map<String, dynamic>? params,
  }) {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    return dio.put(
      url,
      data: data,
      queryParameters: params,
      options: Options(responseType: ResponseType.json, headers: headers),
    );
  }

  static Future<Response> deleteData({
    required String url,
    Map<String, dynamic>? data,
    Map<String, dynamic>? params,
  }) {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    return dio.delete(
      url,
      data: data,
      queryParameters: params,
      options: Options(responseType: ResponseType.json, headers: headers),
    );
  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? data,
    Map<String, dynamic>? params,
  }) {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    return dio.get(
      url,
      data: data,
      queryParameters: params,
      options: Options(responseType: ResponseType.json, headers: headers),
    );
  }
}
