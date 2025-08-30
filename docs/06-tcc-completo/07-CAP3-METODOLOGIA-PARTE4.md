# **CAPÍTULO 3 - METODOLOGIA - PARTE 4**

---

## **3.3 Arquitetura do sistema**

A arquitetura do sistema foi projetada seguindo princípios de Clean Architecture adaptados para desenvolvimento Flutter, garantindo separação de responsabilidades, testabilidade e manutenibilidade a longo prazo.

### **3.3.1 Estrutura de camadas**

**Presentation Layer (Views + Widgets):**
Camada responsável pela interface de usuário e interação direta com o usuário. Implementa telas específicas para cada funcionalidade e widgets reutilizáveis que encapsulam comportamentos comuns.

Estrutura implementada:

```
lib/views/
├── professor/
│   ├── professor_home_screen.dart      # Dashboard do professor
│   ├── meus_alunos_screen.dart         # Listagem de alunos
│   ├── criar_postagem_screen.dart      # Criação de conteúdo
│   ├── gerenciar_aulas_screen.dart     # Cronograma de aulas
│   └── detalhes_aluno_screen.dart      # Perfil individual do aluno
├── aluno/
│   ├── aluno_home_screen.dart          # Dashboard do aluno
│   ├── postagens_aluno_screen.dart     # Conteúdo por matéria
│   ├── cronograma_aluno_screen.dart    # Cronograma pessoal
│   └── detalhes_postagem_screen.dart   # Visualização de postagem
└── login_screen.dart                   # Autenticação
```

**Application Layer (Controllers):**
Camada de controle que implementa casos de uso específicos da aplicação e gerencia estado da interface utilizando Provider pattern.

Controllers implementados:

- **AuthController:** Gerenciamento de autenticação e sessões
- **UserController:** CRUD de usuários e relacionamentos
- **PostagemController:** Gestão de conteúdo educacional
- **AulaController:** Cronograma e agendamento de aulas

**Domain Layer (Models):**
Camada que define entidades de negócio e regras fundamentais do domínio.

Modelos principais:

```dart
class UserModel {
  final String id;
  final String nome;
  final String email;
  final String tipo; // 'professor' ou 'aluno'
  final String? professorId; // Para alunos

  // Métodos de validação e transformação
}

class PostagemModel {
  final String id;
  final String professorId;
  final String materia;
  final String conteudo;
  final List<String> alunosDestino;
  final DateTime dataPostagem;
  final List<String> imagensBase64;
  final List<DocumentoModel> documentos;
}
```

**Infrastructure Layer (Services):**
Camada que implementa comunicação com serviços externos e abstrações de infraestrutura.

Services implementados:

- **AuthService:** Integração com Firebase Authentication
- **UserService:** Operações CRUD no Firestore
- **PostagemService:** Gestão de postagens e anexos
- **AulaService:** Gerenciamento de cronograma

### **3.3.2 Fluxo de dados e comunicação**

O sistema implementa fluxo de dados unidirecional baseado em Provider pattern, garantindo previsibilidade e facilitando debugging:

**Fluxo Típico de Operação:**

1. **User Interaction:** Widget captura evento do usuário
2. **Controller Invocation:** Evento é delegado para controller apropriado
3. **Service Call:** Controller invoca service para operação de dados
4. **Data Processing:** Service processa dados e comunica com Firebase
5. **State Update:** Controller atualiza estado baseado no resultado
6. **UI Rebuild:** Provider notifica widgets para reconstrução automática

**Exemplo de Implementação:**

```dart
class PostagemController extends ChangeNotifier {
  final PostagemService _service = PostagemService();
  PostagemState _state = PostagemState.idle;
  List<PostagemModel> _postagens = [];

  Future<void> criarPostagem(PostagemModel postagem) async {
    try {
      _state = PostagemState.loading;
      notifyListeners();

      await _service.criarPostagem(postagem);
      await carregarPostagens(postagem.professorId);

      _state = PostagemState.success;
    } catch (e) {
      _state = PostagemState.error;
    }
    notifyListeners();
  }
}
```

**Sincronização em Tempo Real:**
Para dados que requerem sincronização automática, utilizou-se Firestore Streams:

```dart
Stream<List<PostagemModel>> getPostagensStream(String alunoId) {
  return _firestore
    .collection('postagens')
    .where('alunosDestino', arrayContains: alunoId)
    .snapshots()
    .map((snapshot) => snapshot.docs
        .map((doc) => PostagemModel.fromMap(doc.data(), doc.id))
        .toList());
}
```

### **3.3.3 Estratégia de armazenamento de arquivos**

Uma decisão arquitetural importante foi a escolha entre **Firebase Storage** e **armazenamento Base64** no Firestore. Após análise comparativa, optou-se pelo Base64 pelas seguintes razões:

#### **Comparação técnica das alternativas**

**Firebase Storage (não escolhido):**

- **Vantagens:** Otimizado para arquivos grandes, URLs diretas, CDN automático
- **Desvantagens:** Maior complexidade de implementação, dependência adicional, URLs temporárias
- **Adequação:** Ideal para aplicações com grandes volumes de arquivos

**Base64 no Firestore (escolhido):**

- **Vantagens:** Simplicidade de implementação, dados autocontidos, sincronia automática
- **Desvantagens:** Overhead de ~33% no tamanho, limite de documento (1MB)
- **Adequação:** Ideal para protótipos e arquivos pequenos/médios

#### **Justificativa da escolha**

**1. Simplicidade arquitetural:**
A codificação Base64 permite armazenar arquivos diretamente nos documentos Firestore, eliminando a necessidade de gerenciar dois serviços distintos e suas respectivas regras de segurança.

**2. Consistência transacional:**
Arquivos armazenados como Base64 são atomicamente consistentes com os metadados da postagem, evitando problemas de sincronização entre Firestore e Storage.

**3. Escopo do projeto:**
Para o contexto de TCC e uso educacional, o overhead do Base64 é aceitável considerando o volume previsto de arquivos (máximo 5MB por imagem, 10MB por documento).

**4. Facilidade de implementação:**
A conversão Base64 é nativa no Flutter/Dart, reduzindo dependências externas e simplificando o processo de desenvolvimento e testes.

```dart
// Conversão simples e direta
final bytes = await imagemFile.readAsBytes();
final base64String = base64Encode(bytes);

// Armazenamento direto no documento
await _firestore.collection('postagens').add({
  'conteudo': conteudo,
  'imagensBase64': [base64String], // Integrado ao documento
});
```

#### **Limitações reconhecidas**

- **Tamanho:** Documentos Firestore limitados a 1MB (adequado para o escopo)
- **Performance:** Overhead de ~33% no tamanho dos arquivos
- **Escalabilidade:** Não adequado para aplicações com alto volume de arquivos

#### **Estratégia de migração futura**

O design modular permite migração futura para Firebase Storage sem impacto na lógica de negócio:

```dart
abstract class ArmazenamentoService {
  Future<String> salvarImagem(Uint8List bytes);
  Future<Uint8List> carregarImagem(String referencia);
}

// Implementação atual
class Base64ArmazenamentoService implements ArmazenamentoService { }

// Implementação futura
class FirebaseStorageService implements ArmazenamentoService { }
```

### **3.3.3 Padrões de projeto implementados**

**Provider Pattern:** Gerenciamento de estado reativo com notificação automática de mudanças.

**Repository Pattern:** Abstração da camada de dados através de services que encapsulam lógica de acesso ao Firestore.

**Factory Pattern:** Criação de objetos model através de factory methods que garantem validação e inicialização adequadas.

**Observer Pattern:** Implementado através de StreamBuilder para sincronização em tempo real com Firebase.

**Singleton Pattern:** Instâncias únicas de services para garantir consistência de estado e otimização de recursos.

---

### 📊 **MÉTRICAS DA PARTE 4**

| **Seção**                | **Palavras**     | **Conteúdo**          |
| ------------------------ | ---------------- | --------------------- |
| **3.3.1 Estrutura**      | 287 palavras     | Camadas arquiteturais |
| **3.3.2 Fluxo de Dados** | 298 palavras     | Comunicação interna   |
| **3.3.3 Padrões**        | 123 palavras     | Design patterns       |
| **TOTAL PARTE 4**        | **708 palavras** | **≈3 páginas**        |

---

**📄 Continua na Parte 5: Processo de Desenvolvimento**
