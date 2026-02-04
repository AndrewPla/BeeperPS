# Commands run on module import go here
# E.g. Argument Completers could be placed here

$env:BEEPER_ACCESS_TOKEN = [Environment]::GetEnvironmentVariable(
	"BEEPER_ACCESS_TOKEN",
	[EnvironmentVariableTarget]::User
)