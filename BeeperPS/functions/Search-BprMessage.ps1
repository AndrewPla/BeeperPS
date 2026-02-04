function Search-BprMessage {
	<#
    .SYNOPSIS
    Search for messages across chats using Beeper's message index.
    
    .DESCRIPTION
    Searches for messages with advanced filtering options including date ranges, media types, senders, and chat types.
    
    .PARAMETER Query
    Literal word search (non-semantic). Finds messages containing these EXACT words in any order. 
    Use single words users actually type, not concepts or phrases. Example: use "dinner" not "dinner plans".
    
    .PARAMETER AccountIDs
    Array of account IDs to limit search to specific accounts.
    
    .PARAMETER ChatIDs
    Array of chat IDs to limit search to specific chats.
    
    .PARAMETER ChatType
    Filter by chat type: 'group' for group chats, 'single' for 1:1 chats.
    
    .PARAMETER DateAfter
    Only include messages with timestamp strictly after this ISO 8601 datetime (e.g., '2024-07-01T00:00:00Z').
    
    .PARAMETER DateBefore
    Only include messages with timestamp strictly before this ISO 8601 datetime (e.g., '2024-07-31T23:59:59Z').
    
    .PARAMETER Sender
    Filter by sender: 'me' (messages sent by you), 'others' (messages sent by others), or a specific user ID string.
    
    .PARAMETER MediaTypes
    Filter messages by media types. Use @('any') for any media type, or specify exact types like @('video', 'image').
    
    .PARAMETER ExcludeLowPriority
    Exclude messages marked Low Priority by the user. Default: true.
    
    .PARAMETER IncludeMuted
    Include messages in chats marked as Muted by the user. Default: true.
    
    .PARAMETER Limit
    Maximum number of messages to return (0-20). Default is 20.
    
    .PARAMETER Cursor
    Pagination cursor for retrieving the next page of results.
    
    .PARAMETER Direction
    Pagination direction used with 'cursor': 'before' fetches older results, 'after' fetches newer results.
    
    .EXAMPLE
    Search-BprMessage -Query "deadline"
    Search for messages containing the word "deadline"
    
    .EXAMPLE
    Search-BprMessage -Query "meeting" -ChatType "group" -DateAfter "2024-01-01T00:00:00Z"
    Search for "meeting" in group chats after January 1, 2024
    
    .EXAMPLE
    Search-BprMessage -MediaTypes @("image", "video") -DateAfter "2024-01-01T00:00:00Z"
    Search for messages with images or videos from this year
    
    .EXAMPLE
    Search-BprMessage -Sender "me" -DateAfter "2024-01-01T00:00:00Z" -Limit 10
    Search for your own messages from this year, limited to 10 results
    #>
	[CmdletBinding()]
	param(
		[string]$Query,
        
		[string[]]$AccountIDs,
        
		[string[]]$ChatIDs,
        
		[ValidateSet('group', 'single')]
		[string]$ChatType,
        
		[string]$DateAfter,
        
		[string]$DateBefore,
        
		[string]$Sender,
        
		[ValidateSet('any', 'video', 'image', 'audio', 'file')]
		[string[]]$MediaTypes,
        
		[bool]$ExcludeLowPriority = $true,
        
		[bool]$IncludeMuted = $true,
        
		[ValidateRange(0, 20)]
		[int]$Limit = 20,
        
		[string]$Cursor,
        
		[ValidateSet('before', 'after')]
		[string]$Direction
	)
    
	$queryParams = @{
		excludeLowPriority = $ExcludeLowPriority.ToString().ToLower()
		includeMuted       = $IncludeMuted.ToString().ToLower()
		limit              = $Limit
	}
    
	if ($Query) { $queryParams.query = $Query }
	if ($AccountIDs) { $queryParams.accountIDs = $AccountIDs }
	if ($ChatIDs) { $queryParams.chatIDs = $ChatIDs }
	if ($ChatType) { $queryParams.chatType = $ChatType }
	if ($DateAfter) { $queryParams.dateAfter = $DateAfter }
	if ($DateBefore) { $queryParams.dateBefore = $DateBefore }
	if ($Sender) { $queryParams.sender = $Sender }
	if ($MediaTypes) { $queryParams.mediaTypes = $MediaTypes }
	if ($Cursor) { $queryParams.cursor = $Cursor }
	if ($Direction) { $queryParams.direction = $Direction }
    
	Invoke-BprApi -Method GET -Path '/v1/messages/search' -Query $queryParams
}
