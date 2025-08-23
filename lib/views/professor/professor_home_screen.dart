/// Home Screen para professores
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
                Navigator.pushNamed(context, AppRoutes.gerenciarAulas);
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
