function Search-BprChat {
	<#
    .SYNOPSIS
    Search for chats.
    
    .DESCRIPTION
    Searches for chats using a query string with pagination support.
    
    .PARAMETER Query
    The search query string.
    
    .PARAMETER Limit
    Maximum number of results to return. Default is 50.
    
    .PARAMETER Cursor
    Pagination cursor for retrieving the next page of results.
    
    .EXAMPLE
    Search-BprChat -Query "project team"
    #>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string]$Query,
        
		[int]$Limit = 50,
		[string]$Cursor
	)
    
	$queryParams = @{
		q     = $Query
		limit = $Limit
	}
	if ($Cursor) { $queryParams.cursor = $Cursor }
    
	Invoke-BprApi -Method GET -Path '/v1/chats/search' -Query $queryParams | Select-Object -ExpandProperty items
}
