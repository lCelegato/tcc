/// Constantes globais da aplicação
///
/// Centraliza valores fixos, configurações e mensagens
/// para facilitar manutenção e consistência
library;

class AppConstants {
  // Tipos de usuário
  static const String tipoAluno = 'aluno';
  static const String tipoProfessor = 'professor';

  // Matérias disponíveis
  static const List<String> materiasDisponiveis = [
    'matematica',
    'portugues',
    'ciencia',
    'historia',
    'geografia',
    'ingles',
    'educacao_fisica',
    'artes',
  ];

  // Nomes amigáveis das matérias
  static const Map<String, String> materiasNomes = {
    'matematica': 'Matemática',
    'portugues': 'Português',
    'ciencia': 'Ciências',
    'historia': 'História',
    'geografia': 'Geografia',
    'ingles': 'Inglês',
    'educacao_fisica': 'Educação Física',
    'artes': 'Artes',
  };

  // Dias da semana
  static const List<Map<String, dynamic>> diasSemana = [
    {'valor': 1, 'nome': 'Segunda-feira', 'abrev': 'Seg'},
    {'valor': 2, 'nome': 'Terça-feira', 'abrev': 'Ter'},
    {'valor': 3, 'nome': 'Quarta-feira', 'abrev': 'Qua'},
    {'valor': 4, 'nome': 'Quinta-feira', 'abrev': 'Qui'},
    {'valor': 5, 'nome': 'Sexta-feira', 'abrev': 'Sex'},
    {'valor': 6, 'nome': 'Sábado', 'abrev': 'Sáb'},
    {'valor': 7, 'nome': 'Domingo', 'abrev': 'Dom'},
  ];

  // Coleções do Firebase
  static const String colecaoUsuarios = 'usuarios';
  static const String colecaoAlunos = 'alunos';
  static const String colecaoProfessores = 'professores';
  static const String colecaoPostagens = 'postagens';
  static const String colecaoAulas = 'aulas';

  // Mensagens de erro comuns
  static const String erroConexao = 'Erro de conexão. Tente novamente.';
  static const String erroDadosInvalidos = 'Dados inválidos fornecidos.';
  static const String erroPermissao = 'Você não tem permissão para esta ação.';
  static const String erroGenerico = 'Ocorreu um erro inesperado.';

  // Configurações de validação
  static const int tamanhoMinimoSenha = 6;
  static const int tamanhoMaximoTitulo = 100;
  static const int tamanhoMaximoConteudo = 5000;

  // Configurações de UI
  static const double paddingPadrao = 16.0;
  static const double marginPadrao = 8.0;
  static const double raioCantosPadrao = 8.0;

  // Regex patterns
  static const String regexEmail = r'^[^@]+@[^@]+\.[^@]+$';
  static const String regexHorario = r'^\d{2}:\d{2}$';
}

/// Extension para facilitar acesso aos nomes das matérias
extension MateriaExtension on String {
  String get nomeAmigavel => AppConstants.materiasNomes[this] ?? this;
}

/// Extension para dias da semana
extension DiaSemanaExtension on int {
  String get nomeDiaSemana {
    final dia = AppConstants.diasSemana.firstWhere(
      (d) => d['valor'] == this,
      orElse: () => {'nome': 'Dia inválido'},
    );
    return dia['nome'] as String;
  }

  String get nomeDiaAbreviado {
    final dia = AppConstants.diasSemana.firstWhere(
      (d) => d['valor'] == this,
      orElse: () => {'abrev': 'Inv'},
    );
    return dia['abrev'] as String;
  }
}
