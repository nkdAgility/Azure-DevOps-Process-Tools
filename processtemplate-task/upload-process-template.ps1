[CmdletBinding()]
param(
    [string] $account,
    [string] $accesstoken,
    [string] $encoding,
    [string] $failOnMissing, #keep for backward compatibility
    [string] $tokenPrefix,
    [string] $tokenSuffix,
    [string] $writeBOM,
    [string] $actionOnMissing,
    [string] $keepToken
)
