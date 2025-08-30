# 3. METODOLOGIA

## 3.1 Abordagem da Pesquisa

Este trabalho adota uma abordagem qualitativa de natureza aplicada, utilizando pesquisa experimental para desenvolvimento e validação da aplicação móvel educacional. A metodologia combina revisão bibliográfica, desenvolvimento prático e testes de usabilidade.

### 3.1.1 Método de Desenvolvimento

Utilizou-se metodologia ágil com sprints semanais, priorizando entregas incrementais e feedback contínuo. O processo incluiu:

- Análise de requisitos
- Prototipagem de interfaces
- Desenvolvimento iterativo
- Testes funcionais
- Validação com usuários

## 3.2 Tecnologias Utilizadas

### 3.2.1 Frontend

- **Flutter 3.24:** Framework principal para desenvolvimento
- **Dart:** Linguagem de programação
- **Material Design:** Biblioteca de componentes UI
- **Provider:** Gerenciamento de estado

### 3.2.2 Backend

- **Firebase Authentication:** Autenticação de usuários
- **Cloud Firestore:** Banco de dados NoSQL
- **Firebase Storage:** Armazenamento de arquivos
- **Firebase Hosting:** Hospedagem web

### 3.2.3 Ferramentas de Desenvolvimento

- **VS Code:** IDE principal
- **Android Studio:** Emuladores e debugging
- **Git:** Controle de versão
- **Firebase Console:** Monitoramento e configuração

## 3.3 Arquitetura do Sistema

### 3.3.1 Padrão Arquitetural

A aplicação segue o padrão MVC (Model-View-Controller) com separação clara de responsabilidades:

- **Models:** Representação de dados (User, Aluno, Professor)
- **Views:** Interfaces de usuário (Login, Dashboard, Perfil)
- **Controllers:** Lógica de negócio e comunicação com Firebase

### 3.3.2 Estrutura de Dados

O Firestore organiza dados em coleções hierárquicas:

- `users/`: Informações básicas de usuários
- `alunos/`: Dados específicos de estudantes
- `professores/`: Dados específicos de professores

### 3.3.3 Estratégia de Armazenamento

Para todos os arquivos da aplicação, incluindo imagens de perfil e documentos, optou-se por armazenamento direto no Firestore utilizando codificação Base64. Esta decisão fundamenta-se na simplicidade de implementação, eliminação de custos adicionais, redução de complexidade de sincronização e adequação para o volume de dados típico em aplicações educacionais. A limitação de arquivos a tamanhos menores (até 1MB) atende adequadamente às necessidades educacionais, mantendo a solução economicamente viável.

\newpage
