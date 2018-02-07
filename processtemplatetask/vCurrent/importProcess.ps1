[CmdletBinding()]
param(
    [string] $accountURL,
    [string] $accesstoken,
    [string] $processFile,
    [string] $overrideGuid
)
#Main Inputs
$processServiceName = Get-VstsInput -Name VstsXmlProcessService -Require
$processFile = Get-VstsInput -Name processFile -Require
$waitForUpdate = Get-VstsInput -Name waitForUpdate -Require
$waitForInterval = Get-VstsInput -Name waitForInterval -Require
$overrideProcessGuid = Get-VstsInput -Name overrideProcessGuid
$overrideProcessName = Get-VstsInput -Name overrideProcessName
# EndPoint 
$processServiceEndpoint = Get-VstsEndpoint -Name $processServiceName -Require
$accesstoken = [string]$processServiceEndpoint.Auth.Parameters.ApiToken
$accountURL = [string]$processServiceEndpoint.Url

get-childitem -path env:INPUT_*
get-childitem -path env:ENDPOINT_*

Write-VstsTaskVerbose "VSTS Account: $accountURL" 
Write-VstsTaskVerbose "Process File: $processFile" 
Write-VstsTaskVerbose "Acces Token: $accesstoken" 
Write-VstsTaskVerbose "Process GUID: $overrideProcessGuid"
Write-VstsTaskVerbose "Process Name: $overrideProcessName"


#Write-Output "rootDirectory  " $rootDirectory
Write-VstsTaskVerbose "Building Base64 PAT Token"
# Base64-encodes the Personal Access Token (PAT) appropriately
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "",$accesstoken)))
$headers = @{authorization=("Basic {0}" -f $base64AuthInfo)}
$headers.Add("X-TFS-FedAuthRedirect","Suppress")
##########################################
# Get a List of Templates
##########################################
$urllistprocess = "$($accountURL)/_apis/process/processes?api-version=1.0"
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
Write-VstsTaskVerbose "Returned $($templates.count) processe templates on $accountURL"
foreach ($pt in $templates.value)
{
    Write-Output "Found $($pt.name): $($pt.url)"
}
##########################################
# Fix Overrides
##########################################
$file = Get-ChildItem $processFile
Write-VstsTaskVerbose $file
if ((($overrideProcessGuid -ne $null) -and ($overrideProcessGuid -ne "")) -or (($overrideProcessName -ne $null) -and ($overrideProcessName -ne "")))
{
    Write-VstsTaskVerbose "***RUNNNING OVERIDES****"
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $workFolder = [System.IO.Path]::Combine($file.Directory.FullName, "template")
    if (Test-Path $workFolder)
    {
        [System.IO.Directory]::Delete($workFolder, $true)
    }
    [System.IO.Compression.ZipFile]::ExtractToDirectory($file, $workFolder)
    $processFile = "$workFolder\ProcessTemplate.xml"
    $xml = [xml](get-content $processFile)
    if (($overrideProcessGuid -ne $null) -and ($overrideProcessGuid -ne ""))
    {
        $guidXml = $xml.ProcessTemplate.metadata.version.Attributes.GetNamedItem("type")
        $guid = $guidXml.'#text'
         Write-VstsTaskVerbose "Current GUID is $guid and we are replacing it with $overrideProcessGuid before upload"
        $guidXml.'#text' = $overrideProcessGuid
    }
    if (($overrideProcessName -ne $null) -and ($overrideProcessName -ne ""))
    {
        $nameXML = $xml.ProcessTemplate.metadata.name
         Write-VstsTaskVerbose "Current Name of the Process is $nameXML and we are replacing it with $overrideProcessName before upload"
        $xml.ProcessTemplate.metadata.name = $overrideProcessName
    }
    $xml.Save([string]$processFile)
    [System.IO.File]::Delete($file)
    [System.IO.Compression.ZipFile]::CreateFromDirectory($workFolder,$file)
}
##########################################
# Upload templates
##########################################
#$urlPublishProcess = "$($accountURL)/_apis/work/processAdmin/processes/import?ignoreWarnings=true&api-version=2.2-preview"
$urlPublishProcess = "$($accountURL)/_apis/work/processAdmin/processes/import?api-version=4.0-preview.1"
Write-Output "Uploading $file" 
$importResult = Invoke-RestMethod -InFile $file -Uri $urlPublishProcess -Headers $headers -ContentType "application/zip" -Method Post #-Proxy "http://127.0.0.1:8888";
if ($importResult.validationResults.Count -eq 0)
{
    Write-Output "$($file.Name) sucessfully validated and job is queued"
} else {
    Write-VstsTaskError "Validation Failed for $($file.Name)"
    Write-VstsTaskError $uploadResult
    exit 1
}

##########################################
# Wait for Job to finish
##########################################
If ($waitForUpdate)
{
    $waitForJob = 1
    $startTime = $(get-date)
    $promoteJobId= $importResult.promoteJobId
    $id = $importResult.Id
    $urlStatusCheck = "$($accountURL)/_apis/work/processadmin/processes/status/{0}?id={1}&api-version=4.1-preview" -f $id, $promoteJobId #<-- Does not work
    
    While ($waitForJob -eq 1) 
    {
        $elapsedTime = new-timespan $startTime
        $statusResult = Invoke-RestMethod -Uri $urlStatusCheck -Headers $headers -ContentType "application/json" -Method Get #-Proxy "http://127.0.0.1:8888";
        Write-Output ("Job Running {0}m:{1}s | Complete {2} | Pending {3} | Retries {4}" -f [int]$elapsedTime.TotalMinutes, $elapsedTime.Seconds, $statusResult.complete, $statusResult.pending, $statusResult.remainingRetries)
        $successful = $statusResult.successful
        if ($successful -eq 1)
        {
         $waitForJob = 0
        }
        else
        {
          Start-Sleep -s ([int]$waitForInterval)
        }
   }
   if ($statusResult.successful)
   {
    Write-Output ("Job Finished Sucess {0}m:{1}s | Complete {2} | Pending {3} | Retries remaining {4}" -f [int]$elapsedTime.TotalMinutes, $elapsedTime.Seconds, $statusResult.complete, $statusResult.pending, $statusResult.remainingRetries)
   }
   else
   {
     Write-VstsTaskError ("Job Failed {0}m:{1}s | Complete {2} | Pending {3} | Retries remaining {4}" -f [int]$elapsedTime.TotalMinutes, $elapsedTime.Seconds, $statusResult.complete, $statusResult.pending, $statusResult.remainingRetries)
     Write-VstsTaskError $statusResult
     exit 1
   }
   
}


