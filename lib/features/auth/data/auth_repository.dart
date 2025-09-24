import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../../core/jwt_storage.dart';
import 'auth_models.dart';

class AuthRepository {
  final Dio _dio = ApiClient.I.dio;

  Future<AuthResponse> signup(UserSignupRequest req) async {
    final res = await _dio.post('/api/v1/auth/signup', data: req.toJson());
    final auth = AuthResponse.fromJson(res.data);
    await JwtStorage.save(auth.token.accessToken);
    return auth;
  }

  Future<AuthResponse> login(UserLoginRequest req) async {
    final res = await _dio.post('/api/v1/auth/login', data: req.toJson());
    final auth = AuthResponse.fromJson(res.data);
    await JwtStorage.save(auth.token.accessToken);
    return auth;
  }

  Future<UserResponse> me() async {
    final res = await _dio.get('/api/v1/auth/me');
    return UserResponse.fromJson(res.data);
  }

  Future<void> logout() async {
    try {
      await _dio.post('/api/v1/auth/logout');
    } catch (_) {}
    await JwtStorage.clear();
  }

  Future<void> verifyEmail(EmailVerificationRequest req) async {
    await _dio.post('/api/v1/auth/verify-email', data: req.toJson());
  }

  Future<void> resendVerification() async {
    await _dio.post('/api/v1/auth/resend-verification');
  }

  Future<void> forgotPassword(PasswordResetRequest req) async {
    await _dio.post('/api/v1/auth/forgot-password', data: req.toJson());
  }

  Future<void> resetPassword(PasswordResetConfirm req) async {
    await _dio.post('/api/v1/auth/reset-password', data: req.toJson());
  }
}
