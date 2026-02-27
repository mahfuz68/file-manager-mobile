// lib/widgets/file_list_skeleton.dart
// Shimmer loading skeleton that mirrors the web's FileListSkeleton

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FileListSkeleton extends StatelessWidget {
  const FileListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1A1A1A),
      highlightColor: const Color(0xFF2A2A2A),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: 8,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
