/// Serviço responsável por operações CRUD de usuários no Firestore.
/// Separe cada domínio em um service diferente se o projeto crescer.
/// 
/// Funcionalidades:
/// 1. Operações CRUD:
///    - Criar perfil de usuário
///      Exemplo: await userService.createUserProfile(UserModel(...))
///    - Ler dados do usuário
///      Exemplo: userService.getUserData(uid).listen((user) => ...)
///    - Atualizar perfil
///      Exemplo: await userService.updateUserProfile(uid, {'nome': 'Novo Nome'})
///    - Deletar perfil
///      Exemplo: await userService.deleteUserProfile(uid)
/// 
/// 2. Estrutura de Dados:
///    - ID do usuário (UID do Firebase)
///      * String única gerada pelo Firebase Auth
///      * Usado como documento ID no Firestore
///    - Nome completo
///      * String não vazia
///      * Máximo 100 caracteres
///    - Email
///      * Formato válido de email
///      * Deve ser único
///    - Tipo (professor/aluno)
///      * Enum: 'professor' ou 'aluno'
///      * Define permissões e funcionalidades
///    - Data de criação
///      * Timestamp do Firestore
///      * Automático na criação
/// 
/// 3. Tratamento de Erros:
///    - Erros de permissão
///      * permission-denied: Usuário não tem acesso
///      * unauthenticated: Usuário não está logado
///    - Erros de documento não encontrado
///      * not-found: Perfil não existe
///    - Erros de rede
///      * unavailable: Firestore indisponível
///    - Erros de validação
///      * invalid-argument: Dados inválidos
/// 
/// Dependências:
/// - Cloud Firestore: Para armazenamento de dados
///   * Configurado no firebase_options.dart
///   * Inicializado no main.dart
/// - UserModel: Para estrutura de dados
///   * Define campos e validações
///   * Conversão de/para Firestore
/// 
/// Observações:
/// - Todas as operações são assíncronas (async/await)
/// - Dados são observáveis via stream
/// - Erros são propagados para tratamento no controller
/// - Validações são realizadas antes das operações
/// - Coleções separadas para professores e alunos
/// - Documentos indexados por UID
/// 
/// Exemplo de uso:
/// ```dart
/// final userService = UserService();
/// 
/// // Criar perfil
/// try {
///   final user = UserModel(
///     id: 'uid123',
///     nome: 'João Silva',
///     email: 'joao@email.com',
///     tipo: 'professor',
///   );
///   await userService.createUserProfile(user);
/// } catch (e) {
///   debugPrint('Erro ao criar perfil: $e');
/// }
/// 
/// // Observar mudanças
/// userService.getUserData('uid123').listen((user) {
///   if (user != null) {
///     debugPrint('Perfil atualizado: ${user.nome}');
///   }
/// });
/// 
/// // Atualizar dados
/// try {
///   await userService.updateUserProfile('uid123', {
///     'nome': 'João Silva Atualizado',
///   });
/// } catch (e) {
///   debugPrint('Erro ao atualizar: $e');
/// }
/// 
/// // Buscar dados do usuário
/// final userData = await userService.getUserData(uid, 'professor').first;
/// if (userData != null) {
///   print('Usuário encontrado: ${userData.nome}');
/// }
/// 
/// // Observar mudanças
/// userService.getUserData(uid, 'professor').listen((userData) {
///   if (userData != null) {
///     print('Dados atualizados: ${userData.nome}');
///   }
/// });
/// ```
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Retorna a coleção correta baseada no tipo de usuário.
  CollectionReference _getCollectionForType(String tipo) {
    switch (tipo) {
      case 'professor':
        return _firestore.collection('professores');
      case 'aluno':
        return _firestore.collection('alunos');
      default:
        throw Exception('Tipo de usuário inválido: $tipo');
    }
  }

  /// Converte dados do Firestore para Map<String, dynamic>.
  Map<String, dynamic> _convertFirestoreData(dynamic data) {
    if (data == null) return {};
    if (data is DocumentSnapshot) {
      final map = Map<String, dynamic>.from(data.data() as Map<String, dynamic>? ?? {});
      map['id'] = data.id;
      return map;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {};
  }

  /// Cria um novo perfil de usuário no Firestore.
  Future<void> createUserProfile(UserModel user) async {
    try {
      final collection = _getCollectionForType(user.tipo);
      await collection.doc(user.id).set(user.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Retorna um stream com os dados do usuário pelo UID e tipo.
  Stream<UserModel?> getUserData(String uid, String tipo) {
    final collection = _getCollectionForType(tipo);
    return collection
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          final data = _convertFirestoreData(doc.data());
          if (data.isEmpty) return null;
          return UserModel.fromMap(data);
        });
  }

  /// Atualiza o perfil do usuário.
  Future<void> updateUserProfile(String uid, String tipo, Map<String, dynamic> data) async {
    try {
      final collection = _getCollectionForType(tipo);
      await collection.doc(uid).update(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Deleta o perfil do usuário.
  Future<void> deleteUserProfile(String uid, String tipo) async {
    try {
      final collection = _getCollectionForType(tipo);
      await collection.doc(uid).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Retorna um stream com todos os professores.
  Stream<List<UserModel>> getAllProfessores() {
    return _firestore
        .collection('professores')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = Map<String, dynamic>.from(doc.data());
              data['id'] = doc.id;
              return UserModel.fromMap(data);
            })
            .toList());
  }

  /// Retorna um stream com todos os alunos.
  Stream<List<UserModel>> getAllAlunos() {
    return _firestore
        .collection('alunos')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = Map<String, dynamic>.from(doc.data());
              data['id'] = doc.id;
              return UserModel.fromMap(data);
            })
            .toList());
  }

  /// Retorna um stream com os alunos vinculados a um professor.
  Stream<List<UserModel>> getAlunosDoProfessor(String professorId) {
    return _firestore
        .collection('alunos')
        .where('professorId', isEqualTo: professorId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = Map<String, dynamic>.from(doc.data());
              data['id'] = doc.id;
              return UserModel.fromMap(data);
            })
            .toList());
  }

  /// Retorna um stream com dados públicos dos professores.
  Stream<List<UserModel>> getAllProfessoresPublicos() {
    return _firestore
        .collection('professores')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = Map<String, dynamic>.from(doc.data());
              data['id'] = doc.id;
              return UserModel(
                id: data['id'],
                nome: data['nome'],
                email: data['email'],
                tipo: data['tipo'],
                dataCriacao: null,
                professorId: null,
              );
            })
            .toList());
  }
} 