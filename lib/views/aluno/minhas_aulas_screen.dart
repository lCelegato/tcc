/// Tela para o aluno visualizar suas aulas agendadas
///
/// Funcionalidades:
/// - Ver cronograma semanal de aulas
/// - Visualizar horários organizados por dia
/// - Interface simples e clara
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/aula_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/aula_model.dart';

class MinhasAulasScreen extends StatefulWidget {
  const MinhasAulasScreen({super.key});

  @override
  State<MinhasAulasScreen> createState() => _MinhasAulasScreenState();
}

class _MinhasAulasScreenState extends State<MinhasAulasScreen> {
  @override
  void initState() {
    super.initState();
    _carregarAulas();
  }

  void _carregarAulas() {
    final userController = Provider.of<UserController>(context, listen: false);
    final aulaController = Provider.of<AulaController>(context, listen: false);
    final aluno = userController.user;
    if (aluno != null) {
      aulaController.carregarAulasAluno(aluno.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Aulas'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
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
                  Text(
                    controller.errorMessage,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _carregarAulas,
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          final aulasPorDia = controller.agruparAulasPorDia();

          return aulasPorDia.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma aula agendada',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Entre em contato com seu professor',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: _construirCronogramaSemanal(aulasPorDia),
                );
        },
      ),
    );
  }

  List<Widget> _construirCronogramaSemanal(
      Map<int, List<AulaModel>> aulasPorDia) {
    final widgets = <Widget>[];

    // Adicionar título
    widgets.add(
      const Padding(
        padding: EdgeInsets.only(bottom: 24),
        child: Text(
          'Cronograma Semanal',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );

    // Percorrer todos os dias da semana (1-7)
    for (int dia = 1; dia <= 7; dia++) {
      final aulas = aulasPorDia[dia] ?? [];
      final nomeDia = AulaController.diasSemana
          .firstWhere((d) => d['valor'] == dia)['nome'];
      final abrevDia = AulaController.diasSemana
          .firstWhere((d) => d['valor'] == dia)['abrev'];

      widgets.add(
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: aulas.isNotEmpty ? 4 : 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: aulas.isNotEmpty
                  ? Border.all(color: Colors.green, width: 2)
                  : null,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor:
                    aulas.isNotEmpty ? Colors.green : Colors.grey[300],
                child: Text(
                  abrevDia,
                  style: TextStyle(
                    color: aulas.isNotEmpty ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                nomeDia,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: aulas.isEmpty
                  ? const Text('Sem aulas agendadas')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: aulas
                          .map((aula) => Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule,
                                      size: 16,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      aula.horario,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '• ${aula.titulo}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
              trailing: aulas.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${aulas.length} ${aulas.length == 1 ? 'aula' : 'aulas'}',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),
      );
    }

    // Adicionar resumo no final
    final totalAulas = aulasPorDia.values.expand((aulas) => aulas).length;

    if (totalAulas > 0) {
      widgets.add(
        Container(
          margin: const EdgeInsets.only(top: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'Total: $totalAulas ${totalAulas == 1 ? 'aula por semana' : 'aulas por semana'}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  @override
  void dispose() {
    // Não precisa mais do dispose pois usa Provider global
    super.dispose();
  }
}
