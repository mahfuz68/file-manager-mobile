// lib/widgets/bulk_action_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/file_manager_provider.dart';
import '../theme/app_theme.dart';

class BulkActionBar extends StatelessWidget {
  final VoidCallback onDownload;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const BulkActionBar({
    super.key,
    required this.onDownload,
    required this.onDelete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FileManagerProvider>(
      builder: (context, provider, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              // Count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.primary.withOpacity(0.35)),
                ),
                child: Text(
                  '${provider.selectionCount} selected',
                  style: GoogleFonts.jetBrainsMono(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),

              // Actions
              _BulkBtn(icon: Icons.download_outlined, label: 'DL', onTap: onDownload),
              const SizedBox(width: 6),
              _BulkBtn(icon: Icons.share_outlined, label: 'SHARE', onTap: onShare),
              const SizedBox(width: 6),
              _BulkBtn(
                  icon: Icons.delete_outline,
                  label: 'DEL',
                  isDestructive: true,
                  onTap: onDelete),
              const SizedBox(width: 8),

              // Clear
              GestureDetector(
                onTap: provider.clearSelection,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.close, color: Color(0xFF666666), size: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BulkBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  const _BulkBtn({
    required this.icon,
    required this.label,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.destructive : const Color(0xFF888888);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.destructive.withOpacity(0.08)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: isDestructive
                ? AppColors.destructive.withOpacity(0.25)
                : AppColors.border.withOpacity(0.8),
          ),
        ),
        child: Row(children: [
          Icon(icon, color: color.withOpacity(0.7), size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              color: color.withOpacity(0.8),
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
        ]),
      ),
    );
  }
}
