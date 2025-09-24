import 'package:flutter/material.dart';

class BWButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool loading;
  const BWButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.loading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(label),
      ),
    );
  }
}
