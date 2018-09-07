

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
Write-VstsTaskVerbose "overwritePicklist: $overwritePicklist" 
Write-VstsTaskVerbose "continueOnRuleImportFailure: $continueOnRuleImportFailure" 
Write-VstsTaskVerbose "continueOnFieldDefaultValueFailure: $continueOnFieldDefaultValueFailure" 
Write-VstsTaskVerbose "skipImportFormContributions: $skipImportFormContributions" 


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
    Add-Member -InputObject $configOptionsObject -MemberType NoteProperty -Name overwritePicklist -Value $overwritePicklist
    Add-Member -InputObject $configOptionsObject -MemberType NoteProperty -Name continueOnRuleImportFailure -Value $continueOnRuleImportFailure
    Add-Member -InputObject $configOptionsObject -MemberType NoteProperty -Name continueOnFieldDefaultValueFailure -Value $continueOnFieldDefaultValueFailure
    Add-Member -InputObject $configOptionsObject -MemberType NoteProperty -Name skipImportFormContributions -Value $skipImportFormContributions

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

if ($command -eq "migrate") {
  process-migrator
} else {
  process-migrator --mode $command
}




