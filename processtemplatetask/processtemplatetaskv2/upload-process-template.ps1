[CmdletBinding()]
param(
    [string] $account,
    [string] $accesstoken,
    [string] $matchProcessTemplates,
    [string] $overrideGuid
)
$account = Get-VstsInput -Name account -Require
$matchProcessTemplates = Get-VstsInput -Name matchProcessTemplates -Require
$endpointName = Get-VstsInput -Name processTemplateService -Require
$endpoint = Get-VstsEndpoint -Name $endpointName -Require
$OverrideProcessTemplateGUID = Get-VstsInput -Name overrideGuid

$accesstoken = [string]$endpoint.Auth.Parameters.ApiToken

Write-VstsTaskVerbose "Account: $account" 
Write-VstsTaskVerbose "matchProcessTemplates: $matchProcessTemplates" 
Write-VstsTaskVerbose "accesstoken: $accesstoken" 
Write-VstsTaskVerbose "GUID: $OverrideProcessTemplateGUID" 


#Write-Output "rootDirectory  " $rootDirectory
Write-VstsTaskVerbose "Building Base64 PAT Token"
# Base64-encodes the Personal Access Token (PAT) appropriately
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "",$accesstoken)))
$headers = @{authorization=("Basic {0}" -f $base64AuthInfo)}
$headers.Add("X-TFS-FedAuthRedirect","Suppress")
##########################################
# Get a List of Templates
##########################################
$urllistprocess = "$($account)/_apis/process/processes?api-version=1.0"
Write-VstsTaskVerbose "Calling $urllistprocess to get a list of current process templates."
$templates = Invoke-RestMethod -Uri $urllistprocess -Headers $headers -ContentType "application/json" -Method Get;
Try
{
    $jsontemplates = ConvertTo-Json $templates -ErrorAction Stop    
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Write-VstsTaskError "Did not get a list of process templates back, twas not even JSON!"
    Write-VstsTaskError "Most common cause is that you did not authenticate correctly, check the Access Token."
    Write-VstsTaskError $ErrorMessage
    exit 999
}
# Write out the Tenplate list
Write-VstsTaskVerbose "Returned $($templates.count) processe templates on $account"
foreach ($pt in $templates.value)
{
    Write-Output "Found $($pt.name): $($pt.url)"
}
##########################################
# Fix Overrides
##########################################
$file = Get-ChildItem $matchProcessTemplates
Write-VstsTaskVerbose $file
if ($OverrideProcessTemplateGUID -ne $null )
{
    Write-VstsTaskVerbose "***RUNNNING OVERIDES****"
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $workFolder = [System.IO.Path]::Combine($file.Directory.FullName, "template")
    [System.IO.Compression.ZipFile]::ExtractToDirectory($file, $workFolder)
    $processFile = "$workFolder\ProcessTemplate.xml"
    $xml = [xml](get-content $processFile)
    $guidXml = $xml.ProcessTemplate.metadata.version.Attributes.GetNamedItem("type")
    $guid = $guidXml.'#text'
     Write-VstsTaskVerbose "Current GUID is $guid and we are replacing it with $OverrideProcessTemplateGUID before upload"
    $guidXml.'#text' = $OverrideProcessTemplateGUID
    $xml.Save([string]$processFile)
    [System.IO.File]::Move($file, "$file.old")
    [System.IO.Compression.ZipFile]::CreateFromDirectory($workFolder,$file)
}

##########################################
# Upload templates
##########################################
#$urlPublishProcess = "$($account)/_apis/work/processAdmin/processes/import?ignoreWarnings=true&api-version=2.2-preview"
$urlPublishProcess = "$($account)/_apis/work/processAdmin/processes/import?api-version=4.0-preview.1"
Write-Output "Uploading $file" 
$result = Invoke-RestMethod -InFile $file -Uri $urlPublishProcess -Headers $headers -ContentType "application/zip" -Method Post;
Try
{
    $uploadResult = ConvertTo-Json $result
    Write-Output "$file uploaded, checking validatiopn"
}
Catch
{

    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Write-VstsTaskError "Did not get a result retunred from the upload, twas not even JSON!"
    Write-VstsTaskError $ErrorMessage
    Write-VstsTaskError $result
    exit 666
}
if ($result.validationResults.Count -eq 0)
{
    Write-Output "$($file.Name) sucessfully validated"
    exit 0
} else {
    Write-VstsTaskError "Validation Failed for $($file.Name)"
    Write-VstsTaskError $uploadResult
    exit 1
}

