/// Serviço para gerenciar postagens no Firestore
///
/// Responsável por todas as operações relacionadas às postagens:
/// - Criar, ler, atualizar e deletar postagens
/// - Buscar postagens por professor, aluno ou matéria
/// - Upload de anexos
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/postagem_model.dart';

class PostagemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'postagens';

  /// Cria uma nova postagem
  Future<String> criarPostagem(PostagemModel postagem) async {
    try {
      debugPrint(
          'Criando postagem no Firestore para alunos: ${postagem.alunosDestino}');
      debugPrint('Dados da postagem: ${postagem.toFirestore()}');

      final docRef =
          await _firestore.collection(_collection).add(postagem.toFirestore());
      debugPrint('Postagem criada com sucesso! ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Erro ao criar postagem: $e');
      rethrow;
    }
  }

  /// Busca todas as postagens de um professor
  Future<List<PostagemModel>> buscarPostagensPorProfessor(
      String professorId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('professorId', isEqualTo: professorId)
          .where('ativo', isEqualTo: true)
          .get();

      final postagens = querySnapshot.docs
          .map((doc) => PostagemModel.fromFirestore(doc))
          .toList();

      // Ordenar por data de postagem no código local
      postagens.sort((a, b) => b.dataPostagem.compareTo(a.dataPostagem));

      return postagens;
    } catch (e) {
      debugPrint('Erro ao buscar postagens do professor: $e');
      return [];
    }
  }

  /// Busca postagens para um aluno específico
  Future<List<PostagemModel>> buscarPostagensParaAluno(String alunoId) async {
    try {
      debugPrint('Buscando postagens para o aluno ID: $alunoId');
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('alunosDestino', arrayContains: alunoId)
          .where('ativo', isEqualTo: true)
          .get();

      debugPrint(
          'Query executada. Documentos encontrados: ${querySnapshot.docs.length}');

      final postagens = querySnapshot.docs.map((doc) {
        debugPrint('Documento encontrado: ${doc.id}');
        final data = doc.data();
        debugPrint('Dados do documento: $data');
        return PostagemModel.fromFirestore(doc);
      }).toList();

      // Ordenar por data de postagem no código local
      postagens.sort((a, b) => b.dataPostagem.compareTo(a.dataPostagem));

      debugPrint('Total de postagens processadas: ${postagens.length}');
      return postagens;
    } catch (e) {
      debugPrint('Erro ao buscar postagens para aluno: $e');
      return [];
    }
  }

  /// Busca postagens por matéria para um aluno
  Future<List<PostagemModel>> buscarPostagensParaAlunoPorMateria(
    String alunoId,
    String materia,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('alunosDestino', arrayContains: alunoId)
          .where('materia', isEqualTo: materia)
          .where('ativo', isEqualTo: true)
          .orderBy('dataPostagem', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PostagemModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar postagens por matéria: $e');
      return [];
    }
  }

  /// Busca uma postagem específica por ID
  Future<PostagemModel?> buscarPostagemPorId(String postagemId) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(postagemId).get();

      if (doc.exists) {
        return PostagemModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar postagem por ID: $e');
      return null;
    }
  }

  /// Atualiza uma postagem existente
  Future<void> atualizarPostagem(PostagemModel postagem) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(postagem.id)
          .update(postagem.toFirestore());

      debugPrint('Postagem atualizada: ${postagem.id}');
    } catch (e) {
      debugPrint('Erro ao atualizar postagem: $e');
      rethrow;
    }
  }

  /// Remove uma postagem (marca como inativa)
  Future<void> removerPostagem(String postagemId) async {
    try {
      await _firestore.collection(_collection).doc(postagemId).update({
        'ativo': false,
      });

      debugPrint('Postagem removida: $postagemId');
    } catch (e) {
      debugPrint('Erro ao remover postagem: $e');
      rethrow;
    }
  }

  /// Busca postagens agrupadas por matéria para um aluno
  Future<Map<String, List<PostagemModel>>> buscarPostagensAgrupadasPorMateria(
    String alunoId,
  ) async {
    try {
      final postagens = await buscarPostagensParaAluno(alunoId);
      final Map<String, List<PostagemModel>> postagensAgrupadas = {};

      for (final postagem in postagens) {
        if (!postagensAgrupadas.containsKey(postagem.materia)) {
          postagensAgrupadas[postagem.materia] = [];
        }
        postagensAgrupadas[postagem.materia]!.add(postagem);
      }

      return postagensAgrupadas;
    } catch (e) {
      debugPrint('Erro ao agrupar postagens por matéria: $e');
      return {};
    }
  }

  /// Stream para escutar mudanças em tempo real nas postagens do aluno
  Stream<List<PostagemModel>> streamPostagensParaAluno(String alunoId) {
    return _firestore
        .collection(_collection)
        .where('alunosDestino', arrayContains: alunoId)
        .where('ativo', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final postagens =
          snapshot.docs.map((doc) => PostagemModel.fromFirestore(doc)).toList();
      // Ordenar por data no código local
      postagens.sort((a, b) => b.dataPostagem.compareTo(a.dataPostagem));
      return postagens;
    });
  }

  /// Stream para escutar mudanças em tempo real nas postagens do professor
  Stream<List<PostagemModel>> streamPostagensPorProfessor(String professorId) {
    return _firestore
        .collection(_collection)
        .where('professorId', isEqualTo: professorId)
        .where('ativo', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final postagens =
          snapshot.docs.map((doc) => PostagemModel.fromFirestore(doc)).toList();
      // Ordenar por data no código local
      postagens.sort((a, b) => b.dataPostagem.compareTo(a.dataPostagem));
      return postagens;
    });
  }

  /// Adiciona anexo à postagem
  Future<void> adicionarAnexo(String postagemId, String urlAnexo) async {
    try {
      await _firestore.collection(_collection).doc(postagemId).update({
        'anexos': FieldValue.arrayUnion([urlAnexo]),
      });

      debugPrint('Anexo adicionado à postagem: $postagemId');
    } catch (e) {
      debugPrint('Erro ao adicionar anexo: $e');
      rethrow;
    }
  }

  /// Remove anexo da postagem
  Future<void> removerAnexo(String postagemId, String urlAnexo) async {
    try {
      await _firestore.collection(_collection).doc(postagemId).update({
        'anexos': FieldValue.arrayRemove([urlAnexo]),
      });

      debugPrint('Anexo removido da postagem: $postagemId');
    } catch (e) {
      debugPrint('Erro ao remover anexo: $e');
      rethrow;
    }
  }

  /// Conta o número de postagens de um professor
  Future<int> contarPostagensDesteProfessor(String professorId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('professorId', isEqualTo: professorId)
          .where('ativo', isEqualTo: true)
          .count()
          .get();

      return querySnapshot.count ?? 0;
    } catch (e) {
      debugPrint('Erro ao contar postagens: $e');
      return 0;
    }
  }

  /// Busca postagens recentes (últimos 7 dias)
  Future<List<PostagemModel>> buscarPostagensRecentes(String alunoId) async {
    try {
      final DateTime agora = DateTime.now();
      final DateTime seteDiasAtras = agora.subtract(const Duration(days: 7));

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('alunosDestino', arrayContains: alunoId)
          .where('ativo', isEqualTo: true)
          .where('dataPostagem',
              isGreaterThanOrEqualTo: Timestamp.fromDate(seteDiasAtras))
          .orderBy('dataPostagem', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PostagemModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar postagens recentes: $e');
      return [];
    }
  }

  /// Busca todas as postagens de um professor específico
  Future<List<PostagemModel>> buscarPostagensProfessor(
      String professorId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('professorId', isEqualTo: professorId)
          .orderBy('dataPostagem', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PostagemModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar postagens do professor: $e');
      return [];
    }
  }
}
