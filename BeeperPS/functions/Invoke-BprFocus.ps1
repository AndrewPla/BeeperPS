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
