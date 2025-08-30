# 3. METODOLOGIA

## 3.1 Abordagem da Pesquisa

Esta pesquisa adota uma abordagem qualitativa de natureza aplicada, fundamentada em metodologia experimental que combina desenvolvimento prático com validação empírica. A estratégia metodológica integra elementos de pesquisa bibliográfica para fundamentação teórica, desenvolvimento iterativo baseado em princípios ágeis para criação da aplicação, e testes de usabilidade para validação da solução proposta.

O processo de pesquisa iniciou-se com revisão bibliográfica abrangente focada em identificar as principais tendências e desafios no desenvolvimento de aplicações móveis educacionais. Esta fase permitiu compreender o estado da arte em frameworks multiplataforma, particularmente Flutter, e soluções backend-as-a-service, com ênfase especial no Firebase. A análise da literatura existente também proporcionou insights sobre melhores práticas em design de aplicações educacionais e padrões arquiteturais mais adequados para este domínio específico.

A metodologia de desenvolvimento adotada baseia-se em princípios ágeis, implementados através de sprints semanais que priorizam entregas incrementais e feedback contínuo (BECK, 2004). Esta abordagem mostrou-se particularmente adequada para o contexto educacional, onde requisitos podem evoluir rapidamente e a validação com usuários finais torna-se essencial para garantir adequação da solução. Cada sprint incluiu fases de planejamento, desenvolvimento, testes e retrospectiva, permitindo refinamento contínuo tanto dos aspectos técnicos quanto da experiência de usuário.

## 3.2 Tecnologias Utilizadas

A seleção das tecnologias empregadas neste projeto fundamentou-se em critérios rigorosos que consideraram aspectos como maturidade da tecnologia, qualidade da documentação, suporte da comunidade, performance esperada e adequação específica para o domínio educacional. O Flutter foi escolhido como framework principal devido à sua capacidade comprovada de gerar código nativo de alta performance para múltiplas plataformas a partir de uma única base de código.

A linguagem Dart, utilizada pelo Flutter, oferece vantagens significativas para desenvolvimento de aplicações complexas através de sua sintaxe clara e moderna, sistema de tipos robusto e capacidades avançadas de programação orientada a objetos. O sistema de gerenciamento de estado Provider foi selecionado para coordenação de dados entre diferentes componentes da aplicação, oferecendo simplicidade de implementação sem comprometer a escalabilidade da solução.

No frontend, a biblioteca Material Design fornece componentes visuais consistentes que seguem as diretrizes de design do Google, garantindo familiaridade para usuários acostumados com aplicações Android modernas. Esta escolha também facilita a manutenção da consistência visual entre diferentes telas e funcionalidades da aplicação, contribuindo para uma experiência de usuário coesa e profissional.

O Firebase foi selecionado como plataforma backend devido à sua integração nativa com Flutter e à comprehensive suite de serviços que elimina a necessidade de desenvolvimento de infraestrutura backend customizada. O Firebase Authentication oferece sistema de autenticação robusto e seguro, enquanto o Cloud Firestore fornece banco de dados NoSQL com capacidades de sincronização em tempo real essenciais para aplicações colaborativas educacionais.

## 3.3 Arquitetura do Sistema

A arquitetura da aplicação segue o padrão Model-View-Controller (MVC), escolhido por sua adequação para aplicações Flutter e sua capacidade de promover separação clara de responsabilidades entre diferentes camadas da aplicação (REENSKAUG, 1979). Esta abordagem arquitetural facilita manutenção, testes e futuras expansões da aplicação, além de promover reutilização de código e modularidade (FOWLER, 2002).

A camada Model engloba todas as estruturas de dados utilizadas na aplicação, incluindo modelos para usuários, alunos e professores. Estes modelos encapsulam não apenas a estrutura dos dados, mas também validações específicas e métodos de serialização necessários para comunicação com o Firebase. A implementação destes modelos considerou princípios de design orientado a objetos, incluindo encapsulamento adequado e interfaces claras para interação com outras camadas da aplicação (GAMMA et al., 1994).

A camada View concentra toda a lógica de apresentação, implementada através de widgets Flutter organizados hierarquicamente. O design desta camada enfatiza reutilização através de widgets customizados que encapsulam funcionalidades específicas, facilitando manutenção e garantindo consistência visual. A responsividade foi implementada utilizando LayoutBuilder e MediaQuery para garantir adequação automática a diferentes tamanhos de tela e orientações.

A camada Controller gerencia toda a lógica de negócio e comunicação com serviços externos, particularmente o Firebase. Os controllers implementam padrões de programação assíncrona utilizando Futures e Streams para garantir que operações de rede não bloqueiem a interface de usuário. Esta camada também implementa estratégias de tratamento de erros robustas que garantem experiência de usuário suave mesmo em condições adversas de conectividade.

A estratégia de armazenamento de dados reflete uma análise cuidadosa dos requisitos específicos da aplicação educacional. Para todos os arquivos da aplicação, incluindo imagens de perfil e documentos, optou-se por armazenamento direto no Firestore utilizando codificação Base64. Esta decisão fundamenta-se na simplicidade de implementação, eliminação de custos adicionais de serviços de armazenamento externos, redução de complexidade de sincronização e adequação para o volume de dados típico em aplicações educacionais básicas. A limitação de arquivos a tamanhos menores (até 1MB) atende adequadamente às necessidades educacionais identificadas, mantendo a solução economicamente viável e tecnicamente simples.

\newpage
