$reportPath = "$env:USERPROFILE\OneDrive\Desktop\system-health-report.txt"

Start-Transcript -Path $reportPath -Force

Write-Host ""
Write-Host "Health Warnings:"
Write-Host "----------------"

$warningFound = $false

# RAM warning
$ramUsagePercent = [math]::Round(($usedRAM / $totalRAM) * 100, 0)

if ($ramUsagePercent -ge 80) {
    Write-Host "WARNING: High memory usage - $ramUsagePercent% used"
    $warningFound = $true
}

# Disk warning
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {

    $freeSpaceGB = [math]::Round($_.FreeSpace / 1GB, 2)

    if ($freeSpaceGB -lt 20) {
        Write-Host "WARNING: Low disk space on drive $($_.DeviceID) - $freeSpaceGB GB free"
        $warningFound = $true
    }
}

# Internet warning
if (-not $internetTest) {
    Write-Host "WARNING: Internet connection problem detected"
    $warningFound = $true
}

# Uptime warning
if ($uptime.Days -ge 7) {
    Write-Host "WARNING: System has not been restarted for $($uptime.Days) days"
    $warningFound = $true
}

if (-not $warningFound) {
    Write-Host "No major system warnings detected."
}
Write-Host "====================================="
Write-Host "   Windows System Health Checker"
Write-Host "====================================="
Write-Host ""

# Computer information
$computerName = $env:COMPUTERNAME
$userName = $env:USERNAME
$os = Get-CimInstance Win32_OperatingSystem
$computer = Get-CimInstance Win32_ComputerSystem

Write-Host "Computer Name: $computerName"
Write-Host "Logged-in User: $userName"
Write-Host "Windows Version: $($os.Caption)"
Write-Host "System Type: $($computer.SystemType)"
Write-Host ""

# CPU information
$cpu = Get-CimInstance Win32_Processor

Write-Host "CPU: $($cpu.Name)"
Write-Host ""

# Memory information
$totalRAM = [math]::Round($computer.TotalPhysicalMemory / 1GB, 2)
$freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
$usedRAM = [math]::Round($totalRAM - $freeRAM, 2)

Write-Host "Total RAM: $totalRAM GB"
Write-Host "Used RAM: $usedRAM GB"
Write-Host "Free RAM: $freeRAM GB"
Write-Host ""

# Disk information
Write-Host "Disk Information:"
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {

    $size = [math]::Round($_.Size / 1GB, 2)
    $free = [math]::Round($_.FreeSpace / 1GB, 2)
    $used = [math]::Round($size - $free, 2)

    Write-Host "Drive: $($_.DeviceID)"
    Write-Host "Total: $size GB"
    Write-Host "Used: $used GB"
    Write-Host "Free: $free GB"
    Write-Host ""
}

# Network information
Write-Host "Network Information:"

$ipAddress = Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object {
        $_.IPAddress -notlike "127.*" -and
        $_.IPAddress -notlike "169.*"
    } |
    Select-Object -First 1

if ($ipAddress) {
    Write-Host "IPv4 Address: $($ipAddress.IPAddress)"
} else {
    Write-Host "IPv4 Address: Not found"
}

Write-Host ""

# Internet connectivity test
Write-Host "Testing Internet Connection..."

$internetTest = Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet

if ($internetTest) {
    Write-Host "Internet Status: Connected"
} else {
    Write-Host "Internet Status: Connection problem detected"
}

Write-Host ""

# System uptime
$lastBoot = $os.LastBootUpTime
$uptime = (Get-Date) - $lastBoot

Write-Host "System Uptime:"
Write-Host "$($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes"

Write-Host ""
Write-Host "Health Warnings:"
Write-Host "----------------"

$warningFound = $false

# RAM warning
$ramUsagePercent = [math]::Round(($usedRAM / $totalRAM) * 100, 0)

if ($ramUsagePercent -ge 80) {
    Write-Host "WARNING: High memory usage - $ramUsagePercent% used"
    $warningFound = $true
}

# Disk warning
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {

    $freeSpaceGB = [math]::Round($_.FreeSpace / 1GB, 2)

    if ($freeSpaceGB -lt 20) {
        Write-Host "WARNING: Low disk space on drive $($_.DeviceID) - $freeSpaceGB GB free"
        $warningFound = $true
    }
}

# Internet warning
if (-not $internetTest) {
    Write-Host "WARNING: Internet connection problem detected"
    $warningFound = $true
}

# Uptime warning
if ($uptime.Days -ge 7) {
    Write-Host "WARNING: System has not been restarted for $($uptime.Days) days"
    $warningFound = $true
}

if (-not $warningFound) {
    Write-Host "No major system warnings detected."
}

Write-Host ""
Write-Host "====================================="
Write-Host "        Health Check Complete"
Write-Host "====================================="
Stop-Transcript

Write-Host ""
Write-Host "Report saved to:"
Write-Host $reportPath
