#!/bin/bash
# Script para concatenar todos os arquivos do TCC em ordem
# Arquivo: concatenar-tcc.sh

echo "🚀 Iniciando concatenação do TCC..."

OUTPUT_FILE="TCC-COMPLETO.md"
TCC_DIR="c:/Programacao/tcc/docs/06-tcc-completo"

cd "$TCC_DIR" || exit 1

echo "Criando arquivo unificado: $OUTPUT_FILE"

# Limpar arquivo de saida se existir
> "$OUTPUT_FILE"

# Função para adicionar arquivo com quebra de página
add_file() {
    local file=$1
    local add_newpage=${2:-true}
    
    if [ -f "$file" ]; then
        echo "Adicionando: $file"
        
        if [ "$add_newpage" = "true" ]; then
            echo -e "\n\\newpage\n" >> "$OUTPUT_FILE"
        fi
        
        cat "$file" >> "$OUTPUT_FILE"
        echo -e "\n" >> "$OUTPUT_FILE"
    else
        echo "⚠️  Arquivo não encontrado: $file"
    fi
}

echo "Adicionando elementos pré-textuais..."

# Elementos pré-textuais
add_file "01-CAPA.md" false
add_file "02-FOLHA-DE-ROSTO.md"
add_file "03-RESUMO.md"
add_file "04-SUMARIO.md"

echo "Adicionando elementos textuais..."

# Capítulos principais
add_file "05-CAP1-INTRODUCAO.md"
add_file "06-CAP2-FUNDAMENTACAO.md"

# Capítulo 3 (metodologia) - 6 partes
add_file "07-CAP3-METODOLOGIA.md"
add_file "07-CAP3-METODOLOGIA-PARTE2.md" false
add_file "07-CAP3-METODOLOGIA-PARTE3.md" false
add_file "07-CAP3-METODOLOGIA-PARTE4.md" false
add_file "07-CAP3-METODOLOGIA-PARTE5.md" false

# Capítulo 4 (desenvolvimento) - 6 partes  
add_file "08-CAP4-DESENVOLVIMENTO-PARTE1.md"
add_file "08-CAP4-DESENVOLVIMENTO-PARTE2.md" false
add_file "08-CAP4-DESENVOLVIMENTO-PARTE3.md" false
add_file "08-CAP4-DESENVOLVIMENTO-PARTE4.md" false
add_file "08-CAP4-DESENVOLVIMENTO-PARTE5.md" false
add_file "08-CAP4-DESENVOLVIMENTO-PARTE6.md" false

# Capítulos finais
add_file "09-CAP5-RESULTADOS.md"
add_file "10-CAP6-CONCLUSAO.md"

echo "Adicionando elementos pós-textuais..."

# Elementos pós-textuais
add_file "11-REFERENCIAS.md"
add_file "12-APENDICES.md"
add_file "13-ANEXOS.md"

echo ""
echo "✅ TCC concatenado com sucesso!"
echo "📄 Arquivo gerado: $OUTPUT_FILE"

# Estatísticas
LINHAS=$(wc -l < "$OUTPUT_FILE")
TAMANHO=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE" 2>/dev/null)
PALAVRAS=$(wc -w < "$OUTPUT_FILE")

echo "📊 Estatísticas:"
echo "   - Total de linhas: $LINHAS"
echo "   - Total de palavras: $PALAVRAS"
echo "   - Tamanho do arquivo: $TAMANHO bytes"

echo ""
echo "📋 Próximos passos:"
echo "   1. Abrir $OUTPUT_FILE em editor Markdown"
echo "   2. Revisar formatação se necessário"
echo "   3. Converter para PDF usando:"
echo "      - Pandoc: pandoc $OUTPUT_FILE -o TCC-COMPLETO.pdf"
echo "      - Typora: Abrir e exportar como PDF"
echo "      - Notion: Importar e exportar PDF"
echo ""

# Tornar o script executável
chmod +x "$0"
