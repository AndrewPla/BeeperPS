function Get-BprConfig {
	<#
    .SYNOPSIS
    Get the current Beeper API configuration.
    
    .DESCRIPTION
    Returns the current configuration settings including base URL and whether a token is set.
    
    .EXAMPLE
    Get-BprConfig
    #>
	[CmdletBinding()]
	param()

	if (-not $script:BeeperConfigBaseUrl) {
		throw "Beeper configuration is not initialized. Use Set-BprConfig to set it up."
	}

	if (-not $script:BeeperConfigToken -and $env:BEEPER_ACCESS_TOKEN) {
		$script:BeeperConfigToken = $env:BEEPER_ACCESS_TOKEN
	}
    
	if (-not $script:BeeperConfigToken) {
		throw 'Beeper access token is not configured. Use Set-BprConfig or set the $env:BEEPER_ACCESS_TOKEN environment variable.'
	}
   
    
	[PSCustomObject]@{
		BaseUrl         = $script:BeeperConfigBaseUrl
		TokenConfigured = [bool]$script:BeeperConfigToken
	}
}
