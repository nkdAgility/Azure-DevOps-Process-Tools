#Save-Module -Name VstsTaskSdk -Path ..\processtemplatetask\processtemplatetaskv2\ps_modules\
#Set-Location C:\Users\MartinHinshelwoodnkd\source\repos\vsts-processtemplate-task\processtemplatetask\processtemplatetaskv2
Import-Module .\\ps_modules\VstsTaskSdk\VstsTaskSdk.psd1
#Import-Module -Name VstsTaskSdk
#### Usefull bits ##############



################################################
############### Test Data Setup ################ www.itprotoday.com/microsoft-azure/read-secret-azure-key-vault-using-powershell
################################################
$TestDataFile = "c:\temp\pt\TestData.json"
if (!(Test-Path $TestDataFile))
{
   
  $TestDataPS =  new-object psobject
  Add-Member -InputObject $TestDataPS -MemberType NoteProperty -Name processFile -Value "c:\temp\pt\SLM-PT-VSTS-2017.7.0.zip"
  Add-Member -InputObject $TestDataPS -MemberType NoteProperty -Name AccountURL -Value "https://xxx-xxx-devbox.visualstudio.com"
  Add-Member -InputObject $TestDataPS -MemberType NoteProperty -Name ApiToken -Value "mytoken"
  Add-Member -InputObject $TestDataPS -MemberType NoteProperty -Name waitForUpdate -Value $true
  Add-Member -InputObject $TestDataPS -MemberType NoteProperty -Name waitForInterval -Value 10
  Add-Member -InputObject $TestDataPS -MemberType NoteProperty -Name overrideProcessGuid -Value ""
  Add-Member -InputObject $TestDataPS -MemberType NoteProperty -Name overrideProcessName -Value ""
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
# Input 'MyInput':
$env:INPUT_VstsXmlProcessService = 'EP1'
$env:ENDPOINT_URL_EP1 = $TestData.AccountURL
$env:ENDPOINT_AUTH_EP1 = "{ `"Parameters`": { `"ApiToken`": `"$($TestData.ApiToken)`"}, `"Scheme`": `"Token`" }"
$env:ENDPOINT_DATA_EP1 = '{ "Key1": "Value1", "Key2": "Value2" }'

$env:INPUT_processFile = $TestData.processFile
$env:INPUT_waitForUpdate = $TestData.waitForUpdate
$env:INPUT_waitForInterval = $TestData.waitForInterval
$env:INPUT_overrideProcessGuid = $TestData.overrideProcessGuid
$env:INPUT_overrideProcessName = $TestData.overrideProcessName
Invoke-vstsTaskScript -scriptBlock { . .\importProcess.ps1 } -Verbose

