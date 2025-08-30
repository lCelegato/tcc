/// Controller para gerenciar aulas e agendamentos
///
/// Responsabilidades:
/// - Controlar o estado das aulas
/// - Validar dados de entrada
/// - Gerenciar operações CRUD
/// - Notificar mudanças na UI
library;

import 'package:flutter/foundation.dart';
import '../models/aula_model.dart';
import '../services/aula_service.dart';
import '../utils/constants.dart';

enum AulaState { idle, loading, success, error }

class AulaController extends ChangeNotifier {
  final AulaService _aulaService = AulaService();

  AulaState _state = AulaState.idle;
  String _errorMessage = '';
  List<AulaModel> _aulas = [];

  // Getters
  AulaState get state => _state;
  String get errorMessage => _errorMessage;
  List<AulaModel> get aulas => _aulas;

  /// Define o estado e notifica os listeners
  void _setState(AulaState newState, {String? error}) {
    _state = newState;
    _errorMessage = error ?? '';
    notifyListeners();
  }

  /// Cria uma nova aula no cronograma
  Future<bool> criarAula({
    required String professorId,
    required String alunoId,
    required int diaSemana,
    required String horario,
    String titulo = 'Aula particular',
  }) async {
    try {
      _setState(AulaState.loading);

      // Validar dados de entrada
      if (!_validarDadosAula(diaSemana, horario)) {
        _setState(AulaState.error, error: 'Dados inválidos');
        return false;
      }

      // Verificar se já existe aula no mesmo horário para o professor
      final aulasExistentes =
          await _aulaService.buscarAulasPorProfessor(professorId);
      final conflito = aulasExistentes.any(
          (aula) => aula.diaSemana == diaSemana && aula.horario == horario);

      if (conflito) {
        _setState(AulaState.error,
            error: 'Já existe uma aula agendada neste horário');
        return false;
      }

      final novaAula = AulaModel(
        id: '', // Será definido pelo serviço
        professorId: professorId,
        alunoId: alunoId,
        diaSemana: diaSemana,
        horario: horario,
        titulo: titulo,
      );

      await _aulaService.criarAula(novaAula);
      _setState(AulaState.success);

      // Recarregar lista de aulas
      await carregarAulasProfessor(professorId);

      return true;
    } catch (e) {
      _setState(AulaState.error, error: 'Erro ao criar aula: $e');
      return false;
    }
  }

  /// Carrega aulas de um professor
  Future<void> carregarAulasProfessor(String professorId) async {
    try {
      _setState(AulaState.loading);
      _aulas = await _aulaService.buscarAulasPorProfessor(professorId);
      _setState(AulaState.success);
    } catch (e) {
      _setState(AulaState.error, error: 'Erro ao carregar aulas');
    }
  }

  /// Carrega aulas de um aluno
  Future<void> carregarAulasAluno(String alunoId) async {
    try {
      _setState(AulaState.loading);
      _aulas = await _aulaService.buscarAulasPorAluno(alunoId);
      _setState(AulaState.success);
    } catch (e) {
      _setState(AulaState.error, error: 'Erro ao carregar aulas');
    }
  }

  /// Busca aulas específicas de um aluno com um professor
  Future<List<AulaModel>> buscarAulasEspecificas(
    String alunoId,
    String professorId,
  ) async {
    try {
      return await _aulaService.buscarAulasAlunoEProfessor(
          alunoId, professorId);
    } catch (e) {
      return [];
    }
  }

  /// Atualiza uma aula existente
  Future<bool> atualizarAula(AulaModel aula) async {
    try {
      _setState(AulaState.loading);

      if (!_validarDadosAula(aula.diaSemana, aula.horario)) {
        _setState(AulaState.error, error: 'Dados inválidos');
        return false;
      }

      await _aulaService.atualizarAula(aula);
      _setState(AulaState.success);

      // Recarregar lista
      await carregarAulasProfessor(aula.professorId);

      return true;
    } catch (e) {
      _setState(AulaState.error, error: 'Erro ao atualizar aula');
      return false;
    }
  }

  /// Remove uma aula (desativa)
  Future<bool> removerAula(String aulaId, String professorId) async {
    try {
      _setState(AulaState.loading);
      await _aulaService.desativarAula(aulaId);
      _setState(AulaState.success);

      // Recarregar lista
      await carregarAulasProfessor(professorId);

      return true;
    } catch (e) {
      _setState(AulaState.error, error: 'Erro ao remover aula');
      return false;
    }
  }

  /// Remove todas as aulas de um aluno
  Future<void> removerAulasDoAluno(String alunoId) async {
    try {
      await _aulaService.removerAulasDoAluno(alunoId);
    } catch (e) {
      // Ignora erro ao remover aulas do aluno
    }
  }

  /// Agrupa aulas por dia da semana para exibição
  Map<int, List<AulaModel>> agruparAulasPorDia() {
    final Map<int, List<AulaModel>> aulasPorDia = {};

    for (final aula in _aulas) {
      if (!aulasPorDia.containsKey(aula.diaSemana)) {
        aulasPorDia[aula.diaSemana] = [];
      }
      aulasPorDia[aula.diaSemana]!.add(aula);
    }

    // Ordenar aulas dentro de cada dia por horário
    aulasPorDia.forEach((dia, aulas) {
      aulas.sort((a, b) => a.horario.compareTo(b.horario));
    });

    return aulasPorDia;
  }

  /// Valida dados de entrada para aula
  bool _validarDadosAula(int diaSemana, String horario) {
    // Validar dia da semana
    if (diaSemana < 1 || diaSemana > 7) {
      return false;
    }

    // Validar formato do horário (HH:mm)
    final regex = RegExp(AppConstants.regexHorario);
    if (!regex.hasMatch(horario)) {
      return false;
    }

    final parts = horario.split(':');
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return false;
    }

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return false;
    }

    return true;
  }

  /// Lista com os dias da semana para seleção
  static List<Map<String, dynamic>> get diasSemana => AppConstants.diasSemana;

  /// Reseta o estado do controller
  void resetState() {
    _setState(AulaState.idle);
  }

  /// Remove aulas órfãs (de alunos que não existem mais)
  Future<void> limparAulasOrfas(
      String professorId, List<String> alunosExistentesIds) async {
    try {
      _setState(AulaState.loading);

      // Buscar todas as aulas do professor
      final todasAulas =
          await _aulaService.buscarAulasPorProfessor(professorId);

      // Identificar aulas órfãs
      final aulasOrfas = todasAulas
          .where((aula) => !alunosExistentesIds.contains(aula.alunoId))
          .toList();

      // Remover aulas órfãs
      for (final aula in aulasOrfas) {
        await _aulaService.deletarAula(aula.id);
      }

      if (aulasOrfas.isNotEmpty) {
        // Recarregar aulas atualizadas
        await carregarAulasProfessor(professorId);
      }

      _setState(AulaState.success);
    } catch (e) {
      _setState(AulaState.error, error: 'Erro ao limpar aulas órfãs');
    }
  }
}
