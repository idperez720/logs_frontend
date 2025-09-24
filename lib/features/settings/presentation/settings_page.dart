import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logs_mobile_app/core/theme.dart';
import 'package:logs_mobile_app/features/auth/state/auth_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);
    final themeCtl = ref.read(themeControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Font', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),

            // Font options (radio list)
            ...AppFont.values.map((f) {
              return RadioListTile<AppFont>(
                activeColor: Colors.black,
                value: f,
                groupValue: themeState.font,
                title: Text(f.label),
                onChanged: (val) {
                  if (val != null) themeCtl.setFont(val);
                },
              );
            }),

            const SizedBox(height: 24),
            const Divider(height: 32, color: Colors.black),

            const Text('Danger Zone',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),

            // Delete account (confirmation dialog)
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

                // TODO: Wire to backend delete endpoint when available.
                // For now, we log out and show a message.
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Account deletion not implemented on backend yet. Logged out.')),
                  );
                  Navigator.of(context).pop(); // Close settings
                }
              },
              icon: const Icon(Icons.delete_outline, color: Colors.black),
              label: const Text('Delete account',
                  style: TextStyle(color: Colors.black)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black, width: 1.5),
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
