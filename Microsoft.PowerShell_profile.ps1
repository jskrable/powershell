Import-Module posh-git

function which($cmd) { (Get-Command $cmd).Definition }
function whoami { (get-content env:\userdomain) + "\" + (get-content env:\username) }
function Get-Time { return $(get-date | foreach { $_.ToLongTimeString() } ) }
$host.PrivateData.ErrorForegroundColor = 'White'
function prompt
{
    # Write the time 
    $prompt = Write-Prompt "["
    $prompt += Write-Prompt $(Get-Time) -ForegroundColor ([ConsoleColor]::Yellow)
    $prompt += Write-Prompt "] "
    # Write the path
    $prompt += Write-Prompt (get-content env:\username) -ForegroundColor ([ConsoleColor]::Green)
    $prompt += Write-Prompt ("@") -ForegroundColor ([ConsoleColor]::Green)
    $prompt += Write-Prompt $($(Get-Location).Path.replace($home,"~").replace("\","/")) -ForegroundColor ([ConsoleColor]::Green)
    $prompt += Write-Prompt $(if ($nestedpromptlevel -ge 1) { '>>' }) -ForegroundColor ([ConsoleColor]::Green)
    
    # Have posh-git display its default prompt
    # $prompt += & $GitPromptScriptBlock

    return "> "

    # if ($prompt) { "$prompt " } else { " " }
}

function ll
{
    param ($dir = ".", $all = $false) 

    $origFg = $host.ui.rawui.foregroundColor 
    if ( $all ) { $toList = ls -force $dir }
    else { $toList = ls $dir }

    foreach ($Item in $toList)  
    { 
        Switch ($Item.Extension)  
        { 
            ".Exe" {$host.ui.rawui.foregroundColor = "Yellow"} 
            ".cmd" {$host.ui.rawui.foregroundColor = "Red"} 
            ".msh" {$host.ui.rawui.foregroundColor = "Red"} 
            ".vbs" {$host.ui.rawui.foregroundColor = "Red"} 
            Default {$host.ui.rawui.foregroundColor = $origFg} 
        } 
        if ($item.Mode.StartsWith("d")) {$host.ui.rawui.foregroundColor = "Cyan"}
        $item 
    }  
    $host.ui.rawui.foregroundColor = $origFg 
}

function lla
{
    param ( $dir=".")
    ll $dir $true
}

function la { ls -force }
# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

function ds ($dir=".") { 
  get-childitem $dir | 
    % { $f = $_ ; 
        get-childitem -r $_.FullName | 
           measure-object -property length -sum | 
             select @{Name="Name";Expression={$f}},Sum}
}

<#function du($path=".") {
  get-childitem $path | % { $file = $_ ;
  get-childitem -r $_.FullName | measure-object -property length -sum |
    select @{Name="Name";Expression={$file}},Sum}
}#>


function du
{   Param (
        $Path = "."
    )
    ForEach ($File in (Get-ChildItem $Path))
    {   If ($File.PSisContainer)
        {   $Size = [Math]::Round((Get-ChildItem $File.FullName -Recurse | Measure-Object -Property Length -Sum).Sum / 1KB,2)
            $Type = "Folder"
        }
        Else
        {   $Size = $File.Length
            $Type = ""
        }
        [PSCustomObject]@{
            Name = $File.Name
            Type = $Type
            Size = $Size
        }
    }
}