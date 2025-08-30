/// Tela para o professor criar novas postagens
///
/// Permite ao professor:
/// - Criar postagens com título, conteúdo e matéria
/// - Selecionar alunos destinatários
/// - Adicionar anexos (futuramente)
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/postagem_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/postagem_model.dart';
import '../../models/user_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/image_manager_widget.dart';
import '../../widgets/documento_manager_widget.dart';

class CriarPostagemScreen extends StatefulWidget {
  const CriarPostagemScreen({super.key});

  @override
  State<CriarPostagemScreen> createState() => _CriarPostagemScreenState();
}

class _CriarPostagemScreenState extends State<CriarPostagemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _conteudoController = TextEditingController();

  String? _materiaSelecionada;
  final List<String> _alunosSelecionados = [];
  final List<String> _imagensSelecionadas = [];
  final List<Map<String, dynamic>> _documentosSelecionados = [];
  List<UserModel> _alunosDisponiveis = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarAlunos();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    super.dispose();
  }

  Future<void> _carregarAlunos() async {
    final userController = context.read<UserController>();
    final usuario = userController.user;

    if (usuario != null) {
      // Usar o stream para obter os alunos do professor
      userController.getAlunosDoProfessor(usuario.id).listen((alunos) {
        if (mounted) {
          setState(() {
            _alunosDisponiveis = alunos;
          });
        }
      });
    }
  }

  void _criarPostagem() async {
    if (!_formKey.currentState!.validate()) return;
    if (_materiaSelecionada == null) {
      _mostrarErro('Selecione uma matéria');
      return;
    }
    if (_alunosSelecionados.isEmpty) {
      _mostrarErro('Selecione pelo menos um aluno');
      return;
    }

    setState(() => _isLoading = true);

    final userController = context.read<UserController>();
    final postagemController = context.read<PostagemController>();
    final usuario = userController.user;

    if (usuario == null) {
      _mostrarErro('Usuário não encontrado');
      setState(() => _isLoading = false);
      return;
    }

    final sucesso = await postagemController.criarPostagem(
      professorId: usuario.id,
      titulo: _tituloController.text.trim(),
      conteudo: _conteudoController.text.trim(),
      materia: _materiaSelecionada!,
      alunosDestino: _alunosSelecionados,
      imagens: _imagensSelecionadas.isNotEmpty ? _imagensSelecionadas : null,
      documentos:
          _documentosSelecionados.isNotEmpty ? _documentosSelecionados : null,
    );

    setState(() => _isLoading = false);

    if (sucesso) {
      _mostrarSucesso('Postagem criada com sucesso!');
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      _mostrarErro(postagemController.errorMessage);
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _mostrarSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Postagem'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite um título';
                }
                if (value.trim().length < 3) {
                  return 'Título deve ter pelo menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Matéria
            DropdownButtonFormField<String>(
              initialValue: _materiaSelecionada,
              decoration: const InputDecoration(
                labelText: 'Matéria',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.subject),
              ),
              items: PostagemModel.materiasDisponiveis
                  .map((materia) => DropdownMenuItem<String>(
                        value: materia['valor'],
                        child: Text(materia['nome']!),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _materiaSelecionada = value;
                });
              },
              validator: (value) {
                if (value == null) {
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
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite o conteúdo';
                }
                if (value.trim().length < 10) {
                  return 'Conteúdo deve ter pelo menos 10 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Seção de documentos
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DocumentoManagerWidget(
                  documentos: _documentosSelecionados,
                  onDocumentosChanged: (novosDocumentos) {
                    setState(() {
                      _documentosSelecionados.clear();
                      _documentosSelecionados.addAll(novosDocumentos);
                    });
                  },
                  podeEditar: true,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Seção de imagens
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ImageManagerWidget(
                  imagensExistentes: _imagensSelecionadas,
                  onImagensChanged: (novasImagens) {
                    setState(() {
                      _imagensSelecionadas.clear();
                      _imagensSelecionadas.addAll(novasImagens);
                    });
                  },
                  isEditing: true,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Seleção de alunos
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selecionar Alunos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_alunosDisponiveis.isEmpty)
                      const Text('Nenhum aluno encontrado')
                    else
                      Column(
                        children: _alunosDisponiveis.map((aluno) {
                          final isSelected =
                              _alunosSelecionados.contains(aluno.id);
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
                              });
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botões
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton(
                    label: 'Publicar',
                    onPressed: _isLoading ? () {} : _criarPostagem,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
