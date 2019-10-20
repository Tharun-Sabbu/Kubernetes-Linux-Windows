<powershell>
    $TAG_NAME="KubernetesCluster"
    $INSTANCE_ID=cmd.exe /c curl -XGET http://169.254.169.254/latest/meta-data/instance-id
    $REGION=cmd.exe /c curl -XGET http://169.254.169.254/latest/meta-data/placement/availability-zone
    $REGION=$REGION.Substring(0,$REGION.Length-1)
    $instanceTags = Get-EC2Tag -Region $REGION -Filter @{ Name="resource-id"; Values=$INSTANCE_ID }
    $ClusterName = $instanceTags.Where({$_.Key -eq $TAG_NAME}).Value
    while ($true)
    {
      if(Get-S3Object -BucketName ${S3Bucket_NAME} | where{$_.Key -like "kubeadm/${ClusterName}"})
      { 
        aws.cmd s3 cp s3://${S3Bucket_NAME}/kubeadm/${ClusterName}/config C:\k\
        $env:HostIP = (
            Get-NetIPConfiguration |
            Where-Object {
                $_.IPv4DefaultGateway -ne $null -and
                $_.NetAdapter.Status -ne "Disconnected"
            }
        ).IPv4Address.IPAddress
        C:\k\awsclisetup.ps1
        C:\k\join.ps1 -ManagementIP  $env:HostIP -NetworkMode overlay -ClusterCIDR 172.21.128.0/17 -KubeDnsServiceIP 172.21.0.10 -ServiceCIDR 172.21.0.0/17 -LogDir C:\k\logs -KubeletFeatureGates ""
        C:\k\fix_metadata.ps1
        Break
      } 
      else 
      { 
        Start-Sleep -Seconds 30 
      }
    }
</powershell>
<runAsLocalSystem>true</runAsLocalSystem>
