import 'user_model.dart';

/// Modelo específico para Aluno herdando de UserModel.
class AlunoModel extends UserModel {
  AlunoModel({
    required super.id,
    required super.nome,
    required super.email,
    super.dataCriacao,
    required super.tipo,
    super.professorId,
  });

  factory AlunoModel.fromUser(UserModel user) {
    return AlunoModel(
      id: user.id,
      nome: user.nome,
      email: user.email,
      tipo: user.tipo,
      dataCriacao: user.dataCriacao,
      professorId: user.professorId,
    );
  }

  factory AlunoModel.fromMap(Map<String, dynamic> map) {
    return AlunoModel(
      id: map['id'] as String,
      nome: map['nome'] as String,
      email: map['email'] as String,
      tipo: map['tipo'] as String,
      dataCriacao: map['dataCriacao'],
      professorId: map['professorId'],
    );
  }

  @override
  AlunoModel copyWith({
    String? id,
    String? nome,
    String? email,
    String? tipo,
    DateTime? dataCriacao,
    String? professorId,
  }) {
    return AlunoModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      tipo: tipo ?? this.tipo,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      professorId: professorId ?? this.professorId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlunoModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  // Adicione métodos ou campos específicos de aluno aqui
}
