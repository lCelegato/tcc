# 📋 INSTRUÇÕES PARA CONCATENAÇÃO E CONVERSÃO PDF

Este diretório (`scripts-conversao/`) contém scripts para concatenar todos os arquivos do TCC em um único arquivo Markdown, facilitando a conversão posterior para PDF.

## 📁 Estrutura de Arquivos

```
docs/06-tcc-completo/
├── scripts-conversao/          # 📂 Pasta com utilitários de conversão
│   ├── concatenar-tcc.bat      # Script Windows (Batch)
│   ├── concatenar-tcc.sh       # Script Linux/Mac (Bash)
│   ├── concatenar-tcc.ps1      # Script Windows (PowerShell)
│   └── README-CONCATENACAO.md  # Este arquivo
├── 01-CAPA.md                  # 📄 Arquivos do TCC...
├── 02-FOLHA-DE-ROSTO.md
├── ...
└── TCC-COMPLETO.md             # 📄 Arquivo gerado pelos scripts
```

## 🛠️ Scripts Disponíveis

### 1. **concatenar-tcc.bat** (Windows - Batch)

Script simples para Windows usando CMD.

**Como usar:**

```cmd
cd c:\Programacao\tcc\docs\06-tcc-completo\scripts-conversao
concatenar-tcc.bat
```

### 2. **concatenar-tcc.sh** (Linux/Mac - Bash)

Script para sistemas Unix com validações.

**Como usar:**

```bash
cd /c/Programacao/tcc/docs/06-tcc-completo/scripts-conversao
chmod +x concatenar-tcc.sh
./concatenar-tcc.sh
```

### 3. **concatenar-tcc.ps1** (PowerShell - Recomendado)

Script mais avançado com validações e estatísticas.

**Como usar:**

```powershell
cd c:\Programacao\tcc\docs\06-tcc-completo\scripts-conversao
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\concatenar-tcc.ps1
```

**Opções avançadas:**

```powershell
# Gerar sem quebras de página
.\concatenar-tcc.ps1 -AddPageBreaks:$false

# Arquivo customizado
.\concatenar-tcc.ps1 -OutputFile "MEU-TCC.md"

# Sem validações
.\concatenar-tcc.ps1 -ValidateFiles:$false -ShowStats:$false
```

## 📄 Arquivo Gerado

Todos os scripts geram: **`TCC-COMPLETO.md`**

### Estrutura do arquivo concatenado:

```
📁 TCC-COMPLETO.md
├── 01-CAPA.md
├── 02-FOLHA-DE-ROSTO.md
├── 03-RESUMO.md
├── 04-SUMARIO.md
├── 05-CAP1-INTRODUCAO.md
├── 06-CAP2-FUNDAMENTACAO.md
├── 07-CAP3-METODOLOGIA.md (6 partes)
├── 08-CAP4-DESENVOLVIMENTO.md (6 partes)
├── 09-CAP5-RESULTADOS.md
├── 10-CAP6-CONCLUSAO.md
├── 11-REFERENCIAS.md
├── 12-APENDICES.md
└── 13-ANEXOS.md
```

## 🔄 Conversão para PDF

### **Opção 1: Pandoc (Recomendado para qualidade)**

```bash
# Instalação do Pandoc
# Windows: choco install pandoc
# Mac: brew install pandoc
# Linux: sudo apt install pandoc

# Conversão básica
pandoc TCC-COMPLETO.md -o TCC-COMPLETO.pdf

# Conversão avançada com índice
pandoc TCC-COMPLETO.md -o TCC-COMPLETO.pdf \
  --toc \
  --toc-depth=3 \
  --number-sections \
  --highlight-style=tango \
  --pdf-engine=xelatex

# Com template customizado
pandoc TCC-COMPLETO.md -o TCC-COMPLETO.pdf \
  --template=template-abnt.latex \
  --variable=geometry:margin=2.5cm
```

### **Opção 2: Typora (Mais fácil)**

1. Instalar Typora: https://typora.io/
2. Abrir `TCC-COMPLETO.md`
3. File → Export → PDF
4. Ajustar configurações (margens, fonte, etc.)
5. Exportar

### **Opção 3: VS Code + Markdown PDF**

1. Instalar extensão "Markdown PDF"
2. Abrir `TCC-COMPLETO.md` no VS Code
3. Ctrl+Shift+P → "Markdown PDF: Export (pdf)"

### **Opção 4: Notion**

1. Criar nova página no Notion
2. Importar arquivo Markdown
3. Export → PDF

### **Opção 5: GitBook**

1. Criar novo espaço no GitBook
2. Importar Markdown
3. Publicar → Export PDF

## ⚙️ Configurações Recomendadas para PDF

### **Margens ABNT:**

- Superior: 3cm
- Inferior: 2cm
- Esquerda: 3cm
- Direita: 2cm

### **Fonte ABNT:**

- Times New Roman ou Arial
- Tamanho 12 para texto
- Tamanho 10 para citações

### **Espaçamento:**

- Entrelinhas: 1,5
- Parágrafos: Justificado
- Recuo primeira linha: 1,25cm

## 🔧 Solução de Problemas

### **Erro: "Execution Policy"**

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### **Erro: "Arquivo não encontrado"**

- Verificar se todos os 25 arquivos estão no diretório
- Executar script PowerShell com `-ValidateFiles:$true`

### **PDF com formatação ruim**

- Usar Pandoc com template LaTeX
- Ajustar configurações no Typora
- Revisar quebras de página no Markdown

### **Imagens não aparecem no PDF**

- Verificar se paths das imagens estão corretos
- Usar caminhos relativos ou absolutos
- Considerar incorporar imagens como Base64

## 📊 Estatísticas Esperadas

Com base no TCC completo:

- **Arquivos:** 25 arquivos
- **Palavras:** ~28.500 palavras
- **Páginas:** ~95-105 páginas (dependendo da formatação)
- **Tamanho:** ~2-3 MB (arquivo MD)

## 🆘 Suporte

Se encontrar problemas:

1. Verificar se todos os arquivos existem
2. Executar script PowerShell para diagnóstico
3. Revisar encoding (deve ser UTF-8)
4. Testar com arquivo menor primeiro

---

**✅ Com estes scripts, seu TCC estará pronto para conversão profissional em PDF!**
