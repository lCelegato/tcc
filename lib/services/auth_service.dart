/// Serviço responsável por operações de autenticação com o Firebase.
/// Separe autenticação de outros domínios para manter o código limpo.
///
/// Funcionalidades:
/// 1. Autenticação:
///    - Login com email/senha
///      Exemplo: await authService.signInWithEmailAndPassword('email@exemplo.com', 'senha123')
///    - Registro de novos usuários
///      Exemplo: await authService.createUserWithEmailAndPassword('email@exemplo.com', 'senha123')
///    - Logout
///      Exemplo: await authService.signOut()
///    - Verificação de estado de autenticação
///      Exemplo: authService.authStateChanges.listen((user) => ...)
///
/// 2. Gerenciamento de Estado:
///    - Stream de mudanças no estado de autenticação
///      * Notifica quando usuário faz login/logout
///      * Útil para atualizar UI automaticamente
///    - Acesso ao usuário atual
///      * Retorna null se não houver usuário logado
///      * Contém informações como UID, email, etc.
///
/// 3. Tratamento de Erros:
///    - Erros de credenciais inválidas
///      * user-not-found: Email não cadastrado
///      * wrong-password: Senha incorreta
///      * invalid-email: Formato de email inválido
///    - Erros de email em uso
///      * email-already-in-use: Email já cadastrado
///    - Erros de senha fraca
///      * weak-password: Senha muito simples
///    - Erros de rede
///      * network-request-failed: Problema de conexão
///
/// Dependências:
/// - Firebase Auth: Para operações de autenticação
///   * Configurado no firebase_options.dart
///   * Inicializado no main.dart
///
/// Observações:
/// - Todas as operações são assíncronas (async/await)
/// - Erros são propagados para tratamento no controller
/// - Estado de autenticação é observável via stream
/// - Mensagens de erro são em português
/// - Não armazena dados sensíveis localmente
///
/// Exemplo de Uso:
/// ```dart
/// final authService = AuthService();
///
/// // Login
/// try {
///   await authService.signInWithEmailAndPassword(email, password);
/// } catch (e) {
///   print('Erro no login: $e');
/// }
///
/// // Verificar usuário atual
/// final user = authService.currentUser;
/// if (user != null) {
///   print('Usuário logado: ${user.email}');
/// }
///
/// // Observar mudanças
/// authService.authStateChanges.listen((user) {
///   if (user != null) {
///     print('Usuário fez login');
///   } else {
///     print('Usuário fez logout');
///   }
/// });
/// ```
library;

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Stream de mudanças no estado de autenticação.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Retorna o usuário atual logado, ou null se não houver.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Realiza login com email e senha.
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  /// Cria um novo usuário com email e senha.
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  /// Realiza logout do usuário atual.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
