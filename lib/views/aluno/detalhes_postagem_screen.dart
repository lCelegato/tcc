/// Tela para visualizar os detalhes completos de uma postagem
///
/// Mostra o conteúdo completo da postagem quando o aluno
/// clica no card da postagem
library;

import 'package:flutter/material.dart';
import '../../models/postagem_model.dart';

class DetalhesPostagemScreen extends StatelessWidget {
  final PostagemModel postagem;

  const DetalhesPostagemScreen({
    super.key,
    required this.postagem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(postagem.nomeMateria),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com informações da postagem
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Matéria
                    Row(
                      children: [
                        _getIconeMateria(postagem.nomeMateria),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            postagem.nomeMateria,
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Título
                    Text(
                      postagem.titulo,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Data
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Publicado em ${postagem.dataFormatada}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Conteúdo da postagem
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Conteúdo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      postagem.conteudo,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Anexos (se houver)
            if (postagem.temAnexos) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.attach_file, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Anexos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...postagem.anexos!
                          .map((anexo) => _buildAnexoItem(anexo)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnexoItem(String anexo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // TODO: Implementar abertura do anexo
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _getIconeAnexo(anexo),
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getNomeAnexo(anexo),
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.download,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getIconeMateria(String materia) {
    IconData icone;
    switch (materia.toLowerCase()) {
      case 'matemática':
        icone = Icons.calculate;
        break;
      case 'português':
        icone = Icons.menu_book;
        break;
      case 'história':
        icone = Icons.history_edu;
        break;
      case 'geografia':
        icone = Icons.public;
        break;
      case 'ciência':
        icone = Icons.science;
        break;
      default:
        icone = Icons.school;
    }

    return Icon(
      icone,
      color: Colors.blue,
      size: 24,
    );
  }

  IconData _getIconeAnexo(String anexo) {
    final extensao = anexo.split('.').last.toLowerCase();

    switch (extensao) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
        return Icons.audio_file;
      default:
        return Icons.attachment;
    }
  }

  String _getNomeAnexo(String anexo) {
    // Extrai o nome do arquivo da URL
    final uri = Uri.parse(anexo);
    final segments = uri.pathSegments;
    if (segments.isNotEmpty) {
      return segments.last;
    }
    return 'Anexo';
  }
}
