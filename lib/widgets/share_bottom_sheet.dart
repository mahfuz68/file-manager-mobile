// lib/widgets/share_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/file_manager_provider.dart';
import '../theme/app_theme.dart';
import 'base_bottom_sheet.dart';
import 'share_link_bottom_sheet.dart';

class ShareBottomSheet extends StatefulWidget {
  final String fileKey;
  final String fileName;

  const ShareBottomSheet({
    super.key,
    required this.fileKey,
    required this.fileName,
  });

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  bool _generating = false;
  String? _activePreset = '1 hour';
  int _duration = 1;
  String _unit = 'hours';

  static const _presets = [
    ('15 min', 15, 'minutes'),
    ('1 hour', 1, 'hours'),
    ('1 day', 1, 'days'),
    ('7 days', 7, 'days'),
  ];

  int get _totalSeconds {
    switch (_unit) {
      case 'minutes': return _duration * 60;
      case 'hours':   return _duration * 3600;
      case 'days':    return _duration * 86400;
      case 'weeks':   return _duration * 604800;
      default:        return _duration * 3600;
    }
  }

  Future<void> _generate() async {
    setState(() => _generating = true);
    try {
      final provider = context.read<FileManagerProvider>();
      final url = provider.getShareUrl(widget.fileKey, _totalSeconds);
      final expiryDate = DateTime.now().add(Duration(seconds: _totalSeconds));
      if (mounted) {
        Navigator.pop(context);
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => ShareLinkBottomSheet(
            fileName: widget.fileName,
            url: url,
            expiryDate: expiryDate,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed: $e'),
              backgroundColor: AppColors.destructive),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheet(
      title: 'Generate Share Link',
      subtitle: 'PRESIGNED URL · CLOUDFLARE R2',
      accentColor: AppColors.primary,
      icon: Icons.share_outlined,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick presets
            Text(
              'QUICK EXPIRY',
              style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF555555), fontSize: 9, letterSpacing: 2),
            ),
            const SizedBox(height: 10),
            Row(
              children: _presets.map((preset) {
                final (label, dur, unit) = preset;
                final isActive = _activePreset == label;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _activePreset = label;
                        _duration = dur;
                        _unit = unit;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 36,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary.withOpacity(0.12)
                              : Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isActive
                                ? AppColors.primary.withOpacity(0.4)
                                : AppColors.border.withOpacity(0.7),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: GoogleFonts.jetBrainsMono(
                              color: isActive
                                  ? AppColors.primary
                                  : const Color(0xFF666666),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Divider
            Row(children: [
              Expanded(
                  child: Container(
                      height: 1,
                      color: AppColors.border.withOpacity(0.6))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('OR CUSTOM',
                    style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFF444444),
                        fontSize: 9,
                        letterSpacing: 1.5)),
              ),
              Expanded(
                  child: Container(
                      height: 1,
                      color: AppColors.border.withOpacity(0.6))),
            ]),
            const SizedBox(height: 16),

            // Custom
            Text(
              'CUSTOM DURATION',
              style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF555555), fontSize: 9, letterSpacing: 2),
            ),
            const SizedBox(height: 10),
            Row(children: [
              SizedBox(
                width: 90,
                child: DarkTextField(
                  initialValue: '$_duration',
                  hintText: '1',
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    final n = int.tryParse(v);
                    if (n != null && n > 0) {
                      setState(() {
                        _duration = n;
                        _activePreset = null;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                  child: _UnitPicker(
                    value: _unit,
                    onChanged: (v) =>
                        setState(() { _unit = v; _activePreset = null; }),
                  )),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.schedule, size: 12, color: Color(0xFF444444)),
              const SizedBox(width: 6),
              Text('Link expires after ',
                  style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFF444444), fontSize: 11)),
              Text('$_duration $_unit',
                  style: GoogleFonts.jetBrainsMono(
                      color: AppColors.primary.withOpacity(0.7), fontSize: 11)),
            ]),
            const SizedBox(height: 20),
            SheetPrimaryButton(
              label: 'Generate Share Link',
              icon: Icons.link,
              isLoading: _generating,
              onTap: _generate,
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitPicker extends StatelessWidget {
  final String value;
  final void Function(String) onChanged;

  const _UnitPicker({required this.value, required this.onChanged});

  static const _units = ['minutes', 'hours', 'days', 'weeks'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withOpacity(0.7)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF141414),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Color(0xFF555555), size: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 12),
          items: _units
              .map((u) => DropdownMenuItem(
                    value: u,
                    child: Text(u,
                        style: GoogleFonts.jetBrainsMono(
                            color: Colors.white, fontSize: 12)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
