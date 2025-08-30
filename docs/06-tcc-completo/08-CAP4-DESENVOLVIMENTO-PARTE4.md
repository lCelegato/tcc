# **CAPÍTULO 4 - DESENVOLVIMENTO DO SISTEMA - PARTE 4**

---

## **4.3.3 Módulo de postagens**

O módulo de postagens implementa sistema completo de CRUD para conteúdo educacional, incluindo categorização por matérias e sistema de anexos.

#### **PostagemController - Gestão de Conteúdo**

```dart
class PostagemController extends ChangeNotifier {
  final PostagemService _postagemService = PostagemService();
  List<PostagemModel> _postagens = [];
  Map<String, List<PostagemModel>> _postagensAgrupadasPorMateria = {};
  PostagemState _state = PostagemState.idle;
  String? _errorMessage;

  List<PostagemModel> get postagens => _postagens;
  Map<String, List<PostagemModel>> get postagensAgrupadasPorMateria =>
      _postagensAgrupadasPorMateria;
  PostagemState get state => _state;
  String? get errorMessage => _errorMessage;

  // Criar nova postagem
  Future<bool> criarPostagem(PostagemModel postagem) async {
    try {
      _setState(PostagemState.loading);

      // Validações de negócio
      if (postagem.materia.isEmpty) {
        throw Exception('Matéria é obrigatória');
      }
      if (postagem.alunosDestino.isEmpty) {
        throw Exception('Selecione pelo menos um aluno');
      }
      if (postagem.conteudo.trim().isEmpty) {
        throw Exception('Conteúdo é obrigatório');
      }

      await _postagemService.criarPostagem(postagem);
      await carregarPostagensProfessor(postagem.professorId);

      _setState(PostagemState.success);
      return true;
    } catch (e) {
      _setState(PostagemState.error, error: e.toString());
      return false;
    }
  }

  // Carregar postagens do professor
  Future<void> carregarPostagensProfessor(String professorId) async {
    try {
      _setState(PostagemState.loading);
      _postagens = await _postagemService.buscarPostagensProfessor(professorId);
      _setState(PostagemState.success);
    } catch (e) {
      _setState(PostagemState.error, error: 'Erro ao carregar postagens');
    }
  }

  // Carregar postagens agrupadas por matéria para aluno
  Future<void> carregarPostagensAgrupadasPorMateria(String alunoId) async {
    try {
      _setState(PostagemState.loading);

      final postagens = await _postagemService.buscarPostagensParaAluno(alunoId);

      // Agrupar por matéria
      _postagensAgrupadasPorMateria.clear();
      for (final postagem in postagens) {
        if (!_postagensAgrupadasPorMateria.containsKey(postagem.materia)) {
          _postagensAgrupadasPorMateria[postagem.materia] = [];
        }
        _postagensAgrupadasPorMateria[postagem.materia]!.add(postagem);
      }

      // Ordenar cada matéria por data (mais recente primeiro)
      _postagensAgrupadasPorMateria.forEach((materia, postagens) {
        postagens.sort((a, b) => b.dataPostagem.compareTo(a.dataPostagem));
      });

      _setState(PostagemState.success);
    } catch (e) {
      _setState(PostagemState.error, error: 'Erro ao carregar postagens');
    }
  }

  // Atualizar postagem existente
  Future<bool> atualizarPostagem(PostagemModel postagem) async {
    try {
      _setState(PostagemState.loading);
      await _postagemService.atualizarPostagem(postagem);
      await carregarPostagensProfessor(postagem.professorId);
      _setState(PostagemState.success);
      return true;
    } catch (e) {
      _setState(PostagemState.error, error: 'Erro ao atualizar postagem');
      return false;
    }
  }

  // Excluir postagem
  Future<bool> excluirPostagem(String postagemId, String professorId) async {
    try {
      _setState(PostagemState.loading);
      await _postagemService.excluirPostagem(postagemId);
      await carregarPostagensProfessor(professorId);
      _setState(PostagemState.success);
      return true;
    } catch (e) {
      _setState(PostagemState.error, error: 'Erro ao excluir postagem');
      return false;
    }
  }

  void _setState(PostagemState newState, {String? error}) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }
}
```

#### **PostagemService - Comunicação com Firestore**

```dart
class PostagemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Criar nova postagem
  Future<String> criarPostagem(PostagemModel postagem) async {
    try {
      final docRef = await _firestore.collection('postagens').add({
        'professorId': postagem.professorId,
        'materia': postagem.materia,
        'conteudo': postagem.conteudo,
        'alunosDestino': postagem.alunosDestino,
        'dataPostagem': FieldValue.serverTimestamp(),
        'imagensBase64': postagem.imagensBase64,
        'documentos': postagem.documentos.map((doc) => doc.toMap()).toList(),
        'ativo': true,
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar postagem: $e');
    }
  }

  // Buscar postagens do professor
  Future<List<PostagemModel>> buscarPostagensProfessor(String professorId) async {
    try {
      final querySnapshot = await _firestore
          .collection('postagens')
          .where('professorId', isEqualTo: professorId)
          .where('ativo', isEqualTo: true)
          .get();

      final postagens = querySnapshot.docs
          .map((doc) => PostagemModel.fromMap(doc.data(), doc.id))
          .toList();

      // Ordenar por data (mais recente primeiro)
      postagens.sort((a, b) => b.dataPostagem.compareTo(a.dataPostagem));

      return postagens;
    } catch (e) {
      throw Exception('Erro ao buscar postagens: $e');
    }
  }

  // Buscar postagens para aluno específico
  Future<List<PostagemModel>> buscarPostagensParaAluno(String alunoId) async {
    try {
      final querySnapshot = await _firestore
          .collection('postagens')
          .where('alunosDestino', arrayContains: alunoId)
          .where('ativo', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PostagemModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar postagens para aluno: $e');
    }
  }

  // Stream para postagens em tempo real
  Stream<List<PostagemModel>> getPostagensStream(String alunoId) {
    return _firestore
        .collection('postagens')
        .where('alunosDestino', arrayContains: alunoId)
        .where('ativo', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostagemModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
```

### **4.3.4 Módulo de cronograma**

O módulo de cronograma implementa sistema de agendamento de aulas com recorrência semanal e validação de conflitos.

#### **AulaController - Gestão de Cronograma**

```dart
class AulaController extends ChangeNotifier {
  final AulaService _aulaService = AulaService();
  List<AulaModel> _aulas = [];
  AulaState _state = AulaState.idle;
  String? _errorMessage;

  List<AulaModel> get aulas => _aulas;
  AulaState get state => _state;
  String? get errorMessage => _errorMessage;

  // Agrupar aulas por dia da semana
  Map<int, List<AulaModel>> get aulasAgrupadasPorDia {
    final agrupadas = <int, List<AulaModel>>{};
    for (int dia = 0; dia < 7; dia++) {
      agrupadas[dia] = _aulas
          .where((aula) => aula.diaSemana == dia)
          .toList()
        ..sort((a, b) => a.horario.compareTo(b.horario));
    }
    return agrupadas;
  }

  // Criar nova aula
  Future<bool> criarAula({
    required String professorId,
    required String alunoId,
    required int diaSemana,
    required String horario,
    required String titulo,
  }) async {
    try {
      _setState(AulaState.loading);

      // Validar dados
      if (!_validarDadosAula(diaSemana, horario)) {
        _setState(AulaState.error, error: 'Dados inválidos');
        return false;
      }

      // Verificar conflito de horário
      final temConflito = await _aulaService.verificarConflitoHorario(
        professorId, diaSemana, horario,
      );

      if (temConflito) {
        _setState(AulaState.error,
            error: 'Já existe uma aula agendada neste horário');
        return false;
      }

      final novaAula = AulaModel(
        id: '',
        professorId: professorId,
        alunoId: alunoId,
        diaSemana: diaSemana,
        horario: horario,
        titulo: titulo,
      );

      await _aulaService.criarAula(novaAula);
      await carregarAulasProfessor(professorId);

      _setState(AulaState.success);
      return true;
    } catch (e) {
      _setState(AulaState.error, error: 'Erro ao criar aula: $e');
      return false;
    }
  }

  // Carregar aulas do professor
  Future<void> carregarAulasProfessor(String professorId) async {
    try {
      _setState(AulaState.loading);
      _aulas = await _aulaService.buscarAulasPorProfessor(professorId);
      _setState(AulaState.success);
    } catch (e) {
      _setState(AulaState.error, error: 'Erro ao carregar aulas');
    }
  }

  // Carregar aulas do aluno
  Future<void> carregarAulasAluno(String alunoId) async {
    try {
      _setState(AulaState.loading);
      _aulas = await _aulaService.buscarAulasPorAluno(alunoId);
      _setState(AulaState.success);
    } catch (e) {
      _setState(AulaState.error, error: 'Erro ao carregar aulas');
    }
  }

  // Atualizar aula existente
  Future<bool> atualizarAula(AulaModel aula) async {
    try {
      _setState(AulaState.loading);

      if (!_validarDadosAula(aula.diaSemana, aula.horario)) {
        _setState(AulaState.error, error: 'Dados inválidos');
        return false;
      }

      await _aulaService.atualizarAula(aula);
      await carregarAulasProfessor(aula.professorId);

      _setState(AulaState.success);
      return true;
    } catch (e) {
      _setState(AulaState.error, error: 'Erro ao atualizar aula');
      return false;
    }
  }

  // Remover aula
  Future<bool> removerAula(String aulaId, String professorId) async {
    try {
      _setState(AulaState.loading);
      await _aulaService.desativarAula(aulaId);
      await carregarAulasProfessor(professorId);
      _setState(AulaState.success);
      return true;
    } catch (e) {
      _setState(AulaState.error, error: 'Erro ao remover aula');
      return false;
    }
  }

  // Validar dados da aula
  bool _validarDadosAula(int diaSemana, String horario) {
    // Validar dia da semana (0-6)
    if (diaSemana < 0 || diaSemana > 6) return false;

    // Validar formato do horário (HH:mm)
    final regexHorario = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!regexHorario.hasMatch(horario)) return false;

    return true;
  }

  void _setState(AulaState newState, {String? error}) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }
}
```

---

### 📊 **MÉTRICAS DA PARTE 4**

| **Seção**            | **Funcionalidades**            | **Palavras**     |
| -------------------- | ------------------------------ | ---------------- |
| **4.3.3 Postagens**  | CRUD completo + agrupamento    | 456 palavras     |
| **4.3.4 Cronograma** | Agendamento + validações       | 398 palavras     |
| **TOTAL PARTE 4**    | **Módulos core implementados** | **854 palavras** |

---

**📄 Continua na Parte 5: Sistema de Anexos e Testes**
