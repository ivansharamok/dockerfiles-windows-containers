# escape=`
# 64-bit ODAC Ora 12.2.0.1: https://www.oracle.com/technetwork/database/windows/downloads/index-090165.html
# vc_redist_2013_x64 dependency: http://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.7.2-windowsservercore-ltsc2016
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
ARG ODAC_ZIP="ODAC122010Xcopy_x64.zip"
ARG ODAC_COMPONENT="asp.net4"

LABEL com.contoso.name="odac64-aspnet4:aspnet-4.7.2-windowsservercore-ltsc2016" `
    com.contoso.description="ASP.NET Framework base image with ODAC 12.2 64-bit and asp.net driver" `
    com.contoso.docker.cmd.build="docker build --build-arg ODAC_COMPONENT='asp.net4' -t odac64-aspnet4:aspnet-4.7.2-windowsservercore-ltsc2016 -f Dockerfile ."

# Environment variables
ENV ORACLE_BASE="c:\oracle" `
    ORACLE_HOME="c:\oracle" `
    TNS_ADMIN="c:\oracle\network\admin"
# download and install vcredist dependency necessary for Oracle client
RUN mkdir \install; `
    Invoke-WebRequest -UseBasicParsing `
    -Uri 'http://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe' `
    -OutFile \install\vcredist_x64.exe; `
    Start-Process \install\vcredist_x64.exe -ArgumentList '/install /quiet' -NoNewWindow -Wait; `
    Remove-Item -Force \install\vcredist_x64.exe;
# copy Oracle ODAC install zip
COPY ${ODAC_ZIP} \install\
# install vcredist
# expand archive and install ODAC
RUN Expand-Archive -Path \install\$env:ODAC_ZIP -DestinationPath \install; `
    Push-Location \install; `
    Start-Process \install\install.bat `
    -ArgumentList '%ODAC_COMPONENT% %ORACLE_BASE% orahome1 true true' `
    -WorkingDirectory \install -NoNewWindow -Wait; `
    Pop-Location; `
    Remove-Item -Recurse -Force -Path \install
