/// Tela de perfil do aluno
///
/// Mostra as informações do aluno e do professor vinculado:
/// - Dados pessoais do aluno
/// - Informações do professor responsável
/// - Opção de logout
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
import '../../widgets/app_button.dart';

class PerfilAlunoScreen extends StatefulWidget {
  const PerfilAlunoScreen({super.key});

  @override
  State<PerfilAlunoScreen> createState() => _PerfilAlunoScreenState();
}

class _PerfilAlunoScreenState extends State<PerfilAlunoScreen> {
  UserModel? _professor;
  bool _isLoadingProfessor = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosProfessor();
  }

  Future<void> _carregarDadosProfessor() async {
    final userController = context.read<UserController>();
    final aluno = userController.user;

    if (aluno?.professorId != null) {
      setState(() {
        _isLoadingProfessor = true;
      });

      try {
        // Buscar dados do professor usando o professorId do aluno
        final professorStream = userController.getUserById(
          aluno!.professorId!,
          'professor',
        );

        final professor = await professorStream.first;
        if (mounted) {
          setState(() {
            _professor = professor;
            _isLoadingProfessor = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingProfessor = false;
          });
        }
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await context.read<AuthController>().signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) {
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
        title: const Text('Meu Perfil'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<UserController>(
        builder: (context, userController, child) {
          final aluno = userController.user;

          if (aluno == null) {
            return const Center(
              child: Text('Erro: Dados do aluno não encontrados'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Seção do Aluno
                _buildAlunoSection(aluno),

                const SizedBox(height: 24),

                // Seção do Professor
                _buildProfessorSection(),

                const SizedBox(height: 32),

                // Botão de Logout
                AppButton(
                  label: 'Sair',
                  onPressed: _handleLogout,
                  color: Colors.red,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlunoSection(UserModel aluno) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar do aluno
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

            // Nome do aluno
            Text(
              aluno.nome,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Email do aluno
            Text(
              aluno.email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Badge de Aluno
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.school,
                    size: 20,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Aluno',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessorSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título da seção
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: Colors.orange.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Professor Responsável',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (_isLoadingProfessor)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_professor != null)
              _buildProfessorInfo(_professor!)
            else
              _buildNoProfessorInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessorInfo(UserModel professor) {
    return Row(
      children: [
        // Avatar do professor
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.orange.shade100,
          child: Icon(
            Icons.person,
            size: 35,
            color: Colors.orange.shade600,
          ),
        ),

        const SizedBox(width: 16),

        // Informações do professor
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                professor.nome,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                professor.email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Professor',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoProfessorInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_off,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Nenhum professor vinculado',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Entre em contato com a coordenação',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
