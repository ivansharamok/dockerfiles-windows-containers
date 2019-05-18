# escape=`
# Oracle instand client and ODBC driver x64: https://www.oracle.com/technetwork/topics/winx64soft-089540.html
# vc_redist_2013_x64 dependency: http://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe
# Oracle instand client and ODBC driver x86: https://www.oracle.com/technetwork/topics/winsoft-085727.html
# vc_redist_2013_x86 dependency: http://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x86.exe
FROM microsoft/dotnet-framework:4.7.2-runtime-windowsservercore-ltsc2016
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
ARG INSTANTCLIENT_ZIP="instantclient-basiclite-nt-12.2.0.1.0.zip"
ARG ODBC_ZIP="instantclient-odbc-nt-12.2.0.1.0-2.zip"
ARG ODBC_PASSWORD
ARG ODBC_DRIVER="Oracle in instantclient_12_2"

LABEL com.contoso.name="odbc32-base:dotnet-4.7.2-runtime-windowsservercore-2016" `
    com.contoso.description=".NET Framework base image with ODBC 12.2 32-bit driver" `
    com.contoso.docker.cmd.build="docker build --build-arg ODBC_PASSWORD='myStrongPass' --build-arg ODBC_ZIP='instantclient-odbc-nt-12.2.0.1.0-2.zip' -t odbc32-base:dotnet-4.7.2-runtime-windowsservercore-2016 -f Dockerfile ."

# Environment variables
ENV ORACLE_BASE="c:\oracle" `
    ORACLE_HOME="c:\oracle" `
    TNS_ADMIN="c:\oracle\network\admin"
# download and install vcredist dependency necessary for Oracle client
RUN mkdir \install; `
    Invoke-WebRequest -UseBasicParsing `
    -Uri 'http://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x86.exe' `
    -OutFile \install\vcredist_x86.exe; `
    Start-Process \install\vcredist_x86.exe -ArgumentList '/install /quiet' -NoNewWindow -Wait; `
    Remove-Item -Force \install\vcredist_x86.exe;
# copy Oracle Instant Client and ODBC install zip
COPY ${ODBC_ZIP} ${INSTANTCLIENT_ZIP} \install\
# expand archives and install Oracle ODBC driver
RUN Expand-Archive -Path \install\$env:INSTANTCLIENT_ZIP -DestinationPath $env:ORACLE_BASE; `
    Expand-Archive -Path \install\$env:ODBC_ZIP -DestinationPath $env:ORACLE_BASE; `
    Push-Location $env:ORACLE_HOME; `
    # using powershell x86 to install 32-bit ODBC driver
    & "$env:windir\syswow64\windowspowershell\v1.0\powershell.exe" `
    -Command {Start-Process .\odbc_install.exe -WorkingDirectory $env:ORACLE_HOME -NoNewWindow -Wait} -NonInteractive -NoProfile; `
    Pop-Location; `
    Remove-Item -Recurse -Force -Path \install
# add ODBC DSN
RUN Add-OdbcDsn -Name testDsn -DriverName $env:ODBC_DRIVER `
    -Platform 64-bit -DsnType System `
    -SetPropertyValue @('Server=tstsrv','Database=mydb_dsn','Description=Test server ODBC connection','UserID=myuser',$ExecutionContext.InvokeCommand.ExpandString('Password=$env:ODBC_PASSWORD'));
