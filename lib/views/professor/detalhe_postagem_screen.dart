/// Tela para visualizar e editar detalhes de uma postagem
///
/// Permite ao professor:
/// - Visualizar detalhes completos da postagem
/// - Ver lista de alunos destinatários
/// - Editar título, conteúdo e matéria
/// - Adicionar/remover alunos da postagem
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/postagem_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/postagem_model.dart';
import '../../models/user_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../utils/validation_utils.dart';

class DetalhePostagemScreen extends StatefulWidget {
  final PostagemModel postagem;

  const DetalhePostagemScreen({
    super.key,
    required this.postagem,
  });

  @override
  State<DetalhePostagemScreen> createState() => _DetalhePostagemScreenState();
}

class _DetalhePostagemScreenState extends State<DetalhePostagemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _conteudoController = TextEditingController();

  String _materiaSelecionada = '';
  List<String> _alunosSelecionados = [];
  List<UserModel> _todosAlunos = [];
  List<UserModel> _alunosNaPostagem = [];
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _inicializarDados();
  }

  void _inicializarDados() {
    _tituloController.text = widget.postagem.titulo;
    _conteudoController.text = widget.postagem.conteudo;
    _materiaSelecionada = widget.postagem.materia;
    _alunosSelecionados = List.from(widget.postagem.alunosDestino);
    _carregarAlunos();
  }

  Future<void> _carregarAlunos() async {
    final userController = context.read<UserController>();

    // Usar stream para obter alunos do professor atual
    final professor = userController.user;
    if (professor != null) {
      userController.getAlunosDoProfessor(professor.id).listen((alunos) {
        if (mounted) {
          setState(() {
            _todosAlunos = alunos;
            _alunosNaPostagem = _todosAlunos
                .where((aluno) => _alunosSelecionados.contains(aluno.id))
                .toList();
          });
        }
      });
    }
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;

    if (_alunosSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos um aluno'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final postagemController = context.read<PostagemController>();

    final postagemAtualizada = widget.postagem.copyWith(
      titulo: _tituloController.text.trim(),
      conteudo: _conteudoController.text.trim(),
      materia: _materiaSelecionada,
      alunosDestino: _alunosSelecionados,
    );

    final sucesso =
        await postagemController.atualizarPostagem(postagemAtualizada);

    setState(() => _isLoading = false);

    if (mounted) {
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Postagem atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${postagemController.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostrarSeletorAlunos() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Selecionar Alunos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _todosAlunos.length,
                  itemBuilder: (context, index) {
                    final aluno = _todosAlunos[index];
                    final isSelected = _alunosSelecionados.contains(aluno.id);

                    return CheckboxListTile(
                      title: Text(aluno.nome),
                      subtitle: Text(aluno.email),
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _alunosSelecionados.add(aluno.id);
                          } else {
                            _alunosSelecionados.remove(aluno.id);
                          }
                          _alunosNaPostagem = _todosAlunos
                              .where((a) => _alunosSelecionados.contains(a.id))
                              .toList();
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Confirmar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Postagem' : 'Detalhes da Postagem'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing
                ? _salvarAlteracoes
                : () => setState(() => _isEditing = true),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informações da postagem
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.post_add, color: Colors.blue[700]),
                                const SizedBox(width: 8),
                                const Text(
                                  'Informações da Postagem',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Título
                            AppTextField(
                              controller: _tituloController,
                              label: 'Título',
                              enabled: _isEditing,
                              validator: (value) {
                                final error =
                                    ValidationUtils.getTitleErrorMessage(
                                        value ?? '');
                                return error.isEmpty ? null : error;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Matéria
                            DropdownButtonFormField<String>(
                              initialValue: _materiaSelecionada,
                              decoration: const InputDecoration(
                                labelText: 'Matéria',
                                border: OutlineInputBorder(),
                              ),
                              items: PostagemModel.materiasDisponiveis
                                  .map((materia) => DropdownMenuItem(
                                        value: materia['valor'],
                                        child: Text(materia['nome']!),
                                      ))
                                  .toList(),
                              onChanged: _isEditing
                                  ? (value) {
                                      setState(
                                          () => _materiaSelecionada = value!);
                                    }
                                  : null,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Selecione uma matéria';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Conteúdo
                            TextFormField(
                              controller: _conteudoController,
                              decoration: const InputDecoration(
                                labelText: 'Conteúdo',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 5,
                              enabled: _isEditing,
                              validator: (value) {
                                final error =
                                    ValidationUtils.getContentErrorMessage(
                                        value ?? '');
                                return error.isEmpty ? null : error;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Data de criação
                            Row(
                              children: [
                                Icon(Icons.schedule,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  'Criado em: ${widget.postagem.dataFormatada}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Alunos destinatários
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.people, color: Colors.blue[700]),
                                const SizedBox(width: 8),
                                const Text(
                                  'Alunos Destinatários',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                if (_isEditing)
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: _mostrarSeletorAlunos,
                                    tooltip: 'Editar alunos',
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_alunosNaPostagem.isEmpty)
                              const Text(
                                'Nenhum aluno selecionado',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            else
                              ...(_alunosNaPostagem.map((aluno) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Colors.blue[100],
                                          child: Text(
                                            aluno.nome[0].toUpperCase(),
                                            style: TextStyle(
                                              color: Colors.blue[700],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                aluno.nome,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                aluno.email,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      size: 16, color: Colors.blue[700]),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_alunosNaPostagem.length} ${_alunosNaPostagem.length == 1 ? 'aluno selecionado' : 'alunos selecionados'}',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_isEditing) ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _inicializarDados(); // Restaurar dados originais
                                });
                              },
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              label: 'Salvar Alterações',
                              onPressed: _isLoading ? () {} : _salvarAlteracoes,
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

  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    super.dispose();
  }
}
