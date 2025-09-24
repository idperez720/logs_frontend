import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logs_mobile_app/core/theme.dart';
import 'package:logs_mobile_app/features/profile/presentation/profile_page.dart';

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
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.black),
                title: const Text(
                  'My Profile',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
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
          ],
        ),
      ),
    );
  }
}
