import 'user_model.dart';

/// Modelo específico para Professor herdando de UserModel.
class ProfessorModel extends UserModel {
  ProfessorModel({
    required super.id,
    required super.nome,
    required super.email,
    super.dataCriacao,
    required super.tipo,
  });

  factory ProfessorModel.fromUser(UserModel user) {
    return ProfessorModel(
      id: user.id,
      nome: user.nome,
      email: user.email,
      tipo: user.tipo,
      dataCriacao: user.dataCriacao,
    );
  }

  factory ProfessorModel.fromMap(Map<String, dynamic> map) {
    return ProfessorModel(
      id: map['id'] as String,
      nome: map['nome'] as String,
      email: map['email'] as String,
      tipo: map['tipo'] as String,
      dataCriacao: map['dataCriacao'],
    );
  }

  @override
  ProfessorModel copyWith({
    String? id,
    String? nome,
    String? email,
    String? tipo,
    DateTime? dataCriacao,
    String? professorId, // compatibilidade
  }) {
    return ProfessorModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      tipo: tipo ?? this.tipo,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfessorModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  // Adicione métodos ou campos específicos de professor aqui
}
