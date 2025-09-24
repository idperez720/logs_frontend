// lib/features/auth/presentation/signup_page.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logs_mobile_app/features/auth/state/auth_controller.dart';
import '../../../shared/widgets/bw_button.dart';
import '../../../shared/widgets/bw_text_field.dart';
import 'splash_page.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});
  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final phoneC = TextEditingController();

  bool _routed = false; // guard against double navigation

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    phoneC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final loading = state is AuthLoading;

    // Centralized routing via SplashPage (no pop!)
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (!mounted || _routed) return;

      if (next is AuthNeedsEmailVerification || next is Authenticated) {
        _routed = true;
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
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  const SizedBox(height: 16),
                  BWTextField(
                    controller: phoneC,
                    label: 'Phone (optional)',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  BWButton(
                    label: 'Sign up',
                    loading: loading,
                    onPressed: () =>
                        ref.read(authControllerProvider.notifier).signup(
                              emailC.text.trim(),
                              passC.text,
                              phone: phoneC.text.isEmpty
                                  ? null
                                  : phoneC.text.trim(),
                            ),
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
