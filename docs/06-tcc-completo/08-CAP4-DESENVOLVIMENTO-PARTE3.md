# **CAPÍTULO 4 - DESENVOLVIMENTO DO SISTEMA - PARTE 3**

---

## **4.3 Implementação dos módulos**

A implementação dos módulos seguiu arquitetura em camadas, com cada módulo sendo desenvolvido de forma independente e posteriormente integrado ao sistema principal.

### **4.3.1 Módulo de autenticação**

O módulo de autenticação constitui a base de segurança do sistema, implementando controle de acesso e gerenciamento de sessões através do Firebase Authentication.

#### **AuthController - Gerenciamento de Estado**

```dart
class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  AuthState _state = AuthState.initial;

  User? get user => _user;
  AuthState get state => _state;
  bool get isAuthenticated => _user != null;

  // Login com email e senha
  Future<bool> login(String email, String password) async {
    try {
      _setState(AuthState.loading);

      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        _user = user;
        _setState(AuthState.authenticated);
        return true;
      }

      _setState(AuthState.unauthenticated);
      return false;
    } catch (e) {
      _setState(AuthState.error);
      return false;
    }
  }

  // Registro de novo professor
  Future<bool> register(String email, String password, String nome) async {
    try {
      _setState(AuthState.loading);

      final user = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        // Criar perfil do professor no Firestore
        await _authService.createProfessorProfile(user.uid, {
          'nome': nome,
          'email': email,
          'tipo': 'professor',
          'dataCadastro': FieldValue.serverTimestamp(),
          'ativo': true,
        });

        _user = user;
        _setState(AuthState.authenticated);
        return true;
      }

      return false;
    } catch (e) {
      _setState(AuthState.error);
      return false;
    }
  }

  // Logout seguro
  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    _setState(AuthState.unauthenticated);
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }
}
```

#### **AuthService - Comunicação com Firebase**

```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream para monitorar mudanças de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuário atual
  User? get currentUser => _auth.currentUser;

  // Login com email e senha
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Registro de novo usuário
  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Criar perfil no Firestore
  Future<void> createProfessorProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('professores').doc(uid).set(data);
    } catch (e) {
      throw Exception('Erro ao criar perfil: $e');
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Tratamento de exceções do Firebase Auth
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email não cadastrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'Email já está em uso';
      case 'weak-password':
        return 'Senha muito fraca';
      case 'invalid-email':
        return 'Email inválido';
      default:
        return 'Erro de autenticação: ${e.message}';
    }
  }
}
```

#### **Tela de Login - Interface**

```dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo e título
                const Icon(
                  Icons.school,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Sistema Educacional',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 48),

                // Campo de email
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Email é obrigatório';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de senha
                AppTextField(
                  controller: _passwordController,
                  label: 'Senha',
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Senha é obrigatória';
                    }
                    if (value!.length < 6) {
                      return 'Senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Botão de login
                Consumer<AuthController>(
                  builder: (context, authController, child) {
                    return AppButton(
                      text: 'Entrar',
                      isLoading: authController.state == AuthState.loading,
                      onPressed: () => _handleLogin(authController),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Link para registro
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text('Não tem conta? Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(AuthController authController) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await authController.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/professor-home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao fazer login'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

### **4.3.2 Módulo de gestão de usuários**

O módulo de gestão de usuários implementa operações CRUD para professores e alunos, mantendo relacionamentos e integridade referencial.

#### **UserController - Controle de Estado**

```dart
class UserController extends ChangeNotifier {
  final UserService _userService = UserService();
  UserModel? _user;
  List<UserModel> _alunos = [];
  UserState _state = UserState.idle;

  UserModel? get user => _user;
  List<UserModel> get alunos => _alunos;
  UserState get state => _state;

  // Carregar dados do usuário logado
  Future<void> loadUserData(String uid, String tipo) async {
    try {
      _state = UserState.loading;
      notifyListeners();

      _user = await _userService.getUserById(uid, tipo);

      if (_user?.tipo == 'professor') {
        await carregarAlunosDoProfessor(_user!.id);
      }

      _state = UserState.success;
    } catch (e) {
      _state = UserState.error;
    }
    notifyListeners();
  }

  // Carregar alunos do professor
  Future<void> carregarAlunosDoProfessor(String professorId) async {
    try {
      _alunos = await _userService.getAlunosPorProfessor(professorId);
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar alunos: $e');
    }
  }

  // Cadastrar novo aluno
  Future<bool> cadastrarAluno({
    required String nome,
    required String email,
    required String senha,
    required String professorId,
  }) async {
    try {
      _state = UserState.loading;
      notifyListeners();

      // Verificar se email já existe
      final emailExiste = await _userService.emailJaExiste(email);
      if (emailExiste) {
        throw Exception('Email já está em uso');
      }

      // Criar usuário no Firebase Auth
      final user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Criar perfil no Firestore
      final aluno = UserModel(
        id: user.user!.uid,
        nome: nome,
        email: email,
        tipo: 'aluno',
        professorId: professorId,
      );

      await _userService.createUserProfile(aluno);
      await carregarAlunosDoProfessor(professorId);

      _state = UserState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = UserState.error;
      notifyListeners();
      throw e;
    }
  }

  // Stream para alunos em tempo real
  Stream<List<UserModel>> getAlunosDoProfessor(String professorId) {
    return _userService.getAlunosDoProfessorStream(professorId);
  }
}
```

---

### 📊 **MÉTRICAS DA PARTE 3**

| **Seção**                    | **Linhas de Código**      | **Palavras**     |
| ---------------------------- | ------------------------- | ---------------- |
| **4.3.1 Autenticação**       | ~200 linhas implementadas | 421 palavras     |
| **4.3.2 Gestão de Usuários** | ~150 linhas implementadas | 298 palavras     |
| **TOTAL PARTE 3**            | **~350 linhas de código** | **719 palavras** |

---

**📄 Continua na Parte 4: Módulos de Postagens e Cronograma**
