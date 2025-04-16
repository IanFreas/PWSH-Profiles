new-alias tp test-path
new-alias sel select-object
new-alias l get-childitem

#git configs
#git config --global alias.s "status" 
#git config --global alias.adog "log --all --decorate --oneline --graph"

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

function ll {gci -fo}

function prompt {
    write-host "[$((get-date).ToString('hh:mm'))] " -nonewline -foregroundcolor yellow

    # Check if you're in a git repo
    if (git rev-parse --is-inside-work-tree 2>/dev/null) {

        if ($env:USER -eq 'root') {
            write-host "($($env:USER)@$(hostname)) " -foregroundcolor darkred -nonewline
        } else {
            write-host "($($env:USER)@$(hostname)) " -foregroundcolor green -nonewline
        }
	
	$modifiedColor = 'red'	
	$modifiedCount = (git status -s | wc -l)
        $currentBranch = (git branch --show-current)	


#TODO ?x for untracked and something for modified and not staged, +1 for added, -1 for removed

	if ($modifiedCount -gt 0) {    
	    write-host "$currentBranch" -foregroundcolor $modifiedColor -nonewline 
	    write-host " +$modifiedCount" -foregroundcolor $modifiedColor 
        } else {
	    write-host "$currentBranch" -foregroundcolor cyan
        }

    } else {
        if ($env:USER -eq 'root') {  
            write-host "($($env:USER)@$(hostname)) " -foregroundcolor darkred 
        } else {
            write-host "($($env:USER)@$(hostname)) " -foregroundcolor green 
        }
    }
    
    write-host "$(get-location)" -foregroundcolor blue
#TODO Fix the issue with Debugging and it goes like >>PS>
    write-host $(if ($nestedpromptlevel -ge 1) { '>>' }) -nonewline


    return 'PS>'
}

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
