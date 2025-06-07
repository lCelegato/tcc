import 'package:flutter/material.dart';
import 'package:projeto_tcc/routes/app_routes.dart';
import 'package:provider/provider.dart';
import '../../controllers/user_controller.dart';
import '../../models/user_model.dart';
import '../../controllers/cadastro_aluno_controller.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_button.dart';

class RegisterAlunoScreen extends StatefulWidget {
  const RegisterAlunoScreen({super.key});

  @override
  State<RegisterAlunoScreen> createState() => _RegisterAlunoScreenState();
}

class _RegisterAlunoScreenState extends State<RegisterAlunoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final CadastroAlunoController _cadastroAlunoController =
      CadastroAlunoController();

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$')
        .hasMatch(password);
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final userController =
          Provider.of<UserController>(context, listen: false);
      final professor = userController.user;

      if (professor != null) {
        await _cadastroAlunoController.cadastrarAluno(
          email: _emailController.text.trim(),
          senha: _passwordController.text.trim(),
          nome: _nameController.text.trim(),
          professorId: professor.id,
          context: context,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Aluno'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_add,
                            size: 80, color: Colors.blue),
                        const SizedBox(height: 16),
                        const Text(
                          'Cadastrar Novo Aluno',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 32),
                        AppTextField(
                          controller: _nameController,
                          label: 'Nome Completo',
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira o nome do aluno';
                            }
                            if (value.length < 3) {
                              return 'O nome deve ter pelo menos 3 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira o email';
                            }
                            if (!_isValidEmail(value)) {
                              return 'Por favor, insira um email válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _passwordController,
                          label: 'Senha',
                          icon: Icons.lock,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira a senha';
                            }
                            if (!_isValidPassword(value)) {
                              return 'A senha deve ter pelo menos 8 caracteres, incluindo letras maiúsculas, minúsculas e números';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirmar Senha',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, confirme a senha';
                            }
                            if (value != _passwordController.text) {
                              return 'As senhas não coincidem';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          label: 'Cadastrar Aluno',
                          onPressed: _register,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
