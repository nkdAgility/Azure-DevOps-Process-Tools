[CmdletBinding()]
param(
    [string] $account,
    [string] $accesstoken,
    [string] $matchProcessTemplates
)
$account = Get-VstsInput -Name account -Require
$matchProcessTemplates = Get-VstsInput -Name matchProcessTemplates -Require
$accesstoken = Get-VstsInput -Name accesstoken -Require

Write-VstsTaskVerbose "Account: $account" 
Write-VstsTaskVerbose "matchProcessTemplates: $matchProcessTemplates" 
Write-VstsTaskVerbose "accesstoken: $accesstoken" 


#Write-Output "rootDirectory  " $rootDirectory
Write-VstsTaskVerbose "Building Base64 PAT Token"
# Base64-encodes the Personal Access Token (PAT) appropriately
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "",$accesstoken)))
$headers = @{authorization=("Basic {0}" -f $base64AuthInfo)}
$headers.Add("X-TFS-FedAuthRedirect","Suppress")
$urllistprocess = "$($account)/_apis/process/processes?api-version=1.0"
Write-VstsTaskVerbose "Calling $urllistprocess to get a list of current process templates."
$templates = Invoke-RestMethod -Uri $urllistprocess -Headers $headers -ContentType "application/json" -Method Get;
Try
{
    $jsontemplates = ConvertTo-Json $templates -ErrorAction Stop
    Write-VstsTaskVerbose "Returned $($templates.count) processe templates on $account"
    foreach ($pt in $templates.value)
    {
        Write-VstsTaskVerbose "Found $($pt.name): $($pt.url)"
    }
    
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Write-VstsTaskError "Did not get a list of process templates back, twas not even JSON!"
    Write-VstsTaskError "Most common cause is that you did not authenticate correctly, check the Access Token."
    Write-VstsTaskError $ErrorMessage
    Break
}
$urlPublishProcess = "$($account)/_apis/work/processAdmin/processes/import?ignoreWarnings=true&api-version=2.2-preview"
$uploads = Get-ChildItem $matchProcessTemplates
Write-Output "You have specified $($uploads.count) process templates to upload"
Write-VstsTaskVerbose $uploads
foreach ($file in $uploads)
{
    Write-Output "Uploading $file" 
    $result = Invoke-RestMethod -InFile $file -Uri $urlPublishProcess -Headers $headers -ContentType "application/zip" -Method Post;
    Try
    {
        $uploadResult = ConvertTo-Json $result -ErrorAction Stop
        if ($result.validationResults.Count = 0)
        {
          Write-Output "$file sucessfully uploaded"
        } else {
           Write-VstsTaskError "Validation Failed for $file" 
           Write-VstsTaskError $uploadResult
        }
    }
    Catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-VstsTaskError "Did not get a result retunred from the upload, twas not even JSON!"
        Write-VstsTaskError $ErrorMessage
        Break
    }
}
