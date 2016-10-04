Save-Module -Name VstsTaskSdk -Path ..\processtemplate-task\ps_modules\



Import-Module ..\processtemplate-task\ps_modules\VstsTaskSdk




Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create('. ..\processtemplate-task\upload-process-template.ps1')) -Verbose