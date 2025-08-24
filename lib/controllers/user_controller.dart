/// Controlador responsável por gerenciar os dados do usuário.
///
/// Responsabilidades:
/// - Gerenciar o estado dos dados do usuário
/// - Controlar operações CRUD do perfil do usuário
/// - Manter o estado de loading durante operações
/// - Notificar mudanças no estado do usuário
///
/// 1. Carregar Dados:
///    - Recebe UID do usuário
///    - Busca dados no Firestore
///    - Atualiza estado local
///    - Notifica listeners sobre mudanças
///
/// 2. Atualizar Perfil:
///    - Recebe dados para atualização
///    - Atualiza no Firestore
///    - Recarrega dados atualizados
///    - Notifica listeners sobre mudanças
///
/// 3. Deletar Perfil:
///    - Remove dados do Firestore
///    - Limpa estado local
///    - Notifica listeners sobre mudanças
///
/// Estados:
/// - _user: Dados atuais do usuário
/// - _isLoading: Estado de loading durante operações
///
/// Dependências:
/// - UserService: Para operações no Firestore
/// - UserModel: Para estrutura de dados do usuário
library;

import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import 'aula_controller.dart';

class UserController extends ChangeNotifier {
  final UserService _userService = UserService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> loadUserData(String uid, String tipo) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userData = await _userService.getUserData(uid, tipo).first;
      _user = userData;
    } catch (e) {
      // print('Erro ao carregar dados do usuário: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(
      String uid, String tipo, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _userService.updateUserProfile(uid, tipo, data);
      await loadUserData(uid, tipo); // Recarrega os dados atualizados
    } catch (e) {
      // print('Erro ao atualizar perfil: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUserProfile(String uid, String tipo) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _userService.deleteUserProfile(uid, tipo);
      _user = null;
    } catch (e) {
      // print('Erro ao deletar perfil: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Buscar todos os professores
  Stream<List<UserModel>> getAllProfessores() {
    return _userService.getAllProfessores();
  }

  // Buscar todos os alunos
  Stream<List<UserModel>> getAllAlunos() {
    return _userService.getAllAlunos();
  }

  // Buscar apenas os alunos vinculados ao professor
  Stream<List<UserModel>> getAlunosDoProfessor(String professorId) {
    return _userService.getAlunosDoProfessor(professorId);
  }

  // Buscar todos os professores públicos (caso queira usar no cadastro sem autenticação)
  Stream<List<UserModel>> getAllProfessoresPublicos() {
    return _userService.getAllProfessoresPublicos();
  }

  // Limpar o usuário carregado
  void clearUser() {
    _user = null;
    notifyListeners();
  }

  // Atualizar dados do aluno
  Future<void> atualizarAluno(
      String alunoId, Map<String, dynamic> dados, BuildContext context) async {
    try {
      await updateUserProfile(alunoId, 'aluno', dados);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados do aluno atualizados com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar dados do aluno: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Excluir aluno
  Future<void> excluirAluno(String alunoId, BuildContext context) async {
    try {
      // Primeiro, remover todas as aulas do aluno
      final aulaController = AulaController();
      await aulaController.removerAulasDoAluno(alunoId);

      // Depois, remover o aluno
      await deleteUserProfile(alunoId, 'aluno');

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aluno e suas aulas foram excluídos com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir aluno: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
