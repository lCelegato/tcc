import 'package:cloud_firestore/cloud_firestore.dart';
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
      return aulaRef.id;
    } catch (e) {
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

      final aulas = query.docs.map((doc) {
        final data = doc.data();
        return AulaModel.fromMap(data);
      }).toList();

      return aulas;
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
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
      return [];
    }
  }

  /// Busca informações do aluno pelo ID
  Future<Map<String, dynamic>?> buscarDadosAluno(String alunoId) async {
    try {
      // Buscar primeiro em alunos (onde os alunos são realmente salvos)
      final alunoDoc = await _firestore.collection('alunos').doc(alunoId).get();

      if (alunoDoc.exists) {
        return alunoDoc.data();
      }

      // Se não encontrou em alunos, tenta em usuarios (fallback)
      final alunoDoc2 =
          await _firestore.collection('usuarios').doc(alunoId).get();

      if (alunoDoc2.exists) {
        return alunoDoc2.data();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Remove uma aula específica permanentemente
  Future<void> deletarAula(String aulaId) async {
    try {
      await _firestore.collection(_collection).doc(aulaId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
