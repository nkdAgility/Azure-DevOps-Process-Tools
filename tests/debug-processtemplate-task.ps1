#Save-Module -Name VstsTaskSdk -Path ..\processtemplatetask\processtemplatetaskv2\ps_modules\
Set-Location C:\Users\MartinHinshelwoodnkd\source\repos\vsts-processtemplate-task\tests
Import-Module ..\processtemplatetask\processtemplatetaskv2\ps_modules\VstsTaskSdk\VstsTaskSdk.psd1
#Import-Module -Name VstsTaskSdk


$erroractionpreference='stop'
# Input 'MyInput':
$env:INPUT_Account = "https://slb-swt-devbox.visualstudio.com"
$env:INPUT_matchProcessTemplates = "c:\temp\pt\SLM-PT-VSTS-2017.7.0.zip"
$env:INPUT_overrideGuid = "newGUID"

$env:INPUT_processTemplateService = 'EP1'
$env:ENDPOINT_URL_EP1 = 'https://myurl'
$env:ENDPOINT_AUTH_EP1 = '{ "Parameters": { "ApiToken": "5aofdqwf3aa7kyf7dvjptctjxqbtptjtavtxhf5airbhisuwekmq"}, "Scheme": "Token" }'

Invoke-vstsTaskScript -scriptBlock { . ..\processtemplatetask\processtemplatetaskv2\upload-process-template.ps1 } -Verbose

