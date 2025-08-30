import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class CompressionService {
  /// Comprime imagem de forma inteligente para máximo aproveitamento
  static Future<Uint8List> compressImageIntelligent(
    Uint8List bytes, {
    int targetSizeKB = 900, // Meta de tamanho final
    int maxWidth = 1600,
    int maxHeight = 1200,
  }) async {
    return await compute(_compressImageIsolate, {
      'bytes': bytes,
      'targetSizeKB': targetSizeKB,
      'maxWidth': maxWidth,
      'maxHeight': maxHeight,
    });
  }

  static Uint8List _compressImageIsolate(Map<String, dynamic> params) {
    final Uint8List bytes = params['bytes'];
    final int targetSizeKB = params['targetSizeKB'];
    final int maxWidth = params['maxWidth'];
    final int maxHeight = params['maxHeight'];

    // Decodificar imagem
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return bytes;

    // Redimensionar se necessário
    if (image.width > maxWidth || image.height > maxHeight) {
      image = img.copyResize(
        image,
        width: image.width > maxWidth ? maxWidth : null,
        height: image.height > maxHeight ? maxHeight : null,
        maintainAspect: true,
      );
    }

    // Compressão adaptativa
    int quality = 85;
    Uint8List compressed =
        Uint8List.fromList(img.encodeJpg(image, quality: quality));

    // Reduzir qualidade até atingir tamanho desejado
    while (compressed.length > targetSizeKB * 1024 && quality > 20) {
      quality -= 10;
      compressed = Uint8List.fromList(img.encodeJpg(image, quality: quality));
    }

    debugPrint(
        '📸 Imagem comprimida: ${compressed.length} bytes com qualidade $quality%');
    return compressed;
  }

  /// Comprime PDF (remove metadados, otimiza)
  static Future<Uint8List> compressPDF(Uint8List pdfBytes) async {
    // Para PDFs, podemos remover metadados e otimizar
    // Por enquanto, retorna original (implementação futura)
    return pdfBytes;
  }
}
