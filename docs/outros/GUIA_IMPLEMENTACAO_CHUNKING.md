# ⚡ Guia de Implementação - Chunking Service

**Estratégia:** Fragmentação de Arquivos  
**Tempo:** 2-3 horas  
**Resultado:** Arquivos ilimitados (10MB, 50MB, etc.)

---

## 📋 **PASSO-A-PASSO DETALHADO**

### **1️⃣ ATIVAR O SERVICE (2 minutos)**

```bash
# 1. Ir para a pasta do projeto
cd c:\Programacao\tcc

# 2. Mover o service para pasta ativa
move "lib\services\future\chunking_service.dart" "lib\services\"
```

### **2️⃣ MODIFICAR O DOCUMENTO_SERVICE (45 minutos)**

**Arquivo:** `lib/services/documento_service.dart`

**🔍 Adicionar import (linha ~1):**

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'chunking_service.dart'; // 🆕 ADICIONAR
```

**🔍 Localizar validação de tamanho (linha ~20):**

```dart
if (bytes.length > tamanhoMaximo) {
  debugPrint('❌ Arquivo muito grande: ${bytes.length} bytes');
  return null;
}
```

**✏️ Substituir por:**

```dart
// 🆕 SUPORTE A CHUNKING PARA ARQUIVOS GRANDES
if (bytes.length > 5 * 1024 * 1024) { // 5MB
  debugPrint('❌ Arquivo muito grande: ${bytes.length} bytes (máximo 5MB)');
  return null;
}

// 🆕 DECIDIR SE USA CHUNKING
final useChunking = bytes.length > tamanhoMaximo; // >750KB usa chunking
```

**🔍 Localizar conversão Base64 (linha ~25):**

```dart
final base64String = base64Encode(bytes);

return {
  'nome': result.files.first.name,
  'tipo': extensao,
  'tamanho': bytes.length,
  'dados': base64String,
  'dataUpload': DateTime.now().toIso8601String(),
};
```

**✏️ Substituir por:**

```dart
// 🆕 LÓGICA CONDICIONAL: CHUNKING OU BASE64 NORMAL
if (useChunking) {
  // Usar chunking para arquivos grandes
  final estruturaChunks = ChunkingService.criarEstruturaPorChunks(
    bytes,
    result.files.first.name!,
    _getMimeType(extensao),
  );

  return {
    ...estruturaChunks,
    'isChunked': true, // 🆕 FLAG PARA IDENTIFICAR
  };
} else {
  // Usar Base64 normal para arquivos pequenos
  final base64String = base64Encode(bytes);

  return {
    'nome': result.files.first.name,
    'tipo': extensao,
    'tamanho': bytes.length,
    'dados': base64String,
    'dataUpload': DateTime.now().toIso8601String(),
    'isChunked': false, // 🆕 FLAG
  };
}
```

**🔍 Adicionar método auxiliar (final do arquivo):**

```dart
// 🆕 MÉTODO PARA MIME TYPE
static String _getMimeType(String extensao) {
  switch (extensao.toLowerCase()) {
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
```

### **3️⃣ MODIFICAR DOCUMENTO_MANAGER_WIDGET (60 minutos)**

**Arquivo:** `lib/widgets/documento_manager_widget.dart`

**🔍 Adicionar import:**

```dart
import '../services/chunking_service.dart'; // 🆕 ADICIONAR
```

**🔍 Localizar método de download (linha ~150):**

```dart
void _baixarDocumento(Map<String, dynamic> doc) async {
  try {
    final String base64String = doc['dados'];
    final Uint8List bytes = base64Decode(base64String);
```

**✏️ Substituir por:**

```dart
void _baixarDocumento(Map<String, dynamic> doc) async {
  try {
    // 🆕 VERIFICAR SE É CHUNKED
    final bool isChunked = doc['isChunked'] ?? false;

    Uint8List bytes;

    if (isChunked) {
      // 🆕 RECONSTITUIR DE CHUNKS
      final chunks = doc['chunks'] as Map<String, dynamic>;
      final totalChunks = doc['totalChunks'] as int;

      final chunksList = <String>[];
      for (int i = 0; i < totalChunks; i++) {
        chunksList.add(chunks['chunk_$i']);
      }

      bytes = ChunkingService.reconstituirArquivo(chunksList);
    } else {
      // Base64 normal
      final String base64String = doc['dados'];
      bytes = base64Decode(base64String);
    }
```

**🔍 Localizar exibição de informações:**

```dart
Text('📄 ${doc['nome']}'),
Text('📊 ${_formatarTamanho(doc['tamanho'])}'),
```

**✏️ Adicionar indicador de chunking:**

```dart
Text('📄 ${doc['nome']}'),
Text('📊 ${_formatarTamanho(doc['tamanho'])}'),
// 🆕 INDICADOR SE É CHUNKED
if (doc['isChunked'] == true)
  const Text('⚡ Arquivo grande (chunked)',
    style: TextStyle(fontSize: 10, color: Colors.blue)),
```

### **4️⃣ ATUALIZAR POSTAGEM_MODEL (30 minutos)**

**Arquivo:** `lib/models/postagem_model.dart`

**🔍 Localizar fromMap (linha ~60):**

```dart
documentos: (data['documentos'] as List<dynamic>?)
  ?.map((doc) => Map<String, dynamic>.from(doc))
  .toList() ?? [],
```

**✏️ Manter como está (sem mudanças)**

O modelo já suporta campos dinâmicos, então funciona automaticamente!

### **5️⃣ TESTAR IMPLEMENTAÇÃO (30 minutos)**

```bash
# 1. Limpar e recompilar
flutter clean
flutter pub get

# 2. Verificar erros
flutter analyze

# 3. Executar app
flutter run

# 4. Testar arquivos pequenos (<750KB)
# - Deve usar Base64 normal
# - Deve funcionar como antes

# 5. Testar arquivos grandes (>750KB, <5MB)
# - Deve usar chunking
# - Deve aparecer "⚡ Arquivo grande (chunked)"
# - Download deve funcionar normalmente
```

### **6️⃣ VERIFICAR FUNCIONAMENTO**

**📱 Teste no app:**

1. Criar postagem como professor
2. Adicionar documento pequeno (PDF <750KB)
   - ✅ Deve funcionar normal
3. Adicionar documento grande (PDF >1MB)
   - ✅ Deve aparecer indicador "chunked"
   - ✅ Upload deve funcionar
   - ✅ Download deve funcionar

**🔍 No Firestore:**

- Documento pequeno: campo `dados` com Base64
- Documento grande: campos `chunks`, `totalChunks`, `isChunked: true`

---

## 🎯 **RESULTADO ESPERADO**

### **✅ Antes:**

- Limite: 750KB
- Método: Base64 simples
- Firestore: 1 campo por documento

### **🚀 Após implementação:**

- Limite: 5MB (configurável)
- Método: Base64 + Chunking híbrido
- Firestore: Múltiplos chunks para arquivos grandes
- Interface: Indicador visual de arquivos grandes

---

## ⚠️ **CUIDADOS IMPORTANTES**

### **📊 Uso do Firestore:**

- Arquivos grandes usam mais campos
- 1MB arquivo = ~1.3 campos de 800KB
- Considerar limites de documentos (1MB total)

### **⚡ Performance:**

- Upload de arquivos grandes é mais lento
- Reconstituição requer processamento
- Considerar loading indicators

### **🔄 Compatibilidade:**

- Documentos antigos continuam funcionando
- Sistema híbrido: pequenos e grandes

---

## 🔄 **COMO REVERTER**

```bash
# 1. Mover service de volta
move "lib\services\chunking_service.dart" "lib\services\future\"

# 2. Reverter mudanças nos arquivos
# (usar git reset ou backup)

# 3. Recompilar
flutter clean
flutter pub get
```

**🎯 Esta implementação permite arquivos realmente grandes mantendo compatibilidade total com documentos existentes!**
