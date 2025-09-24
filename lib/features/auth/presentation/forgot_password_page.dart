// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logs_mobile_app/features/auth/data/auth_models.dart';
import 'package:logs_mobile_app/features/auth/state/auth_controller.dart';
import 'package:logs_mobile_app/shared/widgets/bw_button.dart';
import 'package:logs_mobile_app/shared/widgets/bw_text_field.dart';
import 'package:logs_mobile_app/features/auth/presentation/login_page.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  final bool fromChangePassword;
  const ForgotPasswordPage({super.key, this.fromChangePassword = false});
  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final emailC = TextEditingController();
  final codeC = TextEditingController();
  final passC = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(authControllerProvider);
    if (state is Authenticated) {
      emailC.text = state.user.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authControllerProvider) is AuthLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Password reset')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  BWTextField(
                      controller: emailC,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: BWButton(
                          label: 'Send code',
                          loading: loading,
                          onPressed: widget.fromChangePassword
                              ? () {}
                              : () {
                                  final email = emailC.text.trim();
                                  () async {
                                    try {
                                      await ref
                                          .read(authRepositoryProvider)
                                          .forgotPassword(
                                            PasswordResetRequest(email),
                                          );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Reset code sent')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Failed to send code: $e')),
                                      );
                                    }
                                  }();
                                },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  BWTextField(controller: codeC, label: 'Reset code'),
                  const SizedBox(height: 16),
                  BWTextField(
                      controller: passC, label: 'New password', obscure: true),
                  const SizedBox(height: 16),
                  BWButton(
                    label: 'Update password',
                    loading: loading,
                    onPressed: () async {
                      final email = emailC.text.trim();
                      final code = codeC.text.trim();
                      final newPass = passC.text;
                      try {
                        await ref.read(authRepositoryProvider).resetPassword(
                              PasswordResetConfirm(
                                  email: email,
                                  resetCode: code,
                                  newPassword: newPass),
                            );
                        if (!mounted) return;
                        // After reset, go to LoginPage
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (_) => false,
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to reset password: $e')),
                        );
                      }
                    },
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
