# copilot-cli-powershell

The official [Github Copilot CLI](https://www.npmjs.com/package/@githubnext/github-copilot-cli) has no direct Windows/Powershell support.  
This script substitutes the official project to make it easier to use on Windows.
It is adapted from [a Discord thread](https://ptb.discord.com/channels/735557230698692749/1078056236488085534/1078097805823971369) in the Github-Next Discord Server.

I am not a good Powershell Dev in any way. If someone wants to take this over or contribute, you are very welcome.

This project is not affiliated with Github or Microsoft.
## Installation
First, install the [Official GitHub Copilot CLI](https://www.npmjs.com/package/@githubnext/github-copilot-cli):  
`npm install @githubnext/github-copilot-cli` (requires NodeJS v16+)  
Then run `github-copilot-cli auth` and follow the instructions.

Then you can install this script from the PowerShell Gallery:  
`Install-Module -Name copilot-cli-powershell`  
Next, open your Powershell Profile file (e.g. via `code $PROFILE`) and add a line with the Text  
`Set-GitHubCopilotAliases`  
Finally, restart powershell and invoke Copilot by using `?? Type what Command you want here!`.
