# 6. CONCLUSÃO

## 6.1 Contribuições do Trabalho

Esta pesquisa oferece contribuições significativas tanto para o campo acadêmico quanto para a prática profissional de desenvolvimento de aplicações móveis educacionais. Do ponto de vista técnico, o trabalho demonstra empiricamente a viabilidade e eficácia da combinação Flutter-Firebase para criação de soluções educacionais robustas e escaláveis. A validação prática desta combinação tecnológica através de implementação completa e testes abrangentes fornece evidências concretas que podem orientar decisões arquiteturais em projetos similares.

A contribuição metodológica reside na adaptação bem-sucedida de princípios de desenvolvimento ágil para o contexto acadêmico, demonstrando como metodologias industriais podem ser efetivamente aplicadas em projetos de pesquisa aplicada. O framework de testes desenvolvido, que combina validação funcional com testes de usabilidade específicos para aplicações educacionais, pode servir como modelo para avaliação de soluções similares. A documentação detalhada do processo de desenvolvimento e das decisões arquiteturais tomadas contribui para o corpo de conhecimento disponível sobre desenvolvimento Flutter em contexto educacional.

As contribuições práticas incluem uma aplicação funcional que pode ser imediatamente utilizada em ambientes educacionais reais, demonstrando que pesquisa acadêmica pode resultar em soluções práticas de valor imediato. O código-fonte documentado e a arquitetura modular facilitam adaptação e extensão da solução para diferentes contextos educacionais, multiplicando o impacto prático da pesquisa. O conjunto de boas práticas identificadas durante o desenvolvimento oferece orientação valiosa para desenvolvedores que pretendem criar soluções similares.

## 6.2 Limitações

As limitações desta pesquisa refletem tanto constraintes temporais e de escopo quanto escolhas tecnológicas específicas que podem não ser adequadas para todos os contextos educacionais. A dependência de conectividade para funcionalidades principais, embora mitigada através de estratégias de cache, ainda representa limitação significativa para ambientes com conectividade severamente restrita. A estratégia de armazenamento Base64, embora adequada para arquivos pequenos, não escala eficientemente para casos onde usuários necessitam gerenciar documentos ou mídia de tamanho substancial.

O escopo funcional da aplicação, deliberadamente limitado para manter foco na validação da combinação tecnológica proposta, resulta em ausência de funcionalidades avançadas que podem ser esperadas em sistemas educacionais completos. A ausência de sistema de notas e avaliações, funcionalidades de mensagem em tempo real e capacidades de gestão de turmas representa limitações que podem afetar aplicabilidade da solução em certos contextos educacionais mais complexos.

As limitações de validação incluem o tamanho restrito do grupo de teste e o período limitado de observação, que podem não capturar adequadamente padrões de uso em longo prazo ou identificar problemas que emergem apenas após uso extensivo. A validação em ambiente controlado, embora metodologicamente sound, pode não refletir completamente desafios que emergiriam em deployment real com maior número de usuários e variabilidade de dispositivos e condições de rede.

## 6.3 Trabalhos Futuros

As oportunidades para trabalhos futuros emergen naturalmente das limitações identificadas e do potencial demonstrado pela solução base desenvolvida. A implementação de sistema de mensagens em tempo real representaria extensão valuable que aproveitaria as capacidades de sincronização do Firestore para crear funcionalidades de comunicação que facilitariam colaboração entre estudantes e professores. Esta expansão requeriria consideração cuidadosa de aspectos de moderação e segurança apropriados para contexto educacional.

O desenvolvimento de módulo abrangente de avaliações e notas constituiria adição significativa que transformaria a aplicação de ferramenta de gestão básica em sistema educacional mais completo. Esta funcionalidade apresentaria desafios interessantes relacionados à implementação de diferentes tipos de avaliação, gestão de prazos e feedback automatizado, oferecendo oportunidades para pesquisa adicional em design de sistemas educacionais digitais.

A integração com sistemas de videoconferência para suporte a ensino remoto representaria extensão particularmente relevante considerando mudanças recentes em práticas educacionais. Esta integração requeriria investigação de APIs de terceiros e consideração de aspectos como bandwidth management e quality of service em diferentes condições de rede.

A implementação de Progressive Web App (PWA) alongside da aplicação móvel nativa ofereceria maior flexibilidade de deployment e acesso, particularmente em ambientes onde instalação de aplicações móveis pode ser restricted. Esta expansão permitiria investigação comparativa entre performance de aplicações híbridas e nativas no contexto educacional específico.

Estudos futuros poderiam investigar impacto pedagógico real da aplicação através de deployment em ambientes educacionais reais com medição de outcomes de aprendizagem e satisfação de longo prazo. Pesquisa comparativa com outras tecnologias de desenvolvimento móvel, incluindo React Native e soluções nativas, forneceria insights valiosos sobre trade-offs entre diferentes abordagens arquiteturais para aplicações educacionais.

A investigação de recursos de acessibilidade para usuários com deficiências representaria extensão importante que expandiria significativamente o alcance potential da solução. Esta pesquisa incluiria implementação de suporte a screen readers, navegação por voz e outras tecnologias assistivas relevantes para contexto educacional.

A exploração de elementos de gamificação poderia investigar como técnicas de game design podem ser integradas à aplicação educacional sem comprometer seriedade e eficácia do ambiente de aprendizagem. Esta pesquisa ofereceria oportunidades para estudar engajamento de estudantes e motivação em contextos educacionais digitais.

Este trabalho demonstra que a combinação Flutter-Firebase oferece base sólida para desenvolvimento de aplicações educacionais modernas, proporcionando tanto viabilidade técnica quanto utilidade prática. Os resultados confirmam que esta abordagem tecnológica pode reduzir significativamente tempo de desenvolvimento e complexidade, mantendo padrões de performance e experiência de usuário apropriados para contextos educacionais. A validação através de testes abrangentes confirma que a solução proposta atende aos requisitos para aplicações educacionais do mundo real, fornecendo fundação sólida para futuras expansões e melhorias.

\newpage
