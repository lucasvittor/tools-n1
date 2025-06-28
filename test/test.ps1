# Script: Suporte-N1.ps1
function Show-Menu {
    Clear-Host
        Write-Host "`n"
    Write-Host " `n         SUPORTE N1 " -ForegroundColor Green
    Write-Host "`n 1. Informacoes do Sistema"
    Write-Host "`n 2. Diagnostico de Rede"
    Write-Host "`n 3. Limpeza de Sistema"
    Write-Host "`n 4. Ferramentas Rapidas"
    Write-Host "`n 5. Sair"
        Write-Host "`n"
}

function Get-SystemInfo {
    Clear-Host
    Write-Host "`n========= INFORMACOES DO SISTEMA =========" -ForegroundColor Green

    # --- SISTEMA OPERACIONAL E USUARIO ---
    Write-Host "`n--- SISTEMA E USUARIO ---" -ForegroundColor Green
    $os = Get-WmiObject Win32_OperatingSystem
    Write-Host "Nome do Computador........: $env:COMPUTERNAME"
    Write-Host "Usuario Atual.............: $env:USERNAME"
    Write-Host "Sistema Operacional.......: $($os.Caption)"
    Write-Host "Versao....................: $($os.Version)"
    Write-Host "Build.....................: $($os.BuildNumber)"
    Write-Host "Arquitetura...............: $($os.OSArchitecture)"
    $ultimoBoot = [System.Management.ManagementDateTimeConverter]::ToDateTime($os.LastBootUpTime)
Write-Host ("Ultimo Boot...............: {0}" -f $ultimoBoot)


    # --- HARDWARE ---
    Write-Host "`n--- HARDWARE ---" -ForegroundColor Green
    $cs = Get-WmiObject Win32_ComputerSystem
    $cpu = Get-WmiObject Win32_Processor
    Write-Host "Fabricante................: $($cs.Manufacturer)"
    Write-Host "Modelo....................: $($cs.Model)"
    Write-Host "Processador...............: $($cpu.Name)"
    Write-Host "Velocidade Max............: $($cpu.MaxClockSpeed) MHz"
    Write-Host "Nucleos Fisicos...........: $($cpu.NumberOfCores)"
    Write-Host "Nucleos Logicos...........: $($cpu.NumberOfLogicalProcessors)"
    Write-Host "Memoria RAM Total.........: $([math]::Round($cs.TotalPhysicalMemory / 1GB, 2)) GB"
    Write-Host "Memoria RAM Livre.........: $([math]::Round($os.FreePhysicalMemory / 1MB, 2)) MB"

# --- REDE ---
Write-Host "`n--- REDE ---" -ForegroundColor Green
$ips = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '169.*' -and $_.InterfaceAlias -notlike '*Loopback*' }
$adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }

foreach ($ip in $ips) {
    $adapter = $adapters | Where-Object { $_.Description -like "*$($ip.InterfaceAlias)*" -or $_.InterfaceIndex -eq $ip.InterfaceIndex }
    
    Write-Host ("Interface.................: {0}" -f $ip.InterfaceAlias)
    Write-Host ("IP........................: {0}"  -f $ip.IPAddress)
    if ($adapter) {
    Write-Host ("Descricao.................: {0}" -f $adapter.Description)
    Write-Host ("MAC Address...............: {0}" -f $adapter.MACAddress)
    Write-Host ("Dominio...................: {0}" -f (Get-WmiObject Win32_ComputerSystem).Domain)
    Write-Host ("Gateway...................: {0}" -f ($adapter.DefaultIPGateway -join ', '))
    Write-Host ("DNS Servers...............: {0}" -f ($adapter.DNSServerSearchOrder -join ', '))
    } else {
        Write-Host "  (Informacoes adicionais nao encontradas para esta interface)"
    }
}

    # --- DISCO RIGIDO ---
    Write-Host "`n--- DISCO RIGIDO ---" -ForegroundColor Green
    Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
        $total = [math]::Round($_.Size / 1GB, 2)
        $livre = [math]::Round($_.FreeSpace / 1GB, 2)
        $usado = $total - $livre
        Write-Host "Unidade $($_.DeviceID): Total: $total GB | Usado: $usado GB | Livre: $livre GB | Sistema de Arquivos: $($_.FileSystem)"
    }
    Pause
}


function Test-NetworkDiagnostics {
    Write-Host "`n--- Diagnostico de Rede ---" -ForegroundColor Green

    # Exibir IP atual
    Write-Host "`n--- IP Atual ---"
    ipconfig | findstr /i "IPv4"
        Write-Host "`n"

    # Liberar IP atual
    Write-Host "`n Liberando IP atual (ipconfig /release)..."
    ipconfig /release | Out-Null
    Start-Sleep -Seconds 1
        Write-Host "`n"

    # Renovar IP
    Write-Host "`n Renovando IP (ipconfig /renew)..."
    ipconfig /renew | Out-Null
    Start-Sleep -Seconds 1
        Write-Host "`n"

    # Limpar cache DNS
    Write-Host "`n Limpando cache DNS (ipconfig /flushdns)..."
    ipconfig /flushdns | Out-Null
        Write-Host "`n"

    # Testar conectividade com o Google DNS
    Write-Host "`n Testando conexao com 8.8.8.8 (Google DNS)..."
    Test-Connection -ComputerName 8.8.8.8 -Count 4 -Quiet |
        ForEach-Object {
            if ($_ -eq $true) {
                Write-Host "`n Conectividade com a Internet verificada com sucesso." -ForegroundColor Green
            } else {
                Write-Host "`n Sem resposta do DNS do Google." -ForegroundColor Red
            }
        }
            Write-Host "`n"

    Pause
}


function Clear-SystemTemp {
    Write-Host "n--- Limpeza de Sistema ---" -ForegroundColor Green

    # Limpar TEMP do usuário
    Write-Host "→ Limpando arquivos temporarios do usuario ($env:TEMP)..."
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue

    # Limpar TEMP do sistema
    Write-Host "→ Limpando arquivos temporarios do sistema (C:\Windows\Temp)..."
    Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

    # Limpar cache do Windows Update
    Write-Host "→ Limpando cache do Windows Update..."
    Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue

    # Limpar arquivos de log do sistema
    Write-Host "→ Limpando arquivos .log no diretorio de logs do Windows..."
    Get-ChildItem -Path "C:\Windows\Logs\" -Recurse -Include *.log -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

    # Limpar cache do Edge
    $edgeCache = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
    if (Test-Path $edgeCache) {
        Write-Host "→ Limpando cache do Microsoft Edge..."
        Remove-Item "$edgeCache\*" -Recurse -Force -ErrorAction SilentlyContinue
    }

    # Limpar cache do Google
    $chromeCache = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
    if (Test-Path $chromeCache) {
        Write-Host "→ Limpando cache do Google Chrome..."
        Remove-Item "$chromeCache\*" -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-Host "n Limpeza concluida com seguranca."
    Pause
} não apagou os arquivos TEMP da maquina

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
    $opcao = Read-Host "`n Escolha uma opcao"
    switch ($opcao) {
        "1" { Get-SystemInfo }
        "2" { Test-NetworkDiagnostics }
        "3" { Clear-SystemTemp }
        "4" { Start-QuickTools }
        "5" { break }
        default { Write-Host "Opção inválida!" -ForegroundColor Red; Pause }
    }
} while ($true)
