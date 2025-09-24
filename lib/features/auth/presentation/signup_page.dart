// lib/features/auth/presentation/signup_page.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logs_mobile_app/features/auth/state/auth_controller.dart';
import '../../../shared/widgets/bw_button.dart';
import '../../../shared/widgets/bw_text_field.dart';
import '../../../shared/validators.dart';
import 'splash_page.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});
  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final emailC = TextEditingController();
  final nameC = TextEditingController();
  final passC = TextEditingController();
  final phoneC = TextEditingController();

  bool _routed = false; // guard against double navigation

  @override
  void dispose() {
    emailC.dispose();
    nameC.dispose();
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BWTextField(
                      controller: emailC,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validatorType: ValidatorType.email,
                    ),
                    const SizedBox(height: 16),
                    BWTextField(
                      controller: nameC,
                      label: 'Name',
                      // Keep no validation to maintain original behavior/design.
                      // If you want it required, add a simple validator here.
                    ),
                    const SizedBox(height: 16),
                    BWTextField(
                      controller: passC,
                      label: 'Password',
                      obscure: true,
                      validatorType: ValidatorType.password,
                    ),
                    const SizedBox(height: 16),
                    BWTextField(
                      controller: phoneC,
                      label: 'Phone (optional)',
                      keyboardType: TextInputType.phone,
                      // Allow empty = valid; otherwise use phone validator.
                      validator: (v) {
                        final t = v?.trim() ?? '';
                        if (t.isEmpty) return null;
                        return Validators.phoneValidator(t);
                      },
                    ),
                    const SizedBox(height: 24),
                    BWButton(
                      label: 'Sign up',
                      loading: loading,
                      onPressed: () {
                        final ok = _formKey.currentState?.validate() ?? false;
                        if (!ok) return;

                        ref.read(authControllerProvider.notifier).signup(
                              emailC.text.trim(),
                              nameC.text.trim(),
                              passC.text,
                              phone: phoneC.text.trim().isEmpty
                                  ? null
                                  : phoneC.text.trim(),
                            );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
