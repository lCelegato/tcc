import 'dart:convert';
import 'dart:typed_data';

class ChunkingService {
  static const int chunkSize = 800 * 1024; // 800KB por chunk

  /// Fragmenta arquivo grande em chunks menores
  static List<String> fragmentarArquivo(Uint8List bytes, String fileName) {
    final chunks = <String>[];
    final totalChunks = (bytes.length / chunkSize).ceil();

    for (int i = 0; i < totalChunks; i++) {
      final start = i * chunkSize;
      final end =
          (start + chunkSize > bytes.length) ? bytes.length : start + chunkSize;

      final chunkBytes = bytes.sublist(start, end);
      final chunkBase64 = base64Encode(chunkBytes);

      chunks.add(chunkBase64);
    }

    return chunks;
  }

  /// Reconstrói arquivo a partir dos chunks
  static Uint8List reconstituirArquivo(List<String> chunks) {
    final allBytes = <int>[];

    for (final chunk in chunks) {
      final chunkBytes = base64Decode(chunk);
      allBytes.addAll(chunkBytes);
    }

    return Uint8List.fromList(allBytes);
  }

  /// Estrutura para salvar no Firestore
  static Map<String, dynamic> criarEstruturaPorChunks(
    Uint8List bytes,
    String fileName,
    String mimeType,
  ) {
    final chunks = fragmentarArquivo(bytes, fileName);

    return {
      'nome': fileName,
      'mimeType': mimeType,
      'tamanhoTotal': bytes.length,
      'totalChunks': chunks.length,
      'chunks':
          chunks.asMap().map((index, chunk) => MapEntry('chunk_$index', chunk)),
      'dataUpload': DateTime.now().toIso8601String(),
    };
  }
}

/// Exemplo de uso:
/// 
/// // Para salvar arquivo de 5MB:
/// final estrutura = ChunkingService.criarEstruturaPorChunks(
///   arquivoBytes, 
///   'documento-grande.pdf',
///   'application/pdf'
/// );
/// 
/// // Salvar no Firestore:
/// await FirebaseFirestore.instance
///   .collection('postagens')
///   .doc(id)
///   .update({'documentoGrande': estrutura});
/// 
/// // Para recuperar:
/// final chunks = estrutura['chunks'] as Map<String, dynamic>;
/// final chunksList = chunks.values.cast<String>().toList();
/// final arquivoReconstituido = ChunkingService.reconstituirArquivo(chunksList);
