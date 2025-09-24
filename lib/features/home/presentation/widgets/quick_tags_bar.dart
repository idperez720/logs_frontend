// lib/features/home/presentation/widgets/quick_tags_bar.dart
import 'package:flutter/material.dart';
import '../../../tags/data/tags_repository.dart';

class QuickTagsBar extends StatelessWidget {
  final List<TagItem> tagsCatalog;
  final Set<String> selectedIds;
  final VoidCallback onTap; // opens picker
  const QuickTagsBar(
      {super.key,
      required this.tagsCatalog,
      required this.selectedIds,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: selectedIds.isEmpty
            ? const Text('Add tags', style: TextStyle(color: Colors.black54))
            : Wrap(
                spacing: 8,
                runSpacing: 4,
                children: selectedIds.map((id) {
                  final name = tagsCatalog
                      .firstWhere(
                        (t) => t.id == id,
                        orElse: () => TagItem(id: id, name: 'Tag', color: null),
                      )
                      .name;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Text(name, style: const TextStyle(fontSize: 12)),
                  );
                }).toList(),
              ),
      ),
    );
  }
}
