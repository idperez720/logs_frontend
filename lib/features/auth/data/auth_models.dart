// ignore_for_file: constant_identifier_names

class UserSignupRequest {
  final String email;
  final String name; // required by backend
  final String password;
  final String? phoneNumber;
  UserSignupRequest({
    required this.email,
    required this.name,
    required this.password,
    this.phoneNumber,
  });
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'email': email,
      'name': name,
      'password': password,
      'phone_number': phoneNumber,
    };
    map.removeWhere((_, v) => v == null);
    return map;
  }
}

class UserLoginRequest {
  final String email;
  final String password;
  UserLoginRequest({required this.email, required this.password});
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class EmailVerificationRequest {
  final String email;
  final String otp;
  EmailVerificationRequest({required this.email, required this.otp});
  Map<String, dynamic> toJson() => {'email': email, 'otp': otp};
}

class PasswordResetRequest {
  final String email;
  PasswordResetRequest(this.email);
  Map<String, dynamic> toJson() => {'email': email};
}

class PasswordResetConfirm {
  final String email;
  final String resetCode;
  final String newPassword;
  PasswordResetConfirm(
      {required this.email,
      required this.resetCode,
      required this.newPassword});
  Map<String, dynamic> toJson() =>
      {'email': email, 'reset_code': resetCode, 'new_password': newPassword};
}

class UpdateCurrentUserRequest {
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? password;
  UpdateCurrentUserRequest(
      {this.name, this.email, this.phoneNumber, this.password});
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'password': password,
    };
    map.removeWhere((_, v) => v == null);
    return map;
  }
}

class TokenResponse {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  TokenResponse(
      {required this.accessToken,
      required this.tokenType,
      required this.expiresIn});
  factory TokenResponse.fromJson(Map<String, dynamic> j) => TokenResponse(
        accessToken: j['access_token'],
        tokenType: j['token_type'] ?? 'bearer',
        expiresIn: j['expires_in'],
      );
}

enum UserStatus { ACTIVE, INACTIVE, EMAIL_VERIFICATION }

class UserResponse {
  final String id;
  final String? name;
  final String email;
  final String? phoneNumber;
  final UserStatus status;
  UserResponse(
      {required this.id,
      this.name,
      required this.email,
      this.phoneNumber,
      required this.status});
  factory UserResponse.fromJson(Map<String, dynamic> j) => UserResponse(
        id: j['id'],
        email: j['email'],
        name: j['name'],
        phoneNumber: j['phone_number'],
        status: UserStatus.values.firstWhere((e) => e.name == j['status']),
      );

  UserResponse copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    UserStatus? status,
  }) =>
      UserResponse(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        status: status ?? this.status,
      );
}

class AuthResponse {
  final UserResponse user;
  final TokenResponse token;
  AuthResponse({required this.user, required this.token});
  factory AuthResponse.fromJson(Map<String, dynamic> j) => AuthResponse(
        user: UserResponse.fromJson(j['user']),
        token: TokenResponse.fromJson(j['token']),
      );
}
