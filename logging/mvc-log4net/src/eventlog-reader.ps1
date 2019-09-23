<#
.Synopsis
    Get Windows Event Log entries.

.Example
  .\eventlog-reader.ps1 -ServiceName "w3svc"

  .Example
  .\eventlog-reader.ps1 -ServiceName "w3svc" -LogName "Application" -LogSources @(".NET*", "ASP.NET*") -FrequencyInSeconds 2

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false,Position=0)] $ServiceName="w3svc",
    [Parameter(Mandatory=$false)] $LogName="Application",
    [Parameter(Mandatory=$false)] $LogSources=@('mvc-log4net*', '.NET*', 'ASP.NET*', 'MSDTC*', 'Microsoft*'),
    [Parameter(Mandatory=$false)] $FrequencyInSeconds=2
)

# Write-Verbose "Starting $ServiceName application"
Write-Host "STARTUP: starting '$ServiceName'"
# if used as an ENTRYPOINT in the container, the code won't advance past this line
# & "C:\ServiceMonitor.exe" $ServiceName
Start-Service $ServiceName
Write-Host "$ServiceName service has started"
Write-Host "Call website home page"
Invoke-WebRequest -UseBasicParsing -Uri http://localhost | select StatusCode

$lastCheck = (Get-Date).AddSeconds(-2) 
while ($true) 
{
  foreach ($source in $LogSources) {
    # Write-Host "reading Application EventLog since '$lastCheck' for source '$source'"
    # Get-EventLog -LogName Application -Source "$source" -After $lastCheck | Select-Object TimeGenerated, Source, EntryType, Message
    Get-EventLog -LogName Application -Source "$source" -After $lastCheck | Select-Object TimeGenerated, Source, EntryType, Message | ConvertTo-Json
    # Get-EventLog -LogName Application -Source "$source" -After $lastCheck | Select-Object TimeGenerated, Source, EntryType, Message	| Write-Host
    # Get-EventLog -LogName Application -Source "$source" -After $lastCheck | Select-Object TimeGenerated, Source, EntryType, Message	| ConvertTo-Json | Write-Host
  }
  $lastCheck = Get-Date 
  Start-Sleep -Seconds $FrequencyInSeconds
}