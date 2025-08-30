/// Widget para gerenciamento de imagens em postagens usando Base64
///
/// Permite:
/// - Visualizar imagens existentes (Base64)
/// - Adicionar novas imagens (convertidas para Base64)
/// - Remover imagens
/// - Preview de imagens
library;

import 'package:flutter/material.dart';
import '../services/image_service.dart';

class ImageManagerWidget extends StatefulWidget {
  final List<String> imagensExistentes; // Agora são strings Base64
  final Function(List<String>) onImagensChanged;
  final bool isEditing;

  const ImageManagerWidget({
    super.key,
    required this.imagensExistentes,
    required this.onImagensChanged,
    required this.isEditing,
  });

  @override
  State<ImageManagerWidget> createState() => _ImageManagerWidgetState();
}

class _ImageManagerWidgetState extends State<ImageManagerWidget> {
  final ImageService _imageService = ImageService();
  List<String> _imagens = []; // Lista de strings Base64
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _imagens = List.from(widget.imagensExistentes);
  }

  @override
  void didUpdateWidget(ImageManagerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagensExistentes != widget.imagensExistentes) {
      setState(() {
        _imagens = List.from(widget.imagensExistentes);
      });
    }
  }

  Future<void> _adicionarImagens() async {
    if (!widget.isEditing || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final List<String> novasImagensBase64 =
          await _imageService.selecionarMultiplasImagens();

      if (novasImagensBase64.isNotEmpty) {
        setState(() {
          _imagens.addAll(novasImagensBase64);
        });

        widget.onImagensChanged(_imagens);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('${novasImagensBase64.length} imagem(ns) adicionada(s)'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar imagens: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _removerImagem(int index) {
    if (!widget.isEditing) return;

    setState(() {
      _imagens = _imageService.removerImagem(_imagens, index);
    });

    widget.onImagensChanged(_imagens);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Imagem removida'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _visualizarImagem(String imagemBase64, int index) {
    final bytes = _imageService.base64ParaBytes(imagemBase64);
    if (bytes == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.memory(
                  bytes,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            if (widget.isEditing)
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _removerImagem(index);
                  },
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagemTile(String imagemBase64, int index) {
    final bytes = _imageService.base64ParaBytes(imagemBase64);

    if (bytes == null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[300],
        ),
        child: const Center(
          child: Icon(Icons.error, color: Colors.red),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _visualizarImagem(imagemBase64, index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                bytes,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            if (widget.isEditing)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removerImagem(index),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotaoAdicionar() {
    if (!widget.isEditing) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _isProcessing ? null : _adicionarImagens,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey[400]!,
            width: 2,
            style: BorderStyle.solid,
          ),
          color: _isProcessing ? Colors.grey[200] : Colors.grey[100],
        ),
        child: Center(
          child: _isProcessing
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 32,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Adicionar\nImagens',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_imagens.isEmpty && !widget.isEditing) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_imagens.isNotEmpty || widget.isEditing) ...[
          Row(
            children: [
              const Icon(Icons.image, size: 20),
              const SizedBox(width: 8),
              Text(
                'Imagens (${_imagens.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (_imagens.isNotEmpty || widget.isEditing)
          SizedBox(
            height: 120,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: _imagens.length + (widget.isEditing ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _imagens.length) {
                  return _buildImagemTile(_imagens[index], index);
                } else {
                  return _buildBotaoAdicionar();
                }
              },
            ),
          ),
      ],
    );
  }
}
