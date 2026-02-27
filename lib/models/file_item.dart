// lib/models/file_item.dart

enum FileType { video, image, document, audio, archive, code, file }

class FileItem {
  final String key;
  final String name;
  final int size;
  final DateTime lastModified;
  final String type;

  const FileItem({
    required this.key,
    required this.name,
    required this.size,
    required this.lastModified,
    required this.type,
  });

  FileType get fileType {
    final ext = name.split('.').last.toLowerCase();
    const videoExts = ['mp4', 'mov', 'avi', 'mkv', 'webm', 'flv', 'wmv', 'm4v'];
    const imageExts = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'bmp', 'ico', 'tiff'];
    const documentExts = ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'csv', 'rtf', 'odt'];
    const audioExts = ['mp3', 'wav', 'ogg', 'flac', 'aac', 'm4a', 'wma'];
    const archiveExts = ['zip', 'tar', 'gz', 'rar', '7z', 'bz2', 'xz'];
    const codeExts = ['js', 'ts', 'jsx', 'tsx', 'html', 'css', 'json', 'py', 'go', 'rs', 'java', 'c', 'cpp', 'sh', 'yml', 'yaml', 'md'];

    if (videoExts.contains(ext)) return FileType.video;
    if (imageExts.contains(ext)) return FileType.image;
    if (documentExts.contains(ext)) return FileType.document;
    if (audioExts.contains(ext)) return FileType.audio;
    if (archiveExts.contains(ext)) return FileType.archive;
    if (codeExts.contains(ext)) return FileType.code;
    return FileType.file;
  }

  String get typeName => fileType.name.toUpperCase();

  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

class FolderItem {
  final String key;
  final String name;

  const FolderItem({required this.key, required this.name});
}

class ListResult {
  final List<FileItem> files;
  final List<FolderItem> folders;

  const ListResult({required this.files, required this.folders});
}
