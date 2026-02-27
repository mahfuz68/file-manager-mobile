// lib/widgets/base_bottom_sheet.dart
// Shared bottom-sheet scaffold + reusable form widgets.
// All classes are public so they can be imported by the modal files.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BaseBottomSheet — the rounded container used by every modal
// ─────────────────────────────────────────────────────────────────────────────

class BaseBottomSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accentColor;
  final IconData icon;
  final Widget child;

  const BaseBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F0F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          // Accent gradient line at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  accentColor.withOpacity(0.5),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                // Header row
                Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accentColor.withOpacity(0.25)),
                      boxShadow: [BoxShadow(color: accentColor.withOpacity(0.08), blurRadius: 16)],
                    ),
                    child: Icon(icon, color: accentColor, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      title,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFF555555), fontSize: 9, letterSpacing: 1.5),
                    ),
                  ]),
                ]),
                const SizedBox(height: 24),
                // Sheet-specific content
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DarkTextField
// ─────────────────────────────────────────────────────────────────────────────

class DarkTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String hintText;
  final bool autofocus;
  final TextInputType keyboardType;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;

  const DarkTextField({
    super.key,
    this.controller,
    this.initialValue,
    required this.hintText,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withOpacity(0.7)),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF3A3A3A), fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        onSubmitted: onSubmitted,
        onChanged: onChanged,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SheetPrimaryButton
// ─────────────────────────────────────────────────────────────────────────────

class SheetPrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;
  final Color? color;

  const SheetPrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.primary;
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: Colors.white,
          disabledBackgroundColor: bg.withOpacity(0.55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Please wait…',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ])
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, size: 16),
                const SizedBox(width: 8),
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
              ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SheetSecondaryButton
// ─────────────────────────────────────────────────────────────────────────────

class SheetSecondaryButton extends StatelessWidget {
  final String label;
  final bool disabled;
  final VoidCallback onTap;

  const SheetSecondaryButton({
    super.key,
    required this.label,
    this.disabled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: disabled ? 0.4 : 1,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.7)),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SheetErrorBanner
// ─────────────────────────────────────────────────────────────────────────────

class SheetErrorBanner extends StatelessWidget {
  final String message;
  const SheetErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.error_outline,
            color: AppColors.destructive.withOpacity(0.7), size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
                color: AppColors.destructive.withOpacity(0.85),
                fontSize: 12,
                height: 1.4),
          ),
        ),
      ]),
    );
  }
}
