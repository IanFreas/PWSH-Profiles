new-alias tp test-path
new-alias sel select-object
new-alias l get-childitem

function prompt {
    write-host "[$((get-date).ToString('hh:mm'))]" -nonewline -foregroundcolor yellow
    if ($env:USER -eq 'root') {	
        write-host "($($env:USER)@$(hostname))" -foregroundcolor red
    } else {
        write-host "($($env:USER)@$(hostname))" -foregroundcolor green
    }
    write-host "$(get-location)" -foregroundcolor blue
    write-host $(if ($nestedpromptlevel -ge 1) { '>>' }) -nonewline
    return 'PS>'
}
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
#TODO: Fix duplicate entries showing up, eg, twitch
function Get-Password {
    [cmdletbinding()]
    param(
        [parameter(position = 0, valuefrompipeline)]
        [string] $PasswordName
    )

    if ($PSBoundParameters.ContainsKey('PasswordName')) {
        $passwordItem = op item get $PasswordName --reveal --format json | ConvertFrom-Json 
        $passwordOutput = $passwordItem | Select-Object Name, @{n = 'Username'; e = { ($_.fields).where({ $_.id -eq 'username' }).value } }, @{n = 'Password'; e = { ($_.fields).where({ $_.id -eq 'password' }).value } }
    } else {
        $passwordItem = op item list --vault Private --format json | ConvertFrom-Json
        $passwordOutput = $passwordItem.Title
    }

    return $passwordOutput
}
