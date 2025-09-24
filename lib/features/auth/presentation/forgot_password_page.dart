// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logs_mobile_app/features/auth/data/auth_models.dart';
import 'package:logs_mobile_app/features/auth/state/auth_controller.dart';
import 'package:logs_mobile_app/shared/widgets/bw_button.dart';
import 'package:logs_mobile_app/shared/widgets/bw_text_field.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final emailC = TextEditingController();
  final codeC = TextEditingController();
  final passC = TextEditingController();

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
                          onPressed: () async {
                            await ref
                                .read(authRepositoryProvider)
                                .forgotPassword(
                                    PasswordResetRequest(emailC.text.trim()));
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Reset code sent')));
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
                      await ref
                          .read(authRepositoryProvider)
                          .resetPassword(PasswordResetConfirm(
                            email: emailC.text.trim(),
                            resetCode: codeC.text.trim(),
                            newPassword: passC.text,
                          ));
                      if (mounted) Navigator.pop(context);
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
