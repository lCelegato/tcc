import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CadastroAlunoController extends ChangeNotifier {
  final UserService _userService = UserService();
  final AuthController _authController = AuthController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> validarSenhaProfessor(
      String email, String senha, BuildContext context) async {
    try {
      await _authController.signIn(email, senha, context);
      //await _authController.signOut();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> cadastrarAluno({
    required String email,
    required String senha,
    required String nome,
    required String professorId,
    required BuildContext context,
  }) async {
    try {
      // Salvar o usuário atual (professor)
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Sessão do professor não encontrada.');
      }

      // Validar se o professor existe
      final professores = await _userService.getAllProfessoresPublicos().first;
      if (!professores.any((p) => p.id == professorId)) {
        throw Exception('Professor não encontrado.');
      }

      // Criar usuário no Auth sem fazer login
      await _authController.signUpAlunoComProfessor(
        email,
        senha,
        nome,
        professorId,
      );

      // Restaurar a sessão do professor
      await _auth.signInWithEmailAndPassword(
        email: currentUser.email!,
        password: senha, // Aqui precisamos da senha do professor
      );

      if (!context.mounted) return;
      // Mostrar mensagem de sucesso antes de navegar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta de aluno criada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Aguardar um momento para a SnackBar ser visível antes de navegar
      await Future.delayed(const Duration(milliseconds: 500));
      if (!context.mounted) return;
      // Navegar para a tela de meusAlunos
      Navigator.pushReplacementNamed(context, AppRoutes.meusAlunos);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar conta de aluno: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
