// lib/widgets/upload_progress_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/file_manager_provider.dart';
import '../theme/app_theme.dart';

class UploadProgressBar extends StatelessWidget {
  const UploadProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FileManagerProvider>(
      builder: (context, provider, _) {
        final uploads = provider.uploadProgress.entries.toList();
        if (uploads.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            children: uploads.map((entry) {
              final fileName = entry.key.split('/').last;
              final progress = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Icon(Icons.upload_outlined, color: AppColors.primary, size: 14),
                          const SizedBox(width: 6),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Text(
                              fileName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ]),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: GoogleFonts.jetBrainsMono(
                            color: AppColors.primary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 3,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
