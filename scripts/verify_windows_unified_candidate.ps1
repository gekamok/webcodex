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
        Add-Content -LiteralPath (Join-Path $env:TEMP 'webcodex-installer-verify.log') -Value $Message -Encoding UTF8
    }
}

Write-DebugEvidence ("candidate=" + $CandidatePath)
Write-DebugEvidence ("exists=" + (Test-Path -LiteralPath $CandidatePath -PathType Leaf))
Write-DebugEvidence ("expected=" + $ExpectedSha256)

try {
    $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $CandidatePath).Hash.ToLowerInvariant()
} catch {
    Write-DebugEvidence ("error=" + $_.Exception.Message)
    exit 2
}

Write-DebugEvidence ("actual=" + $actual)

if ($actual -cne $ExpectedSha256) {
    Write-DebugEvidence "result=mismatch"
    exit 1
}

Write-DebugEvidence "result=ok"
exit 0
