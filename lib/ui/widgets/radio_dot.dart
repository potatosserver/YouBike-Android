import 'package:flutter/material.dart';

/// WalkGo 風格 radio 選擇元件 — 左側圓點 + 文字。
/// 供 Theme / Language / Region selection screen 共用。
/// 間距由外部（ListView children）控管，元件本身不帶間距。
class RadioDot extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const RadioDot({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
                width: 2,
              ),
            ),
            child: Center(
              child: isSelected
                  ? Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}