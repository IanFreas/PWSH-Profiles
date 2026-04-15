# Path updates
$env:PATH += ';C:\Users\ifreas\opt\nvim-win64\nvim-win64\bin'
$env:PATH += ';C:\Users\ifreas\opt\fx'
$env:PATH += ';C:\Users\ifreas\AppData\Local\Temp\zellij\bootstrap'

# Auto-launch Zellij if running in Windows Terminal
# # Auto-launch Zellij if running in Windows Terminal
if ($env:WT_SESSION -and -not $env:ZELLIJ) {

    # 1. Add your custom PowerShell folder to the environment PATH
    $env:PATH += ";C:\Users\ifreas\opt\PowerShell-7.5.4-win-x64"

    # 2. Force Zellij to read the exact config file we created
    zellij --config "$env:APPDATA\zellij\config.kdl"

    exit
}
#irm https://zellij.dev/launch.ps1 | iex

# Common aliases
New-Alias tp test-path
New-Alias sel select-object
New-Alias l get-childitem
New-Alias exp Expand-Archive
#new-alias g git

# App specific cofigs 
<#
    git configs
    git config --global alias.s "status" 
    git config --global alias.a "add" 
    git config --global alias.adog "log --all --decorate --oneline --graph"
    git config --global core.editor "nvim"
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

oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/IanFreas/PWSH-Profiles/refs/heads/master/ian.omp.json' | Invoke-Expression

New-PSDrive -PSProvider FileSystem -Name git -Root "$env:userprofile\git" | Out-Null



# Useful functions 

function ll { gci -fo }
function s { git status }
#function nvim { C:\Users\ifreas\opt\nvim-win64\nvim-win64\bin\nvim.exe }
#function fx {C:\Users\ifreas\opt\fx\fx.exe}

function Get-Password {
    
    [cmdletbinding()]
    
    param(
        [parameter(position = 0, valuefrompipeline)]
        [string] $PasswordName
    )

    if ($PSBoundParameters.ContainsKey('PasswordName')) {
        $csvItemOutput = @('Username,Password')
        $listOfItems = op item list --categories Login --vault private --format=json | ConvertFrom-Json -WarningAction Ignore
        $filteredItems = $listOfItems | Where-Object { $_.title -like "*$PasswordName*" }
        if ($filteredItems.count -eq 0) { Write-Error "No matches found for $PasswordName"; continue } 
        $csvItemOutput += $filteredItems | ConvertTo-Json | op item get - --fields username, password --reveal 
        $passwordOutput = $csvItemOutput | ConvertFrom-Csv
    } else {
        $passwordItem = op item list --categories Login --vault private --format=json |
        ConvertFrom-Json -WarningAction Ignore | Select-Object title, id, created_at, updated_at  
        $passwordOutput = $passwordItem | Sort-Object Title
    }

    return $passwordOutput
}
