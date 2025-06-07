/// Serviço responsável por operações de autenticação com o Firebase.
///
/// Dependências:
/// - Firebase Auth: Para operações de autenticação
///   * Configurado no firebase_options.dart
///   * Inicializado no main.dart
///
///
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
