#Save-Module -Name VstsTaskSdk -Path ..\processtemplatetask\processtemplatetaskv2\ps_modules\
#Set-Location C:\Users\MartinHinshelwoodnkd\source\repos\vsts-processtemplate-task\inheritedprocessmigration\vCurrent
Import-Module .\\ps_modules\VstsTaskSdk\VstsTaskSdk.psd1
#Import-Module -Name VstsTaskSdk
#### Usefull bits ##############



################################################
############### Test Data Setup ################ www.itprotoday.com/microsoft-azure/read-secret-azure-key-vault-using-powershell
################################################
$TestDataFile = "c:\temp\inheritedprocessmigration\TestData.json"
if (!(Test-Path $TestDataFile))
{
   
    $TestDataPS =  new-object psobject
    Add-Member -InputObject $TestDataPS -MemberType NoteProperty -Name command -Value "migrate"
    Add-Member -InputObject $TestDataPS -MemberType NoteProperty -Name sourceAccountUrl -Value "https://nkdagility.visualstudio.com"
    Add-Member -InputObject $TestDataPS -MemberType NoteProperty -Name sourceAccountToken -Value "mytoken"
    Add-Member -InputObject $TestDataPS -MemberType NoteProperty -Name sourceProcessName -Value "nkdScrum"
    Add-Member -InputObject $TestDataPS -MemberType NoteProperty -Name targetAccountUrl -Value "https://nkdagility-dev.visualstudio.com"
    Add-Member -InputObject $TestDataPS -MemberType NoteProperty -Name targetAccountToken -Value "mytoken"
    Add-Member -InputObject $TestDataPS -MemberType NoteProperty -Name targetProcessName -Value "nkdScrum"
    Add-Member -InputObject $TestDataPS -MemberType NoteProperty -Name processFilename -Value "c:\temp\configuration.json"
    Add-Member -InputObject $TestDataPS -MemberType NoteProperty -Name logLevel -Value "verbose"
    Add-Member -InputObject $TestDataPS -MemberType NoteProperty -Name logFilename -Value "processMigrator.log"
    Add-Member -InputObject $TestDataPS -MemberType NoteProperty -Name overwritePicklist -Value $false
    Add-Member -InputObject $TestDataPS -MemberType NoteProperty -Name continueOnRuleImportFailure -Value $false
    Add-Member -InputObject $TestDataPS -MemberType NoteProperty -Name continueOnFieldDefaultValueFailure -Value $false
    Add-Member -InputObject $TestDataPS -MemberType NoteProperty -Name skipImportFormContributions -Value $false
    $TestDataJson = ConvertTo-Json $TestDataPS
    New-Item $TestDataFile -ItemType FILE -Value $TestDataJson -Force
}
$TestDataJson = Get-Content $TestDataFile -Raw
$TestData = ConvertFrom-Json $TestDataJson
################################################
$erroractionpreference='stop'
################################################
########### setup inputs #######################
################################################

# Command
$env:INPUT_command = $TestData.command
# Source Account
$env:INPUT_sourceAccount = 'EP1'
$env:ENDPOINT_URL_EP1 = $TestData.sourceAccountUrl
$env:ENDPOINT_AUTH_EP1 = "{ `"Parameters`": { `"ApiToken`": `"$($TestData.sourceAccountToken)`"}, `"Scheme`": `"Token`" }"
$env:ENDPOINT_DATA_EP1 = '{ "Key1": "Value1", "Key2": "Value2" }'
# sourceProcessName
$env:INPUT_sourceProcessName = $TestData.sourceProcessName
# Target Account
$env:INPUT_targetAccount = 'EP2'
$env:ENDPOINT_URL_EP2 = $TestData.targetAccountUrl
$env:ENDPOINT_AUTH_EP2 = "{ `"Parameters`": { `"ApiToken`": `"$($TestData.targetAccountToken)`"}, `"Scheme`": `"Token`" }"
$env:ENDPOINT_DATA_EP2 = '{ "Key1": "Value1", "Key2": "Value2" }'
# targetProcessName
$env:INPUT_targetProcessName = $TestData.targetProcessName
# processFilename
$env:INPUT_processFilename = $TestData.processFilename
# logLevel
$env:INPUT_logLevel = $TestData.logLevel
# logFilename
$env:INPUT_logFilename = $TestData.logFilename
# overwritePicklist
$env:INPUT_overwritePicklist = $TestData.overwritePicklist
# continueOnRuleImportFailure
$env:INPUT_continueOnRuleImportFailure = $TestData.continueOnRuleImportFailure
# continueOnFieldDefaultValueFailure
$env:INPUT_continueOnFieldDefaultValueFailure = $TestData.continueOnFieldDefaultValueFailure
# skipImportFormContributions
$env:INPUT_skipImportFormContributions = $TestData.skipImportFormContributions

Invoke-vstsTaskScript -scriptBlock { . .\processmigratestart.ps1 } -Verbose

