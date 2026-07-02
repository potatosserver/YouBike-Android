import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("系統偵錯日誌"),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () async {
              final allLogs = appState.logs.join('\n');
              await Clipboard.setData(ClipboardData(text: allLogs));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("日誌已複製到剪貼簿")),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appState.logs.length,
        itemBuilder: (context, index) {
          final log = appState.logs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              log,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          );
        },
      ),
    );
  }
}
