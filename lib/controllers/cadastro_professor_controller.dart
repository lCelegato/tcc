import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class CadastroProfessorController extends ChangeNotifier {
  final AuthController _authController = AuthController();

  Future<bool> validarCodigoProfessor(String codigo) async {
    // Exemplo: código para limitar registros
    return codigo.trim() == 'TCC2025';
  }

  Future<void> cadastrarProfessor({
    required String email,
    required String senha,
    required String nome,
    required String codigo,
    required BuildContext context,
  }) async {
    try {
      // Validar código do professor
      final codigoValido = await validarCodigoProfessor(codigo);
      if (!context.mounted) return;
      if (!codigoValido) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código de cadastro de professor inválido!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Criar usuário no Auth
      await _authController.signUp(
        email,
        senha,
        nome,
        'professor',
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta de professor criada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar conta de professor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
