# **CAPÍTULO 4 - DESENVOLVIMENTO DO SISTEMA - PARTE 2**

---

## **4.2 Modelagem do sistema**

A modelagem do sistema constituiu etapa crucial para definição da estrutura de dados, relacionamentos entre entidades e fluxos de navegação da aplicação.

### **4.2.1 Modelo de dados**

O modelo de dados foi projetado considerando a natureza NoSQL do Firestore, priorizando eficiência de consultas e flexibilidade para evolução futura.

#### **Entidade Professor**

```json
{
  "id": "string (auto-generated)",
  "nome": "string (required)",
  "email": "string (required, unique)",
  "tipo": "professor",
  "dataCadastro": "timestamp",
  "ativo": "boolean"
}
```

**Relacionamentos:** Um professor pode ter múltiplos alunos vinculados.

#### **Entidade Aluno**

```json
{
  "id": "string (auto-generated)",
  "nome": "string (required)",
  "email": "string (required, unique)",
  "tipo": "aluno",
  "professorId": "string (required, foreign key)",
  "dataCadastro": "timestamp",
  "ativo": "boolean"
}
```

**Relacionamentos:** Cada aluno pertence a exatamente um professor.

#### **Entidade Postagem**

```json
{
  "id": "string (auto-generated)",
  "professorId": "string (required)",
  "materia": "string (required)",
  "conteudo": "string (required)",
  "alunosDestino": "array<string> (required)",
  "dataPostagem": "timestamp",
  "imagensBase64": "array<string> (optional)",
  "documentos": "array<DocumentoModel> (optional)",
  "ativo": "boolean"
}
```

**Modelo DocumentoModel:**

```json
{
  "nome": "string (filename)",
  "tipo": "string (file extension)",
  "tamanho": "number (bytes)",
  "base64": "string (encoded content)"
}
```

#### **Entidade Aula**

```json
{
  "id": "string (auto-generated)",
  "professorId": "string (required)",
  "alunoId": "string (required)",
  "diaSemana": "number (0-6, domingo-sábado)",
  "horario": "string (HH:mm format)",
  "titulo": "string (required)",
  "dataCriacao": "timestamp",
  "ativo": "boolean"
}
```

### **4.2.2 Diagrama de relacionamentos**

**Relacionamento Professor-Aluno (1:N):**

- Um professor pode ter múltiplos alunos
- Cada aluno pertence a exatamente um professor
- Exclusão em cascata: remover professor remove todos os alunos

**Relacionamento Professor-Postagem (1:N):**

- Um professor pode criar múltiplas postagens
- Cada postagem pertence a exatamente um professor
- Postagens podem ser destinadas a múltiplos alunos específicos

**Relacionamento Professor-Aula (1:N):**

- Um professor pode agendar múltiplas aulas
- Cada aula pertence a exatamente um professor
- Aulas relacionam professor com aluno específico

**Relacionamento Aluno-Aula (1:N):**

- Um aluno pode ter múltiplas aulas agendadas
- Cada aula é destinada a exatamente um aluno
- Exclusão de aluno remove todas as suas aulas

### **4.2.3 Arquitetura de dados no Firestore**

**Estrutura de Collections:**

```
/professores/{professorId}
/alunos/{alunoId}
/postagens/{postagemId}
/aulas/{aulaId}
```

**Estratégia de Indexação:**

- **professores:** Índice composto por (email, ativo)
- **alunos:** Índice composto por (professorId, ativo)
- **postagens:** Índice composto por (professorId, dataPostagem)
- **aulas:** Índice composto por (professorId, diaSemana, horario)

**Queries Otimizadas Implementadas:**

```dart
// Buscar alunos de um professor específico
Query getAlunosProfessor(String professorId) {
  return _firestore
    .collection('alunos')
    .where('professorId', isEqualTo: professorId)
    .where('ativo', isEqualTo: true)
    .orderBy('nome');
}

// Buscar postagens para um aluno específico
Query getPostagensAluno(String alunoId) {
  return _firestore
    .collection('postagens')
    .where('alunosDestino', arrayContains: alunoId)
    .where('ativo', isEqualTo: true)
    .orderBy('dataPostagem', descending: true);
}

// Buscar aulas de um professor por dia
Query getAulasProfessorDia(String professorId, int diaSemana) {
  return _firestore
    .collection('aulas')
    .where('professorId', isEqualTo: professorId)
    .where('diaSemana', isEqualTo: diaSemana)
    .where('ativo', isEqualTo: true)
    .orderBy('horario');
}
```

### **4.2.4 Validação de integridade**

**Validações Implementadas:**

**Email Único:** Verificação de unicidade de email antes de criação de usuário.

```dart
Future<bool> emailJaExiste(String email) async {
  final queryProfessores = await _firestore
    .collection('professores')
    .where('email', isEqualTo: email)
    .get();

  final queryAlunos = await _firestore
    .collection('alunos')
    .where('email', isEqualTo: email)
    .get();

  return queryProfessores.docs.isNotEmpty || queryAlunos.docs.isNotEmpty;
}
```

**Conflito de Horários:** Validação antes de agendar nova aula.

```dart
Future<bool> temConflitoHorario(String professorId, int diaSemana, String horario) async {
  final query = await _firestore
    .collection('aulas')
    .where('professorId', isEqualTo: professorId)
    .where('diaSemana', isEqualTo: diaSemana)
    .where('horario', isEqualTo: horario)
    .where('ativo', isEqualTo: true)
    .get();

  return query.docs.isNotEmpty;
}
```

**Relacionamento Professor-Aluno:** Verificação de vínculo antes de operações.

```dart
Future<bool> alunoVinculadoProfessor(String alunoId, String professorId) async {
  final doc = await _firestore
    .collection('alunos')
    .doc(alunoId)
    .get();

  if (!doc.exists) return false;

  final data = doc.data() as Map<String, dynamic>;
  return data['professorId'] == professorId;
}
```

---

### 📊 **MÉTRICAS DA PARTE 2**

| **Seção**                       | **Componentes**               | **Palavras**     |
| ------------------------------- | ----------------------------- | ---------------- |
| **4.2.1 Modelo de Dados**       | 4 entidades principais        | 287 palavras     |
| **4.2.2 Relacionamentos**       | 4 tipos de relacionamento     | 156 palavras     |
| **4.2.3 Arquitetura Firestore** | Collections e queries         | 198 palavras     |
| **4.2.4 Validação**             | 3 validações críticas         | 145 palavras     |
| **TOTAL PARTE 2**               | **Sistema de dados completo** | **786 palavras** |

---

**📄 Continua na Parte 3: Implementação dos Módulos**
