// lib/services/r2_service.dart
//
// Direct Cloudflare R2 / S3-compatible client.
// Signs every request with AWS Signature V4 using pure Dart (crypto package).
// No native code, no AWS SDK — works on Android, iOS.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import '../models/file_item.dart';

class R2Service {
  late final String _endpoint;
  late final String _accessKeyId;
  late final String _secretAccessKey;
  late final String _bucketName;
  late final String _region;

  R2Service() {
    _endpoint = dotenv.env['R2_ENDPOINT'] ?? '';
    _accessKeyId = dotenv.env['R2_ACCESS_KEY_ID'] ?? '';
    _secretAccessKey = dotenv.env['R2_SECRET_ACCESS_KEY'] ?? '';
    _bucketName = dotenv.env['R2_BUCKET_NAME'] ?? '';
    _region = dotenv.env['R2_REGION'] ?? 'auto';
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SigV4 helpers
  // ─────────────────────────────────────────────────────────────────────────

  static final _dateFmt = DateFormat('yyyyMMdd');
  static final _dateTimeFmt = DateFormat("yyyyMMdd'T'HHmmss'Z'");

  String _fmtDate(DateTime dt) => _dateFmt.format(dt.toUtc());
  String _fmtDateTime(DateTime dt) => _dateTimeFmt.format(dt.toUtc());

  List<int> _hmac(List<int> key, String data) =>
      Hmac(sha256, key).convert(utf8.encode(data)).bytes;

  String _hex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  String _hashHex(List<int> data) => sha256.convert(data).toString();

  List<int> _signingKey(String dateStr) {
    final k1 = _hmac(utf8.encode('AWS4$_secretAccessKey'), dateStr);
    final k2 = _hmac(k1, _region);
    final k3 = _hmac(k2, 's3');
    return _hmac(k3, 'aws4_request');
  }

  /// Build signed headers for a regular (non-presigned) request.
  Map<String, String> _sign({
    required String method,
    required String canonicalUri,       // e.g. /bucket/key
    required Map<String, String> query, // already URI-encoded keys+values
    required Map<String, String> hdrs,  // lowercase keys
    required List<int> body,
  }) {
    final now = DateTime.now().toUtc();
    final dt = _fmtDateTime(now);
    final d = _fmtDate(now);

    final payloadHash = _hashHex(body);

    final allHdrs = {
      ...hdrs,
      'x-amz-content-sha256': payloadHash,
      'x-amz-date': dt,
    };

    final sortedHdrKeys = allHdrs.keys.map((k) => k.toLowerCase()).toList()
      ..sort();

    final canonicalHdrs = sortedHdrKeys
        .map((k) => '$k:${allHdrs[allHdrs.keys.firstWhere((h) => h.toLowerCase() == k)]!.trim()}')
        .join('\n');
    final signedHdrs = sortedHdrKeys.join(';');

    final sortedQS = query.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final canonicalQS = sortedQS
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final canonicalReq = [
      method,
      canonicalUri.isEmpty ? '/' : canonicalUri,
      canonicalQS,
      '$canonicalHdrs\n',
      signedHdrs,
      payloadHash,
    ].join('\n');

    final credScope = '$d/$_region/s3/aws4_request';
    final sts = [
      'AWS4-HMAC-SHA256',
      dt,
      credScope,
      _hashHex(utf8.encode(canonicalReq)),
    ].join('\n');

    final sig = _hex(_hmac(_signingKey(d), sts));
    final auth =
        'AWS4-HMAC-SHA256 Credential=$_accessKeyId/$credScope, SignedHeaders=$signedHdrs, Signature=$sig';

    return {
      ...allHdrs,
      'Authorization': auth,
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Key → path encoding helper
  // ─────────────────────────────────────────────────────────────────────────

  /// Encode each path segment but keep the '/' separators.
  String _encKey(String key) =>
      key.split('/').map(Uri.encodeComponent).join('/');

  String _canonicalUri(String key) =>
      '/$_bucketName${key.isEmpty ? '' : '/${_encKey(key)}'}';

  Uri _uri(String key, [Map<String, String>? query]) {
    final base = '$_endpoint/$_bucketName';
    final encoded = key.isEmpty ? '' : '/${_encKey(key)}';
    final uri = Uri.parse('$base$encoded');
    return (query != null && query.isNotEmpty)
        ? uri.replace(queryParameters: query)
        : uri;
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  LIST
  // ─────────────────────────────────────────────────────────────────────────

  Future<ListResult> listObjects(String prefix) async {
    final qp = <String, String>{
      'list-type': '2',
      'delimiter': '/',
      if (prefix.isNotEmpty) 'prefix': prefix,
    };

    final uri = _uri('', qp);
    final host = uri.host;

    final headers = _sign(
      method: 'GET',
      canonicalUri: '/$_bucketName',
      query: qp,
      hdrs: {'host': host},
      body: [],
    );

    final response = await http.get(uri, headers: headers);
    if (response.statusCode != 200) {
      throw Exception(
          'List failed: ${response.statusCode}\n${response.body}');
    }

    final doc = XmlDocument.parse(response.body);

    // Namespaced helper
    Iterable<XmlElement> elems(XmlElement parent, String tag) =>
        parent.findElements(tag);

    String text(XmlElement parent, String tag) =>
        parent.findElements(tag).first.innerText;

    final folders = doc
        .findAllElements('CommonPrefixes')
        .map((e) {
          final key = text(e, 'Prefix');
          final name = key.split('/').where((s) => s.isNotEmpty).last;
          return FolderItem(key: key, name: name);
        })
        .toList();

    final files = doc
        .findAllElements('Contents')
        .map((e) {
          final key = text(e, 'Key');
          if (key.endsWith('/')) return null;
          final size = int.tryParse(text(e, 'Size')) ?? 0;
          final lastMod = DateTime.tryParse(text(e, 'LastModified')) ?? DateTime.now();
          final name = key.split('/').last;
          final ext = name.contains('.') ? name.split('.').last : '';
          return FileItem(key: key, name: name, size: size, lastModified: lastMod, type: ext.toUpperCase());
        })
        .whereType<FileItem>()
        .toList();

    return ListResult(files: files, folders: folders);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PRESIGNED GET (download / share)
  // ─────────────────────────────────────────────────────────────────────────

  String generatePresignedUrl(String key, {int expirySeconds = 300}) {
    final now = DateTime.now().toUtc();
    final dt = _fmtDateTime(now);
    final d = _fmtDate(now);
    final credScope = '$d/$_region/s3/aws4_request';
    final credential = '$_accessKeyId/$credScope';

    final host = Uri.parse(_endpoint).host;
    final encodedKey = _encKey(key);
    final path = '/$_bucketName/$encodedKey';

    final qp = {
      'X-Amz-Algorithm': 'AWS4-HMAC-SHA256',
      'X-Amz-Credential': credential,
      'X-Amz-Date': dt,
      'X-Amz-Expires': '$expirySeconds',
      'X-Amz-SignedHeaders': 'host',
    };

    final sortedQS = qp.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final canonicalQS = sortedQS
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final canonicalReq = [
      'GET',
      path,
      canonicalQS,
      'host:$host\n',
      'host',
      'UNSIGNED-PAYLOAD',
    ].join('\n');

    final sts = [
      'AWS4-HMAC-SHA256',
      dt,
      credScope,
      _hashHex(utf8.encode(canonicalReq)),
    ].join('\n');

    final sig = _hex(_hmac(_signingKey(d), sts));
    return '$_endpoint/$_bucketName/$encodedKey?$canonicalQS&X-Amz-Signature=$sig';
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  UPLOAD  (streaming with progress)
  // ─────────────────────────────────────────────────────────────────────────

  /// Uploads [bytes] to R2, yielding progress 0.0→1.0.
  Stream<double> uploadFile({
    required String key,
    required Uint8List bytes,
    required String contentType,
  }) async* {
    if (bytes.isEmpty) {
      yield 1.0;
      return;
    }

    final uri = _uri(key);
    final host = uri.host;
    final canonicalUri = _canonicalUri(key);

    final headers = _sign(
      method: 'PUT',
      canonicalUri: canonicalUri,
      query: {},
      hdrs: {
        'host': host,
        'content-type': contentType,
        'content-length': '${bytes.length}',
      },
      body: bytes,
    );

    final client = HttpClient();
    try {
      final req = await client.putUrl(uri);
      headers.forEach((k, v) => req.headers.set(k, v));
      req.contentLength = bytes.length;

      // Stream bytes in 64KB chunks, yielding progress
      const chunkSize = 65536;
      int sent = 0;
      while (sent < bytes.length) {
        final end = (sent + chunkSize).clamp(0, bytes.length);
        req.add(bytes.sublist(sent, end));
        sent = end;
        yield sent / bytes.length;
      }

      final resp = await req.close();
      // Drain response body
      await resp.drain<void>();

      if (resp.statusCode != 200 && resp.statusCode != 204) {
        throw Exception('Upload failed: ${resp.statusCode}');
      }
    } finally {
      client.close();
    }
    yield 1.0;
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  DELETE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> deleteObject(String key) async {
    final uri = _uri(key);
    final host = uri.host;

    final headers = _sign(
      method: 'DELETE',
      canonicalUri: _canonicalUri(key),
      query: {},
      hdrs: {'host': host},
      body: [],
    );

    final resp = await http.delete(uri, headers: headers);
    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception('Delete failed: ${resp.statusCode}');
    }
  }

  /// Recursively delete all objects under a folder prefix.
  Future<void> deleteFolder(String prefix) async {
    final result = await listObjects(prefix);
    for (final file in result.files) {
      await deleteObject(file.key);
    }
    for (final folder in result.folders) {
      await deleteFolder(folder.key);
    }
    // Delete the folder marker
    await deleteObject(prefix);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  RENAME  (CopyObject + DeleteObject)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> renameObject(String oldKey, String newKey) async {
    final copyUri = _uri(newKey);
    final host = copyUri.host;
    final copySource = '/$_bucketName/${_encKey(oldKey)}';

    final headers = _sign(
      method: 'PUT',
      canonicalUri: _canonicalUri(newKey),
      query: {},
      hdrs: {
        'host': host,
        'x-amz-copy-source': copySource,
        'content-length': '0',
      },
      body: [],
    );

    final resp = await http.put(copyUri, headers: headers);
    if (resp.statusCode != 200) {
      throw Exception('Rename (copy) failed: ${resp.statusCode}\n${resp.body}');
    }

    await deleteObject(oldKey);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  CREATE FOLDER  (zero-byte PUT with trailing /)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> createFolder(String key) async {
    final folderKey = key.endsWith('/') ? key : '$key/';
    final uri = _uri(folderKey);
    final host = uri.host;

    final headers = _sign(
      method: 'PUT',
      canonicalUri: _canonicalUri(folderKey),
      query: {},
      hdrs: {
        'host': host,
        'content-type': 'application/octet-stream',
        'content-length': '0',
      },
      body: [],
    );

    final resp = await http.put(uri, headers: headers, body: Uint8List(0));
    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception('Create folder failed: ${resp.statusCode}\n${resp.body}');
    }
  }
}
