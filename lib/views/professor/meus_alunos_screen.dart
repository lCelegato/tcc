import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/user_card.dart';

class MeusAlunosScreen extends StatefulWidget {
  const MeusAlunosScreen({super.key});

  @override
  State<MeusAlunosScreen> createState() => _MeusAlunosScreenState();
}

class _MeusAlunosScreenState extends State<MeusAlunosScreen> {
  bool _carregou = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!_carregou) {
        final userController = context.read<UserController>();
        final authController = context.read<AuthController>();
        final user = authController.currentUser;
        if (user != null) {
          userController.loadUserData(user.uid, 'professor');
          setState(() {
            _carregou = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();
    final professor = userController.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Alunos'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.registerAluno);
        },
        child: const Icon(Icons.add),
      ),
      body: userController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : (professor == null
              ? const Center(
                  child: Text('Não foi possível identificar o professor.'))
              : StreamBuilder<List<UserModel>>(
                  stream: userController.getAlunosDoProfessor(professor.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Erro ao carregar alunos: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final meusAlunos = snapshot.data ?? [];

                    if (meusAlunos.isEmpty) {
                      return const Center(
                        child: Text(
                          'Você ainda não tem alunos vinculados',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          _carregou = false;
                        });
                        await userController.loadUserData(
                            professor.id, 'professor');
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: meusAlunos.length,
                        itemBuilder: (context, index) {
                          final aluno = meusAlunos[index];
                          return UserCard(
                            nome: aluno.nome,
                            email: aluno.email,
                            trailing: IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () async {
                                final result = await Navigator.pushNamed(
                                  context,
                                  AppRoutes.detalhesAluno,
                                  arguments: aluno,
                                );
                                if (result == true) {
                                  setState(() {
                                    _carregou = false;
                                  });
                                  await userController.loadUserData(
                                      professor.id, 'professor');
                                }
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                )),
    );
  }
}
