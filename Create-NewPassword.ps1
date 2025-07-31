param (
    [Parameter(Mandatory = $true)]
    [string]$Salt,
    [Parameter(Mandatory = $true)]
    [string]$Secret
)

function Calculate-Sha256Hash {
    param (
        [Parameter(Mandatory = $true)]
        [string]$InputString
    )

    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)
        $hashBytes = $sha256.ComputeHash($bytes)
        $hashString = -join ($hashBytes | ForEach-Object { $_.ToString("x2") })
        return $hashString
    }
    finally {
        $sha256.Dispose()
    }
}

$SaltSecret = "$Salt$Secret"
$PWD = "$($Salt)$(Calculate-Sha256Hash -InputString $SaltSecret)"
Write-Output $PWD