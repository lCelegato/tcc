# Base64: Armazenamento de Documentos (PDF, DOC, etc.)

**Data:** 30 de agosto de 2025  
**Contexto:** Implementação de upload e visualização de documentos usando Base64

## 📄 **DOCUMENTOS SUPORTADOS**

### **Formatos Compatíveis:**

- **PDF** - Documentos, apostilas, exercícios
- **DOC/DOCX** - Documentos Word
- **TXT** - Arquivos de texto simples
- **RTF** - Rich Text Format
- **ODT** - OpenDocument Text

### **Limitações Técnicas:**

- **Firestore:** 1MB por documento (limite do campo)
- **Base64:** Aumenta tamanho em ~33%
- **Arquivo original:** Máximo recomendado 700KB
- **Total por postagem:** Até 10 documentos

---

## 🔧 **IMPLEMENTAÇÃO TÉCNICA**

### **1. Service para Documentos**

```dart
// lib/services/documento_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class DocumentoService {
  // Tipos de arquivo permitidos
  static const List<String> tiposPermitidos = [
    'pdf', 'doc', 'docx', 'txt', 'rtf', 'odt'
  ];

  // Tamanho máximo (700KB para compensar Base64)
  static const int tamanhoMaximo = 700 * 1024; // 700KB

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
          throw Exception('Arquivo ${arquivo.name} muito grande. Máximo: ${(tamanhoMaximo / 1024).round()}KB');
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
      print('Erro ao selecionar documentos: $e');
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
}
```

### **2. Widget para Gerenciar Documentos**

```dart
// lib/widgets/documento_manager_widget.dart
import 'package:flutter/material.dart';
import '../services/documento_service.dart';

class DocumentoManagerWidget extends StatefulWidget {
  final List<Map<String, dynamic>> documentos;
  final Function(List<Map<String, dynamic>>) onDocumentosChanged;
  final bool podeEditar;

  const DocumentoManagerWidget({
    Key? key,
    required this.documentos,
    required this.onDocumentosChanged,
    this.podeEditar = true,
  }) : super(key: key);

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
                subtitle: Text('${info['tamanhoFormatado']} • ${info['extensao'].toUpperCase()}'),
                trailing: widget.podeEditar
                  ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removerDocumento(index),
                    )
                  : IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () => _baixarDocumento(documento),
                    ),
                onTap: () => _visualizarDocumento(documento),
              ),
            );
          }).toList(),
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

      if (novosDocumentos.isNotEmpty) {
        final documentosAtualizados = [...widget.documentos, ...novosDocumentos];
        widget.onDocumentosChanged(documentosAtualizados);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${novosDocumentos.length} documento(s) adicionado(s)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _carregando = false);
    }
  }

  void _removerDocumento(int index) {
    final documentosAtualizados = [...widget.documentos];
    documentosAtualizados.removeAt(index);
    widget.onDocumentosChanged(documentosAtualizados);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Documento removido'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _visualizarDocumento(Map<String, dynamic> documento) {
    // Implementar visualização baseada no tipo
    final extensao = documento['extensao'] as String;

    if (extensao == 'pdf') {
      _visualizarPDF(documento);
    } else if (extensao == 'txt') {
      _visualizarTexto(documento);
    } else {
      _mostrarInfoDocumento(documento);
    }
  }

  void _visualizarPDF(Map<String, dynamic> documento) {
    // Para PDF, precisaria de um plugin como flutter_pdfview
    // Por enquanto, mostrar opção de download
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(documento['nome']),
        content: const Text('Visualização de PDF requer plugin adicional.\nPor enquanto, use a opção de download.'),
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
            Text('Tipo: ${info['extensao'].toUpperCase()}'),
            Text('Tamanho: ${info['tamanhoFormatado']}'),
            Text('Upload: ${DateTime.parse(info['dataUpload']).toString().split('.')[0]}'),
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

  void _baixarDocumento(Map<String, dynamic> documento) {
    // Implementar download do documento
    // Para web: usar html.AnchorElement
    // Para mobile: usar path_provider + File
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de download em desenvolvimento'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
```

### **3. Atualizar Model de Postagem**

```dart
// Adicionar ao PostagemModel
class PostagemModel {
  // ... campos existentes ...
  final List<Map<String, dynamic>>? documentos;

  PostagemModel({
    // ... parâmetros existentes ...
    this.documentos,
  });

  factory PostagemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostagemModel(
      // ... campos existentes ...
      documentos: data['documentos'] != null
        ? List<Map<String, dynamic>>.from(data['documentos'])
        : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      // ... campos existentes ...
      if (documentos != null) 'documentos': documentos,
    };
  }

  bool get temDocumentos => documentos != null && documentos!.isNotEmpty;
  int get totalDocumentos => documentos?.length ?? 0;
}
```

---

## 📱 **INTEGRAÇÃO NAS TELAS**

### **Tela de Criar Postagem (Professor)**

```dart
// Adicionar ao _CriarPostagemScreenState
List<Map<String, dynamic>> _documentos = [];

// No build():
DocumentoManagerWidget(
  documentos: _documentos,
  onDocumentosChanged: (documentos) {
    setState(() => _documentos = documentos);
  },
  podeEditar: true,
),
```

### **Tela de Detalhes (Aluno)**

```dart
// No build():
if (postagem.temDocumentos)
  DocumentoManagerWidget(
    documentos: postagem.documentos!,
    onDocumentosChanged: (_) {}, // Não pode editar
    podeEditar: false,
  ),
```

---

## 📦 **DEPENDÊNCIAS NECESSÁRIAS**

```yaml
# pubspec.yaml
dependencies:
  file_picker: ^6.1.1 # Para selecionar arquivos
  # flutter_pdfview: ^1.3.2  # Opcional: visualizar PDFs
  # path_provider: ^2.1.1  # Para salvar arquivos baixados
```

---

## 🔧 **FUNCIONALIDADES AVANÇADAS**

### **1. Compressão de PDFs**

```dart
// Comprimir PDFs grandes automaticamente
Future<Uint8List> comprimirPDF(Uint8List pdfBytes) async {
  // Usar biblioteca como pdf_compressor
  // Reduzir qualidade de imagens internas
  // Remover metadados desnecessários
}
```

### **2. Visualização Inline de PDFs**

```dart
// Com flutter_pdfview
Widget _construirVisualizadorPDF(String base64) {
  final bytes = base64Decode(base64.split(',').last);

  return Container(
    height: 400,
    child: PDFView(
      pdfData: bytes,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: false,
      pageFling: false,
    ),
  );
}
```

### **3. OCR em Documentos**

```dart
// Extrair texto de PDFs/imagens
Future<String> extrairTextoDocumento(String base64) async {
  final bytes = base64Decode(base64.split(',').last);

  // Usar google_ml_kit para OCR
  // Ou pdf_text para PDFs
  return await _processarOCR(bytes);
}
```

---

## ✅ **VANTAGENS DO BASE64 PARA DOCUMENTOS**

1. **🔒 Segurança Total** - Documentos não ficam em servidor externo
2. **💰 Zero Custo** - Sem taxas de storage adicional
3. **🚀 Performance** - Carregamento instantâneo (já está no Firestore)
4. **📱 Offline** - Funciona sem internet após primeiro carregamento
5. **🔄 Sincronização** - Automática com o resto dos dados
6. **🛡️ Controle Total** - Sem dependência de serviços terceiros

**Base64 suporta QUALQUER arquivo!** PDFs, documentos, planilhas, apresentações - tudo pode ser armazenado dessa forma. 📄✨
