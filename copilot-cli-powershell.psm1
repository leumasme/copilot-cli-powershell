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
    Invoke-GitHubCopilot "git" $RemainingArguments
}
function Invoke-GHAlias {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromRemainingArguments, HelpMessage = "The remaining arguments for the Copilot command.")]
        [string[]]$RemainingArguments
    )
    Invoke-GitHubCopilot "github" $RemainingArguments
}

function Invoke-GitHubCopilot {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0, HelpMessage = "The Copilot command to execute.")]
        [string]$Command,

        [Parameter(ValueFromRemainingArguments, HelpMessage = "The remaining arguments for the Copilot command.")]
        [string[]]$RemainingArguments
    )

    $tempFile = Join-Path -Path $Env:TEMP -ChildPath "copilot_$((Get-Date).ToString('yyyyMMddHHmmss'))_$(Get-Random -Maximum 9999).txt"

    function Invoke-CopilotCommand {
        param (
            [Parameter(Mandatory)][string]$CopilotCommand
        )

        Invoke-Expression $CopilotCommand

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

    switch ($Command) {
        "help" {
            $codeToRun = "github-copilot-cli help"
            Invoke-Expression $codeToRun
        }
        "git" {
            $remaining = $RemainingArguments -join ' '
            Write-Host "github-copilot-cli git-assist --shellout $tempFile $remaining"
            Invoke-CopilotCommand "github-copilot-cli git-assist --shellout $tempFile $remaining"
        }
        "github" {
            $remaining = $RemainingArguments -join ' '
            Write-Host "github-copilot-cli gh-assist --shellout $tempFile $remaining"
            Invoke-CopilotCommand "github-copilot-cli gh-assist --shellout $tempFile $remaining"
        }
        default {
            $arg = "$Command $($RemainingArguments -join ' ')"
            Write-Host "github-copilot-cli what-the-shell --shellout $tempFile powershell $arg"
            Invoke-CopilotCommand "github-copilot-cli what-the-shell --shellout $tempFile powershell $arg"
        }
    }
}

<#
.SYNOPSIS
    Sets aliases for the Invoke-GitHubCopilot function for easier access.
#>
function Set-GitHubCopilotAliases {
    Set-Alias -Name ?? -Value Invoke-GitHubCopilot -Scope Global
    Set-Alias -Name 'gh?' -Value Invoke-GHAlias -Scope Global
    Set-Alias -Name 'git?' -Value Invoke-GitAlias -Scope Global
}

Export-ModuleMember -Function Invoke-GitHubCopilot, Invoke-GHAlias, Set-GitHubCopilotAliases, Invoke-GitAlias