import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class DocumentoService {
  // Tipos de arquivo permitidos
  static const List<String> tiposPermitidos = [
    'pdf',
    'doc',
    'docx',
    'txt',
    'rtf',
    'odt'
  ];

  // Tamanho máximo (750KB para compensar Base64 e ficar seguro no Firestore)
  // Base64 aumenta ~33%: 750KB → ~1MB (dentro do limite do Firestore)
  static const int tamanhoMaximo = 750 * 1024; // 750KB (seguro para Base64)

  /// Selecionar documentos do dispositivo
  Future<List<Map<String, dynamic>>> selecionarDocumentos() async {
    try {
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: tiposPermitidos,
        allowMultiple: true,
        withData: true, // Importante: incluir os bytes
      );

      if (resultado == null) return [];

      final documentos = <Map<String, dynamic>>[];

      for (final arquivo in resultado.files) {
        // Validar tamanho
        if (arquivo.size > tamanhoMaximo) {
          throw Exception(
              'Arquivo ${arquivo.name} muito grande. Máximo: ${(tamanhoMaximo / 1024).round()}KB');
        }

        // Validar extensão
        final extensao = arquivo.extension?.toLowerCase();
        if (!tiposPermitidos.contains(extensao)) {
          throw Exception('Tipo de arquivo não suportado: $extensao');
        }

        // Converter para Base64
        final bytes = arquivo.bytes!;
        final base64 = base64Encode(bytes);
        final mimeType = _obterMimeType(extensao!);

        documentos.add({
          'nome': arquivo.name,
          'extensao': extensao,
          'tamanho': arquivo.size,
          'mimeType': mimeType,
          'base64': 'data:$mimeType;base64,$base64',
          'dataUpload': DateTime.now().toIso8601String(),
        });
      }

      return documentos;
    } catch (e) {
      debugPrint('Erro ao selecionar documentos: $e');
      rethrow;
    }
  }

  /// Obter MIME type por extensão
  String _obterMimeType(String extensao) {
    switch (extensao) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      case 'rtf':
        return 'application/rtf';
      case 'odt':
        return 'application/vnd.oasis.opendocument.text';
      default:
        return 'application/octet-stream';
    }
  }

  /// Converter Base64 de volta para bytes
  Uint8List base64ParaBytes(String base64ComHeader) {
    // Remove o header "data:application/pdf;base64,"
    final base64Puro = base64ComHeader.split(',').last;
    return base64Decode(base64Puro);
  }

  /// Validar documento Base64
  bool validarDocumentoBase64(String base64) {
    try {
      final bytes = base64ParaBytes(base64);
      return bytes.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Obter informações do documento
  Map<String, dynamic> obterInfoDocumento(Map<String, dynamic> documento) {
    final tamanhoKB = (documento['tamanho'] as int) / 1024;
    final tamanhoMB = tamanhoKB / 1024;

    return {
      'nome': documento['nome'],
      'extensao': documento['extensao'],
      'tamanhoFormatado': tamanhoMB >= 1
          ? '${tamanhoMB.toStringAsFixed(1)} MB'
          : '${tamanhoKB.toStringAsFixed(0)} KB',
      'mimeType': documento['mimeType'],
      'dataUpload': documento['dataUpload'],
    };
  }

  /// Baixar documento (salvar localmente)
  Future<void> baixarDocumento(Map<String, dynamic> documento) async {
    try {
      final bytes = base64ParaBytes(documento['base64']);
      final nome = documento['nome'] as String;

      // Usar FilePicker para salvar
      final caminho = await FilePicker.platform.saveFile(
        dialogTitle: 'Salvar documento',
        fileName: nome,
        bytes: bytes,
      );

      if (caminho != null) {
        debugPrint('Documento salvo em: $caminho');
      }
    } catch (e) {
      debugPrint('Erro ao baixar documento: $e');
      rethrow;
    }
  }
}
