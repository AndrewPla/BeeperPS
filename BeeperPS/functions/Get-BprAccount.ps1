function Get-BprAccount {
	<#
    .SYNOPSIS
    Get Beeper accounts.
    
    .DESCRIPTION
    Retrieves all configured accounts or filters by account ID or network.
    
    .PARAMETER AccountId
    Optional account ID to filter results.
    
    .PARAMETER Network
    Optional network name to filter by.
    
    .EXAMPLE
    Get-BprAccount
    
    .EXAMPLE
    Get-BprAccount -Network "telegram"
    #>
	[CmdletBinding()]
	param(
		[string]$AccountId,
		[string]$Network
	)
    
	$accounts = Invoke-BprApi -Method GET -Path '/v1/accounts'
    
	if ($AccountId) {
		$accounts = $accounts | Where-Object { $_.id -eq $AccountId }
	}
    
	if ($Network) {
		$accounts = $accounts | Where-Object { $_.network -eq $Network }
	}
    
	$accounts
}
