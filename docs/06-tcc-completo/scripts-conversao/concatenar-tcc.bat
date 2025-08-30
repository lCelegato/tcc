@echo off
REM Script para concatenar todos os arquivos do TCC em ordem
REM Arquivo: concatenar-tcc.bat

echo 🚀 Iniciando concatenacao do TCC...

set "OUTPUT_FILE=TCC-COMPLETO.md"
set "TCC_DIR=c:\Programacao\tcc\docs\06-tcc-completo"

cd /d "%TCC_DIR%"

echo Criando arquivo unificado: %OUTPUT_FILE%

REM Limpar arquivo de saida se existir
if exist "%OUTPUT_FILE%" del "%OUTPUT_FILE%"

echo. > "%OUTPUT_FILE%"

REM Adicionar cada arquivo na ordem correta
echo Adicionando elementos pre-textuais...

REM 1. Capa
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "01-CAPA.md" >> "%OUTPUT_FILE%"

REM 2. Folha de Rosto  
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "02-FOLHA-DE-ROSTO.md" >> "%OUTPUT_FILE%"

REM 3. Resumo
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "03-RESUMO.md" >> "%OUTPUT_FILE%"

REM 4. Sumario
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "04-SUMARIO.md" >> "%OUTPUT_FILE%"

echo Adicionando elementos textuais...

REM 5. Capitulo 1
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "05-CAP1-INTRODUCAO.md" >> "%OUTPUT_FILE%"

REM 6. Capitulo 2
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "06-CAP2-FUNDAMENTACAO.md" >> "%OUTPUT_FILE%"

REM 7. Capitulo 3 (6 partes)
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "07-CAP3-METODOLOGIA.md" >> "%OUTPUT_FILE%"

echo. >> "%OUTPUT_FILE%"
type "07-CAP3-METODOLOGIA-PARTE2.md" >> "%OUTPUT_FILE%"

echo. >> "%OUTPUT_FILE%"
type "07-CAP3-METODOLOGIA-PARTE3.md" >> "%OUTPUT_FILE%"

echo. >> "%OUTPUT_FILE%"
type "07-CAP3-METODOLOGIA-PARTE4.md" >> "%OUTPUT_FILE%"

echo. >> "%OUTPUT_FILE%"
type "07-CAP3-METODOLOGIA-PARTE5.md" >> "%OUTPUT_FILE%"

REM 8. Capitulo 4 (6 partes)
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "08-CAP4-DESENVOLVIMENTO-PARTE1.md" >> "%OUTPUT_FILE%"

echo. >> "%OUTPUT_FILE%"
type "08-CAP4-DESENVOLVIMENTO-PARTE2.md" >> "%OUTPUT_FILE%"

echo. >> "%OUTPUT_FILE%"
type "08-CAP4-DESENVOLVIMENTO-PARTE3.md" >> "%OUTPUT_FILE%"

echo. >> "%OUTPUT_FILE%"
type "08-CAP4-DESENVOLVIMENTO-PARTE4.md" >> "%OUTPUT_FILE%"

echo. >> "%OUTPUT_FILE%"
type "08-CAP4-DESENVOLVIMENTO-PARTE5.md" >> "%OUTPUT_FILE%"

echo. >> "%OUTPUT_FILE%"
type "08-CAP4-DESENVOLVIMENTO-PARTE6.md" >> "%OUTPUT_FILE%"

REM 9. Capitulo 5
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "09-CAP5-RESULTADOS.md" >> "%OUTPUT_FILE%"

REM 10. Capitulo 6
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "10-CAP6-CONCLUSAO.md" >> "%OUTPUT_FILE%"

echo Adicionando elementos pos-textuais...

REM 11. Referencias
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "11-REFERENCIAS.md" >> "%OUTPUT_FILE%"

REM 12. Apendices
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "12-APENDICES.md" >> "%OUTPUT_FILE%"

REM 13. Anexos
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "13-ANEXOS.md" >> "%OUTPUT_FILE%"

echo.
echo ✅ TCC concatenado com sucesso!
echo 📄 Arquivo gerado: %OUTPUT_FILE%
echo 📊 Estatisticas:

REM Contar linhas do arquivo final
for /f %%i in ('type "%OUTPUT_FILE%" ^| find /c /v ""') do set LINHAS=%%i
echo    - Total de linhas: %LINHAS%

REM Mostrar tamanho do arquivo
for %%A in ("%OUTPUT_FILE%") do set TAMANHO=%%~zA
echo    - Tamanho do arquivo: %TAMANHO% bytes

echo.
echo 📋 Proximos passos:
echo    1. Abrir %OUTPUT_FILE% em editor Markdown
echo    2. Revisar formatacao se necessario
echo    3. Converter para PDF usando:
echo       - Pandoc: pandoc %OUTPUT_FILE% -o TCC-COMPLETO.pdf
echo       - Typora: Abrir e exportar como PDF
echo       - Notion: Importar e exportar PDF
echo.

pause
