// lib/features/auth/presentation/verify_email_page.dart

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logs_mobile_app/features/auth/state/auth_controller.dart';

import '../../../shared/widgets/bw_button.dart';
import '../../../shared/widgets/bw_text_field.dart';
import 'splash_page.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  final String initialEmail;
  const VerifyEmailPage({super.key, required this.initialEmail});

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  late final TextEditingController emailC =
      TextEditingController(text: widget.initialEmail);
  final TextEditingController otpC = TextEditingController();

  bool _routed = false; // guard double navigation

  @override
  void dispose() {
    emailC.dispose();
    otpC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final loading = state is AuthLoading;

    // Centralized routing: after success, jump to Splash (no pop)
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (!mounted || _routed) return;

      if (next is Authenticated) {
        _routed = true;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SplashPage()),
          (_) => false,
        );
      } else if (next is Unauthenticated && next.error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Verify email')),
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
                    controller: otpC,
                    label: 'OTP code',
                  ),
                  const SizedBox(height: 24),
                  BWButton(
                    label: 'Verify',
                    loading: loading,
                    onPressed: () => ref
                        .read(authControllerProvider.notifier)
                        .verifyEmail(emailC.text.trim(), otpC.text.trim()),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      await ref
                          .read(authRepositoryProvider)
                          .resendVerification();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('OTP resent')),
                      );
                    },
                    child: const Text('Resend OTP',
                        style: TextStyle(color: Colors.black)),
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
