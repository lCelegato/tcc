# Documentação do Aplicativo

Este documento descreve os principais sistemas do aplicativo, incluindo autenticação, cadastro, postagens e cronograma de aulas.

## Sistema de Login

### Visão Geral

O sistema de login do aplicativo é responsável por autenticar usuários através do Firebase Authentication, utilizando email e senha. O sistema identifica automaticamente o tipo de usuário (professor ou aluno) após o login bem-sucedido e redireciona para a tela apropriada.

### Arquitetura

O sistema de login é composto por três componentes principais:

1. **LoginScreen** (`lib/views/login_screen.dart`) - Interface do usuário
2. **AuthController** (`lib/controllers/auth_controller.dart`) - Controlador de estado e lógica de negócio
3. **AuthService** (`lib/services/auth_service.dart`) - Serviço de autenticação com Firebase

Além do login, o sistema também implementa o fluxo de cadastro (sign up), com os seguintes componentes:

4. **RegisterScreen** (`lib/views/register_screen.dart`) - Tela de cadastro de professor
5. **CadastroProfessorController** (`lib/controllers/cadastro_professor_controller.dart`) - Controlador de cadastro de professor
6. **CadastroAlunoController** (`lib/controllers/cadastro_aluno_controller.dart`) - Controlador de cadastro de aluno pelo professor

### Componentes Principais

#### 1. LoginScreen

A tela de login é responsável pela interface do usuário e captura das credenciais.

##### Funções Principais

**`_login()`**
- **Localização**: `lib/views/login_screen.dart:21-40`
- **Descrição**: Função assíncrona que processa o login do usuário
- **Fluxo**:
  1. Valida o formulário usando `_formKey.currentState!.validate()`
  2. Chama `AuthController.signIn()` com email e senha
  3. Exibe mensagens de erro em caso de falha usando `SnackBar`

**Validação de Campos**
- **Email**: Verifica se o campo não está vazio e se contém o caractere `@`
- **Senha**: Verifica se o campo não está vazio

##### Características da Interface

- Formulário com validação em tempo real
- Campos de texto para email e senha
- Botão de login que mostra indicador de carregamento durante a autenticação
- Link para tela de registro
- Design com gradiente e card centralizado

#### 2. AuthController

O controlador gerencia o estado de autenticação e coordena as operações de login.

##### Funções Principais

**`_init()`**
- **Localização**: `lib/controllers/auth_controller.dart:41-52`
- **Descrição**: Inicializa o listener para mudanças no estado de autenticação
- **Funcionalidade**:
  - Escuta o stream `authStateChanges` do Firebase Auth
  - Atualiza `_isAuthenticated` quando o estado muda
  - Chama `_loadUserType()` quando um usuário está autenticado
  - Notifica os listeners sobre mudanças de estado

**`_loadUserType(String uid)`**
- **Localização**: `lib/controllers/auth_controller.dart:54-74`
- **Descrição**: Determina o tipo de usuário (professor ou aluno)
- **Fluxo**:
  1. Tenta buscar dados do usuário na coleção `professor`
  2. Se não encontrar, tenta buscar na coleção `aluno`
  3. Define `_userType` com o tipo encontrado
  4. Trata erros silenciosamente, apenas logando no debug

**`signIn(String email, String password, BuildContext context)`**
- **Localização**: `lib/controllers/auth_controller.dart:76-109`
- **Descrição**: Realiza o processo completo de login
- **Parâmetros**:
  - `email`: Email do usuário
  - `password`: Senha do usuário
  - `context`: Contexto do Flutter para navegação
- **Fluxo**:
  1. Define `_isLoading = true` e notifica listeners
  2. Chama `AuthService.signInWithEmailAndPassword()` para autenticar
  3. Após login bem-sucedido, busca o tipo de usuário com `_loadUserType()`
  4. Carrega os dados completos do usuário no `UserController`
  5. Navega para a tela apropriada:
     - `AppRoutes.professorDashboard` se for professor
     - `AppRoutes.alunoDashboard` se for aluno
  6. Define `_isLoading = false` e notifica listeners
  7. Retorna o contexto

**`signOut()`**
- **Localização**: `lib/controllers/auth_controller.dart:137-157`
- **Descrição**: Realiza logout do usuário
- **Fluxo**:
  1. Define `_isLoading = true`
  2. Chama `AuthService.signOut()`
  3. Limpa `_userType`
  4. Limpa dados do `UserController`
  5. Define `_isLoading = false` e notifica listeners

##### Propriedades

- `isLoading`: Indica se uma operação de autenticação está em andamento
- `isAuthenticated`: Indica se há um usuário autenticado
- `userType`: Tipo do usuário atual ('professor' ou 'aluno')
- `currentUser`: Usuário atual do Firebase Auth

#### 3. AuthService

O serviço encapsula as operações de autenticação com o Firebase.

##### Funções Principais

**`signInWithEmailAndPassword(String email, String password)`**
- **Localização**: `lib/services/auth_service.dart:23-31`
- **Descrição**: Autentica um usuário com email e senha
- **Parâmetros**:
  - `email`: Email do usuário
  - `password`: Senha do usuário
- **Retorno**: `Future<UserCredential>` - Credenciais do usuário autenticado
- **Fluxo**:
  1. Chama `FirebaseAuth.instance.signInWithEmailAndPassword()`
  2. Retorna as credenciais em caso de sucesso
  3. Relança exceções em caso de erro

**`createUserWithEmailAndPassword(String email, String password)`**
- **Localização**: `lib/services/auth_service.dart:34-42`
- **Descrição**: Cria um novo usuário no Firebase Auth
- **Parâmetros**:
  - `email`: Email do novo usuário
  - `password`: Senha do novo usuário
- **Retorno**: `Future<UserCredential>` - Credenciais do usuário criado

**`signOut()`**
- **Localização**: `lib/services/auth_service.dart:45-51`
- **Descrição**: Realiza logout do usuário atual
- **Fluxo**: Chama `FirebaseAuth.instance.signOut()`

##### Propriedades

- `authStateChanges`: Stream que emite mudanças no estado de autenticação
- `currentUser`: Usuário atual logado ou `null` se não houver

## Sistema de Cadastro (Sign Up)

O sistema de cadastro contempla dois cenários:

- Cadastro de Professor (autônomo, via `RegisterScreen`)
- Cadastro de Aluno (realizado por um Professor autenticado)

### Componentes e Funções

#### 1. RegisterScreen (Cadastro de Professor)

- Responsável pela interface de cadastro de professores.

**Funções Principais**

**`_register()`**
- **Localização**: `lib/views/register_screen.dart:36-46`
- **Descrição**: Valida o formulário e aciona o cadastro via `CadastroProfessorController`
- **Validações**:
  - Nome: não vazio e com pelo menos 3 caracteres
  - Email: regex padrão de email
  - Senha: regex que exige 8+ caracteres, com maiúsculas, minúsculas e números
  - Confirmar Senha: igual à senha
  - Código de Professor: obrigatório

**Características da Interface**

- Formulário com validação
- Campos: nome, email, senha, confirmar senha, código de professor
- Botão: "Cadastrar Professor"

#### 2. CadastroProfessorController

Gerencia a lógica de criação de conta de professor, incluindo validação de código.

**`cadastrarProfessor({ email, senha, nome, codigo, context })`**
- **Localização**: `lib/controllers/cadastro_professor_controller.dart:12-57`
- **Fluxo**:
  1. Valida o código do professor com `validarCodigoProfessor()` (ex.: `TCC2025`)
  2. Em caso válido, chama `AuthController.signUp(email, senha, nome, 'professor')`
  3. Exibe `SnackBar` de sucesso/erro
  4. Faz `Navigator.pop(context)` após sucesso

#### 3. CadastroAlunoController (Cadastro de Aluno pelo Professor)

Gerencia a criação de alunos por um professor autenticado, cuidando da re-autenticação do professor após o processo.

**`validarDadosAluno({ nome, email, senha })`**
- **Localização**: `lib/controllers/cadastro_aluno_controller.dart:31-47`
- **Descrição**: Usa utilitários de validação para nome, email e senha; retorna mensagem de erro ou `null`.

**`cadastrarAluno({ email, senha, nome, professorId, context })`**
- **Localização**: `lib/controllers/cadastro_aluno_controller.dart:49-132`
- **Fluxo**:
  1. Valida entradas com `validarDadosAluno`
  2. Obtém o usuário atual (professor) e seu email
  3. Verifica se `professorId` existe entre professores públicos
  4. Cria a conta de aluno chamando `AuthController.signUpAlunoComProfessor(...)`
  5. Solicita a senha do professor via diálogo para re-login
  6. Se a senha for informada, reautentica o professor com `_relogarProfessor()`
  7. Exibe mensagens de sucesso/erro e navega para a tela apropriada

**`_relogarProfessor(context, professorEmail, senha)`**
- **Localização**: `lib/controllers/cadastro_aluno_controller.dart:134-164`
- **Descrição**: Tenta autenticar o professor novamente. Sucesso: mensagem + navega para `AppRoutes.meusAlunos`. Falha: erro + navega para `AppRoutes.login`.

#### 4. AuthController (apoio ao cadastro)

Além do login, o `AuthController` implementa operações de cadastro e apoio ao fluxo do professor criando alunos.

**`signUp(String email, String password, String name, String type)`**
- **Localização**: `lib/controllers/auth_controller.dart:111-135`
- **Descrição**: Cria o usuário no Firebase Auth e salva o perfil no `UserService`
- **Fluxo**:
  1. Define `_isLoading = true` e notifica listeners
  2. Chama `AuthService.createUserWithEmailAndPassword(email, password)`
  3. Cria `UserModel` com `tipo` (ex.: `professor`) e `dataCriacao`
  4. Persiste perfil em `UserService.createUserProfile`
  5. Reseta `_isLoading` e notifica listeners

**`signUpAlunoComProfessor(String email, String password, String name, String professorId)`**
- **Localização**: `lib/controllers/auth_controller.dart:167-194`
- **Descrição**: Cria conta de aluno associada a um `professorId`, persiste perfil e faz logout do aluno recém-criado para que o professor se re-autentique.
- **Fluxo**:
  1. Cria usuário no Auth via `createUserWithEmailAndPassword`
  2. Monta `UserModel` com `tipo = 'aluno'` e `professorId`
  3. Salva perfil em `UserService.createUserProfile`
  4. Faz `signOut()` para encerrar a sessão do aluno criado

### Fluxos de Funcionamento (Cadastro)

#### Fluxo de Cadastro de Professor (via RegisterScreen)

```
1. Usuário (professor) preenche nome, email, senha, confirmação e código
   ↓
2. Clica em "Cadastrar Professor"
   ↓
3. RegisterScreen._register() valida o formulário
   ↓
4. Chama CadastroProfessorController.cadastrarProfessor()
   ↓
5. Valida o código do professor
   ↓
6. AuthController.signUp() cria o usuário no Firebase e salva perfil
   ↓
7. Exibe mensagem de sucesso e retorna (Navigator.pop)
```

#### Fluxo de Cadastro de Aluno (pelo Professor)

```
1. Professor autenticado acessa a funcionalidade de cadastrar aluno
   ↓
2. Informa nome, email e senha do novo aluno
   ↓
3. CadastroAlunoController.cadastrarAluno() valida dados
   ↓
4. Verifica se professorId é válido
   ↓
5. AuthController.signUpAlunoComProfessor() cria conta de aluno e salva perfil
   ↓
6. Sistema faz logout do aluno recém-criado
   ↓
7. UI solicita senha do professor para reautenticação
   ↓
8. Se confirmado, professor é reautenticado e navega para Meus Alunos
   ↓
9. Em caso de erro ou cancelamento, navega para Login conforme necessário
```

### Tratamento de Erros (Cadastro)

- `CadastroProfessorController`: exibe `SnackBar` em caso de código inválido ou erro de criação; sucesso também via `SnackBar`.
- `CadastroAlunoController`: validações com mensagens, diálogos para senha do professor, e `SnackBar` para sucesso/erro; navegação para `login` quando necessário.
- `AuthController.signUp`/`signUpAlunoComProfessor`: controlam `_isLoading`; exceções de Auth/Firestore são propagadas para os controllers de UI tratarem.

### Navegação (Cadastro)

- Cadastro de Professor: após sucesso, `Navigator.pop(context)` (retorna à tela anterior, geralmente `login` ou dashboard)
- Cadastro de Aluno: após reautenticação bem-sucedida do professor, navega para `AppRoutes.meusAlunos`; erros podem redirecionar para `AppRoutes.login`.

### Fluxo de Funcionamento

#### Fluxo de Login Completo

```
1. Usuário preenche email e senha na LoginScreen
   ↓
2. Usuário clica no botão "Entrar"
   ↓
3. LoginScreen._login() valida o formulário
   ↓
4. LoginScreen chama AuthController.signIn()
   ↓
5. AuthController define isLoading = true
   ↓
6. AuthController chama AuthService.signInWithEmailAndPassword()
   ↓
7. AuthService autentica com Firebase Auth
   ↓
8. Firebase Auth retorna UserCredential em caso de sucesso
   ↓
9. AuthController._loadUserType() determina o tipo de usuário
   ↓
10. AuthController carrega dados completos no UserController
    ↓
11. AuthController navega para a tela apropriada:
    - Professor → AppRoutes.professorDashboard
    - Aluno → AppRoutes.alunoDashboard
    ↓
12. AuthController define isLoading = false
```

#### Fluxo de Estado de Autenticação

```
1. AuthController é inicializado no main.dart
   ↓
2. AuthController._init() escuta authStateChanges
   ↓
3. Quando estado de autenticação muda:
   - Se usuário autenticado → carrega tipo de usuário
   - Se usuário desautenticado → limpa tipo de usuário
   ↓
4. AuthController notifica listeners (UI atualiza automaticamente)
```

### Dependências

#### Dependências Externas

- **Firebase Auth** (`firebase_auth`): Serviço de autenticação do Firebase
- **Firebase Core** (`firebase_core`): Inicialização do Firebase
- **Provider** (`provider`): Gerenciamento de estado

#### Dependências Internas

- **UserService**: Para buscar dados do usuário e determinar tipo
- **UserController**: Para gerenciar dados do usuário logado
- **AppRoutes**: Para navegação entre telas
- **UserModel**: Modelo de dados do usuário

### Integração com Firebase

O sistema utiliza Firebase Authentication para:

1. **Autenticação**: Validação de credenciais (email e senha)
2. **Estado de Autenticação**: Stream `authStateChanges` para monitorar login/logout
3. **Sessão Persistente**: O Firebase mantém a sessão do usuário entre reinicializações do app

#### Configuração

O Firebase é inicializado no `main.dart`:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### Tratamento de Erros

#### Na LoginScreen

- Erros são capturados no bloco `catch` de `_login()`
- Mensagens de erro são exibidas via `SnackBar` com fundo vermelho
- O formulário permanece visível para nova tentativa

#### No AuthController

- Erros do Firebase são relançados para serem tratados na UI
- Estado de loading é sempre resetado no bloco `finally`
- Erros ao carregar tipo de usuário são logados mas não interrompem o fluxo

#### No AuthService

- Erros do Firebase são relançados para serem tratados pelo controller
- Não há tratamento de erros no nível do serviço

### Segurança

- Senhas são ocultas no campo de texto (`obscureText = true`)
- Validação de email no frontend (presença de `@`)
- Autenticação real é feita pelo Firebase (validação segura no backend)
- Credenciais são enviadas de forma segura para o Firebase

### Navegação

Após login bem-sucedido, o sistema redireciona automaticamente:

- **Professor**: `/professor-dashboard` → `ProfessorHomeScreen`
- **Aluno**: `/aluno-dashboard` → `AlunoHomeScreen`

A navegação utiliza `Navigator.pushReplacementNamed()` para substituir a tela de login, impedindo que o usuário volte para ela usando o botão de voltar.

### Observações Importantes

1. **Estado de Loading**: O `AuthController` gerencia o estado de loading globalmente, permitindo que a UI exiba indicadores de carregamento
2. **Tipo de Usuário**: O tipo é determinado consultando as coleções do Firestore (`professor` ou `aluno`)
3. **Persistência**: O Firebase mantém a sessão do usuário, então ao reabrir o app, o usuário pode já estar autenticado
4. **Provider**: O `AuthController` é fornecido via `ChangeNotifierProvider` no `main.dart`, permitindo acesso global através do `context.read<AuthController>()` ou `context.watch<AuthController>()`


## Sistema de Postagens (Professor → Aluno)

O sistema de postagens permite que professores publiquem conteúdos por matéria e selecionem os alunos destinatários. Os alunos visualizam as postagens recebidas agrupadas por matéria e podem abrir os detalhes, incluindo imagens, documentos e anexos.

### Componentes

- **PostagemModel** (`lib/models/postagem_model.dart`): Modelo de dados da postagem
- **PostagemService** (`lib/services/postagem_service.dart`): Acesso ao Firestore (CRUD, consultas e streams)
- **PostagemController** (`lib/controllers/postagem_controller.dart`): Lógica e estado das postagens
- Telas do Professor:
  - **CriarPostagemScreen** (`lib/views/professor/criar_postagem_screen.dart`): criação de postagens
  - **MinhasPostagensScreen** (`lib/views/professor/minhas_postagens_screen.dart`): listagem/gestão
  - **DetalhePostagemScreen** (`lib/views/professor/detalhe_postagem_screen.dart`): edição/detalhe (quando usado pelo professor)
- Telas do Aluno:
  - **PostagensAlunoScreen** (`lib/views/aluno/postagens_aluno_screen.dart`): feed agrupado por matéria
  - **DetalhesPostagemScreen** (`lib/views/aluno/detalhes_postagem_screen.dart`): detalhe da postagem

### Modelo de Dados

- Campos principais: `professorId`, `titulo`, `conteudo`, `materia`, `dataPostagem`, `alunosDestino`, `anexos?`, `imagens?`, `documentos?`, `ativo`
- `materia` usa valores definidos em `PostagemModel.materiasDisponiveis`

### Serviço (PostagemService)

Principais operações:
- **`criarPostagem(PostagemModel)`**: cria documento na coleção `postagens`
- **`buscarPostagensProfessor(String professorId)`**: lista postagens ativas do professor
- **`buscarPostagensParaAluno(String alunoId)`** e **`buscarPostagensParaAlunoPorMateria(String alunoId, String materia)`**: lista postagens destinadas ao aluno
- **`buscarPostagensAgrupadasPorMateria(String alunoId)`**: retorna `Map<materia, List<PostagemModel>>`
- **`buscarPostagensRecentes(String alunoId)`**: limita por janela de 7 dias
- **`buscarPostagemPorId(String id)`**, **`atualizarPostagem(PostagemModel)`**, **`removerPostagem(String id)`** (marcação lógica `ativo=false`)
- Streams: **`streamPostagensParaAluno(String alunoId)`** e **`streamPostagensPorProfessor(String professorId)`** para atualizações em tempo real
- Gerência de anexos: **`adicionarAnexo`** e **`removerAnexo`**

### Controller (PostagemController)

Responsável por validar e orquestrar chamadas ao serviço, além de manter o estado para a UI.

- **`criarPostagem({...})`**: valida campos (título, conteúdo, matéria, alunos), cria via serviço e recarrega a lista do professor
- **Carregamentos**: `carregarPostagensProfessor`, `carregarPostagensAluno`, `carregarPostagensAgrupadasPorMateria`, `carregarPostagensPorMateria`, `carregarPostagem`
- **Edição/Remoção**: `atualizarPostagem`, `removerPostagem`
- **Mídias**: `adicionarAnexo`, `removerAnexo`
- **Utilidades**: `filtrarPostagens`, `agruparPostagensaPorData`, `obterContagemPorMateria`, `selecionarPostagem`, `limparSelecao`, `resetState`

### Telas e Fluxos

#### Professor

- **CriarPostagemScreen**:
  - Valida formulário: título (≥3), conteúdo (≥10), matéria obrigatória
  - Carrega alunos do professor via `UserController.getAlunosDoProfessor` (stream)
  - Ao publicar, chama `PostagemController.criarPostagem` com `alunosDestino`, `imagens?`, `documentos?`
- **MinhasPostagensScreen**:
  - Lista postagens do professor via `carregarPostagensProfessor`
  - Ações: criar nova, editar (abre detalhe), remover (marca inativa)

#### Aluno

- **PostagensAlunoScreen**:
  - Carrega `carregarPostagensAgrupadasPorMateria(alunoId)`, renderiza cards por matéria, permite refresh
  - Abre **DetalhesPostagemScreen** ao tocar no card
- **DetalhesPostagemScreen**:
  - Mostra conteúdo completo, data, matéria
  - Exibe imagens (pré-visualização e visualização em tela cheia), documentos e anexos; aluno não edita

### Fluxo de Funcionamento

#### Publicação pelo Professor

```
1. Professor abre CriarPostagemScreen
   ↓
2. Preenche título, conteúdo, matéria e seleciona alunos destinatários
   ↓
3. Pressiona "Publicar" → PostagemController.criarPostagem()
   ↓
4. PostagemService.criarPostagem() salva no Firestore (coleção postagens)
   ↓
5. Controller recarrega lista (carregarPostagensProfessor)
```

#### Visualização pelo Aluno

```
1. Aluno acessa PostagensAlunoScreen
   ↓
2. Controller busca e agrupa postagens destinadas ao aluno por matéria
   ↓
3. Aluno vê cards por matéria e seleciona uma postagem
   ↓
4. Abre DetalhesPostagemScreen com conteúdo, imagens, documentos e anexos
```

### Segurança (Firestore Rules)

- Professor: pode criar, listar, ler, atualizar e excluir suas próprias postagens
- Aluno: pode ler/listar apenas postagens em que seu `uid` está em `alunosDestino`
- Criação: exige que `request.resource.data.professorId == request.auth.uid`


## Sistema de Cronograma de Aulas

O cronograma permite que o professor cadastre horários fixos para cada aluno durante o processo de cadastro e edição. Essas aulas ficam disponíveis tanto para o professor — em uma visão consolidada na tela `GerenciarAulasScreen` — quanto para o aluno — na tela `CronogramaAlunoScreen`.

### Componentes Principais

- **AulaModel** (`lib/models/aula_model.dart`): representação da aula com `professorId`, `alunoId`, `diaSemana`, `horario`, `titulo`, `ativa` e `dataCriacao`
- **AulaService** (`lib/services/aula_service.dart`): camada de acesso ao Firestore (`aulas`)
- **AulaController** (`lib/controllers/aula_controller.dart`): orquestra validações, operações CRUD e estado
- **RegisterAlunoScreen** (`lib/views/professor/register_aluno_screen.dart`): cadastro de aluno + agendamento inicial
- **DetalhesAlunoScreen** (`lib/views/professor/detalhes_aluno_screen.dart`): edição dos dados do aluno e gerenciamento de horários
- **GerenciarAulasScreen** (`lib/views/professor/gerenciar_aulas_screen.dart`): visão consolidada das aulas por dia da semana
- **CronogramaAlunoScreen** (`lib/views/aluno/cronograma_aluno_screen.dart`): visão do cronograma organizada por dia para o aluno

### Serviço (AulaService)

- **`criarAula(AulaModel)`**: grava documento na coleção `aulas`, adicionando `id` e `dataCriacao`
- **`buscarAulasPorProfessor(String professorId)`**: lista aulas ativas de um professor
- **`buscarAulasPorAluno(String alunoId)`** e **`buscarAulasAlunoEProfessor(String alunoId, String professorId)`**: recuperam sessões específicas
- **`atualizarAula(AulaModel)`** e **`desativarAula(String aulaId)`**: manutenção das aulas (edição/remoção lógica)
- **`removerAulasDoAluno(String alunoId)`** e **`deletarAula(String aulaId)`**: limpeza quando aluno é removido ou aula é excluída
- **`buscarDadosAluno(String alunoId)`**: utilitário para recuperar informações do aluno

### Controller (AulaController)

- **`criarAula({...})`**: valida dia/horário, previne conflitos no mesmo horário para o professor e persiste via serviço
- **Carregamentos**: `carregarAulasProfessor`, `carregarAulasAluno`, `buscarAulasEspecificas`
- **Manutenção**: `atualizarAula`, `removerAula`, `removerAulasDoAluno`, `limparAulasOrfas`
- **Organização**: `agruparAulasPorDia` (usado nas telas de professor e aluno), `diasSemana` (fonte única dos dias)

### Cadastro e Edição pelo Professor

- **RegisterAlunoScreen**
  - Durante `_register()`, após criar o aluno via `CadastroAlunoController`, percorre a lista `_agendamentos` e chama `AulaController.criarAula` para cada horário
  - Métodos auxiliares: `_adicionarAgendamento()` (monta lista com `dia`, `horario`, `titulo`), `_removerAgendamento()` e `_selecionarHorario()`
- **DetalhesAlunoScreen**
  - `_carregarAulasDoAluno()` usa `AulaController.buscarAulasEspecificas` para recuperar aulas do professor/aluno
  - `_adicionarNovaAula()` abre `_DialogAdicionarAula`, que cria novos horários via `AulaController.criarAula`
  - `_editarAula()` e `_DialogEditarAula` permitem ajustar dia/horário com `AulaController.atualizarAula`
  - `_excluirAula()` usa `AulaController.removerAula` (marca como inativa) e atualiza a lista

### Telas de Visualização

- **GerenciarAulasScreen** (professor)
  - Carrega aulas do professor (`carregarAulasProfessor`) e mantém cache de nomes dos alunos
  - Oferece filtro por nome, agrupa por dia (`_agruparAulasPorDia`) e apresenta ações de editar/remover por item
  - Usa diálogos próprios para edição (`_DialogEditarAula`) e confirmação de exclusão
- **CronogramaAlunoScreen** (aluno)
  - Durante inicialização chama `carregarAulasAluno`
  - Exibe lista por dia (ordem fixa de segunda a domingo) usando `agruparAulasPorDia`
  - Permite `pull-to-refresh` e mostra cartões com horário e título da aula

### Fluxos de Funcionamento

#### Cadastro ou Edição de Aluno com Cronograma

```
1. Professor cadastra/altera aluno (RegisterAlunoScreen ou DetalhesAlunoScreen)
   ↓
2. Seleciona dia, horário (formato 24h) e título opcional
   ↓
3. Controller valida conflitos e formato; se ok, chama AulaService.criarAula()
   ↓
4. Aulas ficam associadas ao par professor/aluno na coleção `aulas`
```

#### Visualização do Professor (`GerenciarAulasScreen`)

```
1. Tela carrega aulas do professor via AulaController.carregarAulasProfessor()
   ↓
2. Lista é agrupada por dia da semana e pode ser filtrada por aluno
   ↓
3. Professor pode editar ou remover uma aula; controller atualiza Firestore e recarrega
```

#### Visualização do Aluno (`CronogramaAlunoScreen`)

```
1. Tela solicita AulaController.carregarAulasAluno(alunoId)
   ↓
2. Controller agrupa aulas por dia (`agruparAulasPorDia`)
   ↓
3. UI mostra cartões por dia, listando horários e títulos disponíveis
```

### Segurança (Firestore Rules)

- Professores: podem criar, listar, atualizar e excluir aulas onde `professorId == request.auth.uid`
- Alunos: podem ler/listar aulas onde `alunoId == request.auth.uid`
- Criação exige correspondência do `professorId` com o usuário autenticado, prevenindo acesso indevido
