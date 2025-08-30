/// Serviço para gerenciamento de imagens usando Base64
///
/// Responsável por:
/// - Seleção de imagens da galeria/câmera
/// - Conversão para Base64 (sem Firebase Storage)
/// - Compressão e redimensionamento
/// - Armazenamento direto no Firestore
library;

import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Seleciona uma imagem da galeria ou câmera e converte para Base64
  Future<String?> selecionarEConverterImagem(
      {ImageSource source = ImageSource.gallery}) async {
    try {
      debugPrint('🔄 Selecionando imagem...');

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1000, // Ajustado para compensar limite menor
        maxHeight: 800, // Ajustado para compensar limite menor
        imageQuality: 65, // Ajustado para melhor qualidade/tamanho
      );

      if (image == null) {
        debugPrint('❌ Nenhuma imagem selecionada');
        return null;
      }

      // Converter para bytes
      final bytes = await image.readAsBytes();

      // Verificar tamanho (Firestore tem limite de 1MB por campo)
      // Base64 aumenta ~33%, então limite real é ~750KB para ficar seguro
      if (bytes.length > 750 * 1024) {
        // 750KB limite (seguro para Base64 no Firestore)
        debugPrint(
            '❌ Imagem muito grande: ${bytes.length} bytes (máximo 750KB)');
        return null;
      }

      // Converter para Base64
      final base64String = base64Encode(bytes);

      debugPrint(
          '✅ Imagem convertida para Base64: ${base64String.length} caracteres');
      return base64String;
    } catch (e) {
      debugPrint('❌ Erro ao selecionar/converter imagem: $e');
      return null;
    }
  }

  /// Seleciona múltiplas imagens e converte para Base64
  Future<List<String>> selecionarMultiplasImagens() async {
    try {
      debugPrint('🔄 Selecionando múltiplas imagens...');

      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 70,
      );

      if (images.isEmpty) {
        debugPrint('❌ Nenhuma imagem selecionada');
        return [];
      }

      List<String> imagensBase64 = [];

      for (int i = 0; i < images.length; i++) {
        debugPrint('🔄 Processando imagem ${i + 1}/${images.length}...');

        final bytes = await images[i].readAsBytes();

        // Verificar tamanho
        if (bytes.length <= 800 * 1024) {
          final base64String = base64Encode(bytes);
          imagensBase64.add(base64String);
          debugPrint('✅ Imagem ${i + 1} convertida com sucesso');
        } else {
          debugPrint(
              '❌ Imagem ${i + 1} muito grande ignorada: ${images[i].name} (${bytes.length} bytes)');
        }
      }

      debugPrint(
          '🎉 Total de imagens processadas: ${imagensBase64.length}/${images.length}');
      return imagensBase64;
    } catch (e) {
      debugPrint('❌ Erro ao selecionar múltiplas imagens: $e');
      return [];
    }
  }

  /// Upload de múltiplas imagens (agora apenas retorna as strings Base64)
  Future<List<String>> uploadMultiplasImagens({
    required List<XFile> images,
    required String pastaDestino,
    Function(int, int)? onProgress,
  }) async {
    try {
      debugPrint('🔄 Iniciando conversão de ${images.length} imagens...');

      List<String> imagensBase64 = [];

      for (int i = 0; i < images.length; i++) {
        debugPrint('🔄 Convertendo imagem ${i + 1}/${images.length}...');
        onProgress?.call(i + 1, images.length);

        final bytes = await images[i].readAsBytes();

        // Verificar tamanho
        if (bytes.length <= 800 * 1024) {
          final base64String = base64Encode(bytes);
          imagensBase64.add(base64String);
          debugPrint('✅ Imagem ${i + 1} convertida com sucesso');
        } else {
          debugPrint(
              '❌ Falha na conversão da imagem ${i + 1}/${images.length} - muito grande');
        }
      }

      debugPrint(
          '🎉 Conversão concluída: ${imagensBase64.length}/${images.length} imagens');
      return imagensBase64;
    } catch (e) {
      debugPrint('❌ Erro na conversão de múltiplas imagens: $e');
      return [];
    }
  }

  /// Converte Base64 de volta para bytes (para exibir na UI)
  Uint8List? base64ParaBytes(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      debugPrint('❌ Erro ao decodificar Base64: $e');
      return null;
    }
  }

  /// Obtém informações da imagem Base64
  Map<String, dynamic> obterInfoImagem(String base64String) {
    try {
      final bytes = base64Decode(base64String);
      return {
        'tamanho': bytes.length,
        'tamanhoFormatado': '${(bytes.length / 1024).toStringAsFixed(1)} KB',
        'tipo': 'image/jpeg', // Assumindo JPEG devido à compressão
      };
    } catch (e) {
      debugPrint('❌ Erro ao obter info da imagem: $e');
      return {};
    }
  }

  /// Remove uma imagem da lista (para Base64, apenas remove da lista)
  List<String> removerImagem(List<String> listaImagens, int index) {
    if (index >= 0 && index < listaImagens.length) {
      final novaLista = List<String>.from(listaImagens);
      novaLista.removeAt(index);
      debugPrint('🗑️ Imagem removida da posição $index');
      return novaLista;
    }
    return listaImagens;
  }

  /// Valida se uma string é uma imagem Base64 válida
  bool validarImagemBase64(String? base64String) {
    if (base64String == null || base64String.isEmpty) return false;

    try {
      final bytes = base64Decode(base64String);
      return bytes.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Comprime uma imagem Base64 se necessário
  Future<String?> comprimirImagemBase64(String base64String) async {
    try {
      final bytes = base64Decode(base64String);

      // Se já está dentro do limite, retorna como está
      if (bytes.length <= 800 * 1024) {
        return base64String;
      }

      // Para imagens muito grandes, apenas retorna null
      // (em uma implementação real, poderia usar bibliotecas de compressão)
      debugPrint('❌ Imagem muito grande para comprimir: ${bytes.length} bytes');
      return null;
    } catch (e) {
      debugPrint('❌ Erro ao comprimir imagem: $e');
      return null;
    }
  }
}
