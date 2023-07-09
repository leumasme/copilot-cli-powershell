# copilot-cli-powershell

The official [Github Copilot CLI](https://www.npmjs.com/package/@githubnext/github-copilot-cli) has no direct Windows/Powershell support.  
This script substitutes the official project to make it easier to use on Windows.
It is adapted from [a Discord thread](https://ptb.discord.com/channels/735557230698692749/1078056236488085534/1078097805823971369) in the Github-Next Discord Server.

I am not a good Powershell Dev in any way. If someone wants to take this over or contribute, you are very welcome.

This project is not affiliated with Github or Microsoft.
## Installation
First, make sure you have [NodeJS](https://nodejs.org/en) v16+ installed and install the [Official GitHub Copilot CLI](https://www.npmjs.com/package/@githubnext/github-copilot-cli):  
`npm install -g @githubnext/github-copilot-cli` (or yarn/pnpm equivalent if you prefer using those to manage your NodeJS packages)  
Then run `github-copilot-cli auth` and follow the instructions.

Then you can install this script from the PowerShell Gallery:  
`Install-Module -Name copilot-cli-powershell`  
Next, open your Powershell Profile file (e.g. via `code $PROFILE`) and add a line with the Text  
`Set-GitHubCopilotAliases`  
(Or, if you're experiencing issues, use the passive mode instead: `Set-PassiveGitHubCopilotAliases`)  
Finally, restart powershell and invoke Copilot by using `?? Type what Command you want here!`  
or `git? Type what git-specific Command you want here!`  
or `gh? Type what github-cli-specific Command you want here!`

## Normal vs Passive mode

TLDR:

Passive mode will simply register `??`, `git?` and `gh?` as command aliases that start copilot-cli.

Normal mode will hook into powershell to listen for `Enter` keypresses to replace the command with an escaped version before powershell parses it to also capture characters like `"`, `;`, `|`   
Normal mode will break if another script also tries to hook the `Enter` key.  

/TLDR

Powershell tries to parse typed commands to provide functionality like:
- output piping (via "|")
- multiple commands in one line (via ";")
- multiple lines for one command (via automatically detecting unbalanced quotes and brackets)

This however also means that using copilot-cli with an instruction that contains any of these special characters won't work.  
For example:  
`?? Join all words from the Get-Verb command with ", "`  
will be transformed into the instruction  
`Join all words from the Get-Verb command with ,`  
and  
`?? List all png files; sort them by size`  
will be transformed into the instruction  
`List all png files` and a separate **command** `sort them by size`  (which likely errors since `sort` isn't a command/binary)

Normal mode is potentially problematic as `PSReadLine` currently has no support for multiple Key Handlers (not even for retrieving key handlers before replacing them so we can call them later).  
This means that, if another script is also hooking the `Enter` key using `Set-PSReadLineKeyHandler`, only one of the two key handlers will actually run, breaking either this script or the other one.