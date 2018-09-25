
$ErrorActionPreference = "Stop"

# Command
$command = Get-VstsInput -Name command -Require

# sourceAccount 
$sourceAccountName = Get-VstsInput -Name sourceAccount 
if ($sourceAccountName -ne $null -or $sourceAccountName -ne "")
{
	$sourceAccountEp = Get-VstsEndpoint -Name $sourceAccountName
	$sourceAccountToken = [string]$sourceAccountEp.Auth.Parameters.ApiToken
	$sourceAccountUrl = [string]$sourceAccountEp.Url
}
# sourceProcessName

$sourceProcessName = Get-VstsInput -Name sourceProcessName
# TargetAccount
$targetAccountName = Get-VstsInput -Name targetAccount
if ($targetAccountName -ne $null -or $targetAccountName -ne "")
{
	$targetAccountEp = Get-VstsEndpoint -Name $targetAccountName
	$targetAccountToken = [string]$targetAccountEp.Auth.Parameters.ApiToken
	$targetAccountUrl = [string]$targetAccountEp.Url
}
# targetProcessName
$targetProcessName = Get-VstsInput -Name targetProcessName
# processFilename
$processFilename = Get-VstsInput -Name processFilename
# logLevel
$logLevel = Get-VstsInput -Name logLevel -Require
# logFilename
$logFilename = Get-VstsInput -Name logFilename -Require
# overwritePicklist
$overwritePicklist = Get-VstsInput -Name overwritePicklist -Require -AsBool
# continueOnRuleImportFailure
$continueOnRuleImportFailure = Get-VstsInput -Name continueOnRuleImportFailure -Require -AsBool
# continueOnFieldDefaultValueFailure
$continueOnFieldDefaultValueFailure = Get-VstsInput -Name continueOnFieldDefaultValueFailure -Require -AsBool
# skipImportFormContributions
$skipImportFormContributions = Get-VstsInput -Name skipImportFormContributions -Require -AsBool

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
    Add-Member -InputObject $configOptionsObject -MemberType NoteProperty -Name skipImportFormContributions -Value [bool]$skipImportFormContributions

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

Write-VstsTaskVerbose "Removing $configFile file to remove PAT tokens from file system." 
Remove-Item $configFile


