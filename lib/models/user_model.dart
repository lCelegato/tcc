/// Atributos:
/// - id: Identificador único do usuário (UID do Firebase)
/// - nome: Nome completo do usuário
/// - email: Email do usuário (usado para login)
/// - tipo: Tipo de usuário ('professor' ou 'aluno')
/// - dataCriacao: Data e hora de criação do perfil
/// - professorId: Identificador do professor associado ao usuário
///
/// Funcionalidades:
///    - fromMap: Converte dados do Firestore para objeto
///    - toMap: Converte objeto para formato do Firestore
///
/// Validações:
///    - Tipo de usuário válido
///    - Email válido
///    - Nome não vazio
///
/// - Armazenamento de dados do usuário
/// - Transferência de dados entre camadas
/// - Serialização/deserialização com Firestore
///
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserModel {
  final String id;
  final String nome;
  final String email;
  final String tipo;
  final DateTime? dataCriacao;
  final String? professorId;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.tipo,
    this.dataCriacao,
    this.professorId,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    try {
      return UserModel(
        id: map['id'] as String,
        nome: map['nome'] as String,
        email: map['email'] as String,
        tipo: map['tipo'] as String,
        dataCriacao: map['dataCriacao'] != null
            ? (map['dataCriacao'] as Timestamp).toDate()
            : null,
        professorId: map['professorId'],
      );
    } catch (e) {
      debugPrint('Erro ao converter dados: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'tipo': tipo,
      'dataCriacao': dataCriacao,
      'professorId': professorId,
    };
  }

  UserModel copyWith({
    String? id,
    String? nome,
    String? email,
    String? tipo,
    DateTime? dataCriacao,
    String? professorId,
  }) {
    return UserModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      tipo: tipo ?? this.tipo,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      professorId: professorId ?? this.professorId,
    );
  }

  bool get isAluno => tipo == 'aluno';
  bool get isProfessor => tipo == 'professor';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
