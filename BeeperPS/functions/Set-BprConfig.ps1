function Set-BprConfig {
	<#
    .SYNOPSIS
    Configure the Beeper API connection settings.
    
    .DESCRIPTION
    Sets the base URL and authentication token for connecting to the Beeper Desktop API.
    z
    .PARAMETER BaseUrl
    The base URL for the Beeper Desktop API. Defaults to http://localhost:23373.
    
    .PARAMETER Token
    The access token for authenticating with the Beeper API.
    
    .EXAMPLE
    Set-BprConfig -Token "your-access-token"
    
    .EXAMPLE
    Set-BprConfig -BaseUrl "http://localhost:8080" -Token "your-token"
    #>
	[CmdletBinding()]
	param(
		[string]$BaseUrl = 'http://localhost:23373',

		[ValidateScript({
				if (-not $_) {
					throw "BEEPER_ACCESS_TOKEN is missing, specify it using -Token parameter or set the `$env:BEEPER_ACCESS_TOKEN environment variable."
				}
				else { $true }
			})][string]$Token = $env:BEEPER_ACCESS_TOKEN
	)
    
    
	if ($BaseUrl) {
		$script:BeeperConfigBaseUrl = $BaseUrl
		Write-Verbose "Base URL set to: $BaseUrl"
	}
    
	if ($Token) {
		$script:BeeperConfigToken = $Token
		Write-Verbose "Access token configured"
	}
}
