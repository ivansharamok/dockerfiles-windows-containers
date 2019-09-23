#escape=`

#FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-1903 as build
#FROM microsoft/aspnet:4.7.2-windowsservercore-1803
#FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2019
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-1903
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
ARG source

RUN Import-Module WebAdministration; `
    # set AppPool service account
    Set-ItemProperty IIS:\AppPools\DefaultAppPool -name processModel -value @{identitytype='NetworkService'}; `
    # create Application EventLog source that your App can write to
    New-Item 'HKLM:\System\CurrentControlSet\Services\Eventlog\Application' -Name 'mvc-log4net'; `
	reg add 'hklm\System\CurrentControlSet\Services\Eventlog\Application\mvc-log4net' /v EventMessageFile /t REG_SZ /d 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\EventLogMessages.dll'; `
    # grant EvenLog access to the service account
    $Rule = New-Object System.Security.AccessControl.RegistryAccessRule('NT AUTHORITY\NetworkService', 'FullControl', 'ObjectInherit,ContainerInherit', 'None', 'Allow'); `
    # grant access only to your EventLog source
    $Key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Services\EventLog\Application\mvc-log4net', 'ReadWriteSubTree', 'ChangePermissions'); `
    # grant access to all EventLog sources under /Application registry branch
    # $Key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Services\EventLog\Application', 'ReadWriteSubTree', 'ChangePermissions'); `
    $Acl = $Key.GetAccessControl(); `
    $Acl.SetAccessRule($Rule); `
    $Key.SetAccessControl($Acl);

WORKDIR /inetpub/wwwroot
# this assumes that the project is published to 'bin/Release/publish' path by default
COPY ${source:-bin/Release/publish} .
# uncomment if you want to explicitly set permissions for NetworkService account to the webroot path
#RUN $path='C:\inetpub\wwwroot'; `
    #$acl = Get-Acl $path; `
    #$user = 'NT AUTHORITY\NetworkService'; `
    #$newOwner = [System.Security.Principal.NTAccount]($user); `
    #$acl.SetOwner($newOwner); `
    #$ar = New-Object System.Security.AccessControl.FileSystemAccessRule($user, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow'); `
    #$acl.SetAccessRule($ar); `
    #dir -r $path | Set-Acl -aclobject  $acl
ENTRYPOINT .\eventlog-reader.ps1 -ServiceName w3svc -LogName Application -FrequencyInSeconds 2