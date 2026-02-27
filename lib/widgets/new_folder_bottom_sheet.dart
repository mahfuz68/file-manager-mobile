// lib/widgets/new_folder_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/file_manager_provider.dart';
import '../theme/app_theme.dart';
import 'base_bottom_sheet.dart';

class NewFolderBottomSheet extends StatefulWidget {
  const NewFolderBottomSheet({super.key});

  @override
  State<NewFolderBottomSheet> createState() => _NewFolderBottomSheetState();
}

class _NewFolderBottomSheetState extends State<NewFolderBottomSheet> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Folder name is required');
      return;
    }
    if (name.contains('/') || name.contains('..')) {
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

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheet(
      title: 'New Folder',
      subtitle: 'CREATE FOLDER OBJECT',
      accentColor: AppColors.primary,
      icon: Icons.create_new_folder_outlined,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FOLDER NAME',
              style: GoogleFonts.jetBrainsMono(
                color: const Color(0xFF555555),
                fontSize: 9,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            DarkTextField(
              controller: _ctrl,
              hintText: 'my-folder',
              autofocus: true,
              onSubmitted: (_) => _create(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              SheetErrorBanner(message: _error!),
            ],
            const SizedBox(height: 20),
            SheetPrimaryButton(
              label: 'Create Folder',
              icon: Icons.create_new_folder_outlined,
              isLoading: _loading,
              onTap: _create,
            ),
          ],
        ),
      ),
    );
  }
}
