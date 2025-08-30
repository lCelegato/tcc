# 📁 ESTRUTURA DO PROJETO TCC

## 📋 Visão Geral

Este projeto contém um **Trabalho de Conclusão de Curso (TCC)** completo sobre desenvolvimento de aplicação educacional com Flutter e Firebase, organizado de forma acadêmica e profissional.

## 🗂️ Estrutura de Diretórios

```
📁 docs/06-tcc-completo/
├── 📂 scripts-conversao/          # 🛠️ Utilitários para PDF
│   ├── concatenar-tcc.bat         # Script Windows (Batch)
│   ├── concatenar-tcc.sh          # Script Linux/Mac (Bash)
│   ├── concatenar-tcc.ps1         # Script PowerShell (Recomendado)
│   └── README-CONCATENACAO.md     # Instruções de uso
│
├── 📄 TCC-COMPLETO.md             # 📘 Arquivo concatenado (240KB)
├── 📄 ESTRUTURA-PROJETO.md        # 📋 Este arquivo
│
├── 🎓 ELEMENTOS PRÉ-TEXTUAIS
│   ├── 01-CAPA.md
│   ├── 02-FOLHA-DE-ROSTO.md
│   ├── 03-RESUMO.md
│   └── 04-SUMARIO.md
│
├── 📚 ELEMENTOS TEXTUAIS
│   ├── 05-CAP1-INTRODUCAO.md
│   ├── 06-CAP2-FUNDAMENTACAO.md
│   │
│   ├── 🔬 CAPÍTULO 3: METODOLOGIA (5 partes)
│   │   ├── 07-CAP3-METODOLOGIA.md
│   │   ├── 07-CAP3-METODOLOGIA-PARTE2.md
│   │   ├── 07-CAP3-METODOLOGIA-PARTE3.md
│   │   ├── 07-CAP3-METODOLOGIA-PARTE4.md
│   │   └── 07-CAP3-METODOLOGIA-PARTE5.md
│   │
│   ├── 💻 CAPÍTULO 4: DESENVOLVIMENTO (6 partes)
│   │   ├── 08-CAP4-DESENVOLVIMENTO-PARTE1.md
│   │   ├── 08-CAP4-DESENVOLVIMENTO-PARTE2.md
│   │   ├── 08-CAP4-DESENVOLVIMENTO-PARTE3.md
│   │   ├── 08-CAP4-DESENVOLVIMENTO-PARTE4.md
│   │   ├── 08-CAP4-DESENVOLVIMENTO-PARTE5.md
│   │   └── 08-CAP4-DESENVOLVIMENTO-PARTE6.md
│   │
│   ├── 09-CAP5-RESULTADOS.md
│   └── 10-CAP6-CONCLUSAO.md
│
└── 📖 ELEMENTOS PÓS-TEXTUAIS
    ├── 11-REFERENCIAS.md
    ├── 12-APENDICES.md
    └── 13-ANEXOS.md
```

## 📊 Estatísticas do TCC

| Métrica               | Valor                |
| --------------------- | -------------------- |
| **Total de Arquivos** | 25 arquivos          |
| **Palavras**          | ~28.500 palavras     |
| **Linhas**            | 6.524 linhas         |
| **Páginas Estimadas** | 95-105 páginas       |
| **Tamanho Final**     | 240KB (Markdown)     |
| **Referências**       | 37 fontes acadêmicas |

## 🎯 Características Técnicas

### ✅ Conformidade ABNT

- Estrutura conforme NBR 14724
- Formatação adequada para TCC
- Elementos pré, textuais e pós-textuais
- Referências conforme NBR 6023

### 🔧 Tecnologias Abordadas

- **Frontend:** Flutter/Dart
- **Backend:** Firebase (Auth, Firestore, Storage)
- **Armazenamento:** Base64 vs Firebase Storage
- **Arquitetura:** MVC, Clean Architecture
- **Segurança:** Autenticação e autorização
- **Plataforma:** Mobile multiplataforma

### 📝 Conteúdo Acadêmico

- Introdução com problemática clara
- Fundamentação teórica robusta
- Metodologia de desenvolvimento
- Implementação detalhada
- Resultados e análises
- Conclusões e trabalhos futuros

## 🚀 Como Usar

### 1. **Leitura Individual**

Abra qualquer arquivo `.md` para ler capítulos específicos.

### 2. **Geração do PDF Completo**

```bash
# Entrar na pasta de scripts
cd scripts-conversao

# Windows (Batch)
.\concatenar-tcc.bat

# Linux/Mac (Bash)
./concatenar-tcc.sh

# Windows (PowerShell - Recomendado)
.\concatenar-tcc.ps1
```

### 3. **Conversão para PDF**

**Opção A: Pandoc (Qualidade profissional)**

```bash
pandoc TCC-COMPLETO.md -o TCC.pdf --toc --number-sections
```

**Opção B: Typora (Mais fácil)**

1. Abrir `TCC-COMPLETO.md` no Typora
2. File → Export → PDF

**Opção C: VS Code + Markdown PDF**

1. Instalar extensão "Markdown PDF"
2. Abrir arquivo → Ctrl+Shift+P → "Export PDF"

## 🎓 Uso Acadêmico

### **Para Estudantes**

- Exemplo completo de TCC em Tecnologia
- Estrutura ABNT pronta para adaptação
- Metodologia de pesquisa aplicada
- Referências atualizadas e válidas

### **Para Professores**

- Material didático estruturado
- Exemplo de boas práticas acadêmicas
- Base para orientação de TCCs
- Modelo de documentação técnica

### **Para Desenvolvedores**

- Documentação técnica detalhada
- Arquitetura de aplicação educacional
- Análise de tecnologias móveis
- Padrões de desenvolvimento Flutter

## 🔄 Manutenção

### **Atualização de Conteúdo**

1. Editar arquivos `.md` individuais
2. Executar script de concatenação
3. Regenerar PDF se necessário

### **Adição de Novos Capítulos**

1. Criar novo arquivo `.md`
2. Atualizar scripts de concatenação
3. Ajustar numeração no sumário

### **Correções**

1. Identificar arquivo específico
2. Fazer edição pontual
3. Concatenar novamente

## 📞 Suporte

Para dúvidas sobre:

- **Estrutura ABNT:** Consultar NBR 14724
- **Scripts:** Ver `README-CONCATENACAO.md`
- **Tecnologias:** Documentação oficial Flutter/Firebase
- **Conversão PDF:** Testar diferentes ferramentas

---

## 🏆 Resultado Final

**Um TCC completo, profissional e pronto para apresentação!**

- ✅ **Estrutura acadêmica rigorosa**
- ✅ **Conteúdo técnico aprofundado**
- ✅ **Automação para PDF**
- ✅ **Organização profissional**
- ✅ **Fácil manutenção**

**Total: 25 arquivos organizados + scripts de automação = Projeto TCC completo! 🎓**
