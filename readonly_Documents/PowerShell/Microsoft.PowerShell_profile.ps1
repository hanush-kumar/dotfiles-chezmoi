# ---------------------------
# UTF-8 Setup
# ---------------------------
try {
    [Console]::InputEncoding  = [System.Text.Encoding]::UTF8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.UTF8Encoding]::new($false)
    chcp 65001 > $null
} catch {}

Clear-Host

# ---------------------------
# Load Custom User Profile
# ---------------------------
$UserProfilePath = "$env:USERPROFILE\.config\powershell\user_profile.ps1"
if (Test-Path $UserProfilePath) {
    . $UserProfilePath
}

# ---------------------------
# Turbo Oh My Posh (Lazy Load AFTER first command)
# ---------------------------
if ($Host.Name -eq "ConsoleHost" -and (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {

    $global:OMP_LOADED = $false

    function global:prompt {
        if (-not $global:OMP_LOADED) {
            $global:OMP_LOADED = $true
            oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\hul10.omp.json" | Invoke-Expression
        }
        & $function:prompt
    }
}

# ---------------------------
# Fastfetch in Background (Non-blocking)
# ---------------------------
if ($Host.Name -eq "ConsoleHost" -and (Get-Command fastfetch -ErrorAction SilentlyContinue)) {
    Start-Job {
        $Config = "$env:USERPROFILE\.config\fastfetch\config.jsonc"
        if (Test-Path $Config) {
            Start-Sleep -Milliseconds 300
            fastfetch -c $Config
        }
    } | Out-Null
}
function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp
    if (-not [string]::IsNullOrWhiteSpace($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath $cwd
    }
    Remove-Item -Path $tmp
}
# Zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })
