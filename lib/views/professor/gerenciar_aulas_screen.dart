/// Tela para o professor gerenciar todas as aulas agendadas
///
/// Funcionalidades:
/// - Visualizar todas as aulas organizadas por dia da semana
/// - Editar horários das aulas
/// - Remover aulas do cronograma
/// - Buscar aulas por aluno
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/aula_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/aula_model.dart';

class GerenciarAulasScreen extends StatefulWidget {
  const GerenciarAulasScreen({super.key});

  @override
  State<GerenciarAulasScreen> createState() => _GerenciarAulasScreenState();
}

class _GerenciarAulasScreenState extends State<GerenciarAulasScreen> {
  String _filtroAluno = '';
  final Map<String, String> _nomesAlunos = {}; // Cache para nomes dos alunos

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarAulas();
      _carregarNomesAlunos();
    });
  }

  void _carregarAulas() {
    final userController = context.read<UserController>();
    final aulaController = context.read<AulaController>();
    final professor = userController.user;
    if (professor != null) {
      aulaController.carregarAulasProfessor(professor.id);
      // Recarregar nomes também
      _carregarNomesAlunos();
    }
  }

  // Carrega todos os nomes dos alunos do professor de uma vez
  void _carregarNomesAlunos() {
    final userController = context.read<UserController>();
    if (userController.user?.id != null) {
      userController
          .getAlunosDoProfessor(userController.user!.id)
          .listen((alunos) {
        if (mounted) {
          setState(() {
            for (final aluno in alunos) {
              _nomesAlunos[aluno.id] = aluno.nome;
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Aulas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarAulas,
          ),
        ],
      ),
      body: Consumer<AulaController>(
        builder: (context, controller, child) {
          if (controller.state == AulaState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.state == AulaState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(controller.errorMessage),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _carregarAulas,
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          final aulasFiltradas = _filtrarAulas(controller.aulas);
          final aulasPorDia = _agruparAulasPorDia(aulasFiltradas);

          return Column(
            children: [
              // Filtro
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por nome do aluno',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _filtroAluno = value.toLowerCase();
                    });
                  },
                ),
              ),

              // Lista de aulas
              Expanded(
                child: aulasPorDia.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.schedule,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma aula agendada',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: _construirListaDias(aulasPorDia),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<AulaModel> _filtrarAulas(List<AulaModel> aulas) {
    if (_filtroAluno.isEmpty) return aulas;

    return aulas.where((aula) {
      // Vamos filtrar pelo nome do aluno se estiver disponível no cache, senão pelo ID
      final nomeAluno = _nomesAlunos[aula.alunoId] ?? aula.alunoId;
      return nomeAluno.toLowerCase().contains(_filtroAluno);
    }).toList();
  }

  Map<int, List<AulaModel>> _agruparAulasPorDia(List<AulaModel> aulas) {
    final Map<int, List<AulaModel>> aulasPorDia = {};

    for (final aula in aulas) {
      if (!aulasPorDia.containsKey(aula.diaSemana)) {
        aulasPorDia[aula.diaSemana] = [];
      }
      aulasPorDia[aula.diaSemana]!.add(aula);
    }

    // Ordenar aulas dentro de cada dia por horário
    aulasPorDia.forEach((dia, aulas) {
      aulas.sort((a, b) => a.horario.compareTo(b.horario));
    });

    return aulasPorDia;
  }

  List<Widget> _construirListaDias(Map<int, List<AulaModel>> aulasPorDia) {
    final widgets = <Widget>[];
    final diasOrdenados = aulasPorDia.keys.toList()..sort();

    for (final dia in diasOrdenados) {
      final aulas = aulasPorDia[dia]!;
      final nomeDia = AulaController.diasSemana
          .firstWhere((d) => d['valor'] == dia)['nome'];

      widgets.add(
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(
              '$nomeDia (${aulas.length} aulas)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: const Icon(Icons.calendar_today),
            children: aulas.map((aula) => _construirItemAula(aula)).toList(),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _construirItemAula(AulaModel aula) {
    // Buscar nome do aluno do cache
    final nomeAluno = _nomesAlunos[aula.alunoId] ?? 'Carregando...';

    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      title: Text(aula.titulo),
      subtitle: Text('Aluno: $nomeAluno • Horário: ${aula.horario}'),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _acaoAula(value, aula),
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
            value: 'remover',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Remover'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _acaoAula(String acao, AulaModel aula) {
    switch (acao) {
      case 'editar':
        _editarAula(aula);
        break;
      case 'remover':
        _confirmarRemocao(aula);
        break;
    }
  }

  void _editarAula(AulaModel aula) {
    showDialog(
      context: context,
      builder: (context) => _DialogEditarAula(
        aula: aula,
        onAtualizarAula: (aulaAtualizada) async {
          final aulaController = context.read<AulaController>();
          final sucesso = await aulaController.atualizarAula(aulaAtualizada);
          if (sucesso && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Aula atualizada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            // Recarregar aulas
            _carregarAulas();
          }
        },
      ),
    );
  }

  void _confirmarRemocao(AulaModel aula) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Remoção'),
        content: Text(
          'Deseja remover a aula de ${aula.nomeDiaSemana} às ${aula.horario}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final aulaController = context.read<AulaController>();
              final sucesso = await aulaController.removerAula(
                aula.id,
                aula.professorId,
              );
              if (sucesso && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Aula removida com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Recarregar aulas
                _carregarAulas();
              }
            },
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Não precisa mais do dispose pois usa Provider global
}

class _DialogEditarAula extends StatefulWidget {
  final AulaModel aula;
  final Function(AulaModel) onAtualizarAula;

  const _DialogEditarAula({
    required this.aula,
    required this.onAtualizarAula,
  });

  @override
  State<_DialogEditarAula> createState() => _DialogEditarAulaState();
}

class _DialogEditarAulaState extends State<_DialogEditarAula> {
  late int _diaSelecionado;
  late TimeOfDay _horarioSelecionado;

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
      title: const Text('Editar Aula'),
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            final horarioFormatado =
                '${_horarioSelecionado.hour.toString().padLeft(2, '0')}:${_horarioSelecionado.minute.toString().padLeft(2, '0')}';

            final aulaAtualizada = widget.aula.copyWith(
              diaSemana: _diaSelecionado,
              horario: horarioFormatado,
            );

            widget.onAtualizarAula(aulaAtualizada);
            Navigator.of(context).pop();
          },
          child: const Text('Salvar'),
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
}
