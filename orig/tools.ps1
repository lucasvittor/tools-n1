# Script: Suporte-N1.ps1
    $Host.UI.RawUI.BackgroundColor = "black"
    $Host.UI.RawUI.ForegroundColor = "green"
    Clear-Host
function Show-Menu {
    Clear-Host
    $titulo = " SUPORTE N1 - BY LUCAS VITOR "
    $linha = "=" * 40
    Write-Host ""
    Write-Host $linha -ForegroundColor Green
    Write-Host $titulo.PadLeft(($titulo.Length + $linha.Length) / 2).PadRight($linha.Length) -ForegroundColor Green
    Write-Host $linha -ForegroundColor Green
    Write-Host ""
    Write-Host " [1] Informacoes do Sistema"     -ForegroundColor Green
    Write-Host " [2] Diagnostico de Rede"        -ForegroundColor Green
    Write-Host " [3] Limpeza de Sistema"         -ForegroundColor Green
    Write-Host " [4] Ferramentas Rapidas"        -ForegroundColor Green
    Write-Host " [5] Sair"                       -ForegroundColor Green
    Write-Host ""
}


function Get-SystemInfo {
    Clear-Host
    Write-Host "`n========= INFORMACOES DO SISTEMA =========" 

    # --- SISTEMA OPERACIONAL E USUARIO ---
    Write-Host "`n--- SISTEMA E USUARIO ---" 
    $os = Get-WmiObject Win32_OperatingSystem
    Write-Host " Nome do Computador........: $env:COMPUTERNAME"
    Write-Host " Usuario Atual.............: $env:USERNAME"
    Write-Host " Sistema Operacional.......: $($os.Caption)"
    Write-Host " Versao....................: $($os.Version)"
    Write-Host " Build.....................: $($os.BuildNumber)"
    Write-Host " Arquitetura...............: $($os.OSArchitecture)"
    $ultimoBoot = [System.Management.ManagementDateTimeConverter]::ToDateTime($os.LastBootUpTime)
Write-Host (" Ultimo Boot...............: {0}" -f $ultimoBoot)


    # --- HARDWARE ---
    Write-Host "`n--- HARDWARE ---" 
    $cs = Get-WmiObject Win32_ComputerSystem
    $cpu = Get-WmiObject Win32_Processor
    Write-Host " Fabricante................: $($cs.Manufacturer)"
    Write-Host " Modelo....................: $($cs.Model)"
    Write-Host " Processador...............: $($cpu.Name)"
    Write-Host " Velocidade Max............: $($cpu.MaxClockSpeed) MHz"
    Write-Host " Nucleos Fisicos...........: $($cpu.NumberOfCores)"
    Write-Host " Nucleos Logicos...........: $($cpu.NumberOfLogicalProcessors)"
    Write-Host " Memoria RAM Total.........: $([math]::Round($cs.TotalPhysicalMemory / 1GB, 2)) GB"
    Write-Host " Memoria RAM Livre.........: $([math]::Round($os.FreePhysicalMemory / 1MB, 2)) MB"

# --- REDE ---
Write-Host "`n--- REDE ---" 
$ips = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '169.*' -and $_.InterfaceAlias -notlike '*Loopback*' }
$adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }

foreach ($ip in $ips) {
    $adapter = $adapters | Where-Object { $_.Description -like "*$($ip.InterfaceAlias)*" -or $_.InterfaceIndex -eq $ip.InterfaceIndex }
    
    Write-Host (" Interface.................: {0}" -f $ip.InterfaceAlias)
    Write-Host (" IP........................: {0}"  -f $ip.IPAddress)
    if ($adapter) {
    Write-Host (" Descricao.................: {0}" -f $adapter.Description)
    Write-Host (" MAC Address...............: {0}" -f $adapter.MACAddress)
    Write-Host (" Dominio...................: {0}" -f (Get-WmiObject Win32_ComputerSystem).Domain)
    Write-Host (" Gateway...................: {0}" -f ($adapter.DefaultIPGateway -join ', '))
    Write-Host (" DNS Servers...............: {0}" -f ($adapter.DNSServerSearchOrder -join ', '))
    } else {
        Write-Host "  ( Informacoes adicionais nao encontradas para esta interface)"
    }
}

    # --- DISCO RIGIDO ---
    Write-Host "`n--- DISCO RIGIDO ---" 
    Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
        $total = [math]::Round($_.Size / 1GB, 2)
        $livre = [math]::Round($_.FreeSpace / 1GB, 2)
        $usado = $total - $livre
        Write-Host " Unidade $($_.DeviceID): Total: $total GB | Usado: $usado GB | Livre: $livre GB | Sistema de Arquivos: $($_.FileSystem)"
    }
    Pause
}

function Test-NetworkDiagnostics {
    Write-Host "`n--- Diagnostico de Rede ---" 
    ipconfig /release
    ipconfig /renew
    ipconfig /flushdns
    Test-Connection -ComputerName 8.8.8.8 -Count 4
    Pause
}

function Clear-SystemTemp {
    Write-Host "`n--- Limpeza de Sistema ---" 
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host " Arquivos temporarios removidos."
    Pause
}

function Start-QuickTools {
    Write-Host "`n--- Abertura de Ferramentas ---" 
    Start-Process control
    Start-Process taskmgr
    Start-Process devmgmt.msc
    Start-Process services.msc
    Pause
}

do {
    Show-Menu
    $opcao = Read-Host " Escolha uma opcao "
    switch ($opcao) {
        "1" { Get-SystemInfo }
        "2" { Test-NetworkDiagnostics }
        "3" { Clear-SystemTemp }
        "4" { Start-QuickTools }
        "5" { break }
        default { Write-Host "Opção inválida!" -ForegroundColor Red; Pause }
    }
} while ($true)
