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

  Future<String?> cadastrarAluno({
    required String email,
    required String senha,
    required String nome,
    required String professorId,
    required BuildContext context,
  }) async {
    try {
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

      final senhaProfessor =
          await _mostrarDialogSenhaProfessor(context, professorEmail);
      if (senhaProfessor == null) {
        // Se cancelou, vai para login
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
        return alunoId;
      }

      // Tentar fazer login do professor novamente
      try {
        await _auth.signInWithEmailAndPassword(
          email: professorEmail,
          password: senhaProfessor,
        );

        // Login bem-sucedido - mostrar mensagem e voltar para meus alunos
        if (!context.mounted) return alunoId;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aluno cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Voltar para meus alunos
        Navigator.pushReplacementNamed(context, AppRoutes.meusAlunos);
      } catch (e) {
        // Senha incorreta - mostrar erro e ir para login
        if (!context.mounted) return alunoId;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Senha incorreta. Faça login novamente.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }

      return alunoId;
    } catch (e) {
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar conta de aluno: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  Future<String?> _mostrarDialogSenhaProfessor(
      BuildContext context, String professorEmail) async {
    final TextEditingController senhaController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação Necessária'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Para continuar logado, confirme sua senha:'),
              const SizedBox(height: 8),
              Text(
                professorEmail,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Sua senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final senha = senhaController.text.trim();
                if (senha.isNotEmpty) {
                  Navigator.of(context).pop(senha);
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}
