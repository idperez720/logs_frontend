import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';

sealed class AuthState {
  const AuthState();
}

class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthNeedsEmailVerification extends AuthState {
  final String email;
  const AuthNeedsEmailVerification(this.email);
}

class Authenticated extends AuthState {
  final UserResponse user;
  const Authenticated(this.user);
}

class Unauthenticated extends AuthState {
  final String? error;
  const Unauthenticated([this.error]);
}

final authRepositoryProvider =
    Provider<AuthRepository>((_) => AuthRepository());
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.read(authRepositoryProvider))..bootstrap(),
);

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(const AuthUnknown());
  final AuthRepository _repo;

  Future<void> bootstrap() async {
    try {
      state = const AuthLoading();
      final me = await _repo.me();
      state = Authenticated(me);
    } catch (_) {
      state = const Unauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = const AuthLoading();
      final auth =
          await _repo.login(UserLoginRequest(email: email, password: password));
      if (auth.user.status == UserStatus.EMAIL_VERIFICATION) {
        state = AuthNeedsEmailVerification(auth.user.email);
      } else {
        state = Authenticated(auth.user);
      }
    } catch (e) {
      state = Unauthenticated(e.toString());
    }
  }

  Future<void> signup(
    String email,
    String name,
    String password, {
    String? phone,
  }) async {
    try {
      state = const AuthLoading();
      final auth = await _repo.signup(UserSignupRequest(
          email: email, name: name, password: password, phoneNumber: phone));
      if (auth.user.status == UserStatus.EMAIL_VERIFICATION) {
        state = AuthNeedsEmailVerification(auth.user.email);
      } else {
        state = Authenticated(auth.user);
      }
    } catch (e) {
      state = Unauthenticated(e.toString());
    }
  }

  Future<void> verifyEmail(String email, String otp) async {
    try {
      state = const AuthLoading();
      await _repo.verifyEmail(EmailVerificationRequest(email: email, otp: otp));
      final me = await _repo.me();
      state = Authenticated(me);
    } catch (e) {
      state = Unauthenticated(e.toString());
    }
  }

  Future<void> forgot(String email) async {
    await _repo.forgotPassword(PasswordResetRequest(email));
  }

  Future<void> reset(String email, String code, String newPassword) async {
    await _repo.resetPassword(PasswordResetConfirm(
        email: email, resetCode: code, newPassword: newPassword));
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const Unauthenticated();
  }

  Future<void> deleteAccount() async {
    try {
      state = const AuthLoading();
      await _repo.deleteMe();
      state = const Unauthenticated();
    } catch (e) {
      state = Unauthenticated(e.toString());
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phoneNumber,
    String? password,
  }) async {
    try {
      state = const AuthLoading();
      final updatedUser = await _repo.updateMe(
        UpdateCurrentUserRequest(
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          password: password,
        ),
      );
      state = Authenticated(updatedUser);
    } catch (e) {
      state = Unauthenticated(e.toString());
    }
  }
}
