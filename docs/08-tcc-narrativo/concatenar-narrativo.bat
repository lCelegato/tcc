@echo off
chcp 65001 > nul
echo 🚀 Concatenando TCC Narrativo...

set "TCC_DIR=c:\Programacao\tcc\docs\08-tcc-narrativo"
set "OUTPUT_FILE=TCC-NARRATIVO-COMPLETO.md"

cd /d "%TCC_DIR%"

echo Criando arquivo unificado: %OUTPUT_FILE%
echo. > "%OUTPUT_FILE%"

REM 1. Capa
type "01-CAPA.md" >> "%OUTPUT_FILE%"

REM 2. Resumo
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "02-RESUMO.md" >> "%OUTPUT_FILE%"

REM 3. Sumário
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "03-SUMARIO.md" >> "%OUTPUT_FILE%"

REM 4. Introdução
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "04-CAP1-INTRODUCAO.md" >> "%OUTPUT_FILE%"

REM 5. Fundamentação
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "05-CAP2-FUNDAMENTACAO.md" >> "%OUTPUT_FILE%"

REM 6. Metodologia
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "06-CAP3-METODOLOGIA.md" >> "%OUTPUT_FILE%"

REM 7. Desenvolvimento
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "07-CAP4-DESENVOLVIMENTO.md" >> "%OUTPUT_FILE%"

REM 8. Resultados
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "08-CAP5-RESULTADOS.md" >> "%OUTPUT_FILE%"

REM 9. Conclusão
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "09-CAP6-CONCLUSAO.md" >> "%OUTPUT_FILE%"

REM 10. Referências
echo. >> "%OUTPUT_FILE%"
echo \newpage >> "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"
type "10-REFERENCIAS.md" >> "%OUTPUT_FILE%"

echo.
echo ✅ TCC Narrativo concatenado com sucesso!
echo 📄 Arquivo gerado: %OUTPUT_FILE%

REM Estatísticas
for /f %%A in ('find /c /v "" "%OUTPUT_FILE%"') do set "LINHAS=%%A"
for %%A in ("%OUTPUT_FILE%") do set "TAMANHO=%%~zA"

echo 📊 Estatísticas:
echo    - Total de linhas: %LINHAS%
echo    - Tamanho do arquivo: %TAMANHO% bytes
echo    - Estilo: Texto corrido / narrativo
echo    - Páginas estimadas: ~18-22 páginas

echo.
echo 📋 Conversão para PDF:
echo    - Pandoc: pandoc %OUTPUT_FILE% -o TCC-NARRATIVO.pdf
echo    - Typora: Abrir e exportar como PDF
echo.

pause
