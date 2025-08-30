/// Modelo para postagens do professor
///
/// Representa uma postagem criada pelo professor que será
/// visualizada pelos alunos organizadas por matérias
library;

import 'package:cloud_firestore/cloud_firestore.dart';

class PostagemModel {
  final String id;
  final String professorId;
  final String titulo;
  final String conteudo;
  final String materia; // matematica, portugues, historia, geografia, ciencia
  final DateTime dataPostagem;
  final List<String> alunosDestino; // IDs dos alunos que receberão a postagem
  final List<String>? anexos; // URLs dos anexos/imagens
  final List<String>? imagens; // Base64 das imagens da postagem
  final List<Map<String, dynamic>>? documentos; // Documentos em Base64
  final bool ativo;

  PostagemModel({
    required this.id,
    required this.professorId,
    required this.titulo,
    required this.conteudo,
    required this.materia,
    required this.dataPostagem,
    required this.alunosDestino,
    this.anexos,
    this.imagens,
    this.documentos,
    this.ativo = true,
  });

  /// Cria uma instância a partir de um documento Firestore
  factory PostagemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PostagemModel(
      id: doc.id,
      professorId: data['professorId'] ?? '',
      titulo: data['titulo'] ?? '',
      conteudo: data['conteudo'] ?? '',
      materia: data['materia'] ?? '',
      dataPostagem: (data['dataPostagem'] as Timestamp).toDate(),
      alunosDestino: List<String>.from(data['alunosDestino'] ?? []),
      anexos: data['anexos'] != null ? List<String>.from(data['anexos']) : null,
      imagens:
          data['imagens'] != null ? List<String>.from(data['imagens']) : null,
      documentos: data['documentos'] != null
          ? List<Map<String, dynamic>>.from(data['documentos'])
          : null,
      ativo: data['ativo'] ?? true,
    );
  }

  /// Converte para Map para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'professorId': professorId,
      'titulo': titulo,
      'conteudo': conteudo,
      'materia': materia,
      'dataPostagem': Timestamp.fromDate(dataPostagem),
      'alunosDestino': alunosDestino,
      'anexos': anexos,
      'imagens': imagens,
      'documentos': documentos,
      'ativo': ativo,
    };
  }

  /// Cria uma cópia com valores alterados
  PostagemModel copyWith({
    String? id,
    String? professorId,
    String? titulo,
    String? conteudo,
    String? materia,
    DateTime? dataPostagem,
    List<String>? alunosDestino,
    List<String>? anexos,
    List<String>? imagens,
    List<Map<String, dynamic>>? documentos,
    bool? ativo,
  }) {
    return PostagemModel(
      id: id ?? this.id,
      professorId: professorId ?? this.professorId,
      titulo: titulo ?? this.titulo,
      conteudo: conteudo ?? this.conteudo,
      materia: materia ?? this.materia,
      dataPostagem: dataPostagem ?? this.dataPostagem,
      alunosDestino: alunosDestino ?? this.alunosDestino,
      anexos: anexos ?? this.anexos,
      imagens: imagens ?? this.imagens,
      documentos: documentos ?? this.documentos,
      ativo: ativo ?? this.ativo,
    );
  }

  /// Lista das matérias disponíveis
  static List<Map<String, String>> get materiasDisponiveis => [
        {'valor': 'matematica', 'nome': 'Matemática'},
        {'valor': 'portugues', 'nome': 'Português'},
        {'valor': 'historia', 'nome': 'História'},
        {'valor': 'geografia', 'nome': 'Geografia'},
        {'valor': 'ciencia', 'nome': 'Ciência'},
      ];

  /// Retorna o nome da matéria formatado
  String get nomeMateria {
    final materia = materiasDisponiveis.firstWhere(
        (m) => m['valor'] == this.materia,
        orElse: () => {'nome': 'Matéria'});
    return materia['nome']!;
  }

  /// Retorna a data formatada
  String get dataFormatada {
    return '${dataPostagem.day.toString().padLeft(2, '0')}/'
        '${dataPostagem.month.toString().padLeft(2, '0')}/'
        '${dataPostagem.year}';
  }

  /// Retorna se tem anexos
  bool get temAnexos => anexos != null && anexos!.isNotEmpty;

  /// Retorna se tem imagens
  bool get temImagens => imagens != null && imagens!.isNotEmpty;

  /// Retorna se tem documentos
  bool get temDocumentos => documentos != null && documentos!.isNotEmpty;

  /// Retorna total de documentos
  int get totalDocumentos => documentos?.length ?? 0;

  /// Retorna total de mídias (anexos + imagens + documentos)
  int get totalMidias =>
      (anexos?.length ?? 0) +
      (imagens?.length ?? 0) +
      (documentos?.length ?? 0);

  @override
  String toString() {
    return 'PostagemModel(id: $id, titulo: $titulo, materia: $materia, dataPostagem: $dataPostagem)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostagemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
