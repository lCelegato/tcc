# 📚 App de Gestão Escolar

> Sistema completo para professores e alunos com **autenticação**, **postagens** e **cronograma de aulas**.

## 🚀 Funcionalidades Principais

### 🔐 **Sistema de Autenticação**

- Login seguro com **Firebase Auth**
- Auto-detecção de tipo de usuário (Professor/Aluno)
- Cadastro de professores e alunos
- Gerenciamento de sessões

### 📝 **Sistema de Postagens**

- Professores criam conteúdos por matéria
- Anexos, imagens e documentos
- Entrega direcionada para alunos específicos
- Feed organizado por matérias

### 📅 **Cronograma de Aulas**

- Horários fixos para cada aluno
- Visão consolidada para professores
- Cronograma pessoal para alunos
- Gerenciamento completo de horários

## 🏗️ Arquitetura

### 🔑 **Autenticação**

```
LoginScreen → AuthController → AuthService → Firebase Auth
```

**Componentes:**

- `LoginScreen` - Interface de login
- `AuthController` - Gerenciamento de estado
- `AuthService` - Comunicação com Firebase
- `RegisterScreen` - Cadastro de professores

### 📱 **Fluxo de Login**

1. **Validação** de email e senha
2. **Autenticação** via Firebase
3. **Detecção** automática do tipo de usuário
4. **Redirecionamento** para dashboard apropriado

### 👥 **Tipos de Usuário**

- **🎓 Professor**: Dashboard completo, criar postagens, gerenciar alunos
- **📖 Aluno**: Visualizar postagens, cronograma pessoal

---

## 📋 **Sistema de Postagens**

### ✨ **Recursos**

- 📚 **Organização por matérias**
- 🎯 **Entrega direcionada** para alunos específicos
- 📎 **Anexos**: imagens, documentos e arquivos
- 🔄 **Atualizações em tempo real**

### 🔄 **Fluxo Professor → Aluno**

```
Professor cria → Seleciona alunos → Publica → Aluno recebe
```

**Componentes Principais:**

- `PostagemModel` - Estrutura de dados
- `PostagemService` - Operações no Firestore
- `PostagemController` - Lógica de negócio
- `CriarPostagemScreen` - Interface de criação

---

## ⏰ **Cronograma de Aulas**

### 🎯 **Funcionalidades**

- 📅 **Horários fixos** para cada aluno
- 👨‍🏫 **Visão consolidada** para professores
- 📱 **Cronograma pessoal** para alunos
- ⚡ **Gerenciamento em tempo real**

### 🔧 **Componentes**

- `AulaModel` - Dados da aula
- `AulaService` - Operações CRUD
- `AulaController` - Validações e estado
- `GerenciarAulasScreen` - Interface do professor
- `CronogramaAlunoScreen` - Interface do aluno

---

## 🛠️ **Tecnologias**

| Tecnologia           | Uso                     |
| -------------------- | ----------------------- |
| 🔥 **Firebase Auth** | Autenticação segura     |
| 🗄️ **Firestore**     | Banco de dados          |
| 📱 **Flutter**       | Interface mobile        |
| 🔄 **Provider**      | Gerenciamento de estado |

---

## 🔒 **Segurança**

### ✅ **Firestore Rules**

- **Professores**: Acesso completo aos próprios dados
- **Alunos**: Acesso apenas a conteúdo direcionado
- **Validação**: Todas as operações validam o usuário autenticado

### 🛡️ **Autenticação**

- Senhas criptografadas pelo Firebase
- Sessões persistentes e seguras
- Validação de tipos de usuário

---

## 🚀 **Como Usar**

### 👨‍🏫 **Para Professores**

1. **Cadastre-se** com código de professor
2. **Crie alunos** e defina horários
3. **Publique conteúdos** por matéria
4. **Gerencie** cronograma e postagens

### 📖 **Para Alunos**

1. **Faça login** (conta criada pelo professor)
2. **Visualize postagens** organizadas por matéria
3. **Consulte** seu cronograma pessoal
4. **Acesse** materiais e anexos

---

## 📖 **Documentação Técnica**

> Para detalhes técnicos completos, consulte o arquivo em `/Documentacao/readme.md`
