param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$CandidatePath,

    [Parameter(Mandatory = $true, Position = 1)]
    [ValidatePattern('^[0-9a-f]{64}$')]
    [string]$ExpectedSha256
)

$ErrorActionPreference = 'Stop'

function Write-DebugEvidence([string]$Message) {
    if ($env:WEBCODEX_INSTALLER_VERIFY_DEBUG -eq '1') {
        try {
            $path = [System.IO.Path]::Combine($env:TEMP, 'webcodex-installer-verify.log')
            [System.IO.File]::AppendAllText($path, $Message + [Environment]::NewLine, [System.Text.Encoding]::UTF8)
        } catch {
        }
    }
}

Write-DebugEvidence ("candidate=" + $CandidatePath)
Write-DebugEvidence ("exists=" + [System.IO.File]::Exists($CandidatePath))
Write-DebugEvidence ("expected=" + $ExpectedSha256)

$stream = $null
$sha = $null
try {
    $stream = [System.IO.File]::Open(
        $CandidatePath,
        [System.IO.FileMode]::Open,
        [System.IO.FileAccess]::Read,
        [System.IO.FileShare]::Read
    )
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $bytes = $sha.ComputeHash($stream)
    $actual = [System.BitConverter]::ToString($bytes).Replace('-', '').ToLowerInvariant()
} catch {
    Write-DebugEvidence ("error=" + $_.Exception.Message)
    exit 2
} finally {
    if ($sha -ne $null) {
        $sha.Dispose()
    }
    if ($stream -ne $null) {
        $stream.Dispose()
    }
}

Write-DebugEvidence ("actual=" + $actual)

if ($actual -cne $ExpectedSha256) {
    Write-DebugEvidence "result=mismatch"
    exit 1
}

Write-DebugEvidence "result=ok"
exit 0
