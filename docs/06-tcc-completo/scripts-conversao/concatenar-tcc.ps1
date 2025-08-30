# Script PowerShell para concatenar todos os arquivos do TCC
# Arquivo: concatenar-tcc.ps1

param(
    [string]$OutputFile = "TCC-COMPLETO.md",
    [switch]$AddPageBreaks = $true,
    [switch]$ValidateFiles = $true,
    [switch]$ShowStats = $true
)

Write-Host "🚀 Iniciando concatenação do TCC..." -ForegroundColor Green

$TccDir = "c:\Programacao\tcc\docs\06-tcc-completo"
$OutputPath = Join-Path $TccDir $OutputFile

# Verificar se diretório existe
if (-not (Test-Path $TccDir)) {
    Write-Error "❌ Diretório não encontrado: $TccDir"
    exit 1
}

Set-Location $TccDir

# Lista ordenada de arquivos
$FileOrder = @(
    "01-CAPA.md",
    "02-FOLHA-DE-ROSTO.md", 
    "03-RESUMO.md",
    "04-SUMARIO.md",
    "05-CAP1-INTRODUCAO.md",
    "06-CAP2-FUNDAMENTACAO.md",
    "07-CAP3-METODOLOGIA.md",
    "07-CAP3-METODOLOGIA-PARTE2.md",
    "07-CAP3-METODOLOGIA-PARTE3.md", 
    "07-CAP3-METODOLOGIA-PARTE4.md",
    "07-CAP3-METODOLOGIA-PARTE5.md",
    "08-CAP4-DESENVOLVIMENTO-PARTE1.md",
    "08-CAP4-DESENVOLVIMENTO-PARTE2.md",
    "08-CAP4-DESENVOLVIMENTO-PARTE3.md",
    "08-CAP4-DESENVOLVIMENTO-PARTE4.md",
    "08-CAP4-DESENVOLVIMENTO-PARTE5.md", 
    "08-CAP4-DESENVOLVIMENTO-PARTE6.md",
    "09-CAP5-RESULTADOS.md",
    "10-CAP6-CONCLUSAO.md",
    "11-REFERENCIAS.md",
    "12-APENDICES.md",
    "13-ANEXOS.md"
)

# Arquivos que devem ter quebra de página antes
$PageBreakFiles = @(
    "01-CAPA.md",
    "02-FOLHA-DE-ROSTO.md",
    "03-RESUMO.md", 
    "04-SUMARIO.md",
    "05-CAP1-INTRODUCAO.md",
    "06-CAP2-FUNDAMENTACAO.md",
    "07-CAP3-METODOLOGIA.md",
    "08-CAP4-DESENVOLVIMENTO-PARTE1.md",
    "09-CAP5-RESULTADOS.md",
    "10-CAP6-CONCLUSAO.md",
    "11-REFERENCIAS.md",
    "12-APENDICES.md",
    "13-ANEXOS.md"
)

# Validar arquivos se solicitado
if ($ValidateFiles) {
    Write-Host "🔍 Validando arquivos..." -ForegroundColor Yellow
    
    $MissingFiles = @()
    foreach ($File in $FileOrder) {
        if (-not (Test-Path $File)) {
            $MissingFiles += $File
        }
    }
    
    if ($MissingFiles.Count -gt 0) {
        Write-Warning "⚠️  Arquivos não encontrados:"
        $MissingFiles | ForEach-Object { Write-Host "   - $_" -ForegroundColor Red }
        
        $Response = Read-Host "Continuar mesmo assim? (s/N)"
        if ($Response -ne 's' -and $Response -ne 'S') {
            Write-Host "❌ Operação cancelada pelo usuário" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "✅ Todos os arquivos encontrados!" -ForegroundColor Green
    }
}

# Limpar arquivo de saída
if (Test-Path $OutputPath) {
    Remove-Item $OutputPath -Force
}

# Criar arquivo com cabeçalho
$Header = @"
<!-- 
TCC COMPLETO - ARQUIVO CONCATENADO
Gerado automaticamente em: $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")
Total de arquivos: $($FileOrder.Count)
-->

"@

$Header | Out-File -FilePath $OutputPath -Encoding UTF8

Write-Host "📝 Concatenando arquivos..." -ForegroundColor Cyan

$ProcessedFiles = 0
$TotalWords = 0
$TotalLines = 0

foreach ($File in $FileOrder) {
    if (Test-Path $File) {
        Write-Host "   📄 Adicionando: $File" -ForegroundColor Gray
        
        # Adicionar quebra de página se necessário
        if ($AddPageBreaks -and ($File -in $PageBreakFiles) -and ($ProcessedFiles -gt 0)) {
            "`n\newpage`n" | Out-File -FilePath $OutputPath -Append -Encoding UTF8
        } elseif ($ProcessedFiles -gt 0) {
            "`n" | Out-File -FilePath $OutputPath -Append -Encoding UTF8
        }
        
        # Adicionar conteúdo do arquivo
        $Content = Get-Content $File -Raw -Encoding UTF8
        $Content | Out-File -FilePath $OutputPath -Append -Encoding UTF8 -NoNewline
        
        # Estatísticas do arquivo
        $FileLines = (Get-Content $File).Count
        $FileWords = (Get-Content $File -Raw).Split() | Where-Object { $_ } | Measure-Object | Select-Object -ExpandProperty Count
        
        $TotalLines += $FileLines
        $TotalWords += $FileWords
        $ProcessedFiles++
        
        Write-Host "     └─ $FileLines linhas, $FileWords palavras" -ForegroundColor DarkGray
    } else {
        Write-Warning "   ⚠️  Pulando arquivo não encontrado: $File"
    }
}

# Adicionar rodapé
$Footer = @"

<!-- 
FIM DO TCC COMPLETO
Arquivos processados: $ProcessedFiles/$($FileOrder.Count)
Total de linhas: $TotalLines
Total de palavras: $TotalWords
-->
"@

$Footer | Out-File -FilePath $OutputPath -Append -Encoding UTF8

Write-Host ""
Write-Host "✅ TCC concatenado com sucesso!" -ForegroundColor Green
Write-Host "📄 Arquivo gerado: $OutputFile" -ForegroundColor White

if ($ShowStats) {
    $FileSize = (Get-Item $OutputPath).Length
    $FileSizeMB = [math]::Round($FileSize / 1MB, 2)
    
    Write-Host ""
    Write-Host "📊 Estatísticas:" -ForegroundColor Cyan
    Write-Host "   📁 Arquivos processados: $ProcessedFiles/$($FileOrder.Count)" -ForegroundColor White
    Write-Host "   📏 Total de linhas: $TotalLines" -ForegroundColor White
    Write-Host "   📝 Total de palavras: $TotalWords" -ForegroundColor White
    Write-Host "   💾 Tamanho do arquivo: $FileSizeMB MB ($FileSize bytes)" -ForegroundColor White
    
    # Estimativa de páginas (assumindo ~300 palavras por página)
    $EstimatedPages = [math]::Round($TotalWords / 300, 1)
    Write-Host "   📄 Páginas estimadas: $EstimatedPages" -ForegroundColor White
}

Write-Host ""
Write-Host "📋 Próximos passos:" -ForegroundColor Yellow
Write-Host "   1. Abrir $OutputFile em editor Markdown (Typora, VS Code, etc.)" -ForegroundColor White
Write-Host "   2. Revisar formatação se necessário" -ForegroundColor White
Write-Host "   3. Converter para PDF usando uma das opções:" -ForegroundColor White
Write-Host "      🔸 Pandoc: pandoc $OutputFile -o TCC-COMPLETO.pdf --toc" -ForegroundColor Cyan
Write-Host "      🔸 Typora: Abrir → File → Export → PDF" -ForegroundColor Cyan  
Write-Host "      🔸 Notion: Importar MD → Export PDF" -ForegroundColor Cyan
Write-Host "      🔸 GitBook: Importar → Export PDF" -ForegroundColor Cyan
Write-Host ""

# Abrir arquivo automaticamente se solicitado
$OpenFile = Read-Host "Abrir arquivo automaticamente? (s/N)"
if ($OpenFile -eq 's' -or $OpenFile -eq 'S') {
    Start-Process $OutputPath
}
