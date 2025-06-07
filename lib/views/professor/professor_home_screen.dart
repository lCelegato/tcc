/// Tela específica para professores que exibe o menu de funcionalidades disponíveis.
///
/// Funcionalidades disponíveis:
/// 1. Gerenciar Aulas
///    - Permite criar, editar e excluir aulas
///    - Visualizar lista de aulas existentes
///    - Gerenciar conteúdo e materiais das aulas
///
/// 2. Meus Alunos
///    - Lista todos os alunos vinculados ao professor
///    - Visualizar perfil e progresso dos alunos
///    - Gerenciar matrículas e vínculos
///
/// 3. Agenda
///    - Visualizar horários das aulas
///    - Gerenciar disponibilidade
///    - Agendar aulas e eventos
///
/// 4. Relatórios
///    - Visualizar estatísticas de desempenho
///    - Relatórios de frequência
///    - Análise de progresso dos alunos
///
/// Layout:
/// - Grid 2x2 com cards coloridos
/// - Cada card tem ícone, título e ação ao tocar
/// - Cores distintas para cada funcionalidade
///
/// Dependências:
/// - MenuCard: Widget reutilizável para os cards do menu
/// - AppButton: Widget reutilizável para botões
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/menu_card.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class ProfessorHomeScreen extends StatelessWidget {
  const ProfessorHomeScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await context.read<AuthController>().signOut();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Professor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            MenuCard(
              title: 'Gerenciar Aulas',
              icon: Icons.class_,
              color: Colors.blue,
              onTap: () {
                // TODO: Implementar navegação para gerenciamento de aulas
              },
            ),
            MenuCard(
              title: 'Meus Alunos',
              icon: Icons.people,
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.meusAlunos);
              },
            ),
            MenuCard(
              title: 'Agenda',
              icon: Icons.calendar_today,
              color: Colors.orange,
              onTap: () {
                // TODO: Implementar navegação para agenda
              },
            ),
            MenuCard(
              title: 'Relatórios',
              icon: Icons.bar_chart,
              color: Colors.purple,
              onTap: () {
                // TODO: Implementar navegação para relatórios
              },
            ),
          ],
        ),
      ),
    );
  }
}
