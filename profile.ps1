# $Profile.CurrentUserAllHosts
# ~/Documents/PowerShell/profile.ps1
#
# Copy to clipboard with: "+y
# Paste from clipboard with: "+p
#
# Join-Path C: Windows System32 drivers etc

$Env:NEOVIM_INIT_PATH = Join-Path $Env:HOMEPATH AppData Local nvim init.vim

# Configuration
# =============

$Env:DOTNET_NEW_PREFERRED_LANG = "F#"

Function Global:Prompt { "`n$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") $((Get-Location) -Replace "\\","/" -Replace ":"," ")`n; " }

# Settings
# ========

Function Global:dotenv {
	Get-Content .env | Select-String "^([^#=][^=]*)=(.*)$" | ForEach-Object {
		$g = $_.Matches.Groups;
		[Environment]::SetEnvironmentVariable($g[1].Value, $g[2].Value)
	}
}

# Functions
# =========

Function ConvertFrom-Base64 {
	[CmdletBinding()] Param (
		[Parameter(Mandatory, ValueFromPipeline)] [string] $Value
	)
	[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Value))
}

Function ConvertTo-Base64 {
	[CmdletBinding()] Param (
		[Parameter(Mandatory, ValueFromPipeline)] $Value
	)
	# [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($Value))
	[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Value))
}

# https://stackoverflow.com/questions/249760/how-can-i-convert-a-unix-timestamp-to-datetime-and-vice-versa
Function Global:Get-Now {
	# $epoch = [DateTimeOffset]::FromUnixTimeSeconds(0)
	# $t = Get-Date
	# $u = $t.ToUniversalTime()
	# Global = $u.ToString("O")
	$CI = New-Object System.Globalization.CultureInfo("en-AU")
	$Epoch = [DateTimeOffset]::UnixEpoch
	$Now = [DateTimeOffset]::Now
	$UnixDay = ($Now.UtcDateTime - $Epoch.UtcDateTime).Days
	$UnixDaySecond = [int]$Now.UtcDateTime.TimeOfDay.TotalSeconds
	$UnixSecond = $Now.ToUnixTimeSeconds()
	[PSCustomObject]@{
		DayOfYear = $Now.DayOfYear
		Global = $Now.UtcDateTime
		GlobalWeek = $CI.Calendar.GetWeekOfYear($Now.UtcDateTime, $CI.DateTimeFormat.CalendarWeekRule, $CI.DateTimeFormat.FirstDayOfWeek)
		Local = $Now.LocalDateTime
		LocalWeek = $CI.Calendar.GetWeekOfYear($Now.LocalDateTime, $CI.DateTimeFormat.CalendarWeekRule, $CI.DateTimeFormat.FirstDayOfWeek)
		Offset = $Now.Offset
		UnixDay = $UnixDay
		UnixDayHex = $UnixDay.ToString("X")
		UnixDaySecond = $UnixDaySecond
		UnixDaySecondHex = $UnixDaySecond.ToString("X") # This can get to 5 characters (max is 0x15180)
		UnixSecond = $UnixSecond
		UnixSecondHex = $UnixSecond.ToString("X")
	}
}
Set-Alias -Name now -Value Global:Get-Now

$Env:SecondsInDay = 60 * 60 * 24
$Env:SecondsInYear = 60 * 60 * 24 * 365

# This is more accurate for perception of running processes.
#
# `(Get-Date) - (Get-Uptime)` will give a longer time in some cases.
# Brackets are needed so the `-` is not treated as a parameter.
#
Function Global:Get-StartTime {
	Get-Process |
	Where-Object StartTime |
	Sort-Object StartTime |
	Select-Object -ExpandProperty StartTime -First 1 |
	ForEach-Object {$_.ToString("O")}
}

# Projects
# ========

# Function Global:Add-ProjectLink {
# 	[CmdletBinding()] param (
# 		[Parameter(Mandatory = $true)] [ValidateSet([ProjectItemTemplates])] [string] $Name
# 	)
# }

Function Global:Get-ProjectTemplate {
	# $DetailsPath = Join-Path -Path $PSScriptRoot -ChildPath "details.ini"

	$FolderPath = Join-Path -Path $PSScriptRoot -ChildPath "project-templates"
	Get-ChildItem -Directory -Path $FolderPath | ForEach-Object {$_.BaseName}
}

Class ProjectTemplates : System.Management.Automation.IValidateSetValuesGenerator {
	[string[]] GetValidValues () {
		$FolderPath = Join-Path -Path $PSScriptRoot -ChildPath "project-templates"
		$Names = Get-ChildItem -Directory -Path $FolderPath | ForEach-Object {$_.BaseName}
		return [string[]] $Names
	}
}

Function Global:New-Project {
	[CmdletBinding()] Param (
		[Parameter(Mandatory = $true)] [ValidateSet([ProjectTemplates])] [string] $Kind
	)
	Copy-Item -Path (Join-Path -Path $PSScriptRoot -ChildPath "project-templates" -AdditionalChildPath $Kind, *)
	# Copy-Item -Path (Join-Path $PSScriptRoot "fsharp.editorconfig") -Destination (Join-Path (Get-Location) ".editorconfig")
	# Copy-Item -Path (Join-Path $PSScriptRoot "fsharp.gitignore") -Destination (Join-Path (Get-Location) ".gitignore")
}

Class ProjectItemTemplates : System.Management.Automation.IValidateSetValuesGenerator {
	[string[]] GetValidValues () {
		$FolderPath = Join-Path -Path $PSScriptRoot -ChildPath "project-item-templates"
		$Names = Get-ChildItem -File -Path $FolderPath | ForEach-Object {$_.BaseName}
		return [string[]] $Names
	}
}

Function Global:Get-ProjectItem {
	[CmdletBinding()] Param (
		[Parameter(Mandatory = $true)] [ValidateSet([ProjectItemTemplates])] [string] $Kind
	)
	$SourcePath = Join-Path -Path $PSScriptRoot -ChildPath "project-item-templates" -AdditionalChildPath "$Kind.fs"
	Get-Content -Path $SourcePath
}

# NeoVim
# ------

Function Global:Invoke-NeoVimPrint {
	$n = New-TemporaryFile
	nvim $n.FullName
	Get-Content $n.FullName
}

# Node
# ----

Function Global:Get-NpmGlobal {
	$npm = npm ls --depth=0 --global --json | ConvertFrom-Json
	$npm.dependencies.PSObject.Properties | %{[PSCustomObject]@{Name = $_.Name; Version = $_.Value.version}}
}

Function Global:Install-NpmGlobal {
	[CmdletBinding()] Param (
		[Parameter(Mandatory = $true)] [string] $PackageName
	)
	npm install --global $PackageName
}

Function Global:Update-NpmGlobal {
	[CmdletBinding()] Param (
		[Parameter(Mandatory = $true)] [string] $PackageName
	)
	npm update --global $PackageName
}
