/// widget para exibir os alunos do professor
library;

import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final String nome;
  final String email;
  final VoidCallback? onTap;
  final Widget? trailing;

  const UserCard({
    super.key,
    required this.nome,
    required this.email,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(nome),
        subtitle: Text(email),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
