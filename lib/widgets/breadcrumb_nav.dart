// lib/widgets/breadcrumb_nav.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/file_manager_provider.dart';
import '../theme/app_theme.dart';

class BreadcrumbNav extends StatelessWidget {
  final VoidCallback onNewFolder;
  const BreadcrumbNav({super.key, required this.onNewFolder});

  @override
  Widget build(BuildContext context) {
    return Consumer<FileManagerProvider>(
      builder: (context, provider, _) {
        final segments = provider.pathSegments;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Home chip
                      _BreadcrumbChip(
                        label: '/ ROOT',
                        isActive: segments.isEmpty,
                        onTap: () => provider.navigateToIndex(0),
                        isHome: true,
                      ),
                      // Path segments
                      ...segments.asMap().entries.map((entry) {
                        final i = entry.key;
                        final seg = entry.value;
                        final isActive = i == segments.length - 1;
                        return Row(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '/',
                              style: TextStyle(color: AppColors.border, fontSize: 12),
                            ),
                          ),
                          _BreadcrumbChip(
                            label: seg.toUpperCase(),
                            isActive: isActive,
                            onTap: () => provider.navigateToIndex(i + 1),
                            isHome: false,
                          ),
                        ]);
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // New folder button
              GestureDetector(
                onTap: onNewFolder,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.create_new_folder_outlined,
                        color: AppColors.primary, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      'NEW FOLDER',
                      style: GoogleFonts.jetBrainsMono(
                        color: AppColors.primary,
                        fontSize: 9,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BreadcrumbChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final bool isHome;
  final VoidCallback onTap;
  const _BreadcrumbChip({
    required this.label,
    required this.isActive,
    required this.isHome,
    required this.onTap,
  });

  @override
  State<_BreadcrumbChip> createState() => _BreadcrumbChipState();
}

class _BreadcrumbChipState extends State<_BreadcrumbChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: widget.isActive
              ? AppColors.primary.withOpacity(0.12)
              : _pressed
                  ? AppColors.primary.withOpacity(0.06)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: widget.isActive
              ? Border.all(color: AppColors.primary.withOpacity(0.35))
              : null,
        ),
        child: Row(children: [
          if (widget.isHome) ...[
            Icon(
              Icons.storage_outlined,
              size: 12,
              color: widget.isActive ? AppColors.primary : const Color(0xFF555555),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            widget.label,
            style: GoogleFonts.jetBrainsMono(
              color: widget.isActive ? AppColors.primary : const Color(0xFF555555),
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ]),
      ),
    );
  }
}