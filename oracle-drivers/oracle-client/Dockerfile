# escape=`
# Oracle client 12.2: https://www.oracle.com/technetwork/database/enterprise-edition/downloads/oracle12c-windows-3633015.html
# vc_redist_2013_x64 dependency: http://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe
FROM microsoft/dotnet-framework:4.7.2-runtime-windowsservercore-ltsc2016
SHELL ["cmd", "/S", "/C"]
ARG CLIENT_ZIP="winx64_12201_client.zip"
ARG ODAC_COMPONENT="oledb"

LABEL com.contoso.name="oraclclient12c-runtime:dotnet-4.7.2-runtime-windowsservercore-ltsc2016" `
    com.contoso.description=".NET Framework base image with Oracle Client 12c 64-bit" `
    com.contoso.docker.cmd.build="docker build --build-arg CLIENT_ZIP='winx64_12201_client.zip' -t oraclclient12c-runtime:dotnet-4.7.2-runtime-windowsservercore-ltsc2016 -f Dockerfile ."

# Environment variables
ENV ORACLE_BASE="c:\oracle" `
    ORACLE_HOME="c:\oracle\client122" `
    TNS_ADMIN="c:\oracle\network\admin"
# download and install vcredist dependency necessary for Oracle client
RUN md c:\install && `
    powershell -nologo -noprofile -command "{Invoke-WebRequest -UseBasicParsing -Uri 'http://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe' -OutFile \install\vcredist_x64.exe}" && `
    \install\vcredist_x64.exe -ArgumentList '/install /quiet' && `
    rm \install\vcredist_x64.exe
# copy Oracle Client install zip
COPY ${CLIENT_ZIP} \install\
# install vcredist
# expand archive and install Oracle Client runtime version
RUN powershell -nologo -noprofile -command "{Expand-Archive -Path \install\$env:CLIENT_ZIP -DestinationPath \install}" && `
    \install\client\setup.exe -waitforcompletion -logLevel info -ignorePrereq -noconsole -silent "ORACLE_BASE=C:\oracle" "ORACLE_HOME=C:\oracle\client122" "ORACLE_HOME_NAME=OraClient12c" "SELECTED_LANGUAGES=en" "oracle.install.client.installType=Runtime" "INVENTORY_LOCATION=C:\Program Files\Oracle\Inventory" "DECLINE_SECURITY_UPDATES=true" && `
    rmdir /s /q \install
