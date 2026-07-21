import 'package:flutter/material.dart';

/// 共用確認對話框，用於「取消 / 確認」雙 button 模式。
///
/// 呼叫方式：
/// ```dart
/// await ConfirmDialog.show(
///   context,
///   title: l10n.some_confirm_title,
///   content: l10n.some_confirm_content,
///   confirmLabel: l10n.confirm,
///   cancelLabel: l10n.cancel,
///   danger: true,
///   onConfirm: () async { await doSomethingDangerous(); },
/// );
/// ```
class ConfirmDialog {
  ConfirmDialog._();

  /// 顯示確認對話框。回傳 dialog 之後的結果（與 onConfirm 的 future 無關）。
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
    String? cancelLabel,
    bool danger = false,
    VoidCallback? onConfirm,
  }) async {
    final effectiveCancel = cancelLabel ?? MaterialLocalizations.of(context).cancelButtonLabel;
    final cs = Theme.of(context).colorScheme;

    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(effectiveCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (onConfirm != null) {
                onConfirm();
              }
            },
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: danger ? cs.error : cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}