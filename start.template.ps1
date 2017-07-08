# 
# Template for Starting Minecraft Server
# Will be copied to Minecraft Server Folders once
# Minecraft is installed.
#

Function Forbid-RunTemplate {
  [String] $MyName = "$(Split-Path -Leaf $PSCommandpath)"

  if ($MyName -eq "start.template.ps1") {
    Write-Host "Failure: You are trying to start the template."
    Write-Host ""
    Write-Host "Please install Minecraft Server first and then"
    Write-Host "Run this script from the server directory."
    Exit 1
  }
}

Forbid-RunTemplate

[String] $InstallerDir = "$(Join-Path $PSScriptRoot ".." -Resolve)"
[String] $OutFile = Join-Path -Path "${PSScriptRoot}" -ChildPath "minecraft.out.txt"
[String] $ErrFile = Join-Path -Path "${PSScriptRoot}" -ChildPath "minecraft.err.txt"

. (Join-Path $InstallerDir "include-utilities.ps1")

Function Run-Minecraft {
  $WorkingDir = "${PSScriptRoot}"
  $exeLocation = Get-Command "${JavaExec}" | Select -Expand Path

  Start-Process -FilePath "${exeLocation}" -WorkingDirectory "${WorkingDir}" -ArgumentList $JavaArguments -NoNewWindow -RedirectStandardError "${ErrFile}" -RedirectStandardOutput "${OutFile}" -Wait
}

### Use this version again, also copy java-config to server folder.
Function Run-Minecraft {
  $WorkingDir = "$($global:Configuration.minecraft.exec.jar.dir)"
  $Jar = "$($global:Configuration.minecraft.exec.jar.fullPath)"
  $JavaExec = "$($global:Configuration.properties['java.exec'])"
  $exeLocation = Get-Command "${JavaExec}" | Select -Expand Path
  $Java = Get-ChildItem "${exeLocation}"
  $JavaMajor = $Java.VersionInfo.ProductMajorPart
  [String[]] $JavaArgs = $global:Configuration.java.options.common + $global:Configuration.java.options.$JavaMajor
  $JavaArgs = $JavaArgs | ForEach { Replace-Tokens $_ }
  $JavaArgs = $JavaArgs, "-jar", "${Jar}"

  if ("$($global:Configuration.properties['minecraft.gui'])" -ne "true") {
    $JavaArgs = $JavaArgs += "nogui"
  }
  $stdErr = "$($global:Configuration.minecraft.exec.err)"
  $stdOut = "$($global:Configuration.minecraft.exec.out)"
  
  Log-Normal "Starting $Jar with arguments: $JavaArgs"
  Start-Process -FilePath "${exeLocation}" -WorkingDirectory "${WorkingDir}" -ArgumentList $JavaArgs -NoNewWindow -RedirectStandardError "${ErrFile}" -RedirectStandardOutput "${OutFile}" -Wait
  Log-Normal "Done $Jar."
}

Run-Minecraft
