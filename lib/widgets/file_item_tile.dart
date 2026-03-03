// lib/widgets/file_item_tile.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/file_item.dart';
import '../theme/app_theme.dart';

class FileItemTile extends StatefulWidget {
  final FileItem file;
  final bool isSelected;
  final VoidCallback onLongPress;
  final VoidCallback onToggleSelect;
  final void Function(String action) onAction;

  const FileItemTile({
    super.key,
    required this.file,
    required this.isSelected,
    required this.onLongPress,
    required this.onToggleSelect,
    required this.onAction,
  });

  @override
  State<FileItemTile> createState() => _FileItemTileState();
}

class _FileItemTileState extends State<FileItemTile> {
  bool _showActions = false;

  Color get _typeColor {
    switch (widget.file.fileType) {
      case FileType.video:    return AppColors.video;
      case FileType.image:    return AppColors.image;
      case FileType.document: return AppColors.document;
      case FileType.audio:    return AppColors.audio;
      case FileType.archive:  return AppColors.archive;
      case FileType.code:     return AppColors.code;
      case FileType.file:     return AppColors.fileGeneric;
    }
  }

  IconData get _typeIcon {
    switch (widget.file.fileType) {
      case FileType.video:    return Icons.movie_outlined;
      case FileType.image:    return Icons.image_outlined;
      case FileType.document: return Icons.description_outlined;
      case FileType.audio:    return Icons.music_note_outlined;
      case FileType.archive:  return Icons.folder_zip_outlined;
      case FileType.code:     return Icons.code_outlined;
      case FileType.file:     return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final color = _typeColor;

    return GestureDetector(
      onLongPress: widget.onLongPress,
      onTap: isSelected
          ? widget.onToggleSelect
          : () => setState(() => _showActions = !_showActions),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white.withOpacity(0.018),
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
        child: Column(
          children: [
            Row(
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

                // Icon box
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.12) : color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primary.withOpacity(0.3) : color.withOpacity(0.25),
                    ),
                  ),
                  child: Icon(
                    isSelected ? Icons.check : _typeIcon,
                    color: isSelected ? AppColors.primary : color,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),

                // Name + size
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.file.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.file.formattedSize,
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFF555555),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.15) : color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isSelected ? AppColors.primary.withOpacity(0.3) : color.withOpacity(0.25),
                    ),
                  ),
                  child: Text(
                    widget.file.typeName,
                    style: GoogleFonts.jetBrainsMono(
                      color: isSelected ? AppColors.primary : color,
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                // Expand toggle
                if (!isSelected) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _showActions = !_showActions),
                    child: Icon(
                      _showActions ? Icons.expand_less : Icons.more_vert,
                      color: const Color(0xFF444444),
                      size: 18,
                    ),
                  ),
                ],
              ],
            ),

            // Action row (expanded)
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: _showActions && !isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true, // Scroll to the right end by default
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _ActionButton(
                              icon: Icons.drive_file_rename_outline,
                              label: 'Rename',
                              onTap: () {
                                setState(() => _showActions = false);
                                widget.onAction('rename');
                              },
                            ),
                            _ActionButton(
                              icon: Icons.share_outlined,
                              label: 'Share',
                              onTap: () {
                                setState(() => _showActions = false);
                                widget.onAction('share');
                              },
                            ),
                            _ActionButton(
                              icon: Icons.download_outlined,
                              label: 'Download',
                              onTap: () {
                                setState(() => _showActions = false);
                                widget.onAction('download');
                              },
                            ),
                            _ActionButton(
                              icon: Icons.delete_outline,
                              label: 'Delete',
                              isDestructive: true,
                              onTap: () {
                                setState(() => _showActions = false);
                                widget.onAction('delete');
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ActionButton({
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
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.destructive.withOpacity(0.08)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: isDestructive
                ? AppColors.destructive.withOpacity(0.22)
                : const Color(0xFF2A2A2A),
          ),
        ),
        child: Row(children: [
          Icon(icon, color: color.withOpacity(0.7), size: 13),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(color: color.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}