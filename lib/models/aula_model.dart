/// Modelo para representar uma aula agendada semanalmente
///
/// Atributos:
/// - id: Identificador único da aula
/// - professorId: ID do professor que ministra a aula
/// - alunoId: ID do aluno que terá a aula
/// - diaSemana: Dia da semana (1=Segunda, 2=Terça, ..., 7=Domingo)
/// - horario: Horário da aula no formato "HH:mm"
/// - ativa: Se a aula ainda está ativa no cronograma
/// - dataCriacao: Data de criação do agendamento
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

class AulaModel {
  final String id;
  final String professorId;
  final String alunoId;
  final int diaSemana; // 1=Segunda, 2=Terça, ..., 7=Domingo
  final String horario; // Formato "HH:mm"
  final String titulo; // Título personalizado da aula
  final bool ativa;
  final DateTime? dataCriacao;

  AulaModel({
    required this.id,
    required this.professorId,
    required this.alunoId,
    required this.diaSemana,
    required this.horario,
    this.titulo = 'Aula particular',
    this.ativa = true,
    this.dataCriacao,
  });

  factory AulaModel.fromMap(Map<String, dynamic> map) {
    try {
      return AulaModel(
        id: map['id'] as String,
        professorId: map['professorId'] as String,
        alunoId: map['alunoId'] as String,
        diaSemana: map['diaSemana'] as int,
        horario: map['horario'] as String,
        titulo: map['titulo'] as String? ?? 'Aula particular',
        ativa: map['ativa'] as bool? ?? true,
        dataCriacao: map['dataCriacao'] != null
            ? (map['dataCriacao'] as Timestamp).toDate()
            : null,
      );
    } catch (e) {
      debugPrint('Erro ao converter dados da aula: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'professorId': professorId,
      'alunoId': alunoId,
      'diaSemana': diaSemana,
      'horario': horario,
      'titulo': titulo,
      'ativa': ativa,
      'dataCriacao': dataCriacao,
    };
  }

  AulaModel copyWith({
    String? id,
    String? professorId,
    String? alunoId,
    int? diaSemana,
    String? horario,
    String? titulo,
    bool? ativa,
    DateTime? dataCriacao,
  }) {
    return AulaModel(
      id: id ?? this.id,
      professorId: professorId ?? this.professorId,
      alunoId: alunoId ?? this.alunoId,
      diaSemana: diaSemana ?? this.diaSemana,
      horario: horario ?? this.horario,
      titulo: titulo ?? this.titulo,
      ativa: ativa ?? this.ativa,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  /// Retorna o nome do dia da semana
  String get nomeDiaSemana => diaSemana.nomeDiaSemana;

  /// Retorna o nome abreviado do dia da semana
  String get nomeDiaAbreviado => diaSemana.nomeDiaAbreviado;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AulaModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
