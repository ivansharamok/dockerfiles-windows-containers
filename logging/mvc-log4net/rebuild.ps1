[CmdletBinding()]
param(
    [Parameter(Mandatory=$false,Position=0)] $ImageName="mvclog4net",
    [Parameter(Mandatory=$false)] $TagName="test",
    [Parameter(Mandatory=$false)] $BuildContextPath="./src",
    [Parameter(Mandatory=$false)] $BuildArgSource="bin/release/publish",
    [Parameter(Mandatory=$false)] $DockerfilePath="Dockerfile",
    [Parameter(Mandatory=$false)] $HostPort=8081
)# clean all containers from this image
$containersToRemove = docker ps --filter "ancestor=$ImageName`:$TagName" -aq
if ($containersToRemove.Length -gt 0){
    Write-Host "removing containers: $containersToRemove"
    docker rm -f $containersToRemove
}
# build image
docker build -t $ImageName`:$TagName --build-arg source=$BuildArgSource -f $DockerfilePath $BuildContextPath
# launch container
# docker run -d -p 8081:80 mvclog4net:test
$image = docker images --filter="reference=$ImageName`:$TagName" -q
if ($image){
    Write-Host "starting container from image '$ImageName`:$TagName'"
    docker run -d --isolation process -p $HostPort`:80 $ImageName`:$TagName
}
