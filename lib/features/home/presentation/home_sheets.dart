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

import '../../tags/data/tags_repository.dart';
import '../../tags/data/tags_providers.dart';

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
    builder: (_) => _HistorySheet(items: items),
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
    ),
  );
}

/* ----------------------------- SEND SHEET ------------------------------ */

class _SendSheet extends ConsumerStatefulWidget {
  final String initialContent;
  final List<TagItem> tags;
  final Set<String> initialSelectedTagIds;

  const _SendSheet({
    required this.initialContent,
    required this.tags,
    required this.initialSelectedTagIds,
  });

  @override
  ConsumerState<_SendSheet> createState() => _SendSheetState();
}

class _SendSheetState extends ConsumerState<_SendSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleC = TextEditingController();
  final _locationC = TextEditingController();
  final _moodC = TextEditingController();

  String _status = 'PUBLISHED'; // maps to backend LogStatus
  late final Set<String> _selectedTagIds = Set.of(widget.initialSelectedTagIds);
  bool _creating = false;

  @override
  void dispose() {
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to create tag: $e')),
                );
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.initialContent.isEmpty
                      ? '(No content)'
                      : widget.initialContent,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
              const SizedBox(height: 12),

              // Status
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
                      content: widget.initialContent,
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

class _HistorySheet extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _HistorySheet({required this.items});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Recent logs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No recent logs',
                    style: TextStyle(color: Colors.black54)),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final it = items[items.length - 1 - i];
                    final preview = (it['content_preview'] ??
                            it['content'] ??
                            '') as String? ??
                        '';
                    final status = (it['status'] ?? '') as String? ?? '';
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.article, color: Colors.black),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (status.isNotEmpty)
                                  Text(status,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                if (status.isNotEmpty)
                                  const SizedBox(height: 4),
                                Text(preview,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
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
  const _TagPickerSheet({
    required this.tags,
    required this.initiallySelected,
    this.allowCreate = false,
  });

  @override
  ConsumerState<_TagPickerSheet> createState() => _TagPickerSheetState();
}

class _TagPickerSheetState extends ConsumerState<_TagPickerSheet> {
  late final Set<String> _selected = Set.of(widget.initiallySelected);
  final _createC = TextEditingController();
  bool _creating = false;

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to create tag: $e')));
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
