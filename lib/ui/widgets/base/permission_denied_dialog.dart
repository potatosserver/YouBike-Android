// PermissionDeniedDialog — 「權限永久拒絕」共用對話框。
//
// 原本散落於 permission_handler_page 與 settings_screen 兩處的同一個
// AlertDialog 樣板，集中於此；由 PermissionService.showPermanentlyDeniedDialog
// 觸發，傳入任何 BuildContext 皆可。

import 'package:flutter/material.dart';
import 'package:youbike/core/l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionDeniedDialog extends StatelessWidget {
  const PermissionDeniedDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const PermissionDeniedDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.permission_denied_title),
      content: Text(l10n.permission_denied_content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            openAppSettings();
            Navigator.pop(context);
          },
          child: Text(l10n.open_settings),
        ),
      ],
    );
  }
}
