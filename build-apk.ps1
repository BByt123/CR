param(
    [string]$SdkPath = $(if ($env:ANDROID_SDK_ROOT) { $env:ANDROID_SDK_ROOT } elseif ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { Join-Path $env:LOCALAPPDATA 'Android\Sdk' }),
    [string]$JdkPath = ''
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$project = $PSScriptRoot

function Invoke-BuildTool {
    param([string]$Program, [string[]]$Arguments)
    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Program failed with exit code $LASTEXITCODE" }
}

if (!$JdkPath) {
    $candidates = @($env:JAVA_HOME, 'C:\Program Files\Android\Android Studio\jbr')
    $JdkPath = $candidates | Where-Object { $_ -and (Test-Path (Join-Path $_ 'bin\javac.exe')) } | Select-Object -First 1
}
if (!$JdkPath -or !(Test-Path (Join-Path $JdkPath 'bin\javac.exe'))) {
    throw 'A JDK with javac is required. Install Android Studio or pass -JdkPath.'
}
if (!(Test-Path -LiteralPath $SdkPath)) { throw "Android SDK not found: $SdkPath" }
$platform = Get-ChildItem -LiteralPath (Join-Path $SdkPath 'platforms') -Directory |
    Where-Object { $_.Name -match '^android-(\d+)$' -and [int]$Matches[1] -ge 35 } |
    Sort-Object { [int]($_.Name -replace 'android-', '') } -Descending | Select-Object -First 1
$buildTools = Get-ChildItem -LiteralPath (Join-Path $SdkPath 'build-tools') -Directory |
    Where-Object { $_.Name -match '^\d+\.\d+\.\d+$' -and (Test-Path (Join-Path $_.FullName 'aapt2.exe')) } |
    Sort-Object { [version]$_.Name } -Descending | Select-Object -First 1
if (!$platform -or !$buildTools) { throw 'Install Android SDK Platform 35 (or later) and Android SDK Build-Tools in Android Studio.' }
$androidJar = Join-Path $platform.FullName 'android.jar'
$toolsPath = $buildTools.FullName
$java = Join-Path $JdkPath 'bin\java.exe'
$build = Join-Path $project '.build-tools\apk'
$classes = Join-Path $build 'classes'
$dex = Join-Path $build 'dex'
New-Item -ItemType Directory -Force -Path $build, $classes, $dex, (Join-Path $project 'apk') | Out-Null

Push-Location $project
try {
    if (!(Test-Path 'node_modules\vite\bin\vite.js')) {
        Invoke-BuildTool 'npm.cmd' @('install', '--no-audit', '--no-fund')
    }
    Invoke-BuildTool 'npm.cmd' @('test')
    $previousBuildTarget = $env:BUILD_TARGET
    $env:BUILD_TARGET = 'android'
    try {
        Invoke-BuildTool 'npm.cmd' @('run', 'build')
    } finally {
        if ($null -eq $previousBuildTarget) { Remove-Item Env:BUILD_TARGET -ErrorAction SilentlyContinue }
        else { $env:BUILD_TARGET = $previousBuildTarget }
    }

    # Use the same source manifest as Android Studio, adding the SDK/package fields for aapt2.
    $source = Join-Path $project 'android\app\src\main'
    [xml]$manifest = Get-Content -LiteralPath (Join-Path $source 'AndroidManifest.xml') -Raw
    $manifest.manifest.SetAttribute('package', 'com.turbokartrally.samsung')
    $sdk = $manifest.CreateElement('uses-sdk')
    $androidNamespace = 'http://schemas.android.com/apk/res/android'
    $manifest.manifest.SetAttribute('versionCode', $androidNamespace, '1') | Out-Null
    $manifest.manifest.SetAttribute('versionName', $androidNamespace, '1.0') | Out-Null
    $sdk.SetAttribute('minSdkVersion', $androidNamespace, '26') | Out-Null
    $sdk.SetAttribute('targetSdkVersion', $androidNamespace, '35') | Out-Null
    $manifest.manifest.PrependChild($sdk) | Out-Null
    $manifestPath = Join-Path $build 'AndroidManifest.xml'
    $manifest.Save($manifestPath)

    $resources = Join-Path $build 'resources.zip'
    Invoke-BuildTool (Join-Path $toolsPath 'aapt2.exe') @('compile', '--dir', (Join-Path $source 'res'), '-o', $resources)
    $unsigned = Join-Path $build 'unsigned.apk'
    Invoke-BuildTool (Join-Path $toolsPath 'aapt2.exe') @('link', '-o', $unsigned, '--manifest', $manifestPath, '-I', $androidJar, '-A', (Join-Path $source 'assets'), $resources)
    Invoke-BuildTool (Join-Path $JdkPath 'bin\javac.exe') @('--release', '8', '-classpath', $androidJar, '-d', $classes, (Join-Path $source 'java\com\turbokartrally\samsung\MainActivity.java'))
    $classJar = Join-Path $build 'classes.jar'
    Invoke-BuildTool (Join-Path $JdkPath 'bin\jar.exe') @('cf', $classJar, '-C', $classes, '.')
    Invoke-BuildTool $java @('-cp', (Join-Path $toolsPath 'lib\d8.jar'), 'com.android.tools.r8.D8', '--lib', $androidJar, '--min-api', '26', '--output', $dex, $classJar)
    Invoke-BuildTool (Join-Path $JdkPath 'bin\jar.exe') @('uf', $unsigned, '-C', $dex, 'classes.dex')
    $aligned = Join-Path $build 'aligned.apk'
    Invoke-BuildTool (Join-Path $toolsPath 'zipalign.exe') @('-f', '-p', '4', $unsigned, $aligned)

    $keystore = Join-Path $project '.build-tools\debug.keystore'
    if (!(Test-Path -LiteralPath $keystore)) {
        Invoke-BuildTool (Join-Path $JdkPath 'bin\keytool.exe') @('-genkeypair', '-keystore', $keystore, '-storepass', 'android', '-alias', 'androiddebugkey', '-keypass', 'android', '-dname', 'CN=Android Debug,O=Android,C=US', '-keyalg', 'RSA', '-keysize', '2048', '-validity', '10000')
    }
    $apk = Join-Path $project 'apk\Turbo-Kart-Rally-Samsung.apk'
    $signer = Join-Path $toolsPath 'lib\apksigner.jar'
    Invoke-BuildTool $java @('-jar', $signer, 'sign', '--ks', $keystore, '--ks-key-alias', 'androiddebugkey', '--ks-pass', 'pass:android', '--key-pass', 'pass:android', '--out', $apk, $aligned)
    Invoke-BuildTool $java @('-jar', $signer, 'verify', '--verbose', $apk)
    Invoke-BuildTool (Join-Path $toolsPath 'aapt2.exe') @('dump', 'badging', $apk)
    Get-FileHash -Algorithm SHA256 -LiteralPath $apk
    Write-Host "APK created: $apk"
} finally {
    Pop-Location
}
