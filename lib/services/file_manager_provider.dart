// lib/services/file_manager_provider.dart
//
// ChangeNotifier-based state: current path, file list, selection, search.

import 'package:flutter/foundation.dart';
import '../models/file_item.dart';
import 'r2_service.dart';

class FileManagerProvider extends ChangeNotifier {
  final R2Service _r2 = R2Service();

  // Navigation
  final List<String> _pathStack = [''];
  String get currentPath => _pathStack.last;
  List<String> get pathSegments =>
      currentPath.isEmpty ? [] : currentPath.split('/').where((s) => s.isNotEmpty).toList();

  // Data
  ListResult? _result;
  ListResult get result => _result ?? const ListResult(files: [], folders: []);
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;

  // Search / filter
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  String _typeFilter = 'all';
  String get typeFilter => _typeFilter;

  List<FileItem> get filteredFiles {
    var files = result.files;
    if (_searchQuery.isNotEmpty) {
      files = files
          .where((f) => f.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    if (_typeFilter != 'all') {
      files = files.where((f) => f.fileType.name == _typeFilter).toList();
    }
    return files;
  }

  List<FolderItem> get filteredFolders {
    if (_searchQuery.isEmpty) return result.folders;
    return result.folders
        .where((f) => f.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // Selection
  final Set<String> _selected = {};
  Set<String> get selected => _selected;
  bool get hasSelection => _selected.isNotEmpty;
  int get selectionCount => _selected.length;

  // Upload progress
  final Map<String, double> _uploadProgress = {};
  Map<String, double> get uploadProgress => _uploadProgress;

  // ─────────────────────────────────────────────────────────────────────────
  //  Navigation
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> navigateTo(String path) async {
    _pathStack.add(path);
    _selected.clear();
    await refresh();
  }

  Future<void> navigateUp() async {
    if (_pathStack.length > 1) {
      _pathStack.removeLast();
      _selected.clear();
      await refresh();
    }
  }

  Future<void> navigateToIndex(int index) async {
    // index 0 = root
    while (_pathStack.length > index + 1) {
      _pathStack.removeLast();
    }
    _selected.clear();
    await refresh();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Data
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _result = await _r2.listObjects(currentPath);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Selection
  // ─────────────────────────────────────────────────────────────────────────

  void toggleSelect(String key) {
    if (_selected.contains(key)) {
      _selected.remove(key);
    } else {
      _selected.add(key);
    }
    notifyListeners();
  }

  void selectAll() {
    for (final f in result.folders) _selected.add(f.key);
    for (final f in result.files) _selected.add(f.key);
    notifyListeners();
  }

  void clearSelection() {
    _selected.clear();
    notifyListeners();
  }

  bool isSelected(String key) => _selected.contains(key);

  bool get allSelected =>
      _selected.isNotEmpty &&
      _selected.length == result.files.length + result.folders.length;

  // ─────────────────────────────────────────────────────────────────────────
  //  Search / filter
  // ─────────────────────────────────────────────────────────────────────────

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setTypeFilter(String f) {
    _typeFilter = f;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  File actions
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> createFolder(String name) async {
    final key = currentPath.isEmpty ? '$name/' : '$currentPath$name/';
    await _r2.createFolder(key);
    await refresh();
  }

  Future<void> delete(List<String> keys) async {
    for (final key in keys) {
      if (key.endsWith('/')) {
        await _r2.deleteFolder(key);
      } else {
        await _r2.deleteObject(key);
      }
    }
    _selected.removeAll(keys);
    await refresh();
  }

  Future<void> rename(String oldKey, String newName) async {
    final prefix = currentPath;
    final newKey = '$prefix$newName';
    await _r2.renameObject(oldKey, newKey);
    await refresh();
  }

  String getDownloadUrl(String key) =>
      _r2.generatePresignedUrl(key, expirySeconds: 300);

  String getShareUrl(String key, int durationSeconds) =>
      _r2.generatePresignedUrl(key, expirySeconds: durationSeconds);

  /// Upload a file and track progress.
  Future<void> uploadFile({
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final key = currentPath.isEmpty ? fileName : '$currentPath$fileName';
    _uploadProgress[key] = 0;
    notifyListeners();

    await for (final progress in _r2.uploadFile(
      key: key,
      bytes: bytes,
      contentType: contentType,
    )) {
      _uploadProgress[key] = progress;
      notifyListeners();
    }

    _uploadProgress.remove(key);
    await refresh();
  }
}
