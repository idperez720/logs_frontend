// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logs_mobile_app/features/auth/presentation/splash_page.dart';
import 'package:logs_mobile_app/features/home/presentation/widgets/composer.dart';

import '../../auth/data/auth_models.dart';
import '../../auth/state/auth_controller.dart';
import '../../settings/presentation/settings_page.dart';

import '../../logs/data/logs_repository.dart';
import '../../logs/data/logs_providers.dart';

import '../../tags/data/tags_repository.dart';
import '../../tags/data/tags_providers.dart';

import '../state/home_controller.dart';
import 'widgets/fab_menu.dart';

import 'home_sheets.dart'; // showSendSheet, showHistorySheet, showTagPicker

class HomePage extends ConsumerStatefulWidget {
  final UserResponse user;
  const HomePage({super.key, required this.user});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<TagItem> _tagsCatalog = [];
  bool _loadingTags = false;

  Future<void> _ensureTags() async {
    if (_tagsCatalog.isNotEmpty || _loadingTags) return;
    _loadingTags = true;
    try {
      _tagsCatalog = await ref.read(tagsRepositoryProvider).list(size: 100);
      if (mounted) setState(() {});
    } finally {
      _loadingTags = false;
    }
  }

  Future<void> _openHistory() async {
    final items = await ref.read(logsRepositoryProvider).recent(limit: 20);
    await showHistorySheet(context, items);
  }

  Future<void> _openTagsPicker() async {
    await _ensureTags();
    final st = ref.read(homeControllerProvider);
    final picked = await showTagPicker(
      context,
      _tagsCatalog,
      initiallySelected: st.selectedTagIds,
      allowCreate: true, // <-- enable create inside picker
    );
    if (picked != null) {
      ref.read(homeControllerProvider.notifier).setSelectedTags(picked);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tags updated')),
      );
    }
  }

  Future<void> _send() async {
    // tap on main FAB = send with options
    await _ensureTags();
    final st = ref.read(homeControllerProvider);

    if (st.content.trim().isEmpty) {
      // No content: open menu instead of sending
      ref.read(homeControllerProvider.notifier).toggleMenu();
      return;
    }

    final res = await showSendSheet(
      context,
      initialContent: st.content.trim(),
      tags: _tagsCatalog,
      initialSelectedTagIds: st.selectedTagIds,
    );
    if (res == null) return;

    await ref.read(logsRepositoryProvider).createLog(LogCreateRequest(
          content: res.content,
          title: res.title?.trim().isEmpty == true ? null : res.title?.trim(),
          status: res.status,
          location: res.location?.trim().isEmpty == true
              ? null
              : res.location?.trim(),
          mood: res.mood?.trim().isEmpty == true ? null : res.mood?.trim(),
          tagIds: res.selectedTagIds.isEmpty ? null : res.selectedTagIds,
        ));

    if (!mounted) return;
    ref.read(homeControllerProvider.notifier)
      ..clearComposer()
      ..setSelectedTags(res.selectedTagIds);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Log saved')));
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''), // no name/title
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SettingsPage())),
            icon: const Icon(Icons.settings, color: Colors.black),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SplashPage()),
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Fullscreen composer
            Positioned.fill(
              child: Padding(
                // only leave room for the FAB at the bottom
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16 + 72),
                child: Composer(
                  value: st.content,
                  onChanged: (v) =>
                      ref.read(homeControllerProvider.notifier).setContent(v),
                ),
              ),
            ),

            // Floating action button + menu (bottom-right)
            Positioned(
              right: 16,
              bottom: 16,
              child: FabMenu(
                open: st.menuOpen,
                onToggle: () => ref
                    .read(homeControllerProvider.notifier)
                    .toggleMenu(), // long-press
                onSend: _send, // tap
                onHistory: () {
                  ref.read(homeControllerProvider.notifier).toggleMenu();
                  _openHistory();
                },
                onTags: () {
                  ref.read(homeControllerProvider.notifier).toggleMenu();
                  _openTagsPicker();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
