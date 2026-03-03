// lib/widgets/toolbar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/file_manager_provider.dart';
import '../theme/app_theme.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({super.key});

  static const _filters = [
    ('all', 'ALL'),
    ('video', 'VIDEO'),
    ('image', 'IMAGE'),
    ('document', 'DOC'),
    ('audio', 'AUDIO'),
    ('archive', 'ZIP'),
    ('code', 'CODE'),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<FileManagerProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // Search bar
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F0F),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border.withOpacity(0.7)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, color: Color(0xFF444444), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: provider.setSearchQuery,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          hoverColor: Colors.transparent,
                          hintText: 'Search files…',
                          hintStyle: TextStyle(color: Color(0xFF3A3A3A), fontSize: 13),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // File type filter chips
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _filters.map((filter) {
                    final (value, label) = filter;
                    final isActive = provider.typeFilter == value;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () => provider.setTypeFilter(value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary.withOpacity(0.12)
                                : Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isActive
                                  ? AppColors.primary.withOpacity(0.4)
                                  : AppColors.border.withOpacity(0.7),
                            ),
                          ),
                          child: Text(
                            label,
                            style: GoogleFonts.jetBrainsMono(
                              color: isActive ? AppColors.primary : const Color(0xFF666666),
                              fontSize: 9,
                              letterSpacing: 1.5,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
