import 'package:flutter/material.dart';
import '../services/documento_service.dart';

class DocumentoManagerWidget extends StatefulWidget {
  final List<Map<String, dynamic>> documentos;
  final Function(List<Map<String, dynamic>>) onDocumentosChanged;
  final bool podeEditar;

  const DocumentoManagerWidget({
    super.key,
    required this.documentos,
    required this.onDocumentosChanged,
    this.podeEditar = true,
  });

  @override
  State<DocumentoManagerWidget> createState() => _DocumentoManagerWidgetState();
}

class _DocumentoManagerWidgetState extends State<DocumentoManagerWidget> {
  final DocumentoService _documentoService = DocumentoService();
  bool _carregando = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header com botão adicionar
        Row(
          children: [
            const Icon(Icons.description, color: Colors.blue),
            const SizedBox(width: 8),
            const Text(
              'Documentos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (widget.podeEditar) ...[
              TextButton.icon(
                onPressed: _carregando ? null : _adicionarDocumentos,
                icon: _carregando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: Text(_carregando ? 'Carregando...' : 'Adicionar'),
              ),
            ],
          ],
        ),

        const SizedBox(height: 12),

        // Lista de documentos
        if (widget.documentos.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Nenhum documento anexado',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...widget.documentos.asMap().entries.map((entry) {
            final index = entry.key;
            final documento = entry.value;
            final info = _documentoService.obterInfoDocumento(documento);

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: _obterIconeDocumento(info['extensao']),
                title: Text(
                  info['nome'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                    '${info['tamanhoFormatado']} • ${info['extensao'].toUpperCase()}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.blue),
                      onPressed: () => _baixarDocumento(documento),
                      tooltip: 'Baixar documento',
                    ),
                    if (widget.podeEditar)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removerDocumento(index),
                        tooltip: 'Remover documento',
                      ),
                  ],
                ),
                onTap: () => _visualizarDocumento(documento),
              ),
            );
          }),
      ],
    );
  }

  Widget _obterIconeDocumento(String extensao) {
    IconData icone;
    Color cor;

    switch (extensao) {
      case 'pdf':
        icone = Icons.picture_as_pdf;
        cor = Colors.red;
        break;
      case 'doc':
      case 'docx':
        icone = Icons.description;
        cor = Colors.blue;
        break;
      case 'txt':
        icone = Icons.text_snippet;
        cor = Colors.grey;
        break;
      default:
        icone = Icons.insert_drive_file;
        cor = Colors.orange;
    }

    return Icon(icone, color: cor, size: 32);
  }

  Future<void> _adicionarDocumentos() async {
    setState(() => _carregando = true);

    try {
      final novosDocumentos = await _documentoService.selecionarDocumentos();

      if (novosDocumentos.isNotEmpty && mounted) {
        final documentosAtualizados = [
          ...widget.documentos,
          ...novosDocumentos
        ];
        widget.onDocumentosChanged(documentosAtualizados);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('${novosDocumentos.length} documento(s) adicionado(s)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  void _removerDocumento(int index) {
    final documentosAtualizados = [...widget.documentos];
    final documentoRemovido = documentosAtualizados.removeAt(index);
    widget.onDocumentosChanged(documentosAtualizados);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${documentoRemovido['nome']} removido'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _baixarDocumento(Map<String, dynamic> documento) async {
    try {
      await _documentoService.baixarDocumento(documento);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${documento['nome']} baixado com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao baixar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _visualizarDocumento(Map<String, dynamic> documento) {
    final extensao = documento['extensao'] as String;

    if (extensao == 'txt') {
      _visualizarTexto(documento);
    } else {
      _mostrarInfoDocumento(documento);
    }
  }

  void _visualizarTexto(Map<String, dynamic> documento) {
    final bytes = _documentoService.base64ParaBytes(documento['base64']);
    final conteudo = String.fromCharCodes(bytes);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    documento['nome'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    conteudo,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarInfoDocumento(Map<String, dynamic> documento) {
    final info = _documentoService.obterInfoDocumento(documento);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informações do Documento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome: ${info['nome']}'),
            const SizedBox(height: 8),
            Text('Tipo: ${info['extensao'].toUpperCase()}'),
            const SizedBox(height: 8),
            Text('Tamanho: ${info['tamanhoFormatado']}'),
            const SizedBox(height: 8),
            Text(
                'Upload: ${DateTime.parse(info['dataUpload']).toString().split('.')[0]}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _baixarDocumento(documento);
            },
            child: const Text('Baixar'),
          ),
        ],
      ),
    );
  }
}
