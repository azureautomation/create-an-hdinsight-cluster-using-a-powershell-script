$resourceGroupName = "oeresource"
$location = "West Europe"
$storageAccountName = "s$resourceGroupName"
$containerName = "hdp$resourceGroupName"
$clusterName = $containerName
$clusterNodes = 1
$httpUserName = "HDUser"
$sshUserName = "SSHUser"
$password = ConvertTo-secureString "MyPassword" -AsPlainText -Force

Login-AzureRmAccount

#Create a resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location

#Create a storage account
Write-Host "Creating storage account..."
New-AzureRmStorageAccount -Name $storageAccountName -ResourceGroupName $resourceGroupName -Type "Standard_GRS" -Location $location

#Create a Blob storage container
Write-Host "Creating container..."
$storageAccountKey = Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName | %{ $_[0].Value }
$destContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
New-AzureStorageContainer -Name $containerName -Context $destContext

#Create a cluster
Write-Host "Creating HDInsight cluster..."
$httpCredential = New-Object System.Management.Automation.PSCredential ($httpUserName, $password)
$sshCredential = New-Object System.Management.Automation.PSCredential ($sshUserName, $password)
New-AzureRmHDInsightCluster -ResourceGroupName $resourceGroupName -ClusterName $clusterName -ClusterType Hadoop -version 3.3 -Location $location -DefaultStorageAccountName "$storageAccountName.blob.core.windows.net" -DefaultStorageAccountKey $storageAccountKey -DefaultStorageContainer $containerName -ClusterSizeInNodes $clusterNodes -OSType Linux -HttpCredential $httpCredential -SshCredential $sshCredential
Write-Host "Finished...!"