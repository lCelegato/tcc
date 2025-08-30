# **CAPÍTULO 3 - METODOLOGIA - PARTE 2**

---

## **3.2 Tecnologias utilizadas**

A seleção de tecnologias para desenvolvimento do sistema baseou-se em critérios técnicos específicos incluindo performance, escalabilidade, facilidade de manutenção, custo de desenvolvimento e adequação aos requisitos funcionais e não funcionais identificados.

### **3.2.1 Critérios de seleção tecnológica**

**Performance:** Tempo de resposta da aplicação, fluidez da interface e consumo eficiente de recursos do dispositivo.

**Escalabilidade:** Capacidade de suportar crescimento no número de usuários e volume de dados sem degradação significativa de performance.

**Manutenibilidade:** Facilidade de evolução, correção de bugs e adição de novas funcionalidades ao longo do tempo.

**Curva de Aprendizagem:** Complexidade de adoção das tecnologias pela equipe de desenvolvimento.

**Ecossistema:** Disponibilidade de bibliotecas, ferramentas e comunidade de suporte.

**Custo:** Investimento necessário em licenças, infraestrutura e recursos humanos especializados.

### **3.2.2 Frontend - Flutter Framework**

**Flutter 3.35.1** foi selecionado como framework principal para desenvolvimento da interface de usuário após análise comparativa com React Native, Xamarin e desenvolvimento nativo.

**Justificativas Técnicas:**

**Compilação Nativa:** Flutter compila para código ARM nativo, eliminando overhead de bridge JavaScript presente em outras soluções multiplataforma, resultando em performance superior (WENHAO, 2019).

**Rendering Engine Próprio:** Utilização de Skia Graphics Library garante consistência visual absoluta entre plataformas, diferentemente de frameworks que dependem de componentes nativos específicos de cada sistema.

**Hot Reload:** Funcionalidade permite visualização imediata de mudanças no código sem perda de estado da aplicação, acelerando significativamente o ciclo de desenvolvimento.

**Widget System:** Arquitetura baseada em widgets composáveis facilita criação de interfaces complexas através de combinação de componentes simples e reutilizáveis.

**Dart Language:** Linguagem moderna com null safety, async/await nativo e performance otimizada para desenvolvimento de interfaces de usuário.

### **3.2.3 Packages Flutter utilizados**

**Provider 6.1.5:** Gerenciamento de estado reativo baseado em InheritedWidget, proporcionando propagação eficiente de mudanças de estado através da árvore de widgets.

**Image Picker 1.2.0:** Captura e seleção de imagens através de câmera ou galeria, com suporte multiplataforma e tratamento automático de permissões.

**File Picker 10.3.2:** Seleção de documentos do sistema de arquivos com suporte a múltiplos formatos (PDF, DOC, DOCX, TXT, RTF, ODT).

**Permission Handler 12.0.1:** Gerenciamento de permissões do sistema operacional de forma unificada entre Android e iOS.

**Cupertino Icons 1.0.8:** Conjunto de ícones seguindo design guidelines da Apple, garantindo consistência visual em dispositivos iOS.

---

### 📊 **MÉTRICAS DA PARTE 2**

| **Seção**           | **Palavras**     | **Conteúdo**            |
| ------------------- | ---------------- | ----------------------- |
| **3.2.1 Critérios** | 156 palavras     | Metodologia de seleção  |
| **3.2.2 Flutter**   | 198 palavras     | Justificativa técnica   |
| **3.2.3 Packages**  | 145 palavras     | Dependências utilizadas |
| **TOTAL PARTE 2**   | **499 palavras** | **≈2 páginas**          |

---

**📄 Continua na Parte 3: Backend Technologies**
