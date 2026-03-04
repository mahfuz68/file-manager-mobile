// lib/widgets/rename_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/file_manager_provider.dart';
import '../theme/app_theme.dart';
import 'base_bottom_sheet.dart';

class RenameBottomSheet extends StatefulWidget {
  final String currentKey;
  final String currentName;

  const RenameBottomSheet({
    super.key,
    required this.currentKey,
    required this.currentName,
  });

  @override
  State<RenameBottomSheet> createState() => _RenameBottomSheetState();
}

class _RenameBottomSheetState extends State<RenameBottomSheet> {
  late final TextEditingController _ctrl;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentName);
    _ctrl.selection =
        TextSelection(baseOffset: 0, extentOffset: _ctrl.text.length);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _rename() async {
    final newName = _ctrl.text.trim();
    if (newName.isEmpty) {
      setState(() => _error = 'Name is required');
      return;
    }
    if (newName == widget.currentName) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<FileManagerProvider>().rename(widget.currentKey, newName);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Failed to rename: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheet(
      title: 'Rename File',
      subtitle: 'ENTER NEW NAME',
      accentColor: AppColors.primary,
      icon: Icons.drive_file_rename_outline,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NEW NAME',
              style: GoogleFonts.jetBrainsMono(
                color: const Color(0xFF555555),
                fontSize: 9,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            DarkTextField(
              controller: _ctrl,
              hintText: 'new-name.ext',
              autofocus: true,
              onSubmitted: (_) => _rename(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              SheetErrorBanner(message: _error!),
            ],
            const SizedBox(height: 20),
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
                  label: 'Rename',
                  icon: Icons.drive_file_rename_outline,
                  isLoading: _loading,
                  onTap: _rename,
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
