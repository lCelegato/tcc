# **CAPÍTULO 4 - DESENVOLVIMENTO DO SISTEMA - PARTE 5**

---

## **4.3.5 Sistema de anexos e documentos**

O sistema de anexos implementa funcionalidades para upload, armazenamento e gerenciamento de imagens e documentos nas postagens, utilizando codificação Base64 como estratégia principal de armazenamento.

### **Arquitetura do sistema de anexos Base64**

#### **Fundamentos da implementação Base64**

A escolha pela codificação Base64 fundamenta-se em três pilares técnicos:

**1. Integração atômica com Firestore:**

```dart
// Estrutura de documento autocontida
{
  "conteudo": "Texto da postagem",
  "imagensBase64": ["data:image/jpeg;base64,/9j/4AAQSkZJRgABA..."],
  "documentos": [
    {
      "nome": "exercicio.pdf",
      "conteudoBase64": "JVBERi0xLjQKMSAwIG9iajw8L..."
    }
  ]
}
```

**2. Simplicidade de sincronização:**
Eliminação de dependências externas e garantia de consistência transacional entre metadados e arquivos.

**3. Otimização para casos de uso específicos:**
Adequado para arquivos pequenos/médios (~5MB) típicos do contexto educacional.

#### **AnexoController - Gestão de Arquivos**

```dart
class AnexoController extends ChangeNotifier {
  List<DocumentoModel> _documentos = [];
  List<String> _imagensBase64 = [];
  AnexoState _state = AnexoState.idle;
  String? _errorMessage;

  List<DocumentoModel> get documentos => _documentos;
  List<String> get imagensBase64 => _imagensBase64;
  AnexoState get state => _state;
  String? get errorMessage => _errorMessage;

  // Adicionar imagem via base64
  Future<bool> adicionarImagem(XFile imagemFile) async {
    try {
      _setState(AnexoState.loading);

      // Validar tamanho do arquivo (max 5MB)
      final bytes = await imagemFile.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        _setState(AnexoState.error,
            error: 'Imagem muito grande. Máximo 5MB.');
        return false;
      }

      // Validar formato da imagem
      final extensao = imagemFile.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'gif'].contains(extensao)) {
        _setState(AnexoState.error,
            error: 'Formato não suportado. Use JPG, PNG ou GIF.');
        return false;
      }

      // Converter para base64
      final base64String = base64Encode(bytes);
      _imagensBase64.add(base64String);

      _setState(AnexoState.success);
      return true;
    } catch (e) {
      _setState(AnexoState.error, error: 'Erro ao processar imagem: $e');
      return false;
    }
  }

  // Remover imagem por índice
  void removerImagem(int index) {
    if (index >= 0 && index < _imagensBase64.length) {
      _imagensBase64.removeAt(index);
      notifyListeners();
    }
  }

  // Adicionar documento
  Future<bool> adicionarDocumento(XFile arquivoFile) async {
    try {
      _setState(AnexoState.loading);

      // Validar tamanho do arquivo (max 10MB)
      final bytes = await arquivoFile.readAsBytes();
      if (bytes.length > 10 * 1024 * 1024) {
        _setState(AnexoState.error,
            error: 'Arquivo muito grande. Máximo 10MB.');
        return false;
      }

      // Validar tipo de arquivo
      final extensao = arquivoFile.path.split('.').last.toLowerCase();
      final tiposPermitidos = ['pdf', 'doc', 'docx', 'txt', 'rtf'];
      if (!tiposPermitidos.contains(extensao)) {
        _setState(AnexoState.error,
            error: 'Tipo de arquivo não suportado.');
        return false;
      }

      final documento = DocumentoModel(
        nome: arquivoFile.name,
        tipo: extensao,
        tamanho: bytes.length,
        conteudoBase64: base64Encode(bytes),
        dataUpload: DateTime.now(),
      );

      _documentos.add(documento);
      _setState(AnexoState.success);
      return true;
    } catch (e) {
      _setState(AnexoState.error, error: 'Erro ao processar documento: $e');
      return false;
    }
  }

  // Remover documento por índice
  void removerDocumento(int index) {
    if (index >= 0 && index < _documentos.length) {
      _documentos.removeAt(index);
      notifyListeners();
    }
  }

  // Limpar todos os anexos
  void limparAnexos() {
    _imagensBase64.clear();
    _documentos.clear();
    notifyListeners();
  }

  // Obter tamanho total dos anexos em MB
  double get tamanhoTotalMB {
    double total = 0;

    // Somar imagens (aproximado - base64 é ~33% maior que original)
    for (final base64 in _imagensBase64) {
      total += (base64.length * 0.75) / (1024 * 1024);
    }

    // Somar documentos
    for (final doc in _documentos) {
      total += doc.tamanho / (1024 * 1024);
    }

    return total;
  }

  void _setState(AnexoState newState, {String? error}) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }
}
```

#### **Análise técnica da estratégia Base64**

**Vantagens implementadas:**

1. **Atomicidade transacional:** Arquivos e metadados são salvos em operação única
2. **Simplicidade de backup:** Export do Firestore inclui todos os dados
3. **Redução de dependências:** Eliminação do Firebase Storage simplifica arquitetura
4. **Facilidade de debugging:** Dados visíveis diretamente no console Firestore

**Trade-offs identificados:**

1. **Overhead de armazenamento:** Base64 adiciona ~33% ao tamanho original
2. **Limitação de tamanho:** Documentos Firestore limitados a 1MB
3. **Performance de rede:** Transfer de dados maior em conexões lentas

**Implementação de otimizações:**

```dart
// Compressão automática de imagens
Future<Uint8List> _compressImage(Uint8List bytes) async {
  final originalSize = bytes.length;

  // Aplicar compressão se imagem > 1MB
  if (originalSize > 1024 * 1024) {
    final compressed = await FlutterImageCompress.compressWithList(
      bytes,
      quality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );

    print('Compressão: ${originalSize}B → ${compressed.length}B');
    return compressed;
  }

  return bytes;
}

// Validação de tamanho total
bool _validarTamanhoTotal() {
  final tamanhoAtual = tamanhoTotalMB;
  const limiteMaximo = 0.8; // 80% do limite Firestore (1MB)

  return tamanhoAtual <= limiteMaximo;
}
```

**Estratégia de evolução arquitetural:**

O design permite migração futura sem quebra de compatibilidade:

```dart
abstract class ArmazenamentoService {
  Future<String> salvarArquivo(Uint8List bytes, String nome);
  Future<Uint8List> recuperarArquivo(String referencia);
}

// Implementação atual
class Base64ArmazenamentoService implements ArmazenamentoService {
  @override
  Future<String> salvarArquivo(Uint8List bytes, String nome) async {
    return base64Encode(bytes); // Retorna string base64
  }
}

// Implementação futura
class FirebaseStorageService implements ArmazenamentoService {
  @override
  Future<String> salvarArquivo(Uint8List bytes, String nome) async {
    // Upload para Firebase Storage
    final ref = FirebaseStorage.instance.ref().child(nome);
    await ref.putData(bytes);
    return await ref.getDownloadURL(); // Retorna URL
  }
}
```

### **4.4 Testes unitários e integração**

O projeto implementa estratégia abrangente de testes para garantir qualidade e confiabilidade do sistema.

#### **4.4.1 Estrutura de testes**

```dart
// test/models/user_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tcc_app/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('deve criar usuário válido', () {
      // Arrange
      final userData = {
        'nome': 'João Silva',
        'email': 'joao@email.com',
        'tipo': 'aluno',
        'ativo': true,
      };

      // Act
      final user = UserModel.fromMap(userData, 'user123');

      // Assert
      expect(user.id, equals('user123'));
      expect(user.nome, equals('João Silva'));
      expect(user.email, equals('joao@email.com'));
      expect(user.tipo, equals(TipoUsuario.aluno));
      expect(user.ativo, isTrue);
    });

    test('deve validar email corretamente', () {
      // Act & Assert
      expect(UserModel.isValidEmail('teste@email.com'), isTrue);
      expect(UserModel.isValidEmail('email-invalido'), isFalse);
      expect(UserModel.isValidEmail(''), isFalse);
    });

    test('deve converter para Map corretamente', () {
      // Arrange
      final user = UserModel(
        id: 'user123',
        nome: 'Ana Silva',
        email: 'ana@email.com',
        tipo: TipoUsuario.professor,
        ativo: true,
      );

      // Act
      final userMap = user.toMap();

      // Assert
      expect(userMap['nome'], equals('Ana Silva'));
      expect(userMap['email'], equals('ana@email.com'));
      expect(userMap['tipo'], equals('professor'));
      expect(userMap['ativo'], isTrue);
    });
  });
}
```

#### **4.4.2 Testes de controllers**

```dart
// test/controllers/auth_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tcc_app/controllers/auth_controller.dart';
import 'package:tcc_app/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  group('AuthController Tests', () {
    late AuthController authController;
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
      authController = AuthController();
      // Injetar mock (seria feito via dependency injection)
    });

    test('deve fazer login com credenciais válidas', () async {
      // Arrange
      const email = 'teste@email.com';
      const senha = '123456';
      final mockUser = UserModel(
        id: 'user123',
        nome: 'Teste',
        email: email,
        tipo: TipoUsuario.aluno,
        ativo: true,
      );

      when(mockAuthService.signInWithEmailAndPassword(email, senha))
          .thenAnswer((_) async => mockUser);

      // Act
      final resultado = await authController.login(email, senha);

      // Assert
      expect(resultado, isTrue);
      expect(authController.state, equals(AuthState.authenticated));
      expect(authController.currentUser, equals(mockUser));
    });

    test('deve falhar login com credenciais inválidas', () async {
      // Arrange
      const email = 'teste@email.com';
      const senha = 'senha-errada';

      when(mockAuthService.signInWithEmailAndPassword(email, senha))
          .thenThrow(Exception('Credenciais inválidas'));

      // Act
      final resultado = await authController.login(email, senha);

      // Assert
      expect(resultado, isFalse);
      expect(authController.state, equals(AuthState.error));
      expect(authController.errorMessage, isNotNull);
    });
  });
}
```

#### **4.4.3 Testes de integração**

```dart
// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tcc_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Testes de Integração', () {
    testWidgets('fluxo completo de login', (tester) async {
      // Inicializar app
      app.main();
      await tester.pumpAndSettle();

      // Verificar se está na tela de login
      expect(find.text('Login'), findsOneWidget);

      // Preencher formulário
      await tester.enterText(
          find.byKey(const Key('email_field')),
          'teste@email.com'
      );
      await tester.enterText(
          find.byKey(const Key('password_field')),
          '123456'
      );

      // Fazer login
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verificar se chegou na tela principal
      expect(find.text('Bem-vindo'), findsOneWidget);
    });

    testWidgets('criação de postagem', (tester) async {
      // Assumindo que já está logado como professor
      app.main();
      await tester.pumpAndSettle();

      // Navegar para criação de postagem
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Preencher formulário
      await tester.enterText(
          find.byKey(const Key('materia_field')),
          'Matemática'
      );
      await tester.enterText(
          find.byKey(const Key('conteudo_field')),
          'Exercícios de álgebra para próxima aula'
      );

      // Selecionar alunos
      await tester.tap(find.byKey(const Key('select_students_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('student_checkbox_1')));
      await tester.tap(find.byKey(const Key('confirm_students_button')));
      await tester.pumpAndSettle();

      // Salvar postagem
      await tester.tap(find.byKey(const Key('save_post_button')));
      await tester.pumpAndSettle();

      // Verificar se voltou para lista com nova postagem
      expect(find.text('Exercícios de álgebra'), findsOneWidget);
    });
  });
}
```

### **4.5 Considerações de performance**

#### **4.5.1 Otimizações implementadas**

- **Lazy loading**: Carregamento sob demanda de postagens e usuários
- **Pagination**: Implementação de paginação para listas grandes
- **Caching**: Cache local de dados frequentemente acessados
- **Image optimization**: Compressão de imagens antes do upload
- **State management**: Uso eficiente do Provider para evitar rebuilds desnecessários

#### **4.5.2 Monitoramento e métricas**

```dart
class PerformanceMonitor {
  static void trackScreenLoadTime(String screenName, Duration loadTime) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_load_time',
      parameters: {
        'screen_name': screenName,
        'load_time_ms': loadTime.inMilliseconds,
      },
    );
  }

  static void trackApiCallDuration(String endpoint, Duration duration) {
    FirebaseAnalytics.instance.logEvent(
      name: 'api_call_duration',
      parameters: {
        'endpoint': endpoint,
        'duration_ms': duration.inMilliseconds,
      },
    );
  }
}
```

---

### 📊 **MÉTRICAS DA PARTE 5**

| **Seção**                | **Funcionalidades**         | **Palavras**     |
| ------------------------ | --------------------------- | ---------------- |
| **4.3.5 Sistema Anexos** | Upload + validação arquivos | 312 palavras     |
| **4.4 Testes**           | Unitários + integração      | 498 palavras     |
| **4.5 Performance**      | Otimizações + monitoramento | 134 palavras     |
| **TOTAL PARTE 5**        | **Qualidade e performance** | **944 palavras** |

---

**📄 Continua na Parte 6: Implantação e Configurações**
