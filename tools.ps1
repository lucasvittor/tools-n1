# Script: Suporte-N1.ps1
function Show-Menu {
    Clear-Host
    Write-Host "===== SUPORTE N1 =====" -ForegroundColor Green
    Write-Host "1. Informacoes do Sistema"
    Write-Host "2. Diagnostico de Rede"
    Write-Host "3. Limpeza de Sistema"
    Write-Host "4. Ferramentas Rapidas"
    Write-Host "5. Sair"
}

function Get-SystemInfo {
    Write-Host "`n--- Informacoes do Sistema ---" -ForegroundColor Green
    Write-Host "Nome do Computador: $env:COMPUTERNAME"
    Write-Host "Usuario: $env:USERNAME"
    Write-Host "Versao do Windows: " (Get-WmiObject -Class Win32_OperatingSystem).Caption
    Write-Host "IP Local: " (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"} | Select-Object -ExpandProperty IPAddress)
    Write-Host "Espaco em Disco (C:):"
    Get-PSDrive C | Select-Object Used, Free
    Pause
}

function Test-NetworkDiagnostics {
    Write-Host "`n--- Diagnostico de Rede ---" -ForegroundColor Green
    ipconfig /release
    ipconfig /renew
    ipconfig /flushdns
    Test-Connection -ComputerName 8.8.8.8 -Count 4
    Pause
}

function Clear-SystemTemp {
    Write-Host "`n--- Limpeza de Sistema ---" -ForegroundColor Green
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Arquivos temporarios removidos."
    Pause
}

function Start-QuickTools {
    Write-Host "`n--- Abertura de Ferramentas ---" -ForegroundColor Green
    Start-Process control
    Start-Process taskmgr
    Start-Process devmgmt.msc
    Start-Process services.msc
    Pause
}

do {
    Show-Menu
    $opcao = Read-Host "Escolha uma opcao"
    switch ($opcao) {
        "1" { Get-SystemInfo }
        "2" { Test-NetworkDiagnostics }
        "3" { Clear-SystemTemp }
        "4" { Start-QuickTools }
        "5" { break }
        default { Write-Host "Opção inválida!" -ForegroundColor Red; Pause }
    }
} while ($true)
