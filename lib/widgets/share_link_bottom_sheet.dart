// lib/widgets/share_link_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import 'base_bottom_sheet.dart';

class ShareLinkBottomSheet extends StatefulWidget {
  final String fileName;
  final String url;
  final DateTime expiryDate;

  const ShareLinkBottomSheet({
    super.key,
    required this.fileName,
    required this.url,
    required this.expiryDate,
  });

  @override
  State<ShareLinkBottomSheet> createState() => _ShareLinkBottomSheetState();
}

class _ShareLinkBottomSheetState extends State<ShareLinkBottomSheet> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.url));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d, yyyy · HH:mm');
    final expiryStr = formatter.format(widget.expiryDate);

    return BaseBottomSheet(
      title: 'Share Link Ready',
      subtitle: 'PRESIGNED URL · CLOUDFLARE R2',
      accentColor: AppColors.success,
      icon: Icons.link,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File info card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border.withOpacity(0.6)),
            ),
            child: Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.success.withOpacity(0.2)),
                ),
                child: const Icon(Icons.insert_drive_file_outlined,
                    color: AppColors.success, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.fileName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Row(children: [
                        const Icon(Icons.schedule,
                            size: 11, color: Color(0xFF555555)),
                        const SizedBox(width: 4),
                        Text(
                          'Expires $expiryStr',
                          style: GoogleFonts.jetBrainsMono(
                              color: const Color(0xFF555555), fontSize: 10),
                        ),
                      ]),
                    ]),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.success.withOpacity(0.5),
                        blurRadius: 6)
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // URL display
          Text(
            'SHARE LINK',
            style: GoogleFonts.jetBrainsMono(
                color: const Color(0xFF555555), fontSize: 9, letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF080808),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border.withOpacity(0.7)),
            ),
            child: Text(
              widget.url,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF777777), fontSize: 10, height: 1.5),
            ),
          ),
          const SizedBox(height: 20),

          // Copy button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _copy,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _copied ? AppColors.success : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _copied
                    ? const Row(
                        key: ValueKey('copied'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, size: 16),
                          SizedBox(width: 8),
                          Text('Link Copied!',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      )
                    : const Row(
                        key: ValueKey('copy'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.copy, size: 16),
                          SizedBox(width: 8),
                          Text('Copy Link',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
