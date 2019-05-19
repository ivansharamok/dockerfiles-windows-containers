# Proxy

When building images within enterprise domain, direct access to the Internet may not be allowed. If build environment is air-gapped, the `Visual C++ Redistributable package` should be downloaded manually.
If there is a proxy that can be used, you can use it to pull resources from the Internet.

Often enterprise proxy is an internal domain resource. In such case, you must join your build process containers to domain. Currently it can be done by using Group Managed Serve Account (gMSA). Get the account and pass it into the `docker build` command: `docker build --security-opt "credentialspec=file://gMSADockerDev.json"`.

Use proxy that requires authentication and default credentials could be used:

```powershell
$env:HTTP_PROXY="http://proxy.contoso.com:80";
Invoke-WebRequest -UseBasicParsing -Proxy $env:HTTP_PROXY -ProxyUseDefaultCredentials `
-Uri 'http://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe' `
-OutFile \install\vcredist_x64.exe;
```

Use proxy that requires authentication with specific credentials:

```powershell
$env:HTTP_PROXY="http://proxy.contoso.com:80";
$ppass = 'myStrongPass' | ConvertTo-SecureString -AsPlainText -Force;
$pcred = new-object pscredential('contoso.com\myUser',$ppass);
Invoke-WebRequest -UseBasicParsing -Proxy $env:HTTP_PROXY -ProxyCredentials $pcred `
-Uri 'http://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe' `
-OutFile \install\vcredist_x64.exe;
```
