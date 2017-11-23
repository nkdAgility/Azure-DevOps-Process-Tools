#Save-Module -Name VstsTaskSdk -Path ..\processtemplatetask\processtemplatetaskv2\ps_modules\
Import-Module ..\processtemplatetask\processtemplatetaskv2\ps_modules\VstsTaskSdk\VstsTaskSdk.psm1
#Import-Module -Name VstsTaskSdk


$erroractionpreference='stop'
# Input 'MyInput':
$env:INPUT_Account = "https://nkdagility.visualstudio.com"
$env:INPUT_matchProcessTemplates = ""

$env:INPUT_processTemplateService = 'EP1'
$env:ENDPOINT_URL_EP1 = 'https://myurl'
$env:ENDPOINT_AUTH_EP1 = '{ "Parameters": { "AccessToken": "Sometokendata", }, "Scheme": "Token" }'
$env:ENDPOINT_DATA_EP1 = '{ "Key1": "Value1", "Key2": "Value2" }'


Invoke-vstsTaskScript -scriptBlock { . ..\processtemplatetask\processtemplatetaskv2\upload-process-template.ps1 } -Verbose

