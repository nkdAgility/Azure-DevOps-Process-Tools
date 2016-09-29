[CmdletBinding()]
param(
    [string] $account,
    [string] $user,
    [string] $token
)


$account = "http://nkdagility.visualstudio.com"
$user = "martin@nkdagility.com"
$token = "<testtoken>"
# Base64-encodes the Personal Access Token (PAT) appropriately
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user,$token)))
$headers = @{authorization=("Basic {0}" -f $base64AuthInfo)}
$urllistprocess = "$($account)/_apis/process/processes?api-version=1.0"
$stuff = Invoke-RestMethod -Uri $urllistprocess -Headers $headers -ContentType "application/json" -Method Get;

$stuff
