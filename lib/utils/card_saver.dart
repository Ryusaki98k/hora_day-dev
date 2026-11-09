import 'dart:typed_data';

import 'card_saver_stub.dart'
    if (dart.library.html) 'card_saver_web.dart'
    if (dart.library.io) 'card_saver_io.dart' as impl;

class CardSaver {
  static Future<String> saveImage({
    required Uint8List bytes,
    required String filename,
  }) async {
    return await impl.saveCardImage(bytes: bytes, filename: filename);
  }
}
