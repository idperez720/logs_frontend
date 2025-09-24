import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../../core/jwt_storage.dart';
import 'auth_models.dart';

class AuthRepository {
  final Dio _dio = ApiClient.I.dio;

  String _messageFromDioError(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
      if (data is Map && data['detail'] is String) {
        return data['detail'] as String;
      }
      if (data is Map && data['detail'] is List && data['detail'].isNotEmpty) {
        final first = data['detail'].first;
        if (first is Map && first['msg'] is String)
          return first['msg'] as String;
      }
      if (e.message != null && e.message!.isNotEmpty) return e.message!;
    } catch (_) {}
    return 'Request failed';
  }

  Future<AuthResponse> signup(UserSignupRequest req) async {
    try {
      final res = await _dio.post('/api/v1/auth/signup', data: req.toJson());
      final auth = AuthResponse.fromJson(res.data);
      await JwtStorage.save(auth.token.accessToken);
      return auth;
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  Future<AuthResponse> login(UserLoginRequest req) async {
    try {
      final res = await _dio.post('/api/v1/auth/login', data: req.toJson());
      final auth = AuthResponse.fromJson(res.data);
      await JwtStorage.save(auth.token.accessToken);
      return auth;
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  Future<UserResponse> me() async {
    try {
      final res = await _dio.get('/api/v1/auth/me');
      return UserResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  Future<UserResponse> updateMe(UpdateCurrentUserRequest req) async {
    try {
      final res = await _dio.put('/api/v1/auth/me', data: req.toJson());
      return UserResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  Future<void> deleteMe() async {
    try {
      await _dio.delete('/api/v1/auth/me');
      await JwtStorage.clear();
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/api/v1/auth/logout');
    } on DioException {
      // Surface only the message without stopping local logout side-effects
      // You can choose to ignore or rethrow depending on UX; here we ignore.
    } finally {
      await JwtStorage.clear();
    }
  }

  Future<void> verifyEmail(EmailVerificationRequest req) async {
    try {
      await _dio.post('/api/v1/auth/verify-email', data: req.toJson());
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  Future<void> resendVerification() async {
    try {
      await _dio.post('/api/v1/auth/resend-verification');
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  Future<void> forgotPassword(PasswordResetRequest req) async {
    try {
      await _dio.post('/api/v1/auth/forgot-password', data: req.toJson());
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  Future<void> resetPassword(PasswordResetConfirm req) async {
    try {
      await _dio.post('/api/v1/auth/reset-password', data: req.toJson());
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }
}
