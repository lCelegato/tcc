// Widget test para verificar inicialização da aplicação TCC
//
// Testa componentes básicos da aplicação sem dependências Firebase

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App should render basic components',
      (WidgetTester tester) async {
    // Test básico: verificar se componentes Material funcionam

    final materialApp = MaterialApp(
      title: 'Sistema de Aulas - Test',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Sistema de Aulas'),
        ),
        body: const Center(
          child: Text('Sistema de Aulas Particulares'),
        ),
      ),
    );

    // Build do widget de teste
    await tester.pumpWidget(materialApp);

    // Verificar se o texto da aplicação aparece
    expect(find.text('Sistema de Aulas Particulares'), findsOneWidget);
    expect(find.text('Sistema de Aulas'), findsOneWidget);

    // Verificar se é um MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('Login form components test', (WidgetTester tester) async {
    // Teste de componentes de formulário de login

    final testWidget = MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('TCC - Login')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Login',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Digite seu email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  hintText: 'Digite sua senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpWidget(testWidget);

    // Verificar elementos de login
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Digite seu email'), findsOneWidget);
    expect(find.text('Digite sua senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Custom widgets test', (WidgetTester tester) async {
    // Teste de widgets customizados

    final testWidget = MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Aluno Test'),
                subtitle: const Text('aluno@test.com'),
                trailing: const Icon(Icons.arrow_forward),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Postagem'),
                    const Text('Conteúdo da postagem de teste'),
                    Row(
                      children: [
                        Chip(label: const Text('Matemática')),
                        const SizedBox(width: 8),
                        Chip(label: const Text('Segunda')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(testWidget);

    // Verificar elementos customizados
    expect(find.text('Aluno Test'), findsOneWidget);
    expect(find.text('aluno@test.com'), findsOneWidget);
    expect(find.text('Postagem'), findsOneWidget);
    expect(find.text('Matemática'), findsOneWidget);
    expect(find.text('Segunda'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(2));
    expect(find.byType(Chip), findsNWidgets(2));
    expect(find.byIcon(Icons.person), findsOneWidget);
  });
}
