function Get-BprChat {
	<#
    .SYNOPSIS
    Get chat information.
    
    .DESCRIPTION
    Retrieves a specific chat by ID or lists all chats with pagination support.
    
    .PARAMETER ChatId
    The ID of a specific chat to retrieve.
    
    .PARAMETER Limit
    Maximum number of chats to return per page. Default is 50.
    
    .PARAMETER Cursor
    Pagination cursor for retrieving the next page of results.
    
    .PARAMETER All
    Retrieve all chats by automatically paging through results.
    
    .EXAMPLE
    Get-BprChat -ChatId "chat123"
    
    .EXAMPLE
    Get-BprChat -All
    #>
	[CmdletBinding()]
	param(
		[string]$ChatId,
		[int]$Limit = 50,
		[string]$Cursor,
		[switch]$All
	)
    
	if ($ChatId) {
		Invoke-BprApi -Method GET -Path "/v1/chats/$ChatId"
	}
	elseif ($All) {
		$allChats = @()
		$currentCursor = $Cursor
		$maxItems = 5000
        
		do {
			$queryParams = @{ limit = $Limit }
			if ($currentCursor) { $queryParams.cursor = $currentCursor }
            
			$result = Invoke-BprApi -Method GET -Path '/v1/chats' -Query $queryParams
			$allChats += $result.chats
			$currentCursor = $result.nextCursor
            
		} while ($currentCursor -and $allChats.Count -lt $maxItems)
        
		$allChats
	}
	else {
		$queryParams = @{ limit = $Limit }
		if ($Cursor) { $queryParams.cursor = $Cursor }
        
		$result = Invoke-BprApi -Method GET -Path '/v1/chats' -Query $queryParams
		$result.chats
	}
}
