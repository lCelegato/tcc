/// Gerenciador de rotas da aplicação.
///
/// Funcionalidades:
/// 1. Definição de Rotas:
///    - Login: Tela de autenticação
///    - Register: Tela de registro
///    - Home: Tela principal (professor/aluno)
///
/// 2. Navegação:
///    - Rotas nomeadas
///    - Substituição de rotas
///    - Navegação com parâmetros
///
/// Estrutura:
/// - Constantes para nomes das rotas
/// - Mapa de rotas para o MaterialApp
/// - Método para obter rotas
///
/// Uso:
/// - Configuração do MaterialApp
/// - Navegação entre telas
/// - Gerenciamento de fluxo
///
/// Observações:
/// - Rotas são estáticas
/// - Nomes de rotas são constantes
/// - Facilita manutenção de rotas
library;

import 'package:flutter/material.dart';
import '../views/login_screen.dart';
import '../views/register_screen.dart';
import '../views/professor/professor_home_screen.dart';
import '../views/aluno/aluno_home_screen.dart';
import '../views/professor/meus_alunos_screen.dart';
import '../views/professor/detalhes_aluno_screen.dart';
import '../views/professor/register_aluno_screen.dart';
import '../views/professor/gerenciar_aulas_screen.dart';
import '../views/professor/criar_postagem_screen.dart';
import '../views/professor/minhas_postagens_screen.dart';
import '../views/aluno/minhas_aulas_screen.dart';
import '../views/aluno/postagens_aluno_screen.dart';
import '../views/aluno/detalhes_postagem_screen.dart';
import '../models/user_model.dart';
import '../models/postagem_model.dart';

class AppRoutes {
  /// Definição centralizada das rotas nomeadas do app.
  /// Use estas constantes para navegação segura e manutenção fácil.

  /// Tela de login
  static const String login = '/login';

  /// Tela de cadastro de professor
  static const String register = '/register';

  /// Tela de cadastro de aluno
  static const String registerAluno = '/registerAluno';

  /// Tela de home do professor
  static const String professorHome = '/professor-home';

  /// Tela principal do professor com navegação
  static const String professorDashboard = '/professor-dashboard';

  /// Tela de home do aluno
  static const String alunoHome = '/aluno-home';

  /// Tela principal do aluno com navegação
  static const String alunoDashboard = '/aluno-dashboard';

  /// Tela de listagem de alunos do professor
  static const String meusAlunos = '/meus-alunos';

  /// Tela de detalhes do aluno
  static const String detalhesAluno = '/detalhes-aluno';

  /// Tela de gerenciar aulas do professor
  static const String gerenciarAulas = '/gerenciar-aulas';

  /// Tela de criar postagem
  static const String criarPostagem = '/criar-postagem';

  /// Tela de postagens do professor
  static const String minhasPostagens = '/minhas-postagens';

  /// Tela de minhas aulas do aluno
  static const String minhasAulas = '/minhas-aulas';

  /// Tela de postagens para o aluno
  static const String postagensAluno = '/postagens-aluno';

  /// Tela de detalhes da postagem
  static const String detalhesPostagem = '/detalhes-postagem';

  /// Mapa de rotas nomeadas para uso no MaterialApp
  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        registerAluno: (context) => const RegisterAlunoScreen(),
        professorHome: (context) => const ProfessorHomeScreen(),
        professorDashboard: (context) => const ProfessorHomeScreen(),
        alunoHome: (context) => const AlunoHomeScreen(),
        alunoDashboard: (context) => const AlunoHomeScreen(),
        meusAlunos: (context) => const MeusAlunosScreen(),
        gerenciarAulas: (context) => const GerenciarAulasScreen(),
        criarPostagem: (context) => const CriarPostagemScreen(),
        minhasPostagens: (context) => const MinhasPostagensScreen(),
        minhasAulas: (context) => const MinhasAulasScreen(),
        postagensAluno: (context) => const PostagensAlunoScreen(),
      };

  /// Geração de rotas dinâmicas
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == detalhesAluno) {
      final aluno = settings.arguments as UserModel;
      return MaterialPageRoute(
        builder: (context) => DetalhesAlunoScreen(aluno: aluno),
      );
    }
    if (settings.name == detalhesPostagem) {
      final postagem = settings.arguments as PostagemModel;
      return MaterialPageRoute(
        builder: (context) => DetalhesPostagemScreen(postagem: postagem),
      );
    }
    return MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    );
  }
}
