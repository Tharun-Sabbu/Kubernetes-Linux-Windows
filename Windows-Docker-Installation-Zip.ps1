invoke-webrequest -UseBasicparsing -Outfile docker-19-03-0.zip https://dockermsft.blob.core.windows.net/dockercontainer/docker-19-03-0.zip -verbose
Expand-Archive docker-19-03-0.zip -DestinationPath $Env:ProgramFiles -Force
Remove-Item -Force docker-19-03-0.zip
$env:path += ";$env:ProgramFiles\docker"
$newPath = "$env:ProgramFiles\docker;" + [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("PATH", $newPath, [EnvironmentVariableTarget]::Machine)
dockerd --register-service
Start-Service docker 
