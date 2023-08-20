import 'package:image/image.dart' as IMG;
import 'dart:typed_data';
import 'dart:async';

Future<Uint8List> resizeImage(dynamic message) async {
  final completer = Completer<Uint8List>();

  final data = message['data'];
  final pixelRatio = message['pixelRatio'];
  final dpi = message['dpi'];

  try {
    final img = IMG.decodeImage(Uint8List.fromList(data));
    if (img != null) {
      final resized = IMG.copyResize(
        img,
        width: img.width * (pixelRatio / 10) * dpi ~/ 100,
        height: img.height * (pixelRatio / 10) * dpi ~/ 100,
      );
      final resizedData = Uint8List.fromList(IMG.encodeJpg(resized));
      completer.complete(resizedData);
    } else {
      completer.complete(data);
    }
  } catch (e) {
    completer.complete(data);
  }

  return completer.future;
}
