import 'package:dio/dio.dart';
import 'package:gms_flutter_windows/Bloc/Manager.dart';
import 'package:gms_flutter_windows/Remote/Dio_Linker.dart';
import 'package:gms_flutter_windows/Remote/End_Points.dart';
import 'package:gms_flutter_windows/Shared/SecureStorage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  bool _isRefreshing = false;
  final noAuthEndpoints = {LOGIN, REFRESHTOKEN};

  AuthInterceptor(this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip adding token to these endPoints
    if (noAuthEndpoints.contains(options.path)) {
      return handler.next(options);
    }
    final access = await TokenStorage.readAccessToken();
    if (access != null) {
      options.headers['Authorization'] = 'Bearer $access';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    // Skip refresh logic for these APIs
    if (noAuthEndpoints.contains(req.path)) {
      return handler.next(err);
    }
    if (err.response?.statusCode == 401 && !req.extra.containsKey('retry')) {
      try {
        final refreshed = await _handleRefreshToken();
        if (refreshed) {
          final opts = Options(
            method: req.method,
            headers: {
              ...req.headers,
              'Authorization': 'Bearer ${await TokenStorage.readAccessToken()}',
            },
            extra: {...req.extra, 'retry': true},
          );
          final cloneResponse = await dio.request(
            req.path,
            data: req.data,
            queryParameters: req.queryParameters,
            options: opts,
          );
          return handler.resolve(cloneResponse);
        } else {
          Manager manager = Manager();
          manager.performLogout();
          handler.next(err);
        }
      } catch (_) {
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }

  Future<bool> _handleRefreshToken() async {
    if (_isRefreshing) {
      while (_isRefreshing) {
        await Future.delayed(Duration(milliseconds: 150));
      }
      return (await TokenStorage.readAccessToken()) != null;
    }
    _isRefreshing = true;
    try {
      final refresh = await TokenStorage.readRefreshToken();
      if (refresh == null) return false;

      final response = await Dio_Linker.postData(
        url: REFRESHTOKEN,
        data: {'refreshToken': refresh},
      );
      final newAccess = response.data['accessToken'] as String?;
      final newRefresh = response.data['refreshToken'] as String?;
      if (newAccess != null && newRefresh != null) {
        await TokenStorage.writeAccessToken(newAccess);
        await TokenStorage.writeRefreshToken(newRefresh);
      }
      return newAccess != null;
    } catch (_) {
      await TokenStorage.deleteAccessToken();
      await TokenStorage.deleteRefreshToken();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }
}
