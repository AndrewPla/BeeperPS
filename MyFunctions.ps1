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

function Invoke-BprFocus {
	<#
    .SYNOPSIS
    Focus the Beeper Desktop application and optionally navigate to a specific chat or message.
    
    .DESCRIPTION
    Brings Beeper Desktop to the foreground and can optionally open a specific chat, jump to a message, or pre-fill a draft.
    
    .PARAMETER ChatId
    The ID of the chat to focus on.
    
    .PARAMETER MessageId
    The ID of the message to jump to.
    
    .PARAMETER DraftText
    Text to pre-fill in the message draft.
    
    .PARAMETER DraftAttachmentPath
    Path to a file to attach as a draft.
    
    .EXAMPLE
    Invoke-BprFocus -ChatId "chat123"
    #>
	[CmdletBinding()]
	param(
		[string]$ChatId,
		[string]$MessageId,
		[string]$DraftText,
		[string]$DraftAttachmentPath
	)
    
	$body = @{}
	if ($ChatId) { $body.chatID = $ChatId }
	if ($MessageId) { $body.messageID = $MessageId }
	if ($DraftText) { $body.draftText = $DraftText }
	if ($DraftAttachmentPath) { $body.draftAttachmentPath = $DraftAttachmentPath }
    
	Invoke-BprApi -Method POST -Path '/v1/focus' -Body $body
}

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