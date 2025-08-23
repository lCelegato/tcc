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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AulaModel {
  final String id;
  final String professorId;
  final String alunoId;
  final int diaSemana; // 1=Segunda, 2=Terça, ..., 7=Domingo
  final String horario; // Formato "HH:mm"
  final bool ativa;
  final DateTime? dataCriacao;

  AulaModel({
    required this.id,
    required this.professorId,
    required this.alunoId,
    required this.diaSemana,
    required this.horario,
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
    bool? ativa,
    DateTime? dataCriacao,
  }) {
    return AulaModel(
      id: id ?? this.id,
      professorId: professorId ?? this.professorId,
      alunoId: alunoId ?? this.alunoId,
      diaSemana: diaSemana ?? this.diaSemana,
      horario: horario ?? this.horario,
      ativa: ativa ?? this.ativa,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  /// Retorna o nome do dia da semana
  String get nomeDiaSemana {
    switch (diaSemana) {
      case 1:
        return 'Segunda-feira';
      case 2:
        return 'Terça-feira';
      case 3:
        return 'Quarta-feira';
      case 4:
        return 'Quinta-feira';
      case 5:
        return 'Sexta-feira';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return 'Dia inválido';
    }
  }

  /// Retorna o nome abreviado do dia da semana
  String get nomeDiaAbreviado {
    switch (diaSemana) {
      case 1:
        return 'Seg';
      case 2:
        return 'Ter';
      case 3:
        return 'Qua';
      case 4:
        return 'Qui';
      case 5:
        return 'Sex';
      case 6:
        return 'Sáb';
      case 7:
        return 'Dom';
      default:
        return 'Inv';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AulaModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
