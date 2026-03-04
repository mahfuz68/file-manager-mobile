// lib/widgets/new_folder_modal.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/file_manager_provider.dart';
import '../theme/app_theme.dart';

class NewFolderModal extends StatefulWidget {
  const NewFolderModal({super.key});

  @override
  State<NewFolderModal> createState() => _NewFolderModalState();
}

class _NewFolderModalState extends State<NewFolderModal> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A), // Dark background as specified in design
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Rounded top corners
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
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
                  // Header row with icon, title/subtitle, and close button
                  Row(
                    children: [
                      // Left: Icon (folder with plus) inside a rounded square with a dark green border
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(8), // Rounded square
                          border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                        ),
                        child: const Icon(Icons.create_new_folder_outlined, color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 14),
                      // Title and subtitle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Create New Folder",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "NEW DIRECTORY · CLOUDFLARE R2",
                            style: GoogleFonts.jetBrainsMono(
                              color: const Color(0xFF555555),
                              fontSize: 9,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Divider below header
                  Container(
                    height: 1,
                    color: const Color(0xFF2A2A2A),
                  ),
                ],
              ),
            ),
            // Context Section (Path Indicator)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F0F),
                  borderRadius: BorderRadius.circular(8),
                  border: Border(
                    left: BorderSide(
                      color: AppColors.primary.withOpacity(0.25), // Subtle green border accent on the left edge
                      width: 2,
                    ),
                    top: BorderSide(color: const Color(0xFF2A2A2A)),
                    right: BorderSide(color: const Color(0xFF2A2A2A)),
                    bottom: BorderSide(color: const Color(0xFF2A2A2A)),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.folder_outlined, size: 14, color: Color(0xFF555555)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CREATING INSIDE",
                          style: GoogleFonts.jetBrainsMono(
                            color: const Color(0xFF555555),
                            fontSize: 9,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Selector<FileManagerProvider, String>(
                          selector: (_, provider) => provider.currentPath,
                          builder: (context, currentPath, _) {
                            final displayPath = currentPath.isEmpty ? "/ (root)" : currentPath;
                            return Text(
                              displayPath,
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFFAAAAAA),
                                fontSize: 11,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Input Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FOLDER NAME",
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFF555555),
                      fontSize: 9,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0A0A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: TextField(
                      controller: _ctrl,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'e.g. documents, images, 2026...',
                        hintStyle: TextStyle(color: Color(0xFF3A3A3A), fontSize: 14),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onSubmitted: (_) => _create(),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.destructive.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          top: BorderSide(color: AppColors.destructive.withOpacity(0.15)),
                          right: BorderSide(color: AppColors.destructive.withOpacity(0.15)),
                          bottom: BorderSide(color: AppColors.destructive.withOpacity(0.15)),
                          left: BorderSide(color: AppColors.destructive.withOpacity(0.5), width: 2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error_outline, color: AppColors.destructive.withOpacity(0.7), size: 14),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(color: AppColors.destructive.withOpacity(0.85), fontSize: 12, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Divider
            Container(
              height: 1,
              color: const Color(0xFF2A2A2A),
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _loading ? null : () => Navigator.pop(context),
                      child: Opacity(
                        opacity: _loading ? 0.4 : 1,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2A2A2A)),
                          ),
                          child: const Center(
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Color(0xFF888888), fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _create,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primary.withOpacity(0.55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _loading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Please wait…', style: TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.create_new_folder_outlined, size: 16),
                                  SizedBox(width: 8),
                                  Text('Create Folder', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _create() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Folder name cannot be empty');
      return;
    }
    if (name.contains('/') || name == '..' || name == '.') {
      setState(() => _error = 'Invalid folder name');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<FileManagerProvider>().createFolder(name);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Failed to create folder: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}