/// Utilitários de validação para campos de entrada
///
/// Centraliza todas as validações do aplicativo para
/// garantir consistência e facilitar manutenção
library;

import '../utils/constants.dart';

class ValidationUtils {
  // Validação de email
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final regex = RegExp(AppConstants.regexEmail);
    return regex.hasMatch(email);
  }

  // Validação de senha
  static bool isValidPassword(String password) {
    return password.length >= AppConstants.tamanhoMinimoSenha;
  }

  // Validação de nome
  static bool isValidName(String name) {
    return name.trim().isNotEmpty && name.trim().length >= 2;
  }

  // Validação de título de postagem
  static bool isValidTitle(String title) {
    return title.trim().isNotEmpty &&
        title.length <= AppConstants.tamanhoMaximoTitulo;
  }

  // Validação de conteúdo de postagem
  static bool isValidContent(String content) {
    return content.trim().isNotEmpty &&
        content.length <= AppConstants.tamanhoMaximoConteudo;
  }

  // Validação de horário (HH:mm)
  static bool isValidTime(String time) {
    if (time.isEmpty) return false;

    final regex = RegExp(AppConstants.regexHorario);
    if (!regex.hasMatch(time)) return false;

    final parts = time.split(':');
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return false;

    return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  }

  // Validação de dia da semana
  static bool isValidWeekDay(int day) {
    return day >= 1 && day <= 7;
  }

  // Validação de tipo de usuário
  static bool isValidUserType(String type) {
    return type == AppConstants.tipoAluno || type == AppConstants.tipoProfessor;
  }

  // Validação de matéria
  static bool isValidSubject(String subject) {
    return AppConstants.materiasDisponiveis.contains(subject);
  }

  // Mensagens de erro padronizadas
  static String getEmailErrorMessage(String email) {
    if (email.isEmpty) return 'Email é obrigatório';
    if (!isValidEmail(email)) return 'Email inválido';
    return '';
  }

  static String getPasswordErrorMessage(String password) {
    if (password.isEmpty) return 'Senha é obrigatória';
    if (!isValidPassword(password)) {
      return 'Senha deve ter pelo menos ${AppConstants.tamanhoMinimoSenha} caracteres';
    }
    return '';
  }

  static String getNameErrorMessage(String name) {
    if (name.trim().isEmpty) return 'Nome é obrigatório';
    if (!isValidName(name)) return 'Nome deve ter pelo menos 2 caracteres';
    return '';
  }

  static String getTitleErrorMessage(String title) {
    if (title.trim().isEmpty) return 'Título é obrigatório';
    if (!isValidTitle(title)) {
      return 'Título deve ter no máximo ${AppConstants.tamanhoMaximoTitulo} caracteres';
    }
    return '';
  }

  static String getContentErrorMessage(String content) {
    if (content.trim().isEmpty) return 'Conteúdo é obrigatório';
    if (!isValidContent(content)) {
      return 'Conteúdo deve ter no máximo ${AppConstants.tamanhoMaximoConteudo} caracteres';
    }
    return '';
  }

  static String getTimeErrorMessage(String time) {
    if (time.isEmpty) return 'Horário é obrigatório';
    if (!isValidTime(time)) return 'Horário deve estar no formato HH:mm';
    return '';
  }
}
