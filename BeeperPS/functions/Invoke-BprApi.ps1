function Invoke-BprApi {

	[CmdletBinding()]
	param(
		[ValidateSet('GET', 'POST', 'PUT', 'DELETE')]
		[string]$Method = 'GET',
        
		[Parameter(Mandatory)]
		[string]$Path,
        
		[hashtable]$Query = @{},
        
		[object]$Body,
        
		[switch]$Raw,

		$Token = $script:BeeperConfigToken
	)
	if (-not $script:BeeperConfigToken) {
		throw "Beeper access token is not configured. Use Set-BprConfig or set the BEEPER_ACCESS_TOKEN environment variable."
	}
    
	# Build URI
	$uri = $script:BeeperConfigBaseUrl.TrimEnd('/') + $Path
	if ($Query.Count -gt 0) {
		$queryString = ($Query.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Web.HttpUtility]::UrlEncode($_.Value))" }) -join '&'
		$uri += "?$queryString"
	}
    
	# Prepare headers
	$headers = @{
		'Authorization' = "Bearer $Token"
		'Content-Type'  = 'application/json'
	}
    
	# Prepare request parameters
	$requestParams = @{
		Uri     = $uri
		Method  = $Method
		Headers = $headers
	}
    
	if ($Body) {
		$requestParams.Body = $Body | ConvertTo-Json -Depth 10
	}
    
	Write-Verbose "Making $Method request to: $uri"
    
	try {
		$response = Invoke-RestMethod @requestParams
		if ($Raw) {
			$response
		}
		else {
			$response
		}
	}
	catch {
		$errorMessage = "Beeper API call failed: $($_.Exception.Message)"
		if ($_.Exception.Response) {
			$errorMessage += " (Status: $($_.Exception.Response.StatusCode))"
		}
		throw $errorMessage
	}
}
