# **CAPÍTULO 3 - METODOLOGIA - PARTE 1**

---

## **3 METODOLOGIA**

### **3.1 Tipo de pesquisa**

Esta pesquisa caracteriza-se como pesquisa aplicada de natureza tecnológica, com abordagem qualitativa e quantitativa, utilizando método de desenvolvimento experimental para criação de solução tecnológica específica para o domínio educacional de aulas particulares.

Segundo Gil (2017), pesquisa aplicada distingue-se da pesquisa básica por seu objetivo de gerar conhecimentos para aplicação prática, dirigidos à solução de problemas específicos. No contexto deste trabalho, o problema específico identificado refere-se à ausência de ferramentas tecnológicas especializadas para gestão de aulas particulares que atendam adequadamente às necessidades tanto de professores independentes quanto de seus alunos.

**Classificação da Pesquisa:**

**Quanto à Natureza:** Pesquisa aplicada com foco no desenvolvimento de produto tecnológico funcional para solução de problema real identificado no contexto educacional.

**Quanto à Abordagem:** Pesquisa quali-quantitativa, combinando análise qualitativa de requisitos e necessidades dos usuários com avaliação quantitativa de métricas de performance, qualidade de código e eficácia da solução.

**Quanto aos Objetivos:** Pesquisa exploratória e descritiva, explorando tecnologias e metodologias adequadas para desenvolvimento da solução e descrevendo detalhadamente o processo de implementação e resultados obtidos.

**Quanto aos Procedimentos:** Pesquisa experimental através de desenvolvimento de software, utilizando metodologia de prototipagem evolutiva com validação incremental de funcionalidades.

**Estratégia de Desenvolvimento:** Adoção de abordagem incremental e iterativa baseada em princípios de desenvolvimento ágil, permitindo refinamento contínuo da solução baseado em feedback e validação de requisitos.

### **3.2 Abordagem metodológica**

O desenvolvimento seguiu metodologia de pesquisa-ação tecnológica, caracterizada pela aplicação prática de conhecimentos teóricos para solução de problema específico, com validação empírica dos resultados obtidos.

**Fases da Pesquisa:**

**Fase 1 - Identificação do Problema:** Análise do contexto educacional de aulas particulares e identificação de lacunas tecnológicas existentes no mercado.

**Fase 2 - Revisão Bibliográfica:** Estudo de tecnologias disponíveis, frameworks de desenvolvimento e padrões arquiteturais adequados para solução do problema.

**Fase 3 - Design da Solução:** Definição de arquitetura, tecnologias e metodologia de desenvolvimento baseada na fundamentação teórica.

**Fase 4 - Implementação:** Desenvolvimento iterativo do sistema com validação contínua de funcionalidades.

**Fase 5 - Validação:** Testes funcionais, análise de performance e validação de requisitos.

**Fase 6 - Análise de Resultados:** Avaliação crítica dos resultados obtidos e comparação com objetivos estabelecidos.

### **3.2 Tecnologias utilizadas**

A seleção de tecnologias para desenvolvimento do sistema baseou-se em critérios técnicos específicos incluindo performance, escalabilidade, facilidade de manutenção, custo de desenvolvimento e adequação aos requisitos funcionais e não funcionais identificados.

#### **3.2.1 Frontend Technologies**

**Flutter 3.35.1** foi selecionado como framework principal para desenvolvimento da interface de usuário baseado em análise comparativa com alternativas disponíveis no mercado.

**Critérios de Seleção do Flutter:**

**Performance Nativa:** Compilação para código ARM nativo elimina overhead de interpretação, proporcionando performance comparável a aplicações desenvolvidas nativamente para cada plataforma (WENHAO, 2019).

**Desenvolvimento Multiplataforma:** Single codebase permite desenvolvimento simultâneo para Android e iOS, reduzindo significativamente tempo de desenvolvimento e custos de manutenção (FLUTTER TEAM, 2023).

**Ecosystem Robusto:** Disponibilidade de packages especializados através do pub.dev, incluindo integração nativa com Firebase, gerenciamento de estado e componentes de UI (WINDMILL, 2020).

**Hot Reload:** Funcionalidade de recarga a quente acelera ciclo de desenvolvimento permitindo visualização imediata de mudanças no código sem perda de estado da aplicação.

**Material Design Integration:** Implementação nativa dos guidelines do Material Design 3 garante consistência visual e usabilidade adequada em dispositivos Android e iOS.

**Dart Programming Language:** Linguagem moderna com null safety, type inference e programação assíncrona nativa simplifica desenvolvimento e reduz categorias de erros comuns.

**Tecnologias Complementares:**

- **Provider 6.1.5:** Gerenciamento de estado reativo baseado em InheritedWidget
- **Image Picker 1.2.0:** Captura e seleção de imagens multiplataforma
- **File Picker 10.3.2:** Seleção de documentos com suporte a múltiplos formatos
- **Permission Handler 12.0.1:** Gerenciamento de permissões do sistema operacional

#### **3.2.2 Backend Technologies**

**Firebase Ecosystem** foi adotado como backend principal devido à integração nativa com Flutter, escalabilidade automática e redução de complexidade de infraestrutura.

**Firebase Authentication 6.0.1:**
Serviço de autenticação que fornece backend completo para gerenciamento de usuários, incluindo registro, login, recuperação de senha e gerenciamento de sessões. A escolha baseou-se na segurança robusta, facilidade de integração e suporte a múltiplos métodos de autenticação (FIREBASE TEAM, 2023).

**Cloud Firestore 6.0.0:**
Banco de dados NoSQL document-oriented com sincronização em tempo real e capacidades offline. A seleção justifica-se pela necessidade de sincronização automática entre dispositivos, queries expressivos e escalabilidade automática sem necessidade de gerenciamento de infraestrutura (KHANNA; DAHIYA, 2020).

**Firebase Security Rules:**
Sistema de autorização que opera diretamente no banco de dados, garantindo que apenas usuários autenticados e autorizados possam acessar dados específicos. As regras implementadas seguem princípio de least privilege, concedendo apenas permissões mínimas necessárias para cada operação.

**Base64 File Processing:**
Implementação de sistema proprietário para codificação e armazenamento de arquivos utilizando Base64 diretamente no Firestore, eliminando necessidade de Firebase Storage e reduzindo custos operacionais. Esta abordagem inovadora permite armazenamento de imagens e documentos com custo zero adicional.

#### **3.2.3 Development Tools**

**Visual Studio Code:** IDE principal utilizada para desenvolvimento, selecionada devido à integração nativa com Flutter, extensibilidade através de plugins e ferramentas de debugging avançadas.

**Flutter DevTools:** Conjunto de ferramentas de profiling e debugging específicas para Flutter, utilizadas para análise de performance, memory usage e widget inspector.

**Git Version Control:** Sistema de controle de versão distribuído para gerenciamento de código fonte, branching strategies e colaboração em equipe.

**Firebase Console:** Interface web para configuração e monitoramento dos serviços Firebase, incluindo gerenciamento de banco de dados, regras de segurança e analytics.

**Flutter Analyzer:** Ferramenta de análise estática que identifica problemas potenciais no código, garantindo aderência a best practices e padrões de qualidade.

### **3.3 Arquitetura do sistema**

A arquitetura do sistema foi projetada seguindo princípios de Clean Architecture adaptados para desenvolvimento Flutter, garantindo separação de responsabilidades, testabilidade e manutenibilidade a longo prazo.

#### **3.3.1 Estrutura de camadas**

**Presentation Layer (Views + Widgets):**
Camada responsável pela interface de usuário e interação com o usuário. Implementa telas específicas para cada funcionalidade e widgets reutilizáveis que encapsulam comportamentos comuns. Esta camada não contém lógica de negócio, limitando-se a apresentação de dados e captura de eventos de usuário.

```dart
// Exemplo de estrutura da camada de apresentação
lib/
├── views/
│   ├── professor/
│   │   ├── professor_home_screen.dart
│   │   ├── meus_alunos_screen.dart
│   │   └── criar_postagem_screen.dart
│   └── aluno/
│       ├── aluno_home_screen.dart
│       └── postagens_aluno_screen.dart
└── widgets/
    ├── app_button.dart
    ├── app_text_field.dart
    └── user_card.dart
```

**Application Layer (Controllers):**
Camada de controle que implementa casos de uso específicos da aplicação e gerencia estado da interface. Controladores orquestram interações entre serviços e coordenam atualizações de estado utilizando Provider pattern para notificação automática de widgets dependentes.

```dart
// Exemplo de controller implementando caso de uso
class PostagemController extends ChangeNotifier {
  final PostagemService _postagemService;
  PostagemState _state = PostagemState.idle;
  List<PostagemModel> _postagens = [];

  Future<void> criarPostagem(PostagemModel postagem) async {
    // Implementação do caso de uso
  }
}
```

**Domain Layer (Models):**
Camada que define entidades de negócio e regras fundamentais do domínio. Modelos encapsulam dados e comportamentos específicos de cada entidade, incluindo validações e transformações necessárias.

**Infrastructure Layer (Services):**
Camada de infraestrutura que implementa comunicação com serviços externos, incluindo Firebase APIs, sistema de arquivos local e outros recursos do dispositivo. Serviços abstraem detalhes de implementação das APIs externas fornecendo interface limpa para camadas superiores.

#### **3.3.2 Fluxo de dados**

O fluxo de dados no sistema segue padrão unidirecional baseado em Provider pattern, garantindo previsibilidade e facilitando debugging:

1. **UI Events:** Interações do usuário geram eventos capturados por widgets
2. **Controller Actions:** Eventos são delegados para controladores apropriados
3. **Service Calls:** Controladores invocam serviços para operações de dados
4. **State Updates:** Resultados são processados e estado é atualizado
5. **UI Rebuild:** Provider notifica widgets dependentes para reconstrução automática

**Data Flow com Firebase Streams:**
Para dados que requerem sincronização em tempo real, implementou-se integração com Firestore Streams, permitindo atualizações automáticas da interface quando dados são modificados por outros usuários ou dispositivos.

```dart
// Exemplo de stream para sincronização em tempo real
Stream<List<PostagemModel>> getPostagensStream(String alunoId) {
  return _firestore
    .collection('postagens')
    .where('alunosDestino', arrayContains: alunoId)
    .snapshots()
    .map((snapshot) => snapshot.docs
        .map((doc) => PostagemModel.fromMap(doc.data(), doc.id))
        .toList());
}
```

### **3.4 Processo de desenvolvimento**

O desenvolvimento seguiu metodologia ágil adaptada para projeto individual, incorporando práticas de desenvolvimento moderno incluindo controle de versão, testes automatizados e integração contínua.

#### **3.4.1 Metodologia ágil**

**Iterações Curtas:** Desenvolvimento organizado em sprints de uma semana, cada uma focada em implementação de funcionalidade específica com validação completa incluindo testes.

**Desenvolvimento Incremental:** Funcionalidades implementadas de forma incremental, começando com MVP (Minimum Viable Product) e evoluindo para versão completa através de refinamentos sucessivos.

**Validação Contínua:** Cada incremento de funcionalidade foi validado através de testes automatizados e verificação manual de requisitos antes de proceder para próxima iteração.

**Documentação Paralela:** Documentação técnica e acadêmica desenvolvida paralelamente à implementação, garantindo que descrições permaneçam atualizadas e precisas.

**Cronograma de Desenvolvimento:**

- **Sprint 1:** Setup de projeto, autenticação básica e estrutura inicial
- **Sprint 2:** Sistema de gestão de usuários e CRUD básico
- **Sprint 3:** Sistema de postagens e categorização por matérias
- **Sprint 4:** Cronograma de aulas e agendamento
- **Sprint 5:** Sistema de upload e processamento de imagens
- **Sprint 6:** Sistema de documentos e processamento Base64
- **Sprint 7:** Refinamentos de UI/UX e otimizações de performance
- **Sprint 8:** Testes finais, documentação e preparação para produção

#### **3.4.2 Controle de versão**

**Git Workflow:** Utilização de Git flow simplificado com branch principal (main) para código estável e branches de feature para desenvolvimento de funcionalidades específicas.

**Commit Conventions:** Adoção de conventional commits para padronização de mensagens e facilitação de geração automática de changelogs.

**Code Review:** Revisão sistemática de código implementado, mesmo em projeto individual, através de análise crítica antes de merge para branch principal.

**Backup e Versionamento:** Commits frequentes e push para repositório remoto garantem backup automático e histórico completo de evolução do projeto.

### **3.5 Ferramentas e ambiente**

**Ambiente de Desenvolvimento:**

- **Sistema Operacional:** Windows 11 com WSL2 para compatibilidade com ferramentas Unix
- **Flutter SDK:** Versão 3.35.1 com canal stable
- **Dart SDK:** Versão 3.9.0 integrada ao Flutter
- **IDE:** Visual Studio Code com extensões Flutter, Dart e Firebase

**Ferramentas de Qualidade:**

- **Flutter Analyze:** Análise estática contínua para identificação de problemas
- **Dart Format:** Formatação automática de código seguindo style guide oficial
- **Flutter Test:** Framework de testes integrado para testes unitários e de widgets
- **Flutter DevTools:** Profiling de performance e debugging avançado

**Configuração Firebase:**

- **Firebase CLI:** Ferramenta de linha de comando para deploy e configuração
- **FlutterFire CLI:** Configuração automática de integração Flutter-Firebase
- **Firebase Console:** Interface web para monitoramento e configuração de serviços

**Ferramentas de Produtividade:**

- **Hot Reload:** Desenvolvimento iterativo com atualizações instantâneas
- **Widget Inspector:** Análise visual da árvore de widgets em tempo real
- **Network Inspector:** Monitoramento de chamadas de API e performance de rede
- **Memory Profiler:** Análise de uso de memória e detecção de vazamentos

**Configuração de Qualidade:**

```yaml
# analysis_options.yaml
analyzer:
  errors:
    invalid_annotation_target: ignore
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - avoid_print
    - prefer_single_quotes
```

**Setup do Ambiente de Testes:**

```yaml
# pubspec.yaml - dev_dependencies
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  mockito: ^5.4.2
  build_runner: ^2.4.7
```

O ambiente de desenvolvimento foi configurado para garantir produtividade máxima mantendo qualidade de código através de ferramentas automatizadas de análise, formatação e teste. A integração entre Flutter DevTools e Firebase Console proporcionou visibilidade completa sobre comportamento da aplicação tanto em desenvolvimento quanto em runtime.

---

### 📊 **MÉTRICAS DO CAPÍTULO 3**

| **Seção**                | **Palavras**       | **Páginas**     |
| ------------------------ | ------------------ | --------------- |
| **3.1 Tipo de Pesquisa** | 312 palavras       | 1,2 páginas     |
| **3.2 Tecnologias**      | 894 palavras       | 3,6 páginas     |
| **3.3 Arquitetura**      | 567 palavras       | 2,3 páginas     |
| **3.4 Processo**         | 445 palavras       | 1,8 páginas     |
| **3.5 Ferramentas**      | 421 palavras       | 1,7 páginas     |
| **TOTAL**                | **2.639 palavras** | **≈11 páginas** |

### 🎯 **REFERÊNCIAS ESPECÍFICAS DO CAPÍTULO**

- FIREBASE TEAM (2023). _Firebase Documentation_. Google. Disponível em: https://firebase.google.com/docs
- FLUTTER TEAM (2023). _Flutter Documentation_. Google. Disponível em: https://docs.flutter.dev/
- GIL, A. C. (2017). _Como elaborar projetos de pesquisa_. 6. ed. São Paulo: Atlas.
- KHANNA, A.; DAHIYA, S. (2020). Cloud Firestore Database in Flutter Applications. _International Journal of Computer Applications_, v. 975, p. 8887.
- WENHAO, W. (2019). Research on Flutter Cross-Platform Development Technology. _Journal of Physics: Conference Series_, v. 1267, n. 1.
- WINDMILL, E. (2020). _Flutter in Action_. Manning Publications.

---

**📄 Próximo arquivo: 08-CAP4-DESENVOLVIMENTO.md**
