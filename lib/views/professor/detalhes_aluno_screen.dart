import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/aula_controller.dart';
import '../../models/user_model.dart';
import '../../models/aula_model.dart';
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

  // Controladores para aulas
  late AulaController _aulaController;
  List<AulaModel> _aulasDoAluno = [];
  bool _isLoadingAulas = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.aluno.nome);
    _emailController = TextEditingController(text: widget.aluno.email);
    _senhaController = TextEditingController();
    _aulaController = AulaController();
    _carregarAulasDoAluno();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _aulaController.dispose();
    super.dispose();
  }

  Future<void> _carregarAulasDoAluno() async {
    setState(() {
      _isLoadingAulas = true;
    });

    try {
      debugPrint('Carregando aulas para o aluno: ${widget.aluno.id}');
      await _aulaController.carregarAulasAluno(widget.aluno.id);
      setState(() {
        _aulasDoAluno = _aulaController.aulas;
        _isLoadingAulas = false;
      });
      debugPrint('Aulas carregadas: ${_aulasDoAluno.length}');
    } catch (e) {
      debugPrint('Erro ao carregar aulas: $e');
      setState(() {
        _isLoadingAulas = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar aulas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _adicionarNovaAula() async {
    final userController = context.read<UserController>();
    final professor = userController.user;

    if (professor == null) return;

    showDialog(
      context: context,
      builder: (context) => _DialogAdicionarAula(
        professorId: professor.id,
        alunoId: widget.aluno.id,
        onAulaAdicionada: () {
          _carregarAulasDoAluno();
        },
      ),
    );
  }

  Future<void> _editarAula(AulaModel aula) async {
    showDialog(
      context: context,
      builder: (context) => _DialogEditarAula(
        aula: aula,
        onAulaAtualizada: () {
          _carregarAulasDoAluno();
        },
      ),
    );
  }

  Future<void> _excluirAula(AulaModel aula) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja remover a aula de ${aula.nomeDiaSemana} às ${aula.horario}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmacao == true) {
      final sucesso = await _aulaController.removerAula(
        aula.id,
        aula.professorId,
      );

      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aula removida com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _carregarAulasDoAluno();
      }
    }
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
      await userController.atualizarAluno(
          widget.aluno.id, dadosAtualizados, context);
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
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
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

              // Seção de Horários de Aula
              const SizedBox(height: 32),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Horários de Aula',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _adicionarNovaAula,
                    tooltip: 'Adicionar novo horário',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_isLoadingAulas)
                const Center(child: CircularProgressIndicator())
              else if (_aulasDoAluno.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.schedule_outlined, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Nenhum horário de aula cadastrado',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                ...List.generate(_aulasDoAluno.length, (index) {
                  final aula = _aulasDoAluno[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          aula.nomeDiaAbreviado,
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(aula.nomeDiaSemana),
                      subtitle: Text('Horário: ${aula.horario}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'editar') {
                            _editarAula(aula);
                          } else if (value == 'excluir') {
                            _excluirAula(aula);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'editar',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'excluir',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Excluir'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

// Dialog para adicionar nova aula
class _DialogAdicionarAula extends StatefulWidget {
  final String professorId;
  final String alunoId;
  final VoidCallback onAulaAdicionada;

  const _DialogAdicionarAula({
    required this.professorId,
    required this.alunoId,
    required this.onAulaAdicionada,
  });

  @override
  State<_DialogAdicionarAula> createState() => _DialogAdicionarAulaState();
}

class _DialogAdicionarAulaState extends State<_DialogAdicionarAula> {
  final AulaController _aulaController = AulaController();
  int? _diaSelecionado;
  TimeOfDay? _horarioSelecionado;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Horário de Aula'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            initialValue: _diaSelecionado,
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
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _selecionarHorario,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _salvarAula,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Adicionar'),
        ),
      ],
    );
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

  Future<void> _salvarAula() async {
    if (_diaSelecionado == null || _horarioSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione o dia e horário'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final horarioFormatado =
        '${_horarioSelecionado!.hour.toString().padLeft(2, '0')}:${_horarioSelecionado!.minute.toString().padLeft(2, '0')}';

    final sucesso = await _aulaController.criarAula(
      professorId: widget.professorId,
      alunoId: widget.alunoId,
      diaSemana: _diaSelecionado!,
      horario: horarioFormatado,
    );

    setState(() {
      _isLoading = false;
    });

    if (sucesso && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Horário adicionado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onAulaAdicionada();
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_aulaController.errorMessage.isNotEmpty
              ? _aulaController.errorMessage
              : 'Erro ao adicionar horário'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _aulaController.dispose();
    super.dispose();
  }
}

// Dialog para editar aula existente
class _DialogEditarAula extends StatefulWidget {
  final AulaModel aula;
  final VoidCallback onAulaAtualizada;

  const _DialogEditarAula({
    required this.aula,
    required this.onAulaAtualizada,
  });

  @override
  State<_DialogEditarAula> createState() => _DialogEditarAulaState();
}

class _DialogEditarAulaState extends State<_DialogEditarAula> {
  final AulaController _aulaController = AulaController();
  late int _diaSelecionado;
  late TimeOfDay _horarioSelecionado;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _diaSelecionado = widget.aula.diaSemana;
    final horarioParts = widget.aula.horario.split(':');
    _horarioSelecionado = TimeOfDay(
      hour: int.parse(horarioParts[0]),
      minute: int.parse(horarioParts[1]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Horário de Aula'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            initialValue: _diaSelecionado,
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
                _diaSelecionado = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _selecionarHorario,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_horarioSelecionado.hour.toString().padLeft(2, '0')}:${_horarioSelecionado.minute.toString().padLeft(2, '0')}',
                  ),
                  const Icon(Icons.schedule),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _salvarAlteracoes,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _selecionarHorario() async {
    final TimeOfDay? horario = await showTimePicker(
      context: context,
      initialTime: _horarioSelecionado,
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

  Future<void> _salvarAlteracoes() async {
    setState(() {
      _isLoading = true;
    });

    final horarioFormatado =
        '${_horarioSelecionado.hour.toString().padLeft(2, '0')}:${_horarioSelecionado.minute.toString().padLeft(2, '0')}';

    final aulaAtualizada = widget.aula.copyWith(
      diaSemana: _diaSelecionado,
      horario: horarioFormatado,
    );

    final sucesso = await _aulaController.atualizarAula(aulaAtualizada);

    setState(() {
      _isLoading = false;
    });

    if (sucesso && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Horário atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onAulaAtualizada();
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_aulaController.errorMessage.isNotEmpty
              ? _aulaController.errorMessage
              : 'Erro ao atualizar horário'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _aulaController.dispose();
    super.dispose();
  }
}
