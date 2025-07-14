# Symlink creation
# new-item -ItemType SymbolicLink -Path $PROFILE -Value /home/ian/git/PWSH-Profiles/linux_profile.ps1 -force

# Common aliases
new-alias tp test-path
new-alias sel select-object
new-alias l get-childitem
new-alias g git

# App specific cofigs 
<#
    git configs
    git config --global alias.s "status" 
    git config --global alias.a "add" 
    git config --global alias.adog "log --all --decorate --oneline --graph"
    git config --global core.editor "nvim"
    git config --global init.defaultBranch main
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

oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/IanFreas/PWSH-Profiles/refs/heads/master/ian.omp.json' | invoke-expression

# Useful functions 

function ll {gci -fo}
function s {git status}

function Get-Password {
    
    [cmdletbinding()]
    
    param(
        [parameter(position = 0, valuefrompipeline)]
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

function clip {

    [cmdletbinding()]

    param(
        [parameter(position=0,valuefrompipeline)]
        [string] $ClipInput
    )

    $ClipInput | xclip -sel clip
}

