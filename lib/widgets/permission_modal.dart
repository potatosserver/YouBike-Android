import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';

class PermissionModal extends StatelessWidget {
  final String message;
  final VoidCallback onConfirm;

  const PermissionModal({super.key, required this.message, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("確認", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
