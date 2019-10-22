<powershell>
    $TAG_NAME="KubernetesCluster"
    $INSTANCE_ID=cmd.exe /c curl -XGET http://169.254.169.254/latest/meta-data/instance-id
    $REGION=cmd.exe /c curl -XGET http://169.254.169.254/latest/meta-data/placement/availability-zone
    $REGION=$REGION.Substring(0,$REGION.Length-1)
    $instanceTags = Get-EC2Tag -Region $REGION -Filter @{ Name="resource-id"; Values=$INSTANCE_ID }
    $ClusterName = $instanceTags.Where({$_.Key -eq $TAG_NAME}).Value
    Write-Output "Started User-Data to join node to the cluster"
    while ($true)
    {
      if(Get-S3Object -BucketName ${S3Bucket-Placeholder} "kubeadm" | where{$_.Key -like "kubeadm/${ClusterName}/config"})
      { 
        Write-Output "Started process to join node"
        aws.cmd s3 cp s3://${S3Bucket-Placeholder}/kubeadm/${ClusterName}/config C:\k\
        $env:HostIP = (
            Get-NetIPConfiguration |
            Where-Object {
                $_.IPv4DefaultGateway -ne $null -and
                $_.NetAdapter.Status -ne "Disconnected"
            }
        ).IPv4Address.IPAddress
        C:\k\join.ps1 -ManagementIP  $env:HostIP -NetworkMode overlay -ClusterCIDR 172.21.128.0/17 -KubeDnsServiceIP 172.21.0.10 -ServiceCIDR 172.21.0.0/17 -LogDir C:\k\logs -KubeletFeatureGates ""
        Write-Output "Successfully joined to the cluster"
        Break
      } 
      else 
      { 
        Write-Output "Waiting for the kubeconfig"
        Start-Sleep -Seconds 30 
      }
    }
</powershell>
<runAsLocalSystem>true</runAsLocalSystem>
