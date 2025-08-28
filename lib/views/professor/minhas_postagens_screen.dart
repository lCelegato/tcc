/// Tela para o professor visualizar e gerenciar suas postagens
///
/// Permite visualizar todas as postagens criadas,
/// criar novas e gerenciar as existentes
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/postagem_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/postagem_model.dart';
import 'criar_postagem_screen.dart';
import 'detalhe_postagem_screen.dart';

class MinhasPostagensScreen extends StatefulWidget {
  const MinhasPostagensScreen({super.key});

  @override
  State<MinhasPostagensScreen> createState() => _MinhasPostagensScreenState();
}

class _MinhasPostagensScreenState extends State<MinhasPostagensScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarPostagens();
    });
  }

  Future<void> _carregarPostagens() async {
    final userController = context.read<UserController>();
    final postagemController = context.read<PostagemController>();
    final usuario = userController.user;

    if (usuario != null) {
      await postagemController.carregarPostagensProfessor(usuario.id);
    }
  }

  Future<void> _criarNovaPostagem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CriarPostagemScreen(),
      ),
    );

    if (result == true) {
      _carregarPostagens();
    }
  }

  Future<void> _editarPostagem(PostagemModel postagem) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhePostagemScreen(postagem: postagem),
      ),
    );

    if (result == true) {
      _carregarPostagens();
    }
  }

  Future<void> _confirmarRemocao(PostagemModel postagem) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar remoção'),
        content: Text('Deseja remover a postagem "${postagem.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      if (!mounted) return;
      final userController = context.read<UserController>();
      final postagemController = context.read<PostagemController>();
      final usuario = userController.user;

      if (usuario != null) {
        final sucesso = await postagemController.removerPostagem(
          postagem.id,
          usuario.id,
        );

        if (mounted) {
          if (sucesso) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Postagem removida com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Erro ao remover postagem: ${postagemController.errorMessage}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Postagens'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              final userController = context.read<UserController>();
              final usuario = userController.user;
              if (usuario != null) {
                debugPrint('DEBUG: Professor ID: ${usuario.id}');
                debugPrint('DEBUG: Tipo de usuário: ${usuario.tipo}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Debug: Professor ID: ${usuario.id}'),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarPostagens,
          ),
        ],
      ),
      body: Consumer<PostagemController>(
        builder: (context, postagemController, child) {
          if (postagemController.state == PostagemState.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (postagemController.state == PostagemState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar postagens',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(postagemController.errorMessage),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _carregarPostagens,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final postagens = postagemController.postagens;

          if (postagens.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.post_add,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhuma postagem criada',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crie sua primeira postagem!',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _criarNovaPostagem,
                    icon: const Icon(Icons.add),
                    label: const Text('Criar Postagem'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _carregarPostagens,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: postagens.length,
              itemBuilder: (context, index) {
                final postagem = postagens[index];
                return _buildPostagemCard(postagem);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _criarNovaPostagem,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPostagemCard(PostagemModel postagem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _editarPostagem(postagem),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      postagem.nomeMateria,
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    postagem.dataFormatada,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'remover') {
                        _confirmarRemocao(postagem);
                      } else if (value == 'editar') {
                        _editarPostagem(postagem);
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
                ],
              ),
              const SizedBox(height: 12),

              // Título
              Text(
                postagem.titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Conteúdo (preview)
              Text(
                postagem.conteudo,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),

              // Informações adicionais
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${postagem.alunosDestino.length} ${postagem.alunosDestino.length == 1 ? 'aluno' : 'alunos'}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  if (postagem.temAnexos) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.attach_file,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Anexos',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
