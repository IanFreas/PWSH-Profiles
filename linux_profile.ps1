new-alias tp test-path
new-alias sel select-object
new-alias l get-childitem

<#
    git configs
    git config --global alias.s "status" 
    git config --global alias.adog "log --all --decorate --oneline --graph"
#>
<#
    NeoVim Configs
    /home/ian/.config/nvim/init.vim
    set nu rnu
    set tabstop=4
    set shiftwidth=4
    set expandtab
    set softtabstop=4
    set autoindent
    set smartindent
#>

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

function ll {gci -fo}

function Get-Password {
    
    [cmdletbinding()]
    
    param(
    	[parameter(position=0,valuefrompipeline)]
        [string] $PasswordName
    )

    if ($PSBoundParameters.ContainsKey('PasswordName')){
	$csvItemOutput = @('Username,Password')
        $listOfItems = op item list --categories Login --vault private --format=json | ConvertFrom-JSON -WarningAction Ignore
	$filteredItems = $listOfItems | Where-Object {$_.title -like "*$PasswordName*"}
	if ($filteredItems.count -eq 0) {Write-Error "No matches found for $PasswordName"; continue} 
	$csvItemOutput += $filteredItems | ConvertTo-JSON | op item get - --fields username,password --reveal 
	$passwordOutput = $csvItemOutput | ConvertFrom-CSV
    } else {
        $passwordItem = op item list --categories Login --vault private --format=json |
	ConvertFrom-JSON -WarningAction Ignore | Select-Object title,id,created_at,updated_at  
	$passwordOutput = $passwordItem | Sort-Object Title
    }

    return $passwordOutput
}

#TODO fix this. It can't find xclip
function clip {

    [cmdletbinding()]

    param(
        [parameter(position=0,valuefrompipeline)]
        [string] $ClipInput
    )

    $ClipInput | xclip -sel clip
    
}

# Custom prompt function (ANSI Colors, Minimal Git Logic, Multi-line - Stable Version with commented-out full logic)
function prompt {

    # --- Define ANSI Color Codes ---
    $AnsiReset      = "`e[0m"
    $AnsiYellow     = "`e[33m"
    $AnsiDarkRed    = "`e[31m" # Using standard Red for DarkRed
    $AnsiGreen      = "`e[32m"
    $AnsiCyan       = "`e[36m"
    $AnsiMagenta    = "`e[35m"
    $AnsiBlue       = "`e[34m"

    # --- Start Building the Prompt String ---
    $promptString = ""

    # Add blank line before the prompt by adding newline to the start
    $promptString += "`n" # First newline for blank line separation

    # Display timestamp (Colored)
    $promptString += "$AnsiYellow" + "[$((Get-Date).ToString('hh:mm'))] " + "$AnsiReset"

    # Get the hostname using the hostname command and Trim it
    $hostname = (hostname).Trim()

    # Check if inside a Git repository, discarding the command's output
    # Use Invoke-Command for potentially better isolation
    Invoke-Command { git rev-parse --git-dir } -ErrorAction SilentlyContinue | Out-Null
    if ($?) { # Check if the git rev-parse command succeeded
        # --- Git Repository Section ---

        # Add user@hostname (Colored)
        if ($env:USER -eq 'root') {
            $promptString += "$AnsiDarkRed" + "($($env:USER)@$hostname) " + "$AnsiReset" # Hostname is trimmed
        } else {
            $promptString += "$AnsiGreen" + "($($env:USER)@$hostname) " + "$AnsiReset" # Hostname is trimmed
        }

        # --- Get Branch Name and Basic/Detailed Status ---
        $currentBranch   = git branch --show-current 3>$null
        # Check if changes exist for color, redirect warnings
        $gitStatusOutput = git status --porcelain 3>$null
        $localChangeCount = ($gitStatusOutput | Measure-Object -Line 3>$null).Lines # Used for basic coloring

        # --- Determine Branch Color (Simplified) ---
        $branchAnsiColor = $AnsiCyan # Default
        if ($localChangeCount -gt 0) {
             $branchAnsiColor = $AnsiDarkRed
        }
        # Note: Ahead/behind coloring is commented out below

        # --- Add Branch Name (Colored) ---
        $promptString += "$branchAnsiColor" + "$currentBranch" + "$AnsiReset"

        # --- Add Simple Git Indicator (Colored) ---
        # This is the active part for the stable version
        $promptString += "$branchAnsiColor" + " [Git]" + "$AnsiReset"


        # --- [BEGIN] Commented-out Full Git Status Logic ---
        <#
        # --- Calculate Detailed local changes ---
        $stagedFiles           = @($gitStatusOutput | Where-Object { $_ -match '^[MADRC]\s' } 3>$null)
        $stagedCount           = $stagedFiles.Count
        $unstagedModifiedFiles = @($gitStatusOutput | Where-Object { $_ -match '^\sM' } 3>$null)
        $unstagedModifiedCount = $unstagedModifiedFiles.Count
        $unstagedDeletedFiles  = @($gitStatusOutput | Where-Object { $_ -match '^\sD' } 3>$null)
        $unstagedDeletedCount  = $unstagedDeletedFiles.Count
        $untrackedFiles        = @($gitStatusOutput | Where-Object { $_ -match '^\?\?' } 3>$null)
        $untrackedCount        = $untrackedFiles.Count
        # $localChangeCount is already calculated above

        # --- Calculate Ahead/Behind Status ---
        $aheadCount  = 0
        $behindCount = 0
        # Use Invoke-Command for potentially better isolation and discard output
        Invoke-Command { git rev-parse --abbrev-ref --symbolic-full-name '@{u}' } -ErrorAction SilentlyContinue | Out-Null
        if ($?) { # Check if finding upstream succeeded
             # Use Invoke-Command for potentially better isolation and discard output
            $countsOutput = Invoke-Command { git rev-list --count --left-right '@{u}...HEAD' } -ErrorAction SilentlyContinue | Out-Null
            if ($?) { # Check if rev-list succeeded and produced output
                if ($countsOutput -match "`t") { # Check if the output contains a tab expected for split
                   $behindCount, $aheadCount = $countsOutput.Split([char]9)
                }
            }
        }
        $aheadCount        = [int]$aheadCount
        $behindCount       = [int]$behindCount
        $remoteChangeCount = $aheadCount + $behindCount

        # --- Determine Full Branch Color ---
        $fullBranchAnsiColor = $AnsiCyan # Default
        if ($localChangeCount -gt 0) {
             $fullBranchAnsiColor = $AnsiDarkRed
        } elseif ($remoteChangeCount -gt 0) {
             $fullBranchAnsiColor = $AnsiMagenta
        }
        # Overwrite the simple branch color if using full logic
        # $branchAnsiColor = $fullBranchAnsiColor

        # --- Define Status Symbols ---
        $stagedSymbol         = '✓'
        $unstagedModifiedSymbol = '!'
        $unstagedDeletedSymbol= 'x'
        $untrackedSymbol      = '?'
        $aheadSymbol          = '↑'
        $behindSymbol         = '↓'

        # --- Build Detailed Status String part ---
        if ($localChangeCount -gt 0 -or $remoteChangeCount -gt 0) {
            $statusPart = "" # Start with empty string

            # Ahead/Behind Status
            if ($aheadCount -gt 0)    { $statusPart += "$AnsiMagenta$aheadSymbol$aheadCount$AnsiReset" }
            if ($behindCount -gt 0)   { $statusPart += "$AnsiMagenta$behindSymbol$behindCount$AnsiReset" }
            if ($remoteChangeCount -gt 0 -and $localChangeCount -gt 0) { $statusPart += " " } # Separator

            # Local Changes Status
            $unstagedChangeCount = $unstagedModifiedCount + $unstagedDeletedCount + $untrackedCount
            if ($stagedCount -gt 0)   { $statusPart += "$AnsiCyan$stagedSymbol$stagedCount$AnsiReset" }
            if ($stagedCount -gt 0 -and $unstagedChangeCount -gt 0) { $statusPart += " " } # Separator

            if ($unstagedModifiedCount > 0) { $statusPart += "$AnsiDarkRed$unstagedModifiedSymbol$unstagedModifiedCount$AnsiReset" }
            if ($unstagedDeletedCount > 0)  { $statusPart += "$AnsiDarkRed$unstagedDeletedSymbol$unstagedDeletedCount$AnsiReset" }
            if ($untrackedCount > 0)      { $statusPart += "$AnsiYellow$untrackedSymbol$untrackedCount$AnsiReset" }

            # Add the status part with brackets, coloring brackets with branch color
            # Make sure to comment out the simple "[Git]" indicator above if uncommenting this
            # $promptString += "$branchAnsiColor [$AnsiReset$statusPart$branchAnsiColor]$AnsiReset"
        }
        #>
        # --- [END] Commented-out Full Git Status Logic ---


        # Add newline after Git info to start the next line
        $promptString += "`n" # Second newline for line break

    } else {
        # --- Non-Git Repository Section ---

        # Add user@hostname (Colored)
        if ($env:USER -eq 'root') {
            $promptString += "$AnsiDarkRed" + "($($env:USER)@$hostname) " + "$AnsiReset" # Hostname is trimmed
        } else {
            $promptString += "$AnsiGreen" + "($($env:USER)@$hostname) " + "$AnsiReset" # Hostname is trimmed
        }
        # Add newline after user@host info to start the next line
        $promptString += "`n" # Second newline for line break
    }

    # Add current location (path) (Colored) - Trim the path
    $promptString += "$AnsiBlue" + "$($PWD.Path.Trim())" + "$AnsiReset"

    # Add newline after path to start the final line
    $promptString += "`n" # Third newline for line break

    # Handle nested prompts (e.g., during debugging)
    if ($NestedPromptLevel -ge 1) {
        $promptString += '>>' # Nested prompt indicator remains plain
    }

    # Add the final prompt characters (Plain)
    $promptString += "PS>" # Standard prompt suffix - NO preceding space here

    # --- Return the final constructed string ---
    return $promptString
}

