

# Command
$command = Get-VstsInput -Name command -Require
# sourceAccount
$sourceAccountName = Get-VstsInput -Name sourceAccount -Require
$sourceAccountEp = Get-VstsEndpoint -Name $sourceAccountName -Require
$sourceAccountToken = [string]$sourceAccountEp.Auth.Parameters.ApiToken
$sourceAccountUrl = [string]$sourceAccountEp.Url
# sourceProcessName

$sourceProcessName = Get-VstsInput -Name sourceProcessName -Require
# TargetAccount
$targetAccountName = Get-VstsInput -Name targetAccount -Require
$targetAccountEp = Get-VstsEndpoint -Name $targetAccountName -Require
$targetAccountToken = [string]$targetAccountEp.Auth.Parameters.ApiToken
$targetAccountUrl = [string]$targetAccountEp.Url
# targetProcessName
$targetProcessName = Get-VstsInput -Name targetProcessName -Require
# processFilename
$processFilename = Get-VstsInput -Name processFilename -Require
# logLevel
$logLevel = Get-VstsInput -Name logLevel -Require
# logFilename
$logFilename = Get-VstsInput -Name logFilename -Require
# overwritePicklist
$overwritePicklist = Get-VstsInput -Name overwritePicklist -Require
# continueOnRuleImportFailure
$continueOnRuleImportFailure = Get-VstsInput -Name continueOnRuleImportFailure -Require
# continueOnFieldDefaultValueFailure
$continueOnFieldDefaultValueFailure = Get-VstsInput -Name continueOnFieldDefaultValueFailure -Require
# skipImportFormContributions
$skipImportFormContributions = Get-VstsInput -Name skipImportFormContributions -Require

get-childitem -path env:INPUT_*
get-childitem -path env:ENDPOINT_*

Write-VstsTaskVerbose "command: $command" 
Write-VstsTaskVerbose "sourceAccountUrl: $sourceAccountUrl" 
Write-VstsTaskVerbose "targetProcessName: $targetProcessName" 
Write-VstsTaskVerbose "targetAccountUrl: $targetAccountUrl" 
Write-VstsTaskVerbose "targetProcessName: $targetProcessName" 

###########################################################

Get-Location

$configFile = "configuration.json"
if (!(Test-Path $configFile))
{
   
    $configObject =  new-object psobject
    Add-Member -InputObject $configObject -MemberType NoteProperty -Name sourceAccountUrl -Value $sourceAccountUrl
    Add-Member -InputObject $configObject -MemberType NoteProperty -Name sourceAccountToken -Value $sourceAccountToken
    Add-Member -InputObject $configObject -MemberType NoteProperty -Name sourceProcessName -Value $sourceProcessName
    Add-Member -InputObject $configObject -MemberType NoteProperty -Name targetAccountUrl -Value $targetAccountUrl
    Add-Member -InputObject $configObject -MemberType NoteProperty -Name targetAccountToken -Value $targetAccountToken
    Add-Member -InputObject $configObject -MemberType NoteProperty -Name targetProcessName -Value $targetProcessName

    $configOptionsObject =  new-object psobject

    Add-Member -InputObject $configOptionsObject -MemberType NoteProperty -Name processFilename -Value $processFilename
    Add-Member -InputObject $configOptionsObject -MemberType NoteProperty -Name logLevel -Value $logLevel
    Add-Member -InputObject $configOptionsObject -MemberType NoteProperty -Name logFilename -Value $logFilename
    Add-Member -InputObject $configOptionsObject -MemberType NoteProperty -Name overwritePicklist -Value [bool]$overwritePicklist
    Add-Member -InputObject $configOptionsObject -MemberType NoteProperty -Name continueOnRuleImportFailure -Value [bool]$continueOnRuleImportFailure
    Add-Member -InputObject $configOptionsObject -MemberType NoteProperty -Name continueOnFieldDefaultValueFailure -Value [bool]$continueOnFieldDefaultValueFailure
    Add-Member -InputObject $configOptionsObject -MemberType NoteProperty] -Name skipImportFormContributions -Value [bool]$skipImportFormContributions

    Add-Member -InputObject $configObject -MemberType NoteProperty -Name options -Value $configOptionsObject

    $configJson = ConvertTo-Json $configObject
    New-Item $configFile -ItemType FILE -Value $configJson -Force
}
$configJson = Get-Content $configFile -Raw
$ConfigData = ConvertFrom-Json $configJson

$ConfigData

######

###########################################################

npm install process-migrator -g

Write-VstsTaskVerbose $command

process-migrator --mode=$command --config=$configFile


