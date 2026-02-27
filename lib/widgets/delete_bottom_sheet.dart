// lib/widgets/delete_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/file_manager_provider.dart';
import '../theme/app_theme.dart';
import 'base_bottom_sheet.dart';

class DeleteBottomSheet extends StatefulWidget {
  final List<String> keys;
  const DeleteBottomSheet({super.key, required this.keys});

  @override
  State<DeleteBottomSheet> createState() => _DeleteBottomSheetState();
}

class _DeleteBottomSheetState extends State<DeleteBottomSheet> {
  bool _loading = false;

  List<String> get _names => widget.keys.map((key) {
        final normalized =
            key.endsWith('/') ? key.substring(0, key.length - 1) : key;
        return normalized.split('/').last;
      }).toList();

  Future<void> _delete() async {
    setState(() => _loading = true);
    try {
      await context.read<FileManagerProvider>().delete(widget.keys);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Delete failed: $e'),
              backgroundColor: AppColors.destructive),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final names = _names;
    final isSingle = widget.keys.length == 1;
    final showList = names.length <= 5;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F0F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          // Red accent line
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  Color(0x99EF4444),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.destructive.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.destructive.withOpacity(0.25)),
                    ),
                    child: Icon(Icons.delete_outline,
                        color: AppColors.destructive, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSingle
                              ? 'Delete File?'
                              : 'Delete ${names.length} Files?',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'PERMANENT · CANNOT BE UNDONE',
                          style: GoogleFonts.jetBrainsMono(
                              color: const Color(0xFF555555),
                              fontSize: 9,
                              letterSpacing: 1.5),
                        ),
                      ]),
                ]),
                const SizedBox(height: 20),

                // Warning banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.destructive.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border(
                      top: BorderSide(
                          color: AppColors.destructive.withOpacity(0.15)),
                      right: BorderSide(
                          color: AppColors.destructive.withOpacity(0.15)),
                      bottom: BorderSide(
                          color: AppColors.destructive.withOpacity(0.15)),
                      left: BorderSide(
                          color: AppColors.destructive.withOpacity(0.45),
                          width: 2),
                    ),
                  ),
                  child: Row(children: [
                    Icon(Icons.warning_amber_outlined,
                        color: AppColors.destructive.withOpacity(0.7),
                        size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isSingle
                            ? 'This file will be permanently removed from your R2 bucket and cannot be recovered.'
                            : 'These ${names.length} items will be permanently removed and cannot be recovered.',
                        style: TextStyle(
                            color: AppColors.destructive.withOpacity(0.65),
                            fontSize: 12,
                            height: 1.4),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                // File list
                if (showList) ...[
                  Text(
                    isSingle ? 'File to delete' : 'Items to delete',
                    style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFF444444),
                        fontSize: 9,
                        letterSpacing: 2),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: AppColors.border.withOpacity(0.7)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Column(
                        children: names.asMap().entries.map((e) {
                          final i = e.key;
                          final name = e.value;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: i % 2 == 0
                                  ? Colors.white.withOpacity(0.02)
                                  : Colors.white.withOpacity(0.01),
                              border: i > 0
                                  ? const Border(
                                      top: BorderSide(
                                          color: Color(0x802A2A2A)))
                                  : null,
                            ),
                            child: Row(children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.destructive.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: AppColors.destructive
                                          .withOpacity(0.15)),
                                ),
                                child: Icon(Icons.insert_drive_file_outlined,
                                    color:
                                        AppColors.destructive.withOpacity(0.65),
                                    size: 12),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  name,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.jetBrainsMono(
                                      color: const Color(0xFF888888),
                                      fontSize: 11),
                                ),
                              ),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.destructive.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ]),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.border.withOpacity(0.6)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.apps,
                          color: Color(0xFF555555), size: 18),
                      const SizedBox(width: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${names.length} items selected',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            Text('All will be permanently deleted',
                                style: GoogleFonts.jetBrainsMono(
                                    color: const Color(0xFF444444),
                                    fontSize: 10)),
                          ]),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.destructive.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: AppColors.destructive.withOpacity(0.2)),
                        ),
                        child: Text(
                          '×${names.length}',
                          style: GoogleFonts.jetBrainsMono(
                              color: AppColors.destructive.withOpacity(0.7),
                              fontSize: 11),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),
                ],

                // Action row
                Row(children: [
                  Expanded(
                    child: SheetSecondaryButton(
                      label: 'Cancel',
                      onTap: () => Navigator.pop(context),
                      disabled: _loading,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: SheetPrimaryButton(
                      label: isSingle
                          ? 'Delete File'
                          : 'Delete ${names.length} Items',
                      icon: Icons.delete_outline,
                      isLoading: _loading,
                      onTap: _delete,
                      color: AppColors.destructive,
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
