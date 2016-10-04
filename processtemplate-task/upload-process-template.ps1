[CmdletBinding()]
param(
    [string] $account,
    [string] $accesstoken,
    [string] $rootDirectory
)
Write-Output "Account  " $account
Write-Output "rootDirectory  " $rootDirectory
Write-Output "Building Base64 PAT Token"
# Base64-encodes the Personal Access Token (PAT) appropriately
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "",$token)))
$headers = @{authorization=("Basic {0}" -f $base64AuthInfo)}
$urllistprocess = "$($account)/_apis/process/processes?api-version=1.0"
Write-Output "Invoking $urllistprocess with appropriate headers."
$currentProcesses = Invoke-RestMethod -Uri $urllistprocess -Headers $headers -ContentType "application/json" -Method Get;
Write-Output "Found  $($currentProcesses.count) processes"
Write-Output $currentProcesses
foreach ($process in $currentProcesses.value)
{
   Write-Output "Found " $process.name " as " $process.url
}
$urlPublishProcess = "$($account)/_apis/work/processAdmin/processes/import?ignoreWarnings=true&api-version=2.2-preview"

$uploads = Get-ChildItem $rootDirectory
Write-Output "Found  $($uploads.count) uploads to process"
Write-Output $uploads
foreach ($file in Get-ChildItem $rootDirectory)
{
    Write-Output "Updating with $file" 
    Invoke-RestMethod -InFile $file -Uri $urlPublishProcess -Headers $headers -ContentType "application/zip" -Method Post;
}
