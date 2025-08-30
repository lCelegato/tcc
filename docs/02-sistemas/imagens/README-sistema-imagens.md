# Sistema de Gerenciamento de Imagens - Base64

## 📖 Visão Geral

Este documento descreve a implementação do sistema de gerenciamento de imagens usando codificação Base64 no Firestore, desenvolvido como alternativa ao Firebase Storage.

## 🔧 Arquitetura Técnica

### **Componentes Principais**

#### 1. ImageService (`lib/services/image_service.dart`)

Serviço responsável pela manipulação de imagens:

```dart
class ImageService {
  // Seleção de múltiplas imagens da galeria
  Future<List<String>> selecionarMultiplasImagens()

  // Conversão Base64 para bytes (visualização)
  Uint8List? base64ParaBytes(String base64String)

  // Validação de imagem Base64
  bool validarImagemBase64(String? base64String)

  // Remoção de imagem da lista
  List<String> removerImagem(List<String> lista, int index)
}
```

#### 2. ImageManagerWidget (`lib/widgets/image_manager_widget.dart`)

Widget de interface para gerenciamento:

```dart
class ImageManagerWidget extends StatefulWidget {
  final List<String> imagensExistentes;  // Base64 strings
  final Function(List<String>) onImagensChanged;
  final bool isEditing;
}
```

**Funcionalidades:**

- Grid horizontal de visualização
- Botão para adicionar imagens
- Preview com zoom e remoção
- Indicadores de progresso

#### 3. Integração nas Telas

**Professor (Criar/Editar Postagem):**

```dart
ImageManagerWidget(
  imagensExistentes: _imagensSelecionadas,
  onImagensChanged: (novasImagens) {
    setState(() {
      _imagensSelecionadas = novasImagens;
    });
  },
  isEditing: true,
)
```

**Aluno (Visualização):**

```dart
// Grid de imagens
GridView.builder(
  itemBuilder: (context, index) {
    final imagemBase64 = postagem.imagens![index];
    final bytes = imageService.base64ParaBytes(imagemBase64);
    return Image.memory(bytes);
  },
)
```

## ⚙️ Configurações e Limitações

### **Parâmetros de Compressão**

```dart
final XFile? image = await _picker.pickImage(
  source: source,
  maxWidth: 800,      // Largura máxima
  maxHeight: 600,     // Altura máxima
  imageQuality: 70,   // Qualidade (70%)
);
```

### **Validações Implementadas**

- **Tamanho máximo:** 800KB por imagem
- **Formato:** Automático via ImagePicker
- **Validação Base64:** Verificação de integridade

### **Limites do Sistema**

1. **Firestore Document:** Máximo 1MB total por documento
2. **Imagens por postagem:** Recomendado máximo 5-10 imagens
3. **Performance:** Carregamento via Firestore (não CDN)

## 🔄 Fluxo de Dados

### **Upload (Professor)**

```
1. Usuário seleciona imagens
   ↓
2. ImagePicker captura arquivos
   ↓
3. Compressão automática (800x600, 70%)
   ↓
4. Conversão para Base64
   ↓
5. Armazenamento no array imagens[] do Firestore
```

### **Visualização (Aluno)**

```
1. Firestore retorna documento com imagens[]
   ↓
2. Array de strings Base64
   ↓
3. Conversão Base64 → Uint8List
   ↓
4. Renderização via Image.memory()
```

## 📊 Modelo de Dados

### **PostagemModel**

```dart
class PostagemModel {
  final List<String>? imagens;  // Array de strings Base64

  // Getter de conveniência
  bool get temImagens => imagens != null && imagens!.isNotEmpty;

  // Serialização Firestore
  Map<String, dynamic> toMap() {
    return {
      'imagens': imagens,
      // ... outros campos
    };
  }
}
```

### **Estrutura no Firestore**

```json
{
  "titulo": "Título da postagem",
  "conteudo": "Conteúdo...",
  "imagens": [
    "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD...",
    "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD...",
    "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD..."
  ]
}
```

## 🛠 Guia de Implementação

### **1. Adicionar Widget nas Telas**

```dart
// Em criar_postagem_screen.dart ou detalhe_postagem_screen.dart
ImageManagerWidget(
  imagensExistentes: _imagensSelecionadas,
  onImagensChanged: (novasImagens) {
    setState(() {
      _imagensSelecionadas = novasImagens;
    });
  },
  isEditing: true, // false para apenas visualização
)
```

### **2. Salvar no Firestore**

```dart
// Incluir imagens no modelo
final postagem = PostagemModel(
  // ... outros campos
  imagens: _imagensSelecionadas.isNotEmpty ? _imagensSelecionadas : null,
);

// Salvar via PostagemService
await _postagemService.criarPostagem(postagem);
```

### **3. Exibir para Usuários**

```dart
// Verificar se tem imagens
if (postagem.temImagens) {
  // Exibir grid de imagens
  GridView.builder(
    itemCount: postagem.imagens!.length,
    itemBuilder: (context, index) {
      final imagemBase64 = postagem.imagens![index];
      final imageService = ImageService();
      final bytes = imageService.base64ParaBytes(imagemBase64);

      return bytes != null
        ? Image.memory(bytes, fit: BoxFit.cover)
        : Icon(Icons.error);
    },
  );
}
```

## 🐛 Troubleshooting

### **Problemas Comuns**

1. **Imagem não carrega**

   ```dart
   // Verificar se Base64 é válido
   final isValid = imageService.validarImagemBase64(imagemBase64);
   if (!isValid) {
     print('Base64 inválido');
   }
   ```

2. **Documento muito grande**

   ```dart
   // Verificar tamanho total
   final totalSize = imagensList.fold(0, (sum, img) => sum + img.length);
   if (totalSize > 800000) { // ~800KB
     print('Muitas imagens, reduzir quantidade');
   }
   ```

3. **Performance lenta**
   ```dart
   // Usar compressão maior
   imageQuality: 60, // Reduzir de 70 para 60
   maxWidth: 600,    // Reduzir de 800 para 600
   ```

## 📈 Otimizações Futuras

### **Possíveis Melhorias**

1. **Cache local:** Armazenar imagens decodificadas em memória
2. **Lazy loading:** Carregar imagens sob demanda
3. **Thumbnails:** Gerar miniaturas separadas para grid
4. **Compressão adaptativa:** Ajustar qualidade baseado no tamanho

### **Migração para Storage (Se Necessário)**

```dart
// Interface pode ser mantida, apenas trocar backend
abstract class IImageService {
  Future<List<String>> selecionarMultiplasImagens();
  Uint8List? base64ParaBytes(String imageData);
}

class Base64ImageService implements IImageService { /* implementação atual */ }
class StorageImageService implements IImageService { /* implementação futura */ }
```

---

**Última atualização:** 30 de agosto de 2025  
**Versão:** 1.0.0  
**Status:** ✅ Implementado e funcional
