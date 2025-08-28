/// Controller para gerenciar postagens
///
/// Responsabilidades:
/// - Controlar o estado das postagens
/// - Validar dados de entrada
/// - Gerenciar operações CRUD
/// - Notificar mudanças na UI
library;

import 'package:flutter/foundation.dart';
import '../models/postagem_model.dart';
import '../services/postagem_service.dart';

enum PostagemState { idle, loading, success, error }

class PostagemController extends ChangeNotifier {
  final PostagemService _postagemService = PostagemService();

  PostagemState _state = PostagemState.idle;
  String _errorMessage = '';
  List<PostagemModel> _postagens = [];
  Map<String, List<PostagemModel>> _postagensAgrupadas = {};
  final Map<String, List<PostagemModel>> _postagensAgrupadasPorMateria = {};
  PostagemModel? _postagemSelecionada;

  // Getters
  PostagemState get state => _state;
  String get errorMessage => _errorMessage;
  List<PostagemModel> get postagens => _postagens;
  Map<String, List<PostagemModel>> get postagensAgrupadas =>
      _postagensAgrupadas;
  Map<String, List<PostagemModel>> get postagensAgrupadasPorMateria =>
      _postagensAgrupadasPorMateria;
  PostagemModel? get postagemSelecionada => _postagemSelecionada;

  /// Define o estado e notifica os listeners
  void _setState(PostagemState newState, {String? error}) {
    _state = newState;
    _errorMessage = error ?? '';
    notifyListeners();
  }

  /// Cria uma nova postagem
  Future<bool> criarPostagem({
    required String professorId,
    required String titulo,
    required String conteudo,
    required String materia,
    required List<String> alunosDestino,
    List<String>? anexos,
  }) async {
    try {
      _setState(PostagemState.loading);

      debugPrint(
          'Criando postagem para ${alunosDestino.length} alunos: $alunosDestino');
      debugPrint('Matéria: $materia');
      debugPrint('Título: $titulo');

      // Validar dados de entrada
      if (!_validarDadosPostagem(titulo, conteudo, materia, alunosDestino)) {
        _setState(PostagemState.error, error: 'Dados inválidos');
        return false;
      }

      final novaPostagem = PostagemModel(
        id: '', // Será definido pelo serviço
        professorId: professorId,
        titulo: titulo,
        conteudo: conteudo,
        materia: materia,
        dataPostagem: DateTime.now(),
        alunosDestino: alunosDestino,
        anexos: anexos,
      );

      await _postagemService.criarPostagem(novaPostagem);
      _setState(PostagemState.success);

      // Recarregar lista de postagens
      await carregarPostagensProfessor(professorId);

      return true;
    } catch (e) {
      debugPrint('Erro no controller ao criar postagem: $e');
      _setState(PostagemState.error, error: 'Erro ao criar postagem: $e');
      return false;
    }
  }

  /// Carrega postagens do professor
  Future<void> carregarPostagensProfessor(String professorId) async {
    try {
      _setState(PostagemState.loading);
      _postagens = await _postagemService.buscarPostagensProfessor(professorId);
      _setState(PostagemState.success);
    } catch (e) {
      debugPrint('Erro ao carregar postagens do professor: $e');
      _setState(PostagemState.error, error: 'Erro ao carregar postagens');
    }
  }

  /// Carrega postagens para o aluno
  Future<void> carregarPostagensAluno(String alunoId) async {
    try {
      _setState(PostagemState.loading);
      _postagens = await _postagemService.buscarPostagensParaAluno(alunoId);
      _setState(PostagemState.success);
    } catch (e) {
      debugPrint('Erro ao carregar postagens do aluno: $e');
      _setState(PostagemState.error, error: 'Erro ao carregar postagens');
    }
  }

  /// Carrega postagens agrupadas por matéria para o aluno
  Future<void> carregarPostagensAgrupadasPorMateria(String alunoId) async {
    try {
      _setState(PostagemState.loading);
      _postagensAgrupadas =
          await _postagemService.buscarPostagensAgrupadasPorMateria(alunoId);
      _setState(PostagemState.success);
    } catch (e) {
      debugPrint('Erro ao carregar postagens agrupadas: $e');
      _setState(PostagemState.error, error: 'Erro ao carregar postagens');
    }
  }

  /// Carrega postagens de uma matéria específica
  Future<void> carregarPostagensPorMateria(
      String alunoId, String materia) async {
    try {
      _setState(PostagemState.loading);
      _postagens = await _postagemService.buscarPostagensParaAlunoPorMateria(
          alunoId, materia);
      _setState(PostagemState.success);
    } catch (e) {
      debugPrint('Erro ao carregar postagens por matéria: $e');
      _setState(PostagemState.error, error: 'Erro ao carregar postagens');
    }
  }

  /// Carrega uma postagem específica
  Future<void> carregarPostagem(String postagemId) async {
    try {
      _setState(PostagemState.loading);
      _postagemSelecionada =
          await _postagemService.buscarPostagemPorId(postagemId);
      _setState(PostagemState.success);
    } catch (e) {
      debugPrint('Erro ao carregar postagem: $e');
      _setState(PostagemState.error, error: 'Erro ao carregar postagem');
    }
  }

  /// Atualiza uma postagem existente
  Future<bool> atualizarPostagem(PostagemModel postagem) async {
    try {
      _setState(PostagemState.loading);

      if (!_validarDadosPostagem(
        postagem.titulo,
        postagem.conteudo,
        postagem.materia,
        postagem.alunosDestino,
      )) {
        _setState(PostagemState.error, error: 'Dados inválidos');
        return false;
      }

      await _postagemService.atualizarPostagem(postagem);
      _setState(PostagemState.success);

      // Recarregar lista
      await carregarPostagensProfessor(postagem.professorId);

      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar postagem: $e');
      _setState(PostagemState.error, error: 'Erro ao atualizar postagem');
      return false;
    }
  }

  /// Remove uma postagem
  Future<bool> removerPostagem(String postagemId, String professorId) async {
    try {
      _setState(PostagemState.loading);
      await _postagemService.removerPostagem(postagemId);
      _setState(PostagemState.success);

      // Recarregar lista
      await carregarPostagensProfessor(professorId);

      return true;
    } catch (e) {
      debugPrint('Erro ao remover postagem: $e');
      _setState(PostagemState.error, error: 'Erro ao remover postagem');
      return false;
    }
  }

  /// Busca postagens recentes
  Future<void> carregarPostagensRecentes(String alunoId) async {
    try {
      _setState(PostagemState.loading);
      _postagens = await _postagemService.buscarPostagensRecentes(alunoId);
      _setState(PostagemState.success);
    } catch (e) {
      debugPrint('Erro ao carregar postagens recentes: $e');
      _setState(PostagemState.error,
          error: 'Erro ao carregar postagens recentes');
    }
  }

  /// Adiciona anexo à postagem
  Future<bool> adicionarAnexo(String postagemId, String urlAnexo) async {
    try {
      await _postagemService.adicionarAnexo(postagemId, urlAnexo);

      // Atualizar postagem selecionada se for a mesma
      if (_postagemSelecionada?.id == postagemId) {
        await carregarPostagem(postagemId);
      }

      return true;
    } catch (e) {
      debugPrint('Erro ao adicionar anexo: $e');
      _setState(PostagemState.error, error: 'Erro ao adicionar anexo');
      return false;
    }
  }

  /// Remove anexo da postagem
  Future<bool> removerAnexo(String postagemId, String urlAnexo) async {
    try {
      await _postagemService.removerAnexo(postagemId, urlAnexo);

      // Atualizar postagem selecionada se for a mesma
      if (_postagemSelecionada?.id == postagemId) {
        await carregarPostagem(postagemId);
      }

      return true;
    } catch (e) {
      debugPrint('Erro ao remover anexo: $e');
      _setState(PostagemState.error, error: 'Erro ao remover anexo');
      return false;
    }
  }

  /// Filtra postagens por texto de busca
  List<PostagemModel> filtrarPostagens(String textoBusca) {
    if (textoBusca.isEmpty) return _postagens;

    return _postagens.where((postagem) {
      return postagem.titulo.toLowerCase().contains(textoBusca.toLowerCase()) ||
          postagem.conteudo.toLowerCase().contains(textoBusca.toLowerCase()) ||
          postagem.nomeMateria.toLowerCase().contains(textoBusca.toLowerCase());
    }).toList();
  }

  /// Agrupa postagens por data
  Map<String, List<PostagemModel>> agruparPostagensaPorData() {
    final Map<String, List<PostagemModel>> postagensAgrupadas = {};

    for (final postagem in _postagens) {
      final dataKey = postagem.dataFormatada;

      if (!postagensAgrupadas.containsKey(dataKey)) {
        postagensAgrupadas[dataKey] = [];
      }
      postagensAgrupadas[dataKey]!.add(postagem);
    }

    return postagensAgrupadas;
  }

  /// Obtém contagem de postagens por matéria
  Map<String, int> obterContagemPorMateria() {
    final Map<String, int> contagem = {};

    for (final postagem in _postagens) {
      contagem[postagem.materia] = (contagem[postagem.materia] ?? 0) + 1;
    }

    return contagem;
  }

  /// Valida dados da postagem
  bool _validarDadosPostagem(
    String titulo,
    String conteudo,
    String materia,
    List<String> alunosDestino,
  ) {
    // Validar título
    if (titulo.trim().isEmpty || titulo.length < 3) {
      return false;
    }

    // Validar conteúdo
    if (conteudo.trim().isEmpty || conteudo.length < 10) {
      return false;
    }

    // Validar matéria
    final materiasValidas =
        PostagemModel.materiasDisponiveis.map((m) => m['valor']).toList();
    if (!materiasValidas.contains(materia)) {
      return false;
    }

    // Validar alunos destino
    if (alunosDestino.isEmpty) {
      return false;
    }

    return true;
  }

  /// Define a postagem selecionada
  void selecionarPostagem(PostagemModel postagem) {
    _postagemSelecionada = postagem;
    notifyListeners();
  }

  /// Limpa a postagem selecionada
  void limparSelecao() {
    _postagemSelecionada = null;
    notifyListeners();
  }

  /// Reseta o estado do controller
  void resetState() {
    _setState(PostagemState.idle);
    _postagens.clear();
    _postagensAgrupadas.clear();
    _postagemSelecionada = null;
  }

  /// Lista das matérias disponíveis
  List<Map<String, String>> get materiasDisponiveis =>
      PostagemModel.materiasDisponiveis;
}
