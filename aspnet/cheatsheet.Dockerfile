# escape=`
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG FOO="default value"
ARG ODBC_PASSWORD
ARG PROXY_URL

# ================================================================================ #
# if you need to access domain resources during the image build process, make sure to use gMSA reference in 'docker build' command
# see example in 'com.contoso.docker.cmd.build.domain' label below
# ================================================================================ #

LABEL com.contoso.name="contosoapp:aspnet-4.8" `
      com.contoso.description="ASP.NET Framework base image for Contoso app" `
      com.contoso.docker.cmd.build="docker build --build-arg FOO='my value' --build-arg ODBC_PASSWORD='Secret!' --build-arg PROXY_URL='http://proxy.contoso.com:80' -t contosoapp:aspnet-4.8 -f cheatsheet.Dockerfile ." `
      com.contoso.docker.cmd.build.domain="docker build --security-opt='credentialspec=file://gMSADockerDev.json' --build-arg FOO='my value' --build-arg ODBC_PASSWORD='Secret!' --build-arg PROXY_URL='http://proxy.contoso.com:80'  -t contosoapp:aspnet-4.8 -f cheatsheet.Dockerfile ." `
      com.contoso.author="github.com/ivansharamok"

# set working directory
WORKDIR /inetpub/wwwroot
# copy app files from '\contosoapp' dir into default IIS workdir '/inetpub/wwwroot'
COPY .\contosoapp .

# ================================================================================ #
# [Windows10] Enable feature needed to use WinAuth in order for gMSA to authenticate into web application
# ================================================================================ #
# RUN Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication

# ================================================================================ #
# [Win Server] Option1: Install IIS feature WindowsAuthentication w/ management tools (useful for troubleshooting)
# ================================================================================ #
# RUN Install-WindowsFeature "Web-Windows-Auth" -IncludeManagementTools

# ================================================================================ #
# [Win Server] Option2: use DISM utility to install WinAuth
# ================================================================================ #
# RUN start-process -Filepath dism.exe -ArgumentList  @('/online', '/enable-feature:IIS-WindowsAuthentication', '/ALL') -Wait 

# ================================================================================ #
# This disables Anonymous Authentication and enables Windows Authentication
# ================================================================================ #
# RUN $siteName='Default Web Site'; `
#     Set-WebConfigurationProperty -filter /system.WebServer/security/authentication/AnonymousAuthentication -name enabled -value false -location $sitename; `
#     Set-WebConfigurationProperty -filter /system.WebServer/security/authentication/windowsAuthentication -name enabled -value true -location $sitename;


# ================================================================================ #
# example to remove and recreate website and AppPool, and configure .NET runtime version for the AppPool
# import WebAdministration module
# remove default website
# remove AppPool (not necessary if DefaultAppPool is used)
# create AppPool (not necessary if DefaultAppPool is used)
# create default website, set AppPool service account, set AppPool .NET version
# ================================================================================ #
RUN Import-Module WebAdministration; `
    Remove-Website 'Default Web Site'; `
    Remove-WebAppPool -Name DefaultAppPool; `
    New-Item –Path 'IIS:\AppPools\My AppPool'; `
    New-Website -Name 'My Web Site' -PhysicalPath 'C:\inetpub\wwwroot' -Port 80 -ApplicationPool 'My AppPool' -Force; `
    Set-ItemProperty -Path IIS:\AppPools\DefaultAppPool -Name managedRuntimeVersion -Value 'v2.0';

# ================================================================================ #
# set default NetworkService account
# ================================================================================ #
RUN Import-Module WebAdministration; `
    Set-ItemProperty IIS:\AppPools\DefaultAppPool -name processModel -value @{identitytype=2};

# ================================================================================ #
# set LocalSystem as AppPool service account, disable anonymous auth, enable win auth
# ================================================================================ #
# RUN Import-Module WebAdministration; `
#     Start-IISCommitDelay; `
#     (Get-IISServerManager).ApplicationPools['DefaultAppPool'].ProcessModel.IdentityType='LocalSystem'; `
#     (Get-IISServerManager).Sites[0].Applications[0].VirtualDirectories[0].PhysicalPath = 'c:\contosoapp'; `
#     (Get-IISConfigSection -SectionPath 'system.webServer/security/authentication/anonymousAuthentication').Attributes['enabled'].value = $false; `
#     (Get-IISConfigSection -SectionPath 'system.webServer/security/authentication/windowsAuthentication').Attributes['enabled'].value = $true; `
#     Stop-IISCommitDelay;

# ================================================================================ #
# set custom AppPool service account
# use single quotes to pass domain user (i.e. domain\username)
# ================================================================================ #
# RUN Import-Module WebAdministration; `
#     Set-ItemProperty IIS:\AppPools\DefaultAppPool -name processModel -value @{userName='user_name';password='password';identitytype=3};

# ================================================================================ #
# set AppPool 32-bit mode and managedMode to 'Classic'
# ================================================================================ #
# RUN Import-Module WebAdministration; `
#     $sm = Get-IISServerManager; `
#     $sm.ApplicationPools[0].ManagedPipelineMode='Classic'; `
#     $sm.ApplicationPools['DefaultAppPool'].Enable32BitAppOnWin64='true'; `
#     $sm.CommitChanges();

# ================================================================================ #
# old asp.net app may need these AppPool settings
# ================================================================================ #
# RUN Import-Module WebAdministration; `  
#     Set-ItemProperty 'IIS:\AppPools\.NET v4.5' -Name 'processModel.loadUserProfile' -Value 'True'; `
#     Set-ItemProperty 'IIS:\AppPools\.NET v4.5' -Name 'processModel.setProfileEnvironment' -Value 'True'

# ================================================================================ #
# set ACL permissions for service account
# ================================================================================ #
RUN $path='C:\inetpub\wwwroot'; `
    $acl = Get-Acl $path; `
    $newOwner = [System.Security.Principal.NTAccount]('BUILTIN\IIS_IUSRS'); `
    $acl.SetOwner($newOwner); `
    dir -r $path | Set-Acl -aclobject  $acl

# ================================================================================ #
# set ACL for NetworkService user and grant it FullControl permission
# ================================================================================ #
RUN $path='C:\inetpub\wwwroot'; `
    $acl = Get-Acl $path; `
    $user = 'NT AUTHORITY\NetworkService'; `
    $newOwner = [System.Security.Principal.NTAccount]($user); `
    $acl.SetOwner($newOwner); `
    $ar = New-Object System.Security.AccessControl.FileSystemAccessRule($user, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow'); `
    $acl.SetAccessRule($ar); `
    dir -r $path | Set-Acl -aclobject  $acl

# ================================================================================ #
# enable web management service for dev image to allow IIS remote connection. Uses default port 8172
# this allows to connect host's IIS UI to the container's IIS to view and adjust IIS website settings inside of the container
# NOTE: Windows 10 may not have full IIS capabilities to remote into container's IIS. Win Server IIS version does.
# ================================================================================ #
# Enable Remote IIS Management
# RUN Install-WindowsFeature Web-Mgmt-Service; `
#     NET USER dockerdev 'Docker1234' /ADD; `
#     NET LOCALGROUP 'Administrators' 'dockerdev' /add; `
#     Configure-SMRemoting.exe -enable; `
#     sc.exe config WMSVC start=auto; `
#     Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WebManagement\Server -Name EnableRemoteManagement -Value 1

# ================================================================================ #
# augment PATH env var for Machine (global) scope
# ================================================================================ #
# RUN $newPath = $env:myvar + ';' + $env:ORACLE_HOME + '\bin' + [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Machine); `
#     [System.Environment]::SetEnvironmentVariable('PATH', $newPath, [System.EnvironmentVariableTarget]::Machine)

# ================================================================================ #
# set PATH env var for Process scope
# ================================================================================ #
# RUN PATH "c:\inetpub\wwwroot`;%PATH%"

# ================================================================================ #
# expose container ports
# ================================================================================ #
# EXPOSE 80 5985 8172

# ================================================================================ #
# download EXE using corporate proxy and install it (assumes no specific proxy user credential is required)
# ================================================================================ #
# RUN Invoke-WebRequest -UseBasicParsing -Proxy $env:PROXY_URL -ProxyUseDefaultCredentials `
#     -Uri 'http://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe' `
#     -OutFile \install\vcredist_x64.exe; `
#     & \install\vcredist_x64.exe; `
#     Remove-Item -Force \install\vcredist_x64.exe

# ================================================================================ #
# add ODBC DSN connection
# ================================================================================ #
# RUN Add-OdbcDsn -Name testDsn -DriverName "Oracle in instantclient_12_2" `
#     -Platform 64-bit -DsnType System `
#     -SetPropertyValue @('Server=tstsrv','Database=mydb_dsn','Description=Test server ODBC connection','UserID=myuser',$ExecutionContext.InvokeCommand.ExpandString('Password=$env:ODBC_PASSWORD'));

# ================================================================================ #
# if console app can be executed as Win Service, use ServiceMonitor.exe as an ENTRYPOINT
# get ServiceMonitor.exe to monitor running service
# ================================================================================ #
# RUN Invoke-WebRequest -Uri https://dotnetbinaries.blob.core.windows.net/servicemonitor/2.0.1.6/ServiceMonitor.exe -OutFile C:\ServiceMonitor.exe;

# ================================================================================ #
# configure entrypoint to monitor the service
# ensure service is installed under provided name (e.g. ConsoleApp1)
# ================================================================================ #
# ENTRYPOINT ["C:\\ServiceMonitor.exe", "ConsoleApp1"]
