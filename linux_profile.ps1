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
        write-host $(if ($nestedpromptlevel -ge 1) {'>>'}) -nonewline
        return 'PS>'
}
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
