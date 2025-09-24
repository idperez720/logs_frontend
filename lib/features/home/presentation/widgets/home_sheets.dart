// lib/features/home/presentation/home_sheets.dart
//
// Provides:
//   - Future<SendResult?> showSendSheet(...)
//   - Future<void>       showHistorySheet(...)
//   - Future<Set<String>?> showTagPicker(...)
// And the widgets they use (SendSheet, HistorySheet, TagPickerSheet).
//
// Black/white minimalist UI, Google-Fonts theme friendly.
//

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme.dart';
import '../../../tags/data/tags_repository.dart';
import '../../../tags/data/tags_providers.dart';
import '../../../logs/data/logs_repository.dart';
import '../../../logs/data/logs_providers.dart';

/// Data returned by the Send sheet
class SendResult {
  final String content;
  final String? title;
  final String? status; // "PUBLISHED" | "DRAFT"
  final String? location;
  final String? mood;
  final List<String> selectedTagIds;

  SendResult({
    required this.content,
    this.title,
    this.status,
    this.location,
    this.mood,
    required this.selectedTagIds,
  });
}

/// Show the Send sheet and return the user's choices.
Future<SendResult?> showSendSheet(
  BuildContext context, {
  required String initialContent,
  required List<TagItem> tags,
  required Set<String> initialSelectedTagIds,
  String? initialTitle,
  String? initialLocation,
  String? initialMood,
  String? initialStatus,
  bool allowContentEdit = false,
  bool showStatusSelector = true,
}) {
  return showModalBottomSheet<SendResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _SendSheet(
      initialContent: initialContent,
      tags: tags,
      initialSelectedTagIds: initialSelectedTagIds,
      initialTitle: initialTitle,
      initialLocation: initialLocation,
      initialMood: initialMood,
      initialStatus: initialStatus,
      allowContentEdit: allowContentEdit,
      showStatusSelector: showStatusSelector,
      parentContext: context,
    ),
  );
}

/// Show a compact, scrollable history sheet (uses /logs/recent data).
Future<void> showHistorySheet(
  BuildContext context,
  List<Map<String, dynamic>> items,
) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _HistorySheet(items: items, parentContext: context),
  );
}

/// Show a tag picker and return selected tag IDs.
Future<Set<String>?> showTagPicker(
  BuildContext context,
  List<TagItem> tags, {
  Set<String>? initiallySelected,
  bool allowCreate = false,
}) async {
  return showModalBottomSheet<Set<String>>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _TagPickerSheet(
      tags: tags,
      initiallySelected: initiallySelected ?? const {},
      allowCreate: allowCreate,
      parentContext: context,
    ),
  );
}

/* ----------------------------- SEND SHEET ------------------------------ */

class _SendSheet extends ConsumerStatefulWidget {
  final String initialContent;
  final List<TagItem> tags;
  final Set<String> initialSelectedTagIds;
  final String? initialTitle;
  final String? initialLocation;
  final String? initialMood;
  final String? initialStatus;
  final bool allowContentEdit;
  final bool showStatusSelector;
  final BuildContext parentContext;

  const _SendSheet({
    required this.initialContent,
    required this.tags,
    required this.initialSelectedTagIds,
    this.initialTitle,
    this.initialLocation,
    this.initialMood,
    this.initialStatus,
    this.allowContentEdit = false,
    this.showStatusSelector = true,
    required this.parentContext,
  });

  @override
  ConsumerState<_SendSheet> createState() => _SendSheetState();
}

class _SendSheetState extends ConsumerState<_SendSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleC = TextEditingController();
  final _locationC = TextEditingController();
  final _moodC = TextEditingController();
  late final TextEditingController _contentC;

  late String _status;
  late final Set<String> _selectedTagIds = Set.of(widget.initialSelectedTagIds);
  bool _creating = false;

  void _showSnack(String message) {
    final messenger = ScaffoldMessenger.of(widget.parentContext);
    final media = MediaQuery.of(widget.parentContext);
    final themeState = ref.read(themeControllerProvider);
    final providerTheme = buildBWTheme(themeState.font);
    final contextTheme = Theme.of(widget.parentContext);
    final snackTheme = providerTheme.snackBarTheme;
    final colorScheme = providerTheme.colorScheme;
    final bottomMargin =
        (media.size.height * 0.7).clamp(80.0, media.size.height - 80.0);
    final backgroundColor = colorScheme.primary;
    final resolvedTextStyle = (contextTheme.snackBarTheme.contentTextStyle ??
            snackTheme.contentTextStyle ??
            providerTheme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary,
            )) ??
        TextStyle(
          color: colorScheme.onPrimary,
        );
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, style: resolvedTextStyle),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, 0, 16, bottomMargin),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _contentC = TextEditingController(text: widget.initialContent);
    _titleC.text = widget.initialTitle ?? '';
    _locationC.text = widget.initialLocation ?? '';
    _moodC.text = widget.initialMood ?? '';
    final initialStatus = widget.initialStatus?.trim().toUpperCase();
    if (initialStatus == 'PUBLISHED' || initialStatus == 'DRAFT') {
      _status = initialStatus!;
    } else {
      _status = 'PUBLISHED';
    }
  }

  @override
  void dispose() {
    _contentC.dispose();
    _titleC.dispose();
    _locationC.dispose();
    _moodC.dispose();
    super.dispose();
  }

  Future<void> _createTag() async {
    final nameController = TextEditingController();
    final created = await showDialog<TagItem?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New tag'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              try {
                setState(() => _creating = true);
                final tag = await ref
                    .read(tagsRepositoryProvider)
                    .createTag(name: name);
                if (!mounted) return;
                Navigator.pop(context, tag);
              } catch (e) {
                if (!mounted) return;
                _showSnack('Failed to create tag: $e');
              } finally {
                if (mounted) setState(() => _creating = false);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (created != null) {
      setState(() {
        widget.tags.add(created);
        _selectedTagIds.add(created.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text('Send log',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleC,
                decoration:
                    const InputDecoration(labelText: 'Title (optional)'),
              ),
              const SizedBox(height: 12),

              // Content (read-only preview)
              widget.allowContentEdit
                  ? TextFormField(
                      controller: _contentC,
                      decoration: const InputDecoration(labelText: 'Content'),
                      maxLines: 8,
                      minLines: 4,
                    )
                  : Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _contentC.text.isEmpty
                            ? '(No content)'
                            : _contentC.text,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
              const SizedBox(height: 12),

              // Status
              if (widget.showStatusSelector) ...[
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(
                        value: 'PUBLISHED', child: Text('Published')),
                    DropdownMenuItem(value: 'DRAFT', child: Text('Draft')),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? 'PUBLISHED'),
                ),
                const SizedBox(height: 12),
              ],

              TextFormField(
                controller: _locationC,
                decoration:
                    const InputDecoration(labelText: 'Location (optional)'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _moodC,
                decoration: const InputDecoration(labelText: 'Mood (optional)'),
              ),
              const SizedBox(height: 16),

              const Text('Tags', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.tags.map((t) {
                  final selected = _selectedTagIds.contains(t.id);
                  return ChoiceChip(
                    label: Text(t.name),
                    selected: selected,
                    selectedColor: Colors.black,
                    labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black),
                    backgroundColor: Colors.white,
                    shape: const StadiumBorder(
                      side: BorderSide(color: Colors.black, width: 1.5),
                    ),
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _selectedTagIds.add(t.id);
                        } else {
                          _selectedTagIds.remove(t.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _creating ? null : _createTag,
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: const Text('New tag',
                      style: TextStyle(color: Colors.black)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(SendResult(
                      content: _contentC.text,
                      title: _titleC.text,
                      status: _status,
                      location: _locationC.text,
                      mood: _moodC.text,
                      selectedTagIds: _selectedTagIds.toList(),
                    ));
                  },
                  child: const Text('Send'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------------------------- HISTORY SHEET ---------------------------- */

class _HistoryTabConfig {
  final String status;
  final String label;
  const _HistoryTabConfig(this.status, this.label);
}

const _historyTabs = [
  _HistoryTabConfig('PUBLISHED', 'Published'),
  _HistoryTabConfig('ARCHIVED', 'Archived'),
  _HistoryTabConfig('DRAFT', 'Draft'),
];

class _HistorySheet extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> items;
  final BuildContext parentContext;
  const _HistorySheet({required this.items, required this.parentContext});

  @override
  ConsumerState<_HistorySheet> createState() => _HistorySheetState();
}

class _HistorySheetState extends ConsumerState<_HistorySheet>
    with SingleTickerProviderStateMixin {
  late final List<Map<String, dynamic>> _items =
      widget.items.map((e) => Map<String, dynamic>.from(e)).toList();

  void _showSnack(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(widget.parentContext);
    final media = MediaQuery.of(widget.parentContext);
    final themeState = ref.read(themeControllerProvider);
    final providerTheme = buildBWTheme(themeState.font);
    final colorScheme = providerTheme.colorScheme;
    final heightFactor = media.size.height < 700 ? 0.95 : 0.8;
    final bottomMargin = (media.size.height * heightFactor + 24)
        .clamp(80.0, media.size.height - 40.0);
    final backgroundColor = providerTheme.colorScheme.primary;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: colorScheme.onPrimary)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, 0, 16, bottomMargin),
      ),
    );
  }

  String _statusOf(Map<String, dynamic> it) {
    final raw = it['status'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim().toUpperCase();
    }
    return 'PUBLISHED';
  }

  int _countFor(String status) =>
      _items.where((it) => _statusOf(it) == status).length;

  List<Map<String, dynamic>> _filtered(String status) {
    return _items
        .where((it) => _statusOf(it) == status)
        .toList()
        .reversed
        .toList();
  }

  void _updateItemFields(String id, Map<String, dynamic> changes) {
    if (!mounted) return;
    final idx = _items.indexWhere((it) => '${it['id']}' == id);
    if (idx == -1) return;
    setState(() {
      _items[idx] = {
        ..._items[idx],
        ...changes,
      };
    });
  }

  void _setStatus(String id, String status) =>
      _updateItemFields(id, {'status': status});

  void _removeById(String id) {
    if (!mounted) return;
    setState(() {
      _items.removeWhere((it) => '${it['id']}' == id);
    });
  }

  Future<bool> _handleDelete(Map<String, dynamic> item) async {
    final logId = '${item['id'] ?? ''}';
    if (logId.isEmpty) {
      _showSnack('Log missing identifier', isError: true);
      return false;
    }

    final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete log?'),
            content: const Text(
              'This will permanently delete the log. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.black)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return false;

    try {
      await ref.read(logsRepositoryProvider).delete(logId);
      if (!mounted) return false;
      _removeById(logId);
      _showSnack('Log deleted');
      return true;
    } catch (e) {
      _showSnack('Failed to delete log: $e', isError: true);
      return false;
    }
  }

  Future<bool> _handleArchive(Map<String, dynamic> item) async {
    final currentStatus = _statusOf(item);
    if (currentStatus == 'ARCHIVED') {
      return _handleUnarchive(item);
    }

    final logId = '${item['id'] ?? ''}';
    if (logId.isEmpty) {
      _showSnack('Log missing identifier', isError: true);
      return false;
    }

    try {
      await ref.read(logsRepositoryProvider).archive(logId);
      if (!mounted) return false;
      _setStatus(logId, 'ARCHIVED');
      _showSnack('Log archived');
      return true;
    } catch (e) {
      _showSnack('Failed to archive log: $e', isError: true);
      return false;
    }
  }

  Future<bool> _handleUnarchive(Map<String, dynamic> item) async {
    final logId = '${item['id'] ?? ''}';
    if (logId.isEmpty) {
      _showSnack('Log missing identifier', isError: true);
      return false;
    }

    try {
      await ref.read(logsRepositoryProvider).unarchive(logId);
      if (!mounted) return false;
      _setStatus(logId, 'PUBLISHED');
      _showSnack('Log unarchived');
      return true;
    } catch (e) {
      _showSnack('Failed to unarchive log: $e', isError: true);
      return false;
    }
  }

  Future<bool> _handlePublishDraft(Map<String, dynamic> item) async {
    final logId = '${item['id'] ?? ''}';
    if (logId.isEmpty) {
      _showSnack('Log missing identifier', isError: true);
      return false;
    }

    Map<String, dynamic> detail;
    try {
      detail = await ref.read(logsRepositoryProvider).getById(logId);
    } catch (e) {
      if (!mounted) return false;
      _showSnack('Failed to load draft: $e', isError: true);
      return false;
    }

    if (!mounted) return false;

    List<TagItem> tags = [];
    try {
      tags = await ref.read(tagsRepositoryProvider).list(size: 100);
    } catch (e) {
      // Keep going with empty tags but inform the user.
      if (!mounted) return false;
      _showSnack('Failed to load tags: $e', isError: true);
    }

    final selectedTagIds = <String>{};
    final detailTags = detail['tags'];
    if (detailTags is List) {
      for (final t in detailTags) {
        if (t is Map && t['id'] is String) {
          selectedTagIds.add(t['id'] as String);
        } else if (t is String) {
          selectedTagIds.add(t);
        }
      }
    } else if (detail['tag_ids'] is List) {
      for (final id in detail['tag_ids']) {
        if (id is String) selectedTagIds.add(id);
      }
    }

    final result = await showSendSheet(
      context,
      initialContent: (detail['content'] as String?) ?? '',
      tags: tags,
      initialSelectedTagIds: selectedTagIds,
      initialTitle: detail['title'] as String?,
      initialLocation: detail['location'] as String?,
      initialMood: detail['mood'] as String?,
      initialStatus: 'PUBLISHED',
      allowContentEdit: true,
      showStatusSelector: false,
    );

    if (!mounted) return false;
    if (result == null) return false;

    try {
      await ref.read(logsRepositoryProvider).update(
            logId,
            LogUpdateRequest(
              title: result.title,
              content: result.content,
              status: 'PUBLISHED',
              location: result.location,
              mood: result.mood,
            ),
          );
    } catch (e) {
      if (!mounted) return false;
      _showSnack('Failed to publish draft: $e', isError: true);
      return false;
    }

    if (!mounted) return false;

    try {
      await ref
          .read(logsRepositoryProvider)
          .updateTags(logId, result.selectedTagIds);
    } catch (e) {
      if (!mounted) return false;
      _showSnack('Draft published but tags not updated: $e', isError: true);
    }

    if (!mounted) return false;

    _updateItemFields(logId, {
      'status': 'PUBLISHED',
      'title': result.title,
      'content': result.content,
      'content_preview': result.content,
      'location': result.location,
      'mood': result.mood,
    });

    if (!mounted) return false;
    _showSnack('Draft published');
    return true;
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: color,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: alignment == Alignment.centerLeft
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLogTile(Map<String, dynamic> item) {
    final preview =
        (item['content_preview'] ?? item['content'] ?? '') as String? ?? '';
    final status = _statusOf(item);
    final createdAt = item['created_at'] as String?;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.article, color: Colors.black),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: Colors.black)),
                if (createdAt != null && createdAt.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    createdAt,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  preview,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final heightFactor = media.size.height < 700 ? 0.95 : 0.8;
    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: heightFactor,
        child: DefaultTabController(
          length: _historyTabs.length,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Logs history',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                TabBar(
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black54,
                  indicatorColor: Colors.black,
                  tabs: _historyTabs
                      .map(
                        (tab) => Tab(
                          text: '${tab.label} (${_countFor(tab.status)})',
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    children: _historyTabs.map((tab) {
                      final filtered = _filtered(tab.status);
                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text('No logs here yet',
                              style: TextStyle(color: Colors.black54)),
                        );
                      }
                      return ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final itemId = item['id'] != null
                              ? '${item['id']}'
                              : 'idx-$index-${tab.status}';
                          final status = _statusOf(item);
                          final isArchived = status == 'ARCHIVED';
                          final isDraft = status == 'DRAFT';
                          final trailingIcon = isArchived
                              ? Icons.unarchive
                              : isDraft
                                  ? Icons.publish
                                  : Icons.archive;
                          final trailingLabel = isArchived
                              ? 'Unarchive'
                              : isDraft
                                  ? 'Publish'
                                  : 'Archive';
                          final trailingColor = isArchived
                              ? Colors.green
                              : isDraft
                                  ? Colors.black87
                                  : Colors.blueGrey;
                          return Dismissible(
                            key: ValueKey('log-$itemId'),
                            direction: DismissDirection.horizontal,
                            background: _buildSwipeBackground(
                              alignment: Alignment.centerLeft,
                              icon: Icons.delete,
                              label: 'Delete',
                              color: Colors.redAccent,
                            ),
                            secondaryBackground: _buildSwipeBackground(
                              alignment: Alignment.centerRight,
                              icon: trailingIcon,
                              label: trailingLabel,
                              color: trailingColor,
                            ),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                return _handleDelete(item);
                              }
                              if (direction == DismissDirection.endToStart) {
                                if (isArchived) {
                                  await _handleUnarchive(item);
                                } else if (isDraft) {
                                  await _handlePublishDraft(item);
                                } else {
                                  await _handleArchive(item);
                                }
                                return false;
                              }
                              return false;
                            },
                            child: _buildLogTile(item),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* --------------------------- TAG PICKER SHEET -------------------------- */

class _TagPickerSheet extends ConsumerStatefulWidget {
  final List<TagItem> tags;
  final Set<String> initiallySelected;
  final bool allowCreate;
  final BuildContext parentContext;
  const _TagPickerSheet({
    required this.tags,
    required this.initiallySelected,
    this.allowCreate = false,
    required this.parentContext,
  });

  @override
  ConsumerState<_TagPickerSheet> createState() => _TagPickerSheetState();
}

class _TagPickerSheetState extends ConsumerState<_TagPickerSheet> {
  late final Set<String> _selected = Set.of(widget.initiallySelected);
  final _createC = TextEditingController();
  bool _creating = false;

  void _showSnack(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(widget.parentContext);
    final media = MediaQuery.of(widget.parentContext);
    final themeState = ref.read(themeControllerProvider);
    final providerTheme = buildBWTheme(themeState.font);
    final contextTheme = Theme.of(widget.parentContext);
    final snackTheme = providerTheme.snackBarTheme;
    final colorScheme = providerTheme.colorScheme;
    final bottomMargin =
        (media.size.height * 0.7).clamp(80.0, media.size.height - 40.0);
    final backgroundColor = colorScheme.primary;
    final resolvedTextStyle = (contextTheme.snackBarTheme.contentTextStyle ??
            snackTheme.contentTextStyle ??
            providerTheme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary,
            )) ??
        TextStyle(
          color: colorScheme.onPrimary,
        );
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, style: resolvedTextStyle),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, 0, 16, bottomMargin),
      ),
    );
  }

  @override
  void dispose() {
    _createC.dispose();
    super.dispose();
  }

  Future<void> _createTag() async {
    final name = _createC.text.trim();
    if (name.isEmpty) return;
    setState(() => _creating = true);
    try {
      final tag = await ref.read(tagsRepositoryProvider).createTag(name: name);
      setState(() {
        widget.tags.add(tag);
        _selected.add(tag.id);
        _createC.clear();
      });
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to create tag: $e', isError: true);
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
                child: Text('Select tags',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
            const SizedBox(height: 12),
            if (widget.allowCreate) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _createC,
                      decoration:
                          const InputDecoration(labelText: 'New tag name'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _creating ? null : _createTag,
                    child: _creating
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.tags.map((t) {
                    final selected = _selected.contains(t.id);
                    return ChoiceChip(
                      label: Text(t.name),
                      selected: selected,
                      selectedColor: Colors.black,
                      labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black),
                      backgroundColor: Colors.white,
                      shape: const StadiumBorder(
                        side: BorderSide(color: Colors.black, width: 1.5),
                      ),
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selected.add(t.id);
                          } else {
                            _selected.remove(t.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(_selected),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
