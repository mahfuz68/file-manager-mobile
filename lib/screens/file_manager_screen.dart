// lib/screens/file_manager_screen.dart
//
// Main file manager screen — mirrors the web's FileManagerShell + Header + BreadcrumbNav + FileList.

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/file_item.dart';
import '../services/auth_service.dart';
import '../services/file_manager_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/breadcrumb_nav.dart';
import '../widgets/bulk_action_bar.dart';
import '../widgets/file_item_tile.dart';
import '../widgets/folder_item_tile.dart';
import '../widgets/file_list_skeleton.dart';
import '../widgets/toolbar.dart';
import '../widgets/upload_progress_bar.dart';
import '../widgets/new_folder_bottom_sheet.dart';
import '../widgets/rename_bottom_sheet.dart';
import '../widgets/delete_bottom_sheet.dart';
import '../widgets/share_bottom_sheet.dart';

class FileManagerScreen extends StatefulWidget {
  const FileManagerScreen({super.key});

  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FileManagerProvider>().refresh();
    });
  }

  Future<void> _signOut() async {
    await _authService.signOut();
  }

  // ─── Upload ───────────────────────────────────────────────────────────────

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final provider = context.read<FileManagerProvider>();
    for (final file in result.files) {
      if (file.bytes == null) continue;
      final mime = _guessMime(file.name);
      await provider.uploadFile(
        fileName: file.name,
        bytes: file.bytes!,
        contentType: mime,
      );
    }
  }

  String _guessMime(String name) {
    final ext = name.split('.').last.toLowerCase();
    const map = {
      'jpg': 'image/jpeg', 'jpeg': 'image/jpeg', 'png': 'image/png',
      'gif': 'image/gif', 'webp': 'image/webp', 'svg': 'image/svg+xml',
      'pdf': 'application/pdf', 'mp4': 'video/mp4', 'mp3': 'audio/mpeg',
      'zip': 'application/zip', 'json': 'application/json',
      'txt': 'text/plain', 'html': 'text/html', 'css': 'text/css',
      'js': 'application/javascript',
    };
    return map[ext] ?? 'application/octet-stream';
  }

  // ─── Modals ───────────────────────────────────────────────────────────────

  void _showNewFolder() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NewFolderBottomSheet(),
    );
  }

  void _showRename(String key, String name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RenameBottomSheet(currentKey: key, currentName: name),
    );
  }

  void _showDelete(List<String> keys) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => DeleteBottomSheet(keys: keys),
    );
  }

  void _showShare(String key, String fileName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareBottomSheet(fileKey: key, fileName: fileName),
    );
  }

  void _downloadFile(String key) async {
    final provider = context.read<FileManagerProvider>();
    final url = provider.getDownloadUrl(key);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open download link')),
        );
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Consumer<FileManagerProvider>(
                builder: (context, provider, _) {
                  return Column(
                    children: [
                      // Breadcrumb
                      BreadcrumbNav(onNewFolder: _showNewFolder),

                      // Error banner
                      if (provider.error != null) _buildErrorBanner(provider.error!),

                      // Bulk action bar
                      if (provider.hasSelection)
                        BulkActionBar(
                          onDownload: () {
                            for (final key in provider.selected) {
                              if (!key.endsWith('/')) _downloadFile(key);
                            }
                          },
                          onDelete: () => _showDelete(provider.selected.toList()),
                          onShare: () {
                            final fileKey = provider.selected.firstWhere(
                              (k) => !k.endsWith('/'),
                              orElse: () => '',
                            );
                            if (fileKey.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Select a file to share')),
                              );
                              return;
                            }
                            final fileName = fileKey.split('/').last;
                            _showShare(fileKey, fileName);
                          },
                        ),

                      // Toolbar (search + filter)
                      const Toolbar(),

                      // Upload progress
                      if (provider.uploadProgress.isNotEmpty) UploadProgressBar(),

                      // File list
                      Expanded(
                        child: _buildFileList(provider),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader() {
    final user = _authService.currentUser;
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: Color(0xB32A2A2A)),
        ),
      ),
      child: Stack(
        children: [
          // Top orange accent
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  Color(0x59F97316),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                // Logo
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primary.withOpacity(0.22)),
                  ),
                  child: const Center(child: _BucketIconSmall()),
                ),
                const SizedBox(width: 8),
                Text(
                  'MY FILES',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFF444444),
                    fontSize: 9,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),

                // User email chip
                if (user?.email != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border.withOpacity(0.7)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user!.email![0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 80),
                        child: Text(
                          user.email!,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.jetBrainsMono(
                            color: const Color(0xFF666666),
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(width: 6),
                ],

                // Sign out button
                GestureDetector(
                  onTap: _signOut,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border.withOpacity(0.6)),
                    ),
                    child: const Icon(Icons.logout, size: 16, color: Color(0xFF555555)),
                  ),
                ),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.destructive.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          top: BorderSide(color: AppColors.destructive.withOpacity(0.25)),
          right: BorderSide(color: AppColors.destructive.withOpacity(0.25)),
          bottom: BorderSide(color: AppColors.destructive.withOpacity(0.25)),
          left: BorderSide(color: AppColors.destructive.withOpacity(0.6), width: 2),
        ),
      ),
      child: Row(children: [
        Icon(Icons.info_outline, size: 16, color: AppColors.destructive.withOpacity(0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Failed to load files. Check your R2 credentials.',
            style: TextStyle(color: AppColors.destructive.withOpacity(0.85), fontSize: 12),
          ),
        ),
      ]),
    );
  }

  Widget _buildFileList(FileManagerProvider provider) {
    if (provider.isLoading) {
      return const FileListSkeleton();
    }

    final folders = provider.filteredFolders;
    final files = provider.filteredFiles;

    if (folders.isEmpty && files.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: AppColors.primary,
      backgroundColor: AppColors.card,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // Column headers
          _buildColumnHeaders(provider),
          const SizedBox(height: 8),

          // Folders
          ...folders.map((folder) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FolderItemTile(
                  folder: folder,
                  isSelected: provider.isSelected(folder.key),
                  onTap: () => provider.navigateTo(folder.key),
                  onLongPress: () => provider.toggleSelect(folder.key),
                  onToggleSelect: () => provider.toggleSelect(folder.key),
                ),
              )),

          // Divider between folders and files
          if (folders.isNotEmpty && files.isNotEmpty) ...[
            const Divider(color: Color(0x4D2A2A2A), height: 16),
          ],

          // Files
          ...files.map((file) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FileItemTile(
                  file: file,
                  isSelected: provider.isSelected(file.key),
                  onLongPress: () => provider.toggleSelect(file.key),
                  onToggleSelect: () => provider.toggleSelect(file.key),
                  onAction: (action) => _handleFileAction(action, file),
                ),
              )),

          // Footer count
          _buildFooterCount(folders.length, files.length, provider.selectionCount),
        ],
      ),
    );
  }

  Widget _buildColumnHeaders(FileManagerProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x802A2A2A))),
      ),
      child: Row(children: [
        // Select all checkbox
        GestureDetector(
          onTap: () {
            if (provider.allSelected) {
              provider.clearSelection();
            } else {
              provider.selectAll();
            }
          },
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: provider.allSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: provider.allSelected ? AppColors.primary : const Color(0xFF3C3C3C),
              ),
            ),
            child: provider.allSelected
                ? const Icon(Icons.check, size: 11, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'NAME',
            style: GoogleFonts.jetBrainsMono(
              color: const Color(0xFF4A4A4A),
              fontSize: 9,
              letterSpacing: 2,
            ),
          ),
        ),
        Text(
          'TYPE',
          style: GoogleFonts.jetBrainsMono(
            color: const Color(0xFF4A4A4A),
            fontSize: 9,
            letterSpacing: 2,
          ),
        ),
      ]),
    );
  }

  Widget _buildFooterCount(int folderCount, int fileCount, int selectedCount) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            [
              if (folderCount > 0) '$folderCount folder${folderCount != 1 ? 's' : ''}',
              if (fileCount > 0) '$fileCount file${fileCount != 1 ? 's' : ''}',
            ].join(' · '),
            style: GoogleFonts.jetBrainsMono(
              color: const Color(0xFF3A3A3A),
              fontSize: 10,
            ),
          ),
          if (selectedCount > 0)
            Text(
              '$selectedCount selected',
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.primary.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withOpacity(0.7)),
            ),
            child: const Icon(Icons.folder_open_outlined, color: Color(0xFF3A3A3A), size: 28),
          ),
          const SizedBox(height: 16),
          const Text('No files yet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 6),
          Text(
            'Tap + to upload files',
            style: GoogleFonts.jetBrainsMono(color: const Color(0xFF444444), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // New folder
        FloatingActionButton.small(
          heroTag: 'new_folder',
          onPressed: _showNewFolder,
          backgroundColor: AppColors.card,
          foregroundColor: AppColors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
          child: const Icon(Icons.create_new_folder_outlined, size: 18),
        ),
        const SizedBox(height: 12),
        // Upload
        FloatingActionButton(
          heroTag: 'upload',
          onPressed: _pickAndUpload,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.upload_outlined),
        ),
      ],
    );
  }

  void _handleFileAction(String action, FileItem file) {
    switch (action) {
      case 'rename':
        _showRename(file.key, file.name);
        break;
      case 'share':
        _showShare(file.key, file.name);
        break;
      case 'download':
        _downloadFile(file.key);
        break;
      case 'delete':
        _showDelete([file.key]);
        break;
    }
  }
}

class _BucketIconSmall extends StatelessWidget {
  const _BucketIconSmall();
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.storage_outlined, color: AppColors.primary, size: 14);
  }
}