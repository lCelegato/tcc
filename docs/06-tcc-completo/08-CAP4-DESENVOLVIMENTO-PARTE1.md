# **CAPÍTULO 4 - DESENVOLVIMENTO DO SISTEMA - PARTE 1**

---

## **4 DESENVOLVIMENTO DO SISTEMA**

### **4.1 Análise de requisitos**

A análise de requisitos constituiu fase fundamental do desenvolvimento, envolvendo identificação, documentação e validação das necessidades funcionais e não funcionais do sistema educacional para gestão de aulas particulares.

#### **4.1.1 Requisitos funcionais**

Os requisitos funcionais definem as funcionalidades específicas que o sistema deve implementar para atender às necessidades dos usuários finais.

**RF001 - Sistema de Autenticação**

- O sistema deve permitir autenticação de professores via email e senha
- O sistema deve permitir autenticação automática de alunos com credenciais fornecidas pelo professor
- O sistema deve manter sessão ativa do usuário entre sessões da aplicação
- O sistema deve permitir logout seguro com limpeza completa da sessão

**RF002 - Gestão de Usuários Professor**

- O sistema deve permitir ao professor cadastrar novos alunos
- O sistema deve permitir ao professor visualizar lista de alunos vinculados
- O sistema deve permitir ao professor editar dados dos alunos
- O sistema deve permitir ao professor excluir alunos com remoção de dependências
- O sistema deve exibir dashboard com estatísticas em tempo real

**RF003 - Sistema de Postagens**

- O sistema deve permitir ao professor criar postagens categorizadas por matéria
- O sistema deve permitir ao professor selecionar alunos destinatários específicos
- O sistema deve permitir ao professor anexar múltiplas imagens às postagens
- O sistema deve permitir ao professor anexar documentos diversos às postagens
- O sistema deve permitir ao aluno visualizar postagens organizadas por matéria

**RF004 - Cronograma de Aulas**

- O sistema deve permitir ao professor agendar aulas semanais recorrentes
- O sistema deve permitir definição de horários específicos por dia da semana
- O sistema deve permitir títulos personalizados para cada aula
- O sistema deve validar conflitos de horário antes de confirmar agendamento
- O sistema deve permitir ao aluno visualizar cronograma personalizado

**RF005 - Sistema de Anexos**

- O sistema deve suportar upload de imagens via câmera ou galeria
- O sistema deve suportar upload de documentos (PDF, DOC, DOCX, TXT, RTF, ODT)
- O sistema deve converter automaticamente arquivos para Base64
- O sistema deve permitir download nativo de documentos para alunos
- O sistema deve exibir galeria responsiva para visualização de imagens

#### **4.1.2 Requisitos não funcionais**

Os requisitos não funcionais especificam critérios de qualidade e restrições técnicas que o sistema deve atender.

**RNF001 - Performance**

- Tempo de resposta máximo de 3 segundos para operações de CRUD
- Tempo de startup da aplicação inferior a 5 segundos
- Processamento de upload de imagens em tempo máximo de 10 segundos
- Interface fluida com frame rate mínimo de 60 FPS

**RNF002 - Usabilidade**

- Interface intuitiva seguindo guidelines do Material Design 3
- Navegação consistente entre telas com máximo 3 toques para qualquer funcionalidade
- Feedback visual para todas as ações do usuário
- Mensagens de erro claras e acionáveis

**RNF003 - Confiabilidade**

- Disponibilidade de 99,5% considerando dependência de Firebase
- Recuperação automática de falhas temporárias de conexão
- Backup automático de dados no Firebase
- Validação de integridade de dados em todas as operações

**RNF004 - Segurança**

- Autenticação obrigatória para acesso a qualquer funcionalidade
- Criptografia de dados em trânsito via HTTPS
- Controle de acesso granular via Firebase Security Rules
- Validação de dados de entrada para prevenção de ataques

**RNF005 - Portabilidade**

- Compatibilidade com Android 6.0+ (API level 23+)
- Compatibilidade com iOS 12.0+
- Interface responsiva para diferentes tamanhos de tela
- Funcionamento em tablets e smartphones

**RNF006 - Manutenibilidade**

- Código organizado seguindo Clean Architecture
- Documentação inline abrangente
- Cobertura de testes mínima de 80%
- Conformidade com linting rules do Dart

#### **4.1.3 Regras de negócio**

**RN001 - Hierarquia de Usuários**

- Professores podem gerenciar apenas alunos vinculados a eles
- Alunos podem visualizar apenas conteúdo destinado especificamente a eles
- Não existe comunicação direta entre alunos de professores diferentes

**RN002 - Gestão de Conteúdo**

- Postagens devem obrigatoriamente ter matéria e pelo menos um aluno destinatário
- Exclusão de aluno remove automaticamente todas as aulas agendadas para ele
- Imagens são comprimidas automaticamente para otimização de armazenamento

**RN003 - Cronograma**

- Não são permitidas duas aulas no mesmo horário para o mesmo professor
- Aulas são recorrentes semanalmente até serem removidas explicitamente
- Títulos de aulas podem ser personalizados pelo professor para cada aluno

**RN004 - Segurança de Dados**

- Dados de alunos são privados e acessíveis apenas ao professor vinculado
- Postagens são visíveis apenas aos alunos selecionados como destinatários
- Exclusão de dados é irreversível e deve ser confirmada pelo usuário

---

### 📊 **MÉTRICAS DA PARTE 1**

| **Seção**                   | **Requisitos**                    | **Palavras**     |
| --------------------------- | --------------------------------- | ---------------- |
| **4.1.1 Funcionais**        | 5 principais (RF001-RF005)        | 387 palavras     |
| **4.1.2 Não Funcionais**    | 6 categorias (RNF001-RNF006)      | 298 palavras     |
| **4.1.3 Regras de Negócio** | 4 regras principais (RN001-RN004) | 156 palavras     |
| **TOTAL PARTE 1**           | **15 requisitos documentados**    | **841 palavras** |

---

**📄 Continua na Parte 2: Modelagem do Sistema**
