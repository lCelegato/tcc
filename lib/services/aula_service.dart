import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/aula_model.dart';

class AulaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'aulas';

  /// Cria uma nova aula no cronograma
  Future<String> criarAula(AulaModel aula) async {
    try {
      final aulaRef = _firestore.collection(_collection).doc();
      final aulaComId = aula.copyWith(
        id: aulaRef.id,
        dataCriacao: DateTime.now(),
      );

      await aulaRef.set(aulaComId.toMap());
      debugPrint('Aula criada com sucesso: ${aulaRef.id}');
      return aulaRef.id;
    } catch (e) {
      debugPrint('Erro ao criar aula: $e');
      rethrow;
    }
  }

  /// Busca todas as aulas ativas de um professor
  Future<List<AulaModel>> buscarAulasPorProfessor(String professorId) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('professorId', isEqualTo: professorId)
          .where('ativa', isEqualTo: true)
          .get();

      return query.docs.map((doc) => AulaModel.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Erro ao buscar aulas do professor: $e');
      return [];
    }
  }

  /// Busca todas as aulas ativas de um aluno
  Future<List<AulaModel>> buscarAulasPorAluno(String alunoId) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('alunoId', isEqualTo: alunoId)
          .where('ativa', isEqualTo: true)
          .get();

      return query.docs.map((doc) => AulaModel.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Erro ao buscar aulas do aluno: $e');
      return [];
    }
  }

  /// Atualiza uma aula existente
  Future<void> atualizarAula(AulaModel aula) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(aula.id)
          .update(aula.toMap());
      debugPrint('Aula atualizada com sucesso: ${aula.id}');
    } catch (e) {
      debugPrint('Erro ao atualizar aula: $e');
      rethrow;
    }
  }

  /// Desativa uma aula (não remove, apenas marca como inativa)
  Future<void> desativarAula(String aulaId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(aulaId)
          .update({'ativa': false});
      debugPrint('Aula desativada com sucesso: $aulaId');
    } catch (e) {
      debugPrint('Erro ao desativar aula: $e');
      rethrow;
    }
  }

  /// Remove todas as aulas de um aluno (quando aluno é removido)
  Future<void> removerAulasDoAluno(String alunoId) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('alunoId', isEqualTo: alunoId)
          .get();

      final batch = _firestore.batch();
      for (final doc in query.docs) {
        batch.update(doc.reference, {'ativa': false});
      }

      await batch.commit();
      debugPrint('Aulas do aluno desativadas: $alunoId');
    } catch (e) {
      debugPrint('Erro ao remover aulas do aluno: $e');
      rethrow;
    }
  }

  /// Busca aulas de um aluno específico ministradas por um professor
  Future<List<AulaModel>> buscarAulasAlunoEProfessor(
    String alunoId,
    String professorId,
  ) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('alunoId', isEqualTo: alunoId)
          .where('professorId', isEqualTo: professorId)
          .where('ativa', isEqualTo: true)
          .get();

      return query.docs.map((doc) => AulaModel.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Erro ao buscar aulas específicas: $e');
      return [];
    }
  }
}
