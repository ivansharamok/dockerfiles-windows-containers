#escape=`

#FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-1903 as build
#FROM microsoft/aspnet:4.7.2-windowsservercore-1803
#FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2019
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-1903
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
ARG source

RUN Import-Module WebAdministration; `
    # create Application EventLog source that your App can write to
    New-Item 'HKLM:\System\CurrentControlSet\Services\Eventlog\Application' -Name 'mvc-log4net'; `
	#reg add 'hklm\System\CurrentControlSet\Services\Eventlog\Application\mvc-log4net' /v TypesSupported /t REG_DWORD /d 7
	# need to add EventMessageFile property to work around 'Source not found' error
	reg add 'hklm\System\CurrentControlSet\Services\Eventlog\Application\mvc-log4net' /v EventMessageFile /t REG_SZ /d 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\EventLogMessages.dll'; `
	# grant EventLog\State access to admin if needed
	#$Key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Services\EventLog\State', 'ReadWriteSubTree', 'ChangePermissions'); `
	#$Acl = $Key.GetAccessControl(); `
	#$Rule = New-Object System.Security.AccessControl.RegistryAccessRule('Administrators', 'FullControl', 'ObjectInherit,ContainerInherit', 'None', 'Allow'); `
	#$Acl.SetAccessRule($Rule); `
	#$Key.SetAccessControl($Acl); `
    # grant EvenLog access to the service account. Each AppPoolIdentity dynamic account is a member of IIS_IUSRS group
    $Rule = New-Object System.Security.AccessControl.RegistryAccessRule('IIS_IUSRS', 'FullControl', 'ObjectInherit,ContainerInherit', 'None', 'Allow'); `
    # "IIS AppPool\\DefaultAppPool" account is not known until AppPool starts and creates one
    # therefore you cannot set the registry permissions for a dynamic AppPoolIdentity in the Dockerfile
    # these lines are intended to serve as an example how one can set permissions for a dynamic AppPoolIdentity account
    # $Rule = New-Object System.Security.AccessControl.RegistryAccessRule("IIS AppPool\\DefaultAppPool","FullControl","ContainerInherit","None","Allow"); `
    # grant access only to your registry branch
    $Key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Services\EventLog\Application\mvc-log4net', 'ReadWriteSubTree', 'ChangePermissions'); `
    # grant access to all EventLog sources under /Application registry branch
    # $Key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Services\EventLog\Application', 'ReadWriteSubTree', 'ChangePermissions'); `
    $Acl = $Key.GetAccessControl(); `
    $Acl.SetAccessRule($Rule); `
	$Key.SetAccessControl($Acl);

WORKDIR /inetpub/wwwroot
COPY ${source:-bin/Release/publish} .
# uncomment if you want to explicitly set permissions for NetworkService account to the webroot path
#RUN $path='C:\inetpub\wwwroot'; `
    #$acl = Get-Acl $path; `
    #$group = 'IIS_IUSRS'; `
    #$newOwner = [System.Security.Principal.NTAccount]($group); `
    #$acl.SetOwner($newOwner); `
    #$ar = New-Object System.Security.AccessControl.FileSystemAccessRule($group, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow'); `
    #$acl.SetAccessRule($ar); `
    #dir -r $path | Set-Acl -aclobject  $acl
ENTRYPOINT .\eventlog-reader.ps1 -ServiceName w3svc -LogName Application -FrequencyInSeconds 2