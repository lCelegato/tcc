/// Controller para cadastro de alunos pelo professor
///
/// Responsabilidades:
/// - Validar dados do aluno
/// - Criar conta do aluno
/// - Gerenciar re-autenticação do professor
/// - Navegação pós-cadastro
library;

import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../utils/validation_utils.dart';
import '../widgets/dialog_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CadastroAlunoController extends ChangeNotifier {
  final UserService _userService = UserService();
  final AuthController _authController = AuthController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Valida os dados de entrada do aluno
  String? validarDadosAluno({
    required String nome,
    required String email,
    required String senha,
  }) {
    final nomeError = ValidationUtils.getNameErrorMessage(nome);
    if (nomeError.isNotEmpty) return nomeError;

    final emailError = ValidationUtils.getEmailErrorMessage(email);
    if (emailError.isNotEmpty) return emailError;

    final senhaError = ValidationUtils.getPasswordErrorMessage(senha);
    if (senhaError.isNotEmpty) return senhaError;

    return null;
  }

  Future<String?> cadastrarAluno({
    required String email,
    required String senha,
    required String nome,
    required String professorId,
    required BuildContext context,
  }) async {
    // Validar dados de entrada
    final validationError = validarDadosAluno(
      nome: nome,
      email: email,
      senha: senha,
    );

    if (validationError != null) {
      _mostrarErro(context, validationError);
      return null;
    }

    try {
      _setLoading(true);

      // Salvar dados do usuário atual (professor)
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Sessão do professor não encontrada.');
      }
      final professorEmail = currentUser.email!;

      // Validar se o professor existe
      final professores = await _userService.getAllProfessoresPublicos().first;
      if (!professores.any((p) => p.id == professorId)) {
        throw Exception('Professor não encontrado.');
      }

      // Criar usuário no Auth (isso fará logout automático do professor)
      final userCredential = await _authController.signUpAlunoComProfessor(
        email,
        senha,
        nome,
        professorId,
      );

      final alunoId = userCredential.user!.uid;

      // Mostrar dialog perguntando a senha do professor para relogar
      if (!context.mounted) return null;

      final senhaProfessor = await DialogUtils.showTextInputDialog(
        context: context,
        title: 'Confirmação Necessária',
        message: 'Para continuar logado, confirme sua senha:\n$professorEmail',
        hintText: 'Sua senha',
        obscureText: true,
        validator: (value) =>
            value?.trim().isEmpty ?? true ? 'Senha é obrigatória' : null,
      );

      if (senhaProfessor == null) {
        // Se cancelou, vai para login
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
        return alunoId;
      }

      // Tentar fazer login do professor novamente
      if (context.mounted) {
        await _relogarProfessor(context, professorEmail, senhaProfessor);
      }

      return alunoId;
    } catch (e) {
      if (!context.mounted) return null;
      _mostrarErro(context, 'Erro ao criar conta de aluno: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Re-autentica o professor após criar aluno
  Future<void> _relogarProfessor(
    BuildContext context,
    String professorEmail,
    String senha,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: professorEmail,
        password: senha,
      );

      // Login bem-sucedido - mostrar mensagem e voltar para meus alunos
      if (context.mounted) {
        _mostrarSucesso(context, 'Aluno cadastrado com sucesso!');

        // Voltar para meus alunos
        Navigator.pushReplacementNamed(context, AppRoutes.meusAlunos);
      }
    } catch (e) {
      // Senha incorreta - mostrar erro e ir para login
      if (context.mounted) {
        _mostrarErro(context, 'Senha incorreta. Faça login novamente.');
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  /// Exibe mensagem de erro
  void _mostrarErro(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Exibe mensagem de sucesso
  void _mostrarSucesso(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
      ),
    );
  }
}
