import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logs_mobile_app/features/auth/data/auth_models.dart';
import 'package:logs_mobile_app/features/auth/presentation/forgot_password_page.dart';
import 'package:logs_mobile_app/features/auth/state/auth_controller.dart';
import 'package:logs_mobile_app/shared/validators.dart';
import 'package:logs_mobile_app/shared/widgets/bw_button.dart';
import 'package:logs_mobile_app/shared/widgets/bw_text_field.dart';
import 'dart:async';
import 'package:logs_mobile_app/features/auth/presentation/splash_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _editing = false;

  // Controllers
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  final _bioC = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Prefill from auth state when possible
    final state = ref.read(authControllerProvider);
    if (state is Authenticated) {
      // These fields are optional; guard with try/catch in case of missing props
      try {
        // ignore: avoid_dynamic_calls
        _emailC.text = state.user.email.toString();
      } catch (_) {}
      try {
        // ignore: avoid_dynamic_calls
        _nameC.text = state.user.name?.toString() ?? '';
      } catch (_) {}
      try {
        // ignore: avoid_dynamic_calls
        _phoneC.text = state.user.phoneNumber?.toString() ?? '';
      } catch (_) {}
      // bio left empty by default
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _phoneC.dispose();
    _bioC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                    nameGetter: () => _nameC.text,
                    emailGetter: () => _emailC.text),
                const SizedBox(height: 24),
                if (!_editing) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: BWButton(
                      label: 'Edit info',
                      onPressed: () {
                        setState(() => _editing = true);
                        // After enabling editing, focus the first field
                        Future.microtask(() =>
                            FocusScope.of(context).requestFocus(FocusNode()));
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          IgnorePointer(
                            ignoring: !_editing,
                            child: BWTextField(
                              controller: _nameC,
                              label: 'Name',
                              // Keep name required but simple (no special validator)
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          IgnorePointer(
                            ignoring: !_editing,
                            child: BWTextField(
                              controller: _emailC,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              validatorType: ValidatorType.email,
                            ),
                          ),
                          const SizedBox(height: 16),
                          IgnorePointer(
                            ignoring: !_editing,
                            child: BWTextField(
                              controller: _phoneC,
                              label: 'Phone',
                              keyboardType: TextInputType.phone,
                              // optional phone: empty is valid, else must pass
                              validator: (v) {
                                final t = v?.trim() ?? '';
                                if (t.isEmpty) return null;
                                return Validators.phoneValidator(t);
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Opacity(
                            opacity: _editing ? 1.0 : 0.5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                BWButton(
                                  label: 'Save changes',
                                  onPressed: _editing ? _onSave : () {},
                                ),
                                const SizedBox(height: 8),
                                if (_editing)
                                  BWButton(
                                    label: 'Cancel',
                                    onPressed: _onCancel,
                                  ),
                                if (_editing) const SizedBox(height: 8),
                                BWButton(
                                  label: 'Change password',
                                  onPressed:
                                      _editing ? _onChangePassword : () {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(height: 32, color: Colors.black),
                const Text('Danger Zone',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete account?'),
                        content: const Text(
                          'This action is permanent. Are you sure you want to delete your account?',
                          style: TextStyle(color: Colors.black87),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Cancel',
                                style: TextStyle(color: Colors.black)),
                            onPressed: () => Navigator.of(ctx).pop(false),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black),
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true) return;

                    // Show Splash while deletion runs via controller
                    try {
                      unawaited(ref
                          .read(authControllerProvider.notifier)
                          .deleteAccount());
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const SplashPage()),
                          (_) => false,
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to start deletion: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.black),
                  label: const Text('Delete account',
                      style: TextStyle(color: Colors.black)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black, width: 1.5),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSave() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;
    // Call controller to update profile via PUT /api/v1/auth/me
    await ref.read(authControllerProvider.notifier).updateProfile(
          name: _nameC.text.trim(),
          email: _emailC.text.trim(),
          phoneNumber: _phoneC.text.trim().isEmpty ? null : _phoneC.text.trim(),
        );

    final newState = ref.read(authControllerProvider);
    if (newState is Unauthenticated && newState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: ${newState.error}')),
      );
      return; // keep editing so user can fix
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved')),
    );
    FocusScope.of(context).unfocus();
    setState(() {
      _editing = false;
    }); // refresh header with new name/email and lock form
  }

  void _onChangePassword() async {
    final state = ref.read(authControllerProvider);
    if (state is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to change password.')),
      );
      return;
    }

    final email = state.user.email;

    // Ask for confirmation first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset password?'),
        content: Text(
          'We will send a reset code to the email on your account (\n$email). Do you want to continue?',
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(authRepositoryProvider)
          .forgotPassword(PasswordResetRequest(email.trim()));
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ForgotPasswordPage(fromChangePassword: true),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start password reset: $e')),
      );
    }
  }

  void _onCancel() {
    final state = ref.read(authControllerProvider);
    if (state is Authenticated) {
      try {
        _emailC.text = state.user.email.toString();
      } catch (_) {}
      try {
        _nameC.text = state.user.name?.toString() ?? '';
      } catch (_) {}
      try {
        _phoneC.text = state.user.phoneNumber?.toString() ?? '';
      } catch (_) {}
    }
    FocusScope.of(context).unfocus();
    setState(() => _editing = false);
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.nameGetter,
    required this.emailGetter,
  });

  final String Function() nameGetter;
  final String Function() emailGetter;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first.characters.first.toUpperCase();
    final second =
        parts.length > 1 ? parts[1].characters.first.toUpperCase() : '';
    return '$first$second';
  }

  @override
  Widget build(BuildContext context) {
    final name = nameGetter().trim();
    final email = emailGetter().trim();
    final initials = _initials(name.isNotEmpty ? name : 'User');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Text(
                initials,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : 'Your name',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email.isNotEmpty ? email : 'your@email.com',
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit avatar (coming soon)',
              onPressed: () {},
              icon: const Icon(Icons.edit),
            ),
          ],
        ),
      ),
    );
  }
}
