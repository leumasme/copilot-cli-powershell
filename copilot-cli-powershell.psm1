<#
.SYNOPSIS
    A PowerShell module to interact with the GitHub Copilot CLI.

.DESCRIPTION
    This module provides a convenient way to generate and execute code suggestions
    from the GitHub Copilot CLI in a PowerShell environment.
#>

function Invoke-GitAlias {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromRemainingArguments, HelpMessage = "The remaining arguments for the Copilot command.")]
        [string[]]$RemainingArguments
    )
    Invoke-CopilotCommand "git-assist" ($RemainingArguments -join " ")
}
function Invoke-GHAlias {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromRemainingArguments, HelpMessage = "The remaining arguments for the Copilot command.")]
        [string[]]$RemainingArguments
    )
    Invoke-CopilotCommand "gh-assist" ($RemainingArguments -join " ")
}

function Invoke-GitHubCopilot {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromRemainingArguments, HelpMessage = "The remaining arguments for the Copilot command.")]
        [string[]]$RemainingArguments
    )
    Invoke-CopilotCommand "what-the-shell" ($RemainingArguments -join " ")
}

function Invoke-CopilotCommand {
    param (
        [Parameter(Mandatory)][string]$SubCommand,
        [Parameter(Mandatory)][string]$Instruction
    )

    $tempFile = Join-Path -Path $Env:TEMP -ChildPath "copilot_$((Get-Date).ToString('yyyyMMddHHmmss'))_$(Get-Random -Maximum 9999).txt"

    github-copilot-cli $SubCommand --shellout $tempFile $Instruction

    if ($LASTEXITCODE -eq 0) {
        $fileContentsArray = Get-Content $tempFile
        $fileContents = [string]::Join("`n", $fileContentsArray)
        Write-Host $fileContents
        Invoke-Expression $fileContents
    }
    else {
        Write-Host "User cancelled the command."
    }
}

function Test-EscapedString {
    param (
        [Parameter(Mandatory)][string]$String
    )

    
    $startChar = $String.Substring(0, 1)
    $endChar = $String.Substring($String.Length - 1, 1)

    if (($startChar -eq "'") -and ($endChar -eq "'")) {
        $unescapedQuotes = $String.Substring(1, $String.Length - 2) -replace "''", ""
        if (-not ($unescapedQuotes -like "*'*")) {
            return $true
        }
    }

    return $false
}

<#
.SYNOPSIS
    Sets aliases '??', 'git?', and 'gh?'
#>
function Set-PassiveGitHubCopilotAliases {
    Set-Alias -Name '??' -Value Invoke-GitHubCopilot -Scope Global
    Set-Alias -Name 'gh?' -Value Invoke-GHAlias -Scope Global
    Set-Alias -Name 'git?' -Value Invoke-GitAlias -Scope Global
}

<#
.SYNOPSIS
    Sets aliases '??', 'git?', and 'gh?' and hooks the Enter key to escape commands.
#>
function Set-GitHubCopilotAliases {
    Set-PassiveGitHubCopilotAliases

    Set-PSReadLineKeyHandler -Key Enter -ScriptBlock {
        param($key, $arg)

        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

        $elems = $line.Split(' ', 2)
        $command = $elems[0]
        $question = $elems[1]

        if ($command -in "??", "git?", "gh?") {
            echo (Test-EscapedString -String $elems[1])
            if (-not (Test-EscapedString -String $elems[1])) {
                $question = $elems[1].Replace("'", "''")
                $question = "'$question'"
            }
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, "$command $question") 
        }


        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
}


Export-ModuleMember -Function Set-PassiveGitHubCopilotAliases, Set-GitHubCopilotAliases, Invoke-CopilotCommand, Invoke-GitHubCopilot, Invoke-GHAlias, Invoke-GitAlias