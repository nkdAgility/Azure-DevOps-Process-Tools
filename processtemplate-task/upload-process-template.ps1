[CmdletBinding()]
param(
    [string] $account,
    [string] $accesstoken,
    [string] $rootDirectory
)

# Base64-encodes the Personal Access Token (PAT) appropriately
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "",$token)))
$headers = @{authorization=("Basic {0}" -f $base64AuthInfo)}
$urllistprocess = "$($account)/_apis/process/processes?api-version=1.0"
$currentProcesses = Invoke-RestMethod -Uri $urllistprocess -Headers $headers -ContentType "application/json" -Method Get;
foreach ($process in $currentProcesses.value)
{
   Write-Output "Found " $process.name " as " $process.url
}
$urlPublishProcess = "$($account)/_apis/work/processAdmin/processes/import?ignoreWarnings=true&api-version=2.2-preview"
foreach ($file in Get-ChildItem $rootDirectory)
{
    Write-Output "Updating with  " $file
    Invoke-RestMethod -InFile $file -Uri $urlPublishProcess -Headers $headers -ContentType "application/zip" -Method Post;
}
