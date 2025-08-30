# 4. DESENVOLVIMENTO

## 4.1 Estrutura da Aplicação

O desenvolvimento da aplicação iniciou-se com estabelecimento de uma estrutura organizacional clara que promovesse escalabilidade e facilidade de manutenção. A organização dos diretórios segue convenções estabelecidas pela comunidade Flutter, adaptadas para atender às necessidades específicas de uma aplicação educacional. A estrutura modular resultante facilita navegação no código e promove reutilização de componentes entre diferentes funcionalidades da aplicação.

A implementação dos modelos de dados focou em criar representações flexíveis e extensíveis dos elementos fundamentais do sistema educacional. O UserModel serve como base para todos os tipos de usuário, encapsulando atributos comuns como identificação, informações de contato e preferências básicas. Os modelos especializados AlunoModel e ProfessorModel estendem esta base adicionando atributos específicos para cada tipo de usuário, como informações acadêmicas para estudantes e credenciais profissionais para professores.

Cada modelo implementa métodos de serialização e deserialização que facilitam comunicação eficiente com o Firestore, garantindo que transformações entre representações objeto e JSON sejam transparentes para o restante da aplicação. A validação de dados ocorre tanto no nível de modelo quanto na interface de usuário, proporcionando feedback imediato para usuários enquanto mantém integridade dos dados no backend, seguindo princípios de engenharia de software robusta (IEEE, 1998).

## 4.2 Autenticação e Segurança

A implementação do sistema de autenticação representa um dos aspectos mais críticos da aplicação, dada a sensibilidade dos dados educacionais e a necessidade de diferenciação entre tipos de usuário. O Firebase Authentication foi configurado para suportar autenticação via email e senha, método escolhido por sua simplicidade para usuários educacionais e adequação para implementação de controles de acesso granulares.

O processo de cadastro incorpora validação robusta que verifica não apenas a formatação dos dados inseridos, mas também sua adequação para o contexto educacional específico. Durante o registro, a aplicação coleta informações que permitem classificação automática entre perfis de aluno e professor, utilizando estas informações para configurar permissões apropriadas no sistema. Esta diferenciação ocorre através de campos específicos no Firestore que são consultados durante o processo de login para determinar o tipo de interface e funcionalidades disponíveis para cada usuário.

O AuthController centraliza toda a lógica relacionada à gestão de sessões de usuário, implementando padrões de segurança que garantem proteção adequada contra ataques comuns como session hijacking e cross-site request forgery. A persistência de sessão utiliza recursos nativos do Firebase para manter usuários logados entre sessões da aplicação, implementando simultaneamente timeouts apropriados e renovação automática de tokens quando necessário.

As regras de segurança implementadas no Firestore garantem que usuários acessem apenas dados para os quais possuem permissão explícita. Estas regras são particularmente rigorosas para informações pessoais de estudantes, seguindo princípios de privacy by design que limitam acesso apenas ao mínimo necessário para funcionalidade da aplicação. Professores recebem permissões adicionais que lhes permitem visualizar informações de estudantes sob sua responsabilidade, mas sempre dentro de limitações claramente definidas.

## 4.3 Interface do Usuário

O design da interface de usuário fundamenta-se em princípios de Material Design 3, adaptados para atender às necessidades específicas de usuários educacionais. A paleta de cores foi cuidadosamente selecionada para promover ambiente acolhedor e profissional, utilizando tons de azul e verde que transmitem confiança e tranquilidade. A tipografia baseia-se na família Roboto, escolhida por sua legibilidade excepcional em diferentes tamanhos de tela e sua familiaridade para usuários de dispositivos Android.

A navegação da aplicação utiliza estrutura baseada em bottom navigation que fornece acesso rápido às funcionalidades principais através de ícones intuitivos e labels descritivos. Esta abordagem mostrou-se particularmente eficaz durante testes com usuários menos experientes tecnologicamente, que conseguiram navegar pela aplicação com mínima curva de aprendizado. O dashboard principal adapta-se dinamicamente baseado no tipo de usuário logado, apresentando informações e funcionalidades relevantes para cada perfil específico.

A responsividade da interface foi implementada utilizando widgets adaptativos que ajustam automaticamente layout e proporções baseados nas dimensões da tela disponível. Esta implementação garante experiência consistente entre smartphones e tablets, considerando que ambientes educacionais frequentemente utilizam dispositivos de diferentes tamanhos. Feedback visual adequado acompanha todas as interações do usuário, desde animações sutis durante navegação até indicadores de carregamento durante operações que requerem comunicação com o backend.

## 4.4 Gerenciamento de Dados

A estratégia de gerenciamento de dados implementada na aplicação equilibra eficiência, simplicidade e robustez para atender às demandas específicas do contexto educacional. A sincronização em tempo real é gerenciada através de listeners do Firestore que automaticamente atualizam a interface quando dados são modificados, seja pelo usuário atual ou por outros usuários conectados. Esta funcionalidade torna-se essencial em ambientes educacionais onde múltiplos usuários podem estar interagindo simultaneamente com os mesmos dados.

O sistema de cache local utiliza capacidades nativas do Firestore para manter cópias locais de dados frequentemente acessados, garantindo que a aplicação permaneça responsiva mesmo durante períodos de conectividade limitada. Esta implementação considera padrões de uso típicos em ambientes educacionais, priorizando cache de informações de perfil de usuário e dados acadêmicos essenciais. A sincronização automática reestabelece consistência assim que conectividade é restaurada.

A validação de dados ocorre em múltiplas camadas para garantir integridade e segurança. No frontend, validators customizados verificam formatação e completude de informações inseridas pelos usuários, fornecendo feedback imediato quando necessário. No backend, as regras de segurança do Firestore implementam validações adicionais que verificam não apenas formato dos dados, mas também autorização do usuário para realizar modificações específicas. Esta abordagem em camadas garante que dados inválidos ou não autorizados nunca sejam persistidos no sistema.

O tratamento de arquivos pequenos através de codificação Base64 simplifica significativamente a arquitetura da aplicação ao eliminar necessidade de coordenação entre múltiplos serviços de armazenamento. Esta abordagem mostrou-se adequada para imagens de perfil e documentos de tamanho limitado, oferecendo sincronização automática com outros dados do usuário sem complexidade adicional. Para casos onde arquivos maiores se tornarem necessários, a aplicação mantém infraestrutura preparada para utilização do Firebase Storage através de referências armazenadas no Firestore.

\newpage
