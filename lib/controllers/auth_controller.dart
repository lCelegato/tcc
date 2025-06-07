/// Controlador responsável por gerenciar a autenticação do usuário.
///
/// - Gerenciar o estado de autenticação do usuário
/// - Controlar operações de login, registro e logout
/// - Coordenar a navegação baseada no estado de autenticação
/// - Manter o estado de loading durante operações
///
/// Dependências:
/// - AuthService: Para operações de autenticação
/// - UserService: Para operações de perfil
/// - UserModel: Para estrutura de dados do usuário
/// - AppRoutes: Para navegação
library;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import '../main.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _userType;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get userType => _userType;
  User? get currentUser => _authService.currentUser;

  AuthController() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? firebaseUser) {
      _isAuthenticated = firebaseUser != null;
      if (firebaseUser != null) {
        // Quando o usuário está autenticado, buscar seu tipo
        _loadUserType(firebaseUser.uid);
      } else {
        _userType = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserType(String uid) async {
    try {
      // Tentar buscar como professor primeiro
      final professorData =
          await _userService.getUserData(uid, 'professor').first;
      if (professorData != null) {
        _userType = 'professor';
        return;
      }

      // Se não for professor, tentar como aluno
      final alunoData = await _userService.getUserData(uid, 'aluno').first;
      if (alunoData != null) {
        _userType = 'aluno';
        return;
      }
    } catch (e) {
      // Log do erro ao carregar tipo do usuário
      debugPrint('Erro ao carregar tipo do usuário: $e');
    }
  }

  Future<BuildContext> signIn(
      String email, String password, BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signInWithEmailAndPassword(email, password);

      // Após login bem-sucedido, buscar dados do usuário
      final user = _authService.currentUser;
      if (user != null) {
        await _loadUserType(user.uid);
        if (!context.mounted) return context;
        // Navegar para a tela apropriada baseada no tipo de usuário
        if (_userType == 'professor') {
          Navigator.pushReplacementNamed(context, AppRoutes.professorHome);
        } else if (_userType == 'aluno') {
          Navigator.pushReplacementNamed(context, AppRoutes.alunoHome);
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return context;
  }

  Future<void> signUp(
      String email, String password, String name, String type) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _authService.createUserWithEmailAndPassword(
        email,
        password,
      );

      final user = UserModel(
        id: userCredential.user!.uid,
        nome: name,
        email: email,
        tipo: type,
        dataCriacao: DateTime.now(),
      );

      await _userService.createUserProfile(user);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.signOut();
      _userType = null;
      // Limpar o UserController ao fazer logout
      try {
        final context = navigatorKey.currentContext;
        if (context != null) {
          if (!context.mounted) return;
          final userController =
              Provider.of<UserController>(context, listen: false);
          userController.clearUser();
        }
      } catch (_) {}
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void navigateToRegister(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.registerAluno);
  }

  Future<UserCredential> signUpAlunoComProfessor(
    String email,
    String password,
    String name,
    String professorId,
  ) async {
    // Criar o usuário sem fazer login
    final userCredential = await _authService.createUserWithEmailAndPassword(
      email,
      password,
    );

    final aluno = UserModel(
      id: userCredential.user!.uid,
      nome: name,
      email: email,
      tipo: 'aluno',
      dataCriacao: DateTime.now(),
      professorId: professorId,
    );

    await _userService.createUserProfile(aluno);

    // Fazer logout do aluno recém-criado
    await _authService.signOut();

    return userCredential;
  }
}
