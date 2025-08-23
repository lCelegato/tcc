import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/cadastro_aluno_controller.dart';
import '../../controllers/aula_controller.dart';
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
  final AulaController _aulaController = AulaController();

  // Controles para agendamento de aulas
  final List<Map<String, dynamic>> _agendamentos = [];
  int? _diaSelecionado;
  TimeOfDay? _horarioSelecionado;

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
        // Primeiro cadastra o aluno
        final alunoId = await _cadastroAlunoController.cadastrarAluno(
          email: _emailController.text.trim(),
          senha: _passwordController.text.trim(),
          nome: _nameController.text.trim(),
          professorId: professor.id,
          context: context,
        );

        // Se o aluno foi cadastrado com sucesso e há agendamentos
        if (alunoId != null && _agendamentos.isNotEmpty) {
          // Criar as aulas agendadas
          for (final agendamento in _agendamentos) {
            await _aulaController.criarAula(
              professorId: professor.id,
              alunoId: alunoId,
              diaSemana: agendamento['dia'],
              horario: agendamento['horario'],
            );
          }
        }
      }
    }
  }

  void _adicionarAgendamento() {
    if (_diaSelecionado != null && _horarioSelecionado != null) {
      final horarioFormatado =
          '${_horarioSelecionado!.hour.toString().padLeft(2, '0')}:${_horarioSelecionado!.minute.toString().padLeft(2, '0')}';

      // Verificar se já existe este agendamento
      final jaExiste = _agendamentos.any((agendamento) =>
          agendamento['dia'] == _diaSelecionado &&
          agendamento['horario'] == horarioFormatado);

      if (!jaExiste) {
        setState(() {
          _agendamentos.add({
            'dia': _diaSelecionado!,
            'horario': horarioFormatado,
            'nomeDia': AulaController.diasSemana
                .firstWhere((dia) => dia['valor'] == _diaSelecionado)['nome'],
          });
          _diaSelecionado = null;
          _horarioSelecionado = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este horário já foi adicionado'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _removerAgendamento(int index) {
    setState(() {
      _agendamentos.removeAt(index);
    });
  }

  Future<void> _selecionarHorario() async {
    final TimeOfDay? horario = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (horario != null) {
      setState(() {
        _horarioSelecionado = horario;
      });
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
                        const SizedBox(height: 32),

                        // Seção de Agendamento de Aulas
                        const Divider(),
                        const Text(
                          'Agendamento de Aulas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Seleção de dia e horário
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _diaSelecionado,
                                decoration: const InputDecoration(
                                  labelText: 'Dia da Semana',
                                  border: OutlineInputBorder(),
                                ),
                                items: AulaController.diasSemana
                                    .map((dia) => DropdownMenuItem<int>(
                                          value: dia['valor'],
                                          child: Text(dia['nome']),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _diaSelecionado = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: _selecionarHorario,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _horarioSelecionado != null
                                            ? '${_horarioSelecionado!.hour.toString().padLeft(2, '0')}:${_horarioSelecionado!.minute.toString().padLeft(2, '0')}'
                                            : 'Selecionar horário',
                                        style: TextStyle(
                                          color: _horarioSelecionado != null
                                              ? Colors.black
                                              : Colors.grey[600],
                                        ),
                                      ),
                                      const Icon(Icons.schedule),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Botão para adicionar agendamento
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _adicionarAgendamento,
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar Horário'),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Lista de agendamentos
                        if (_agendamentos.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Horários Agendados:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ...List.generate(_agendamentos.length, (index) {
                                  final agendamento = _agendamentos[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${agendamento['nomeDia']} - ${agendamento['horario']}',
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              _removerAgendamento(index),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
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
