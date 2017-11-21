Save-Module -Name VstsTaskSdk -Path ..\processtemplatetask\processtemplatetaskv2\ps_modules\
Import-Module ..\processtemplatetask\processtemplatetaskv2\ps_modules\VstsTaskSdk\VstsTaskSdk.psm1


Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create('. ..\processtemplate-task\upload-process-template.ps1')) -Verbose