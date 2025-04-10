oh-my-posh init pwsh --config "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/emodipt-extend.omp.json" | Invoke-Expression 

$vimrcPath = 'C:\Program Files\Vim\_vimrc' 
$gitDir = "C:\Users\Ianfr\OneDrive\Documents\GitHub\"
$nvimInit = "C:\Users\Ianfr\AppData\Local\nvim\init.vim"

function New-Journal {
    $JournalDate = get-date -Format "%M-dd-yy"
    new-item -Path .\$JournalDate -ItemType File
}

$JournalDirectory = 'C:\Users\Ianfr\OneDrive\Documents\Journal'


function Out-Default
{
    [CmdletBinding(ConfirmImpact='Medium')]
    param
    (
    [Parameter(ValueFromPipeline=$true)]
    [System.Management.Automation.PSObject] $InputObject
    )
    begin
    {
        $wrappedCmdlet = $ExecutionContext.InvokeCommand.GetCmdlet('Out-Default')
        $sb = { & $wrappedCmdlet @PSBoundParameters }
        $__sp = $sb.GetSteppablePipeline()
        $__sp.Begin($pscmdlet)
    }
    process
    {
        $do_process = $true
        if ($_ -is [System.Management.Automation.ErrorRecord])
        {
            if ($_.Exception -is [System.Management.Automation.CommandNotFoundException])
            {
                $__command = $_.Exception.CommandName
                if (Test-Path -Path $__command -PathType container)
                {
                    Set-Location $__command
                    $do_process = $false
                }
                elseif ($__command -match '^http://|\.(com|org|net|edu)$')
                {
                    if ($matches[0] -ne 'http://')
                    {
                        $__command = 'HTTP://' + $__command
                    }
                    [System.Diagnostics.Process]::Start($__command)
                    $do_process = $false
                }
            }
        }
        if ($do_process)
        {
            $global:LAST = $_;
            $__sp.Process($_)
        }
    }
    end
    {
        $__sp.End()
    }
}

#set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
Set-Alias -Name 'r' -Value Invoke-FuzzyHistory
Set-Alias -Name 'f' -Value Invoke-Fzf
