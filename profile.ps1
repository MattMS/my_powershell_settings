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

Function Global:Prompt { "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") $($pwd -Replace "\\","/" -Replace ":","$")> " }

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

Function Global:Get-StartTime {
	Get-Process |
	Where-Object StartTime |
	Sort-Object StartTime |
	Select-Object -ExpandProperty StartTime -First 1 |
	ForEach-Object {$_.ToString("O")}
}

# NeoVim
# ======

Function Global:Invoke-NeoVimPrint {
	$n = New-TemporaryFile
	nvim $n.FullName
	Get-Content $n.FullName
}
