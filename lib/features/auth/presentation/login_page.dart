// lib/features/auth/presentation/login_page.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logs_mobile_app/features/auth/state/auth_controller.dart';
import '../../../shared/widgets/bw_button.dart';
import '../../../shared/widgets/bw_text_field.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';
import 'splash_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailC = TextEditingController();
  final passC = TextEditingController();

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final loading = state is AuthLoading;

    // Centralized routing via SplashPage after any successful auth state
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (!mounted) return;

      if (next is AuthNeedsEmailVerification || next is Authenticated) {
        // Go to Splash; Splash will route to Home or VerifyEmail
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SplashPage()),
          (_) => false,
        );
      } else if (next is Unauthenticated && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  const Text(
                    'Welcome back',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 24),
                  BWTextField(
                    controller: emailC,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  BWTextField(
                    controller: passC,
                    label: 'Password',
                    obscure: true,
                  ),
                  const SizedBox(height: 24),
                  BWButton(
                    label: 'Sign in',
                    loading: loading,
                    onPressed: () => ref
                        .read(authControllerProvider.notifier)
                        .login(emailC.text.trim(), passC.text),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage()),
                    ),
                    child: const Text('Forgot password?',
                        style: TextStyle(color: Colors.black)),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No account? '),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SignupPage()),
                        ),
                        child: const Text('Create one',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
