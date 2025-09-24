import 'package:flutter/material.dart';

class FabMenu extends StatelessWidget {
  final bool open;
  final VoidCallback onToggle; // open/close menu (via long-press)
  final VoidCallback onSend; // quick send (tap)
  final VoidCallback onHistory;
  final VoidCallback onTags;

  const FabMenu({
    super.key,
    required this.open,
    required this.onToggle,
    required this.onSend,
    required this.onHistory,
    required this.onTags,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: open
              ? Column(
                  key: const ValueKey('menu'),
                  children: [
                    _MiniFab(
                        label: 'History',
                        icon: Icons.history,
                        onTap: onHistory),
                    const SizedBox(height: 10),
                    _MiniFab(
                        label: 'Tags',
                        icon: Icons.sell_outlined,
                        onTap: onTags),
                    const SizedBox(height: 10),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        GestureDetector(
          onTap: onSend, // tap = send
          onLongPress: onToggle, // long-press = open/close menu
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
                color: Colors.black, shape: BoxShape.circle),
            child: Icon(open ? Icons.close : Icons.send, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _MiniFab extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _MiniFab(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(color: Colors.white),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              margin: const EdgeInsets.only(right: 8),
              child: Text(label, style: const TextStyle(color: Colors.black)),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Icon(icon, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
