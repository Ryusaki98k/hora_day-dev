import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<String> saveCardImage({
  required Uint8List bytes,
  required String filename,
}) async {
  final candidates = <Directory>[];

  if (Platform.isWindows) {
    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile != null) {
      final downloadsDir = Directory('$userProfile\\Downloads');
      if (downloadsDir.existsSync()) {
        candidates.add(downloadsDir);
      }
    }
  }

  if (Platform.isAndroid) {
    try {
      final extDirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
      if (extDirs != null && extDirs.isNotEmpty) {
        candidates.addAll(extDirs);
      }
    } catch (_) {}

    try {
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        candidates.add(extDir);
      }
    } catch (_) {}

    final androidDownload = Directory('/storage/emulated/0/Download');
    if (androidDownload.existsSync()) {
      candidates.add(androidDownload);
    }
  } else if (Platform.isIOS || Platform.isMacOS || Platform.isLinux) {
    try {
      final dl = await getDownloadsDirectory();
      if (dl != null) candidates.add(dl);
    } catch (_) {}
  }

  try {
    final docs = await getApplicationDocumentsDirectory();
    candidates.add(docs);
  } catch (_) {}

  // Attempt saving to the best candidate with fallback
  for (final dir in candidates) {
    try {
      final filePath = '${dir.path}${Platform.pathSeparator}$filename';
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);
      return filePath;
    } catch (_) {
      // Continue to next fallback if permission or write fails
    }
  }

  // Final fallback to temp directory
  final tempDir = await getTemporaryDirectory();
  final tempPath = '${tempDir.path}${Platform.pathSeparator}$filename';
  final tempFile = File(tempPath);
  await tempFile.writeAsBytes(bytes, flush: true);
  return tempPath;
}
