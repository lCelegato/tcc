/// Tela principal do professor com navegação entre funcionalidades
///
/// Permite acesso às principais funcionalidades:
/// - Criar nova postagem
/// - Gerenciar postagens existentes
/// - Ver cronograma de aulas
/// - Configurações do perfil
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/postagem_controller.dart';
import '../../controllers/aula_controller.dart';
import '../../models/user_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/menu_card.dart';
import '../../routes/app_routes.dart';
import 'gerenciar_aulas_screen.dart';
import 'criar_postagem_screen.dart';
import 'minhas_postagens_screen.dart';
import 'editar_perfil_screen.dart';
import 'alterar_senha_screen.dart';

class ProfessorHomeScreen extends StatefulWidget {
  const ProfessorHomeScreen({super.key});

  @override
  State<ProfessorHomeScreen> createState() => _ProfessorHomeScreenState();
}

class _ProfessorHomeScreenState extends State<ProfessorHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _HomeContent(),
    const MinhasPostagensScreen(),
    const GerenciarAulasScreen(),
    const _PerfilContent(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Postagens',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Cronograma',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDados();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recarregar dados quando o app volta ao foco
      _recarregarDados();
    }
  }

  void _carregarDados() {
    final userController = context.read<UserController>();
    final postagemController = context.read<PostagemController>();
    final aulaController = context.read<AulaController>();
    final professor = userController.user;

    if (professor != null) {
      // Carregar postagens e aulas do professor
      postagemController.carregarPostagensProfessor(professor.id);
      aulaController.carregarAulasProfessor(professor.id);
    }
  }

  void _recarregarDados() {
    _carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();
    final usuario = userController.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Professor Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _recarregarDados,
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Funcionalidade de notificações em desenvolvimento'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saudação
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, ${usuario?.nome ?? 'Professor'}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'O que você gostaria de fazer hoje?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Ações rápidas
            const Text(
              'Ações Rápidas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Nova Postagem',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CriarPostagemScreen(),
                      ),
                    ),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Meus Alunos',
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.meusAlunos);
                    },
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Menu de funcionalidades
            const Text(
              'Funcionalidades',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                MenuCard(
                  icon: Icons.article,
                  title: 'Gerenciar Postagens',
                  color: Colors.blue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MinhasPostagensScreen(),
                    ),
                  ),
                ),
                MenuCard(
                  icon: Icons.schedule,
                  title: 'Cronograma',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.gerenciarAulas);
                  },
                ),
                MenuCard(
                  icon: Icons.bar_chart,
                  title: 'Relatórios',
                  color: Colors.purple,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Funcionalidade de relatórios em desenvolvimento'),
                      ),
                    );
                  },
                ),
                MenuCard(
                  icon: Icons.people,
                  title: 'Meus Alunos',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.meusAlunos);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Estatísticas rápidas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer3<PostagemController, AulaController, UserController>(
                    builder: (context, postagemController, aulaController,
                        userController, child) {
                      // Contar postagens ativas
                      final totalPostagens =
                          postagemController.postagens.length;

                      // Contar aulas ativas
                      final totalAulas = aulaController.aulas.length;

                      // Usar StreamBuilder para contar alunos reais do professor
                      return StreamBuilder<List<UserModel>>(
                        stream: userController.user?.id != null
                            ? userController
                                .getAlunosDoProfessor(userController.user!.id)
                            : Stream.value([]),
                        builder: (context, snapshot) {
                          final alunosReais = snapshot.data ?? [];
                          final totalAlunosReais = alunosReais.length;

                          // Função para limpar aulas órfãs quando necessário
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (alunosReais.isNotEmpty &&
                                aulaController.aulas.isNotEmpty) {
                              final alunosIdsReais =
                                  alunosReais.map((a) => a.id).toList();
                              final alunosIdsNasAulas = aulaController.aulas
                                  .map((aula) => aula.alunoId)
                                  .toSet();

                              // Verificar se há aulas órfãs
                              final temAulasOrfas = alunosIdsNasAulas
                                  .any((id) => !alunosIdsReais.contains(id));

                              if (temAulasOrfas &&
                                  userController.user?.id != null) {
                                aulaController.limparAulasOrfas(
                                  userController.user!.id,
                                  alunosIdsReais,
                                );
                              }
                            }
                          });

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem('Postagens', '$totalPostagens',
                                  Icons.article),
                              _buildStatItem(
                                  'Alunos', '$totalAlunosReais', Icons.people),
                              _buildStatItem(
                                  'Aulas', '$totalAulas', Icons.school),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _PerfilContent extends StatelessWidget {
  const _PerfilContent();

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar e informações básicas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userController.user?.nome ?? 'Professor',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userController.user?.email ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Opções do perfil
            _buildProfileOption(
              icon: Icons.edit,
              title: 'Editar Perfil',
              subtitle: 'Alterar informações pessoais',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditarPerfilScreen(),
                  ),
                );
              },
            ),
            _buildProfileOption(
              icon: Icons.lock,
              title: 'Alterar Senha',
              subtitle: 'Trocar sua senha atual',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlterarSenhaScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Botão de logout
            AppButton(
              label: 'Sair',
              onPressed: () {
                userController.clearUser();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (Route<dynamic> route) => false,
                );
              },
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        tileColor: Colors.white,
      ),
    );
  }
}
