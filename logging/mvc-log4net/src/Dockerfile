#escape=`

#FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-1903 as build
#FROM microsoft/aspnet:4.7.2-windowsservercore-1803
#FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2019
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-1903
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
ARG source

RUN Import-Module WebAdministration; `
    Set-ItemProperty IIS:\AppPools\DefaultAppPool -name processModel -value @{identitytype='LocalSystem'};
    # alternative way to set AppPool account to LocalSystem
    # Set-ItemProperty IIS:\AppPools\DefaultAppPool -name processModel -value @{identitytype=1};
WORKDIR /inetpub/wwwroot
COPY ${source:-bin/Release/publish} .
ENTRYPOINT .\eventlog-reader.ps1 -ServiceName w3svc -LogName Application -FrequencyInSeconds 2