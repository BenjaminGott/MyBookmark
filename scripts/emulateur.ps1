# Compile la version actuelle du code, démarre l'émulateur Android (s'il ne
# tourne pas déjà), puis installe et ouvre l'app sur l'émulateur et sur tout
# téléphone branché.
#
# Si `android/key.properties` (la clé de release) est présent, on compile en
# release : l'APK met alors à jour les versions publiées sans rien perdre.
# Sinon on compile en debug ; un téléphone qui a une release installée est
# sauté plutôt que désinstallé, pour ne pas effacer ses données.
#
# Usage : .\scripts\emulateur.ps1 [-Avd Pixel_8_API_36]
param(
    [string]$Avd = 'Pixel_8_API_36'
)

$ErrorActionPreference = 'Stop'
$sdk = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { "$env:LOCALAPPDATA\Android\sdk" }
$adbExe = "$sdk\platform-tools\adb.exe"
$package = 'com.benjamin.biblivre'
$root = Split-Path $PSScriptRoot -Parent

# 1. Compile la version actuelle du code.
$mode = if (Test-Path "$root\android\key.properties") { 'release' } else { 'debug' }
Push-Location $root
try {
    flutter build apk "--$mode"
    if ($LASTEXITCODE -ne 0) { throw 'La compilation a échoué.' }
} finally {
    Pop-Location
}
$apk = "$root\build\app\outputs\flutter-apk\app-$mode.apk"

# 2. Émulateur : on le lance seulement si aucun n'est déjà connecté.
function Get-Devices {
    & $adbExe devices | Select-String '^(\S+)\s+device$' |
        ForEach-Object { $_.Matches[0].Groups[1].Value }
}
if (-not (Get-Devices | Where-Object { $_ -like 'emulator-*' })) {
    Write-Host "Démarrage de l'émulateur $Avd..."
    Start-Process "$sdk\emulator\emulator.exe" -ArgumentList '-avd', $Avd
}
while (-not ($emulator = Get-Devices | Where-Object { $_ -like 'emulator-*' } | Select-Object -First 1)) {
    Start-Sleep 2
}
while ((& $adbExe -s $emulator shell getprop sys.boot_completed 2>$null) -ne '1') { Start-Sleep 2 }
Write-Host "Émulateur prêt ($emulator)."

# 3. Installe sur chaque appareil, puis ouvre l'app.
foreach ($serial in Get-Devices) {
    Write-Host "Installation sur $serial..."
    & $adbExe -s $serial install -r $apk
    if ($LASTEXITCODE -ne 0) {
        if ($serial -notlike 'emulator-*') {
            # Signature différente sur un vrai téléphone : désinstaller
            # effacerait ses données, on laisse la main.
            Write-Warning "$serial : la version installée n'a pas la même signature. Ajoute android/key.properties pour la mettre à jour, ou désinstalle-la à la main."
            continue
        }
        Write-Host "Signature différente : désinstallation de l'ancienne version."
        & $adbExe -s $serial uninstall $package | Out-Null
        & $adbExe -s $serial install $apk
        if ($LASTEXITCODE -ne 0) { throw "L'installation a échoué sur $serial." }
    }
    & $adbExe -s $serial shell "monkey -p $package -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1"
    Write-Host "$serial : app installée et lancée."
}
