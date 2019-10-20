cd 'C:\k\'
cmd.exe /c curl -O -k "https://www.python.org/ftp/python/3.7.0/python-3.7.0.exe"
cmd.exe /c curl -O -k "https://bootstrap.pypa.io/get-pip.py"

##Python Installation and awscli setup##
.\python-3.7.0.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 Include_pip=1
Start-Sleep -Second 150
mkdir -p C:\ProgramData\pip\
mv pip.ini 'C:\ProgramData\pip\'

mkdir -p 'C:\Program Files (x86)\Python37-32\'
$env:path += ";C:\Program Files (x86)\Python37-32\"
$newPath = "C:\Program Files (x86)\Python37-32\;" + [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("PATH", $newPath, [EnvironmentVariableTarget]::Machine)

py .\get-pip.py

$env:path += ";C:\Program Files (x86)\Python37-32\Scripts\"
$newPath = "C:\Program Files (x86)\Python37-32\Scripts\;" + [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("PATH", $newPath, [EnvironmentVariableTarget]::Machine)

pip3.exe install awscli
