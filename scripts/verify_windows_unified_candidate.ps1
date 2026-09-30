param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$CandidatePath,

    [Parameter(Mandatory = $true, Position = 1)]
    [ValidatePattern('^[0-9a-f]{64}$')]
    [string]$ExpectedSha256
)

$ErrorActionPreference = 'Stop'

try {
    $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $CandidatePath).Hash.ToLowerInvariant()
} catch {
    exit 2
}

if ($actual -cne $ExpectedSha256) {
    exit 1
}

exit 0
