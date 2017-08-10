<#
.SYNOPSIS
    Locates MSBuild.exe files within the "Program Files (x86)" folder.
.DESCRIPTION
    Locates MSBuild.exe files within the "Program Files (x86)" folder.
.EXAMPLE
    PS C:\> .\Get-MSBuilds.ps1 | Where-Object -FilterScript { $_.Is64Bit }

    Version FileInfo                                                                                          Is64Bit IsVisualStudioPath
    ------- --------                                                                                          ------- ------------------
    12.0    C:\Program Files (x86)\MSBuild\12.0\Bin\amd64\MSBuild.exe                                            True              False
    14.0    C:\Program Files (x86)\MSBuild\14.0\Bin\amd64\MSBuild.exe                                            True              False
    15.0    C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\amd64\MSBuild.exe    True               True
.INPUTS
    Inputs (if any)
.OUTPUTS
    A list of MSBuildInfo objects with Version, FileInfo, and Is64Bit (Boolean) properties.
.NOTES
    Metadata about the MSBuild.exe files is based on the directory. The actuall EXE files are not examined.
#>

class MSBuildInfo {
    [version] $Version
    [System.IO.FileInfo] $FileInfo
    [bool] $Is64Bit
    [bool] $IsVisualStudioPath

    MSBuildInfo([System.IO.FileInfo] $fileInfo) {
        $this.FileInfo = $fileInfo
        [regex]$verRe = "(?i)MSBuild\\([\d\.]+)\\Bin"
        [regex]$amd64re = "(?i)amd64"
        [regex]$vsRe = "(?i)Visual\sStudio"
        [System.Text.RegularExpressions.Match]$match = $verRe.Match($fileInfo.Directory.ToString())
        if ($match.Success) {
            $this.Version = New-Object version $match.Groups[1].Value
        }
        $this.Is64Bit = $amd64re.IsMatch($fileInfo.Directory.ToString())
        $this.IsVisualStudioPath = $vsRe.IsMatch($fileInfo.Directory.ToString())
    }
}

# Get Visual Studio MSBuild files0
$vsMsbuilds = Get-ChildItem -Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio\*\*\MSBuild\*\Bin\**\MSBuild.exe" -Recurse

# Get MSBuild files
$msbuilds = Get-ChildItem -Path "${env:ProgramFiles(x86)}\MSBuild\**\MSBuild.exe" -Recurse

$allBuilds = $vsMsbuilds + $msbuilds

return $allBuilds | ForEach-Object -Process {
    return New-Object MSBuildInfo($_)
} | Sort-Object -Property Version,Is64Bit
