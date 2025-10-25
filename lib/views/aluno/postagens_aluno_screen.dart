/// Tela principal do aluno com as postagens organizadas por matéria
///
/// Mostra as postagens recebidas do professor organizadas em cards
/// por matéria, substituindo o cronograma como tela inicial
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/postagem_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/postagem_model.dart';
import '../../models/user_model.dart';
import 'detalhes_postagem_screen.dart';

class PostagensAlunoScreen extends StatefulWidget {
  const PostagensAlunoScreen({super.key});

  @override
  State<PostagensAlunoScreen> createState() => _PostagensAlunoScreenState();
}

class _PostagensAlunoScreenState extends State<PostagensAlunoScreen> {
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
      await postagemController.carregarPostagensAgrupadasPorMateria(usuario.id);
    }
  }

  Future<void> _recarregarPostagens() async {
    await _carregarPostagens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postagens'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _recarregarPostagens,
          ),
        ],
      ),
      body: Consumer2<PostagemController, UserController>(
        builder: (context, postagemController, userController, child) {
          final aluno = userController.user;

          return Column(
            children: [
              // Seção de Bem-vindo
              if (aluno != null) _buildWelcomeSection(aluno),

              // Conteúdo principal
              Expanded(
                child: _buildMainContent(postagemController),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(UserModel aluno) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Icon(
              Icons.person,
              size: 35,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo, ${aluno.nome.split(' ').first}!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Confira suas postagens e atualizações',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.school,
            size: 32,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(PostagemController postagemController) {
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
              onPressed: _recarregarPostagens,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final postagensAgrupadas = postagemController.postagensAgrupadas;

    if (postagensAgrupadas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhuma postagem encontrada',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Aguarde novas postagens do seu professor',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _recarregarPostagens,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: postagensAgrupadas.length,
        itemBuilder: (context, index) {
          final materia = postagensAgrupadas.keys.elementAt(index);
          final postagens = postagensAgrupadas[materia]!;
          final materiaInfo = PostagemModel.materiasDisponiveis
              .firstWhere((m) => m['valor'] == materia);

          return _buildMateriaSection(
            materia: materiaInfo['nome']!,
            postagens: postagens,
          );
        },
      ),
    );
  }

  Widget _buildMateriaSection({
    required String materia,
    required List<PostagemModel> postagens,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da matéria
            Row(
              children: [
                _getIconeMateria(materia),
                const SizedBox(width: 8),
                Text(
                  materia,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Spacer(),
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
                    '${postagens.length}',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista de postagens
            ...postagens.map((postagem) => _buildPostagemCard(postagem)),
          ],
        ),
      ),
    );
  }

  Widget _buildPostagemCard(PostagemModel postagem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(
            Icons.article,
            color: Colors.blue.shade700,
          ),
        ),
        title: Text(
          postagem.titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              postagem.conteudo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  postagem.dataFormatada,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (postagem.temAnexos) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.attach_file,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Anexos',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalhesPostagemScreen(
                postagem: postagem,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getIconeMateria(String materia) {
    IconData icone;
    switch (materia.toLowerCase()) {
      case 'matemática':
        icone = Icons.calculate;
        break;
      case 'português':
        icone = Icons.menu_book;
        break;
      case 'história':
        icone = Icons.history_edu;
        break;
      case 'geografia':
        icone = Icons.public;
        break;
      case 'ciência':
        icone = Icons.science;
        break;
      default:
        icone = Icons.school;
    }

    return Icon(
      icone,
      color: Colors.blue,
      size: 24,
    );
  }
}
