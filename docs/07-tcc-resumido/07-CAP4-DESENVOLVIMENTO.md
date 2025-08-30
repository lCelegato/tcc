# 4. DESENVOLVIMENTO

## 4.1 Estrutura da Aplicação

A aplicação foi desenvolvida seguindo uma arquitetura modular organizada em camadas distintas para facilitar manutenção e escalabilidade.

### 4.1.1 Organização de Diretórios

```
lib/
├── models/          # Modelos de dados
├── views/           # Interfaces de usuário
├── controllers/     # Lógica de negócio
├── services/        # Integração com Firebase
├── widgets/         # Componentes reutilizáveis
└── routes/          # Navegação da aplicação
```

### 4.1.2 Modelos de Dados

Implementaram-se três modelos principais:

- **UserModel:** Dados básicos comuns (email, nome, tipo)
- **AlunoModel:** Informações específicas de estudantes
- **ProfessorModel:** Dados específicos de professores

## 4.2 Autenticação e Segurança

### 4.2.1 Sistema de Login

O Firebase Authentication gerencia o processo de autenticação com validação de email/senha e diferenciação automática de perfis baseada em dados armazenados no Firestore.

### 4.2.2 Controle de Acesso

Implementaram-se regras de segurança no Firestore que garantem:

- Usuários só acessam seus próprios dados
- Validação de tipos de usuário antes de operações
- Proteção contra acesso não autorizado

### 4.2.3 Gestão de Sessões

O AuthController mantém estado de autenticação persistente, permitindo login automático em reopening da aplicação e logout seguro.

## 4.3 Interface do Usuário

### 4.3.1 Design System

Aplicou-se Material Design 3 com paleta de cores consistente e componentes padronizados:

- Cores primárias: Azul (#2196F3) e Verde (#4CAF50)
- Tipografia: Roboto para legibilidade
- Iconografia: Material Icons para consistência

### 4.3.2 Navegação

Estrutura de navegação baseada em bottom navigation para acesso rápido às principais funcionalidades:

- **Home:** Dashboard principal
- **Perfil:** Dados do usuário
- **Configurações:** Ajustes da aplicação

### 4.3.3 Responsividade

Interfaces adaptáveis a diferentes tamanhos de tela utilizando LayoutBuilder e MediaQuery para otimização em tablets e smartphones.

## 4.4 Gerenciamento de Dados

### 4.4.1 Sincronização

Implementação de listeners em tempo real para sincronização automática de dados entre dispositivo e Firestore, mantendo consistência mesmo com múltiplos usuários conectados.

### 4.4.2 Cache Local

Estratégia de cache para melhorar performance e permitir funcionalidade offline limitada utilizando capabilities nativas do Firestore.

### 4.4.3 Validação de Dados

Validação client-side e server-side através de:

- Validators customizados nos formulários
- Security rules no Firestore
- Sanitização de inputs para prevenir injeções

\newpage
