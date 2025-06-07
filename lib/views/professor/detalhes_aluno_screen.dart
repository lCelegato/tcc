import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/user_controller.dart';
import '../../models/user_model.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_button.dart';

class DetalhesAlunoScreen extends StatefulWidget {
  final UserModel aluno;

  const DetalhesAlunoScreen({
    super.key,
    required this.aluno,
  });

  @override
  State<DetalhesAlunoScreen> createState() => _DetalhesAlunoScreenState();
}

class _DetalhesAlunoScreenState extends State<DetalhesAlunoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _senhaController;
  bool _isEditing = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.aluno.nome);
    _emailController = TextEditingController(text: widget.aluno.email);
    _senhaController = TextEditingController();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _salvarAlteracoes() async {
    if (_formKey.currentState!.validate()) {
      final userController = context.read<UserController>();
      final dadosAtualizados = {
        'nome': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
      };
      if (_senhaController.text.isNotEmpty) {
        dadosAtualizados['senha'] = _senhaController.text.trim();
      }
      await userController.atualizarAluno(widget.aluno.id, dadosAtualizados, context);
      if (mounted) {
        setState(() {
          _isEditing = false;
          _senhaController.clear();
        });
      }
    }
  }

  Future<void> _excluirAluno() async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
          'Tem certeza que deseja excluir este aluno? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmacao == true && mounted) {
      final userController = context.read<UserController>();
      await userController.excluirAluno(widget.aluno.id, context);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Aluno'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _excluirAluno,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _nomeController,
                label: 'Nome',
                icon: Icons.person,
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o email';
                  }
                  if (!value.contains('@')) {
                    return 'Por favor, insira um email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_isEditing) ...[
                AppTextField(
                  controller: _senhaController,
                  label: 'Nova Senha (opcional)',
                  icon: Icons.lock,
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Cancelar',
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _nomeController.text = widget.aluno.nome;
                            _emailController.text = widget.aluno.email;
                            _senhaController.clear();
                          });
                        },
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppButton(
                        label: 'Salvar',
                        onPressed: _salvarAlteracoes,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 