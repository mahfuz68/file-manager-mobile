// lib/widgets/folder_item_tile.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/file_item.dart';
import '../theme/app_theme.dart';

class FolderItemTile extends StatefulWidget {
  final FolderItem folder;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleSelect;

  const FolderItemTile({
    super.key,
    required this.folder,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleSelect,
  });

  @override
  State<FolderItemTile> createState() => _FolderItemTileState();
}

class _FolderItemTileState extends State<FolderItemTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    const folderColor = Color(0xFFF5A623); // warm amber

    return GestureDetector(
      onTap: isSelected ? widget.onToggleSelect : widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : _pressed
                  ? Colors.white.withOpacity(0.03)
                  : Colors.white.withOpacity(0.016),
          borderRadius: BorderRadius.circular(10),
          border: Border(
            top: BorderSide(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.35)
                    : AppColors.border.withOpacity(0.55)),
            right: BorderSide(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.35)
                    : AppColors.border.withOpacity(0.55)),
            bottom: BorderSide(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.35)
                    : AppColors.border.withOpacity(0.55)),
            left: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border.withOpacity(0.3),
                width: 2),
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: widget.onToggleSelect,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : const Color(0xFF3C3C3C),
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 11, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 10),

            // Folder icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.12)
                    : folderColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.3)
                      : folderColor.withOpacity(0.2),
                ),
              ),
              child: Icon(
                isSelected ? Icons.check : Icons.folder_outlined,
                color: isSelected ? AppColors.primary : folderColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),

            // Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.folder.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'FOLDER',
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFF444444),
                      fontSize: 9,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            if (!isSelected)
              Icon(Icons.chevron_right, color: const Color(0xFF3A3A3A), size: 18),
          ],
        ),
      ),
    );
  }
}
