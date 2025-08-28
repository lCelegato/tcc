/// Tela do cronograma de aulas do aluno
///
/// Agora será uma aba separada, não mais a tela inicial
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/aula_controller.dart';
import '../../controllers/user_controller.dart';

class CronogramaAlunoScreen extends StatefulWidget {
  const CronogramaAlunoScreen({super.key});

  @override
  State<CronogramaAlunoScreen> createState() => _CronogramaAlunoScreenState();
}

class _CronogramaAlunoScreenState extends State<CronogramaAlunoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarAulas();
    });
  }

  Future<void> _carregarAulas() async {
    if (!mounted) return;

    final userController = context.read<UserController>();
    final aulaController = context.read<AulaController>();
    final usuario = userController.user;

    if (usuario != null) {
      await aulaController.carregarAulasAluno(usuario.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cronograma'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarAulas,
          ),
        ],
      ),
      body: Consumer<AulaController>(
        builder: (context, aulaController, child) {
          if (aulaController.state == AulaState.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (aulaController.state == AulaState.error) {
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
                    'Erro ao carregar cronograma',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(aulaController.errorMessage),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _carregarAulas,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final aulasPorDia = aulaController.agruparAulasPorDia();

          if (aulasPorDia.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma aula agendada',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Entre em contato com seu professor',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _carregarAulas,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: AulaController.diasSemana.length,
              itemBuilder: (context, index) {
                final dia = AulaController.diasSemana[index];
                final aulas = aulasPorDia[dia['valor']] ?? [];

                return _buildDiaCard(
                  dia: dia['nome']!,
                  abrev: dia['abrev']!,
                  aulas: aulas,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiaCard({
    required String dia,
    required String abrev,
    required List aulas,
  }) {
    final temAulas = aulas.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do dia
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: temAulas ? Colors.blue : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      abrev,
                      style: TextStyle(
                        color: temAulas ? Colors.white : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dia,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (temAulas)
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
                      '${aulas.length} ${aulas.length == 1 ? 'aula' : 'aulas'}',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            if (temAulas) ...[
              const SizedBox(height: 12),
              ...aulas.map((aula) => _buildAulaItem(aula)),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'Nenhuma aula agendada',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAulaItem(dynamic aula) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: Colors.blue.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            aula.horario,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Aula particular',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
