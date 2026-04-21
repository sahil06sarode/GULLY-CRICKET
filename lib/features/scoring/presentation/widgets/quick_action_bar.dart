import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class QuickActionBar extends StatelessWidget {
  const QuickActionBar({
    super.key,
    required this.infoChips,
    required this.onSwap,
    required this.onSelectStriker,
    required this.onSelectBowler,
    required this.onSettings,
    required this.onWifi,
  });

  final List<String> infoChips;
  final VoidCallback onSwap;
  final VoidCallback onSelectStriker;
  final VoidCallback onSelectBowler;
  final VoidCallback onSettings;
  final VoidCallback onWifi;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: infoChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    infoChips[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _ActionChipButton(
                label: 'Swap',
                icon: Icons.swap_horiz,
                onTap: onSwap,
              ),
              _ActionChipButton(
                label: 'Striker',
                icon: Icons.sports_cricket,
                onTap: onSelectStriker,
              ),
              _ActionChipButton(
                label: 'Bowler',
                icon: Icons.sports_baseball,
                onTap: onSelectBowler,
              ),
              _ActionChipButton(
                label: 'Settings',
                icon: Icons.tune,
                onTap: onSettings,
              ),
              _ActionChipButton(
                label: 'WiFi',
                icon: Icons.wifi_tethering,
                onTap: onWifi,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: FilledButton.tonalIcon(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          tapTargetSize: MaterialTapTargetSize.padded,
          visualDensity: VisualDensity.standard,
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
