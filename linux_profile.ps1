function prompt {
        write-host "[$((get-date).ToString('hh:mm'))]" -nonewline -foregroundcolor yellow
        write-host "($($env:USER))" -foregroundcolor red
        write-host "$(get-location)" -foregroundcolor blue
        write-host $(if ($nestedpromptlevel -ge 1) {'>>'}) -nonewline
        return 'PS>'
}
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
