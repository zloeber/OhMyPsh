Function Global:Get-vClusterCapacity {
    <#    
    .SYNOPSIS    

        Connect to vSphere vCenter Server and return the vSphere Cluster and 
        vSphere SDRS Cluster resources capacity information.
    
    .DESCRIPTION

        Allows the administrator to connect to vSphere vCenter Server and 
        retrieve the cluster resources capacity information based on 
        calculating the actual resources capacity, usable available resources 
        capacity, consumed resources capacity, virtual vs physical resource ratio
        and overcommit percentage.
    
    .PARAMETER vCenterName 
        
        Specify VMware vSphere vCenter Hostname 
        
    .PARAMETER Username 
        
        Specify the Username for VMware vSphere vCenter Server
            
    .PARAMETER Password
        
        Specify the Password for VMware vSphere vCenter Server
    
    .PARAMETER Cluster
        
        Specify the VMware vSphere Cluster Name
    
    .PARAMETER DatastoreCluster 
        
        Specify the VMware vSphere Datastore Cluster Name
            
    .EXAMPLE 
    
        C:\> Import-Module `
                -Global D:\Temp\Get-vClusterCapacity.psm1 ;

        C:\> Get-vClusterCapacity `
                -vCenterName vCenter.vmware.local `
                -Cluster vSphereCluster `
                -DatastoreCluster vSphere_Datastore_Cluster `
                -Username vmware.local\username `
                -Password Password123 ;
    .INPUTS

        The Get-vClusterCapacity Cmdlet will accept all string inputs from pipeline.

    .OUTPUTS

        The Get-vClusterCapacity Cmdlet will output following details below:

        Cluster Name                                                 : vSphereCluster
        Cluster ESXi Host Names                                      : {vsphere-esx022.vmware.local,
                                                                    vsphere-esx057.vmware.local,
                                                                    vsphere-esx038.vmware.local,
                                                                    vsphere-esx051.vmware.local...}
        Cluster CPU Cores                                            : 96
        Cluster Total Allocated vCPUs                                : 537
        Cluster Total PoweredOn vCPUs                                : 315
        Cluster Total PoweredOff vCPUs                               :
        Cluster vCPU/Core Ratio                                      : 3.281
        Cluster CPU Overcommit (%)                                   : 228.125
        Cluster Physical RAM (GB)                                    : 1535.59
        Cluster Total Allocated vRAM (GB)                            : 1792.98
        Cluster Total PoweredOn vRAM (GB)                            : 1063
        Cluster vRAM/Physical RAM Ratio                              : 0.692
        Cluster RAM Overcommit (%)                                   : -30.78
        Datastore Cluster Name                                       : vSphere_Datastore_Cluster
        Datastore Cluster Datastore Names                            : {vSphere_Datastore_VMFS0001_00, vSphere_Datastore_VMFS0001_01,
                                                                    vSphere_Datastore_VMFS0001_02, vSphere_Datastore_VMFS0001_03...}
        Datastore Cluster Capacity (GB)                              : 47098.25
        Datastore Cluster Reservation (GB)                           : 4709.82
        Datastore Cluster Usable Capacity (GB)                       : 42388.42
        Datastore Cluster PoweredOn Guest Used Space (GB)            : 18885.69
        Datastore Cluster PoweredOff Guest Used Space (GB)           : 28212.56
        Datastore Cluster Used Space (GB)                            : 31410.96
        Datastore Cluster Provisioned Space (GB)                     : 32197.46
        Datastore Cluster Provisioned / Capacity Ratio               : 0.684
        Datastore Cluster Provisioned / Capacity Ratio - Reservation : 0.76
        Datastore Cluster Storage Overcommit (%)                     : -31.64

    .COMPONENT

        This Get-vClusterCapacity Cmdlet requires VMware PowerCLI to be installed in order to provide the PowerShell capabilities to
        connect to vSphere vCenter and interrogate the environment.
        
    .NOTES
    
        Title   : PowerShell Get VMWare vSphere Cluster and Datastore Cluster Capacity 
        FileName: Get-vClusterCapacity.psm1 
        Author  : Ryen Kia Zhi Tang 
        Date    : 22/06/2016 
        Blog    : ryentang.wordpress.com
        Version : 1.0

    .LINK

        Microsoft TechNet Gallery - Get-vClusterCapacity Cmdlet for VMware vSphere vCenter: https://gallery.technet.microsoft.com/Get-vClusterCapacity-a2ab9755
        
    #> 
    Param( 

        [Parameter( 
            Mandatory=$True, 
            ValueFromPipeline=$True, 
            ValueFromPipelineByPropertyName=$True)] 
        [Alias('VIServer')] 
        [String] $vCenterName = $env:COMPUTERNAME ,

        [Parameter( 
            Mandatory=$True, 
            ValueFromPipeline=$True, 
            ValueFromPipelineByPropertyName=$True)] 
        [Alias('U')] 
        [String] $Username, 

        [Parameter( 
            Mandatory=$True, 
            ValueFromPipeline=$True, 
            ValueFromPipelineByPropertyName=$True)] 
        [Alias('P')] 
        [String] $Password, 

        [Parameter( 
            Mandatory=$True, 
            ValueFromPipeline=$True, 
            ValueFromPipelineByPropertyName=$True)] 
        [Alias('HClu')] 
        [String] $Cluster, 

        [Parameter( 
            Mandatory=$True, 
            ValueFromPipeline=$True, 
            ValueFromPipelineByPropertyName=$True)] 
        [Alias('DataClu')] 
        [String] $DatastoreCluster

    ) ;

    BEGIN {

        # Display progress
        Write-Progress `
            -Id 1 `
            -Activity 'Working on adding VMware PowerCLI PSSnapin...' `
            -Status 'Validating VMware PowerCLI is installed.' ;

        if((Get-PSSnapin -Name VMware.VIMAutomation.Core -Registered) -ne (Out-Null)) {

            # Display progress
            Write-Progress `
                -Id 1 `
                -Activity 'Working on adding VMware PowerCLI PSSnapin...' `
                -Status 'Adding VMware PowerCLI PSSnapin. Please wait...' ;

            Try {

                # Add VMware PowerShell CLI Snapin
                Add-PSSnapin `
                    -Name VMware.VIMAutomation.Core `
                    -ErrorAction Stop ;
            
            }Catch{
                
                Write-Host 'Oops. Something went wrong. Please kindly ensure that VMware PowerCLI is installed properly.' `
                    -ForegroundColor Red ;

                Return (Out-Null) ;
            
            } ;
            
            # Display progress
            Write-Progress `
                -Id 1 `
                -Activity 'Working on adding VMware PowerCLI PSSnapin...' `
                -Status 'Added VMware PowerShell CLI Snapin.' ;

        }else{

            # Display progress
            Write-Progress `
                -Id 1 `
                -Activity 'Working on adding VMware PowerCLI PSSnapin...' `
                -Status 'Adding VMware PowerShell CLI PSSnapin failed. VMware.VIMAutomation.Core is not registered.' `
                -Completed ;

            Write-Host 'Please kindly ensure that VMware PowerCLI is installed' `
                -ForegroundColor Red ;

            Exit ;

        } ;

        # Create an array collection to store information for each individual ESXi host
        $ClusterPropertiesCollection = @() ;


        # Display progress
        Write-Progress `
            -Id 1 `
            -Activity 'Working on connecting to vCenter Server...' `
            -Status ('Attempting to connect to vCenter Server [' + $vCenterName + ']. Please wait...') ;

        # Connect to vSphere vCenter
        $ObjConnection = Connect-VIServer `
                            -Server $vCenterName `
                            -User $Username `
                            -Password $Password ;

        if($ObjConnection.IsConnected -eq "True") {

            # Display progress
            Write-Progress `
                -Id 1 `
                -Activity 'Working on connecting to vCenter Server...' `
                -Status ('Connected to vCenter Server [' + $vCenterName + ']') ;

        }else{

            # Display progress
            Write-Progress `
                -Id 1 `
                -Activity 'Working on connecting to vCenter Server...' `
                -Status ('Connection to vCenter Server [' + $vCenterName + '] failed') `
                -Completed ;

            Write-Host 'Please kindly ensure that VMware vCenter Server is available' `
            -ForegroundColor Red ;

            Exit ;

        } ;

    } ;

    PROCESS {
        
        # Display progress
        Write-Progress `
            -Id 1 `
            -Activity 'Working on collecting ESXi Hosts information...' `
            -Status 'Attempting to collect ESXi Hosts properties. Please wait...' ;

        # Get a collection of ESXi hosts properties within the cluster
        $VMhosts = Get-Cluster `
                        -Name $Cluster | `
                            Get-VMHost ;
        
        if($VMhosts -ne (Out-Null)) {

            # Display progress
            Write-Progress `
                -Id 1 `
                -Activity 'Working on collecting ESXi Hosts information...' `
                -Status 'Collected ESXi Hosts properties' ;
        
        }else{

            # Display progress
            Write-Progress `
                -Id 1 `
                -Activity 'Working on collecting ESXi Hosts information...' `
                -Status 'Collecting ESXi Hosts properties failed. Found no ESXi Host in Cluster.' `
                -Completed ;
            
            # Exit
            Return (Out-Null) ;

        } ;

        # Create an array collection to store information for each individual ESXi host
        $VMHostPropertiesCollection = @() ;


        # Display progress
        Write-Progress `
            -Id 1 `
            -Activity 'Working on each ESXi Host information...' `
            -Status 'Calculating every ESXi Host capacity. Please wait...' ;

        ForEach($VMhost in $VMhosts) {
            
            # Progress Bar
            $intProgressCount++ ;
            
            # Display progress
            Write-Progress `
                -Id 100 `
                -ParentId 1 `
                -Activity 'Working on each ESXi Host information...' `
                -Status ('Calculating each ESXi Host [' + $VMhost.Name + '] capacity. Please wait...') `
                -PercentComplete (($intProgressCount/($VMhosts | Measure-Object).Count)*100) `
                -CurrentOperation ([String] ([Math]::Round(($intProgressCount/($VMhosts | Measure-Object).Count)*100, 2)) + '% complete') ;

            # Get total amount of Powered On VM guest vCPUs per host
            $VMHostTotalPoweredOnVMGuestvCPUs = (Get-VM `
                                                    -Location $VMhost | `
                                                        Where-Object { $_.PowerState -eq "PoweredOn" } | `
                                                            Measure-Object NumCpu -Sum).Sum ;
        
            $VMHostPhysicalRAM = [Math]::Round($VMhost.MemoryTotalGB, 2) ;

            $VMHostTotalPoweredOnVMGuestvRAM = [Math]::Round((Get-VM `
                                                    -Location $VMhost | `
                                                        Where-Object { $_.PowerState -eq "PoweredOn" } | `
                                                            Measure-Object MemoryGB -Sum).Sum, 2) ;


            # Construct the properties for our custom object            
            $VMHostProperties = `
                    @{

                    'ESXi Hostname' = $VMhost.Name ;
                
                    'CPU Cores' = $VMhost.NumCpu ;

                    'Total Allocated vCPUs' = (Get-VM `
                                                    -Location $VMhost | `
                                                        Measure-Object NumCpu -Sum).Sum ;

                    'Total PoweredOn vCPUs' = If($VMHostTotalPoweredOnVMGuestvCPUs) { `
                                                $VMHostTotalPoweredOnVMGuestvCPUs ; `
                                                } Else { [Int] "0" ; } ;
                
                    'vCPU/Core Ratio' = If($VMHostTotalPoweredOnVMGuestvCPUs) { `
                                            [Math]::Round(($VMHostTotalPoweredOnVMGuestvCPUs / $VMhost.NumCpu), 3) ; `
                                        } Else { Out-Null ; } ;

                    'CPU Overcommit (%)' = If($VMHostTotalPoweredOnVMGuestvCPUs) { `
                                                [Math]::Round(100*(($VMHostTotalPoweredOnVMGuestvCPUs - $VMhost.NumCpu) / $VMhost.NumCpu), 3) ; `
                                            } Else { Out-Null ; } ;

                    'Physical RAM (GB)' = $VMHostPhysicalRAM ;

                    'Total Allocated vRAM (GB)' = [Math]::Round((Get-VM `
                                                                    -Location $VMhost | `
                                                                    Measure-Object MemoryGB -Sum).Sum, 2) ;

                    'Total PoweredOn vRAM (GB)' = If($VMHostTotalPoweredOnVMGuestvRAM) { `
                                                    $VMHostTotalPoweredOnVMGuestvRAM ; `
                                                    } Else { [Int] "0" ; } ;

                    'vRAM/Physical RAM Ratio' = If($VMHostTotalPoweredOnVMGuestvRAM) { `
                                                    [Math]::Round(($VMHostTotalPoweredOnVMGuestvRAM / $VMHostPhysicalRAM), 3) ; `
                                                } Else { Out-Null ; } ;

                    'RAM Overcommit (%)' = If($VMHostTotalPoweredOnVMGuestvRAM) { `
                                                [Math]::Round(100*(($VMHostTotalPoweredOnVMGuestvRAM - $VMHostPhysicalRAM) / $VMHostPhysicalRAM), 2) ; `
                                            } Else { Out-Null ; } ;

                    } ;

            # Construct a custom object contain the list of properties above
            $ObjVMHostProperties = New-Object `
                                        -TypeName PSObject `
                                        -Property $VMHostProperties ;

            # Store each ESXi Host properties to a collection
            $VMHostPropertiesCollection += $ObjVMHostProperties ;

            # Display progress
            Write-Progress `
                -Id 100 `
                -ParentId 1 `
                -Activity 'Working on each ESXi Host information...' `
                -Status ('Calculated ESXi Host [' + $VMhost.Name + '] capacity.') `
                -Completed ;

        } ;

        # Display progress
        Write-Progress `
            -Id 1 `
            -Activity 'Working on vSphere Cluster information...' `
            -Status ('Calculating Cluster [' + $Cluster + '] resource capacity. Please wait...') ;

        $ClusterTotalPoweredOnGuestvCPUs = (Get-VM `
                                                -Location $Cluster | `
                                                Where-Object { $_.PowerState -eq "PoweredOn" } | `
                                                Measure-Object NumCpu -Sum).Sum ;

        $ClusterTotalCPUCores = ($VMhosts | `
                                    Measure-Object NumCpu -Sum).Sum ;

        $ClusterTotalPoweredOnGuestvRAM = [Math]::Round((Get-VM `
                                                -Location $Cluster | `
                                                Where-Object { $_.PowerState -eq "PoweredOn" } | `
                                                Measure-Object MemoryGB -Sum).Sum, 2) ;

        $ClusterTotalPhysicalRAM = [Math]::Round(($VMhosts | `
                                            Measure-Object MemoryTotalGB -Sum).Sum, 2) ;

        # Display progress
        Write-Progress `
            -Id 1 `
            -Activity 'Working on vSphere Datastore Cluster information...' `
            -Status ('Calculating Datastore Cluster [' + $Cluster + '] resource capacity. Please wait...') ;
        
        $DatastoreClusterCapacity = [Math]::Round(((Get-DatastoreCluster `
                                            -Name $DatastoreCluster).CapacityGB | `
                                                Measure-Object -Sum).Sum, 2) ;

        $VMDatastoreProperties = Get-VM `
                                    -Datastore $DatastoreCluster ;

        $DatastoresProperties = Get-Datastore `
                                    -Location $DatastoreCluster ;

        $DatastoreClusterUsedSpace = [Math]::Round((($VMDatastoreProperties | Select -Expand UsedSpaceGB) | `
                                                Measure-Object -Sum).Sum, 2) ;

        $DatastoreClusterPoweredOnGuestUsedSpace = [Math]::Round((($VMDatastoreProperties | `
                                                Where-Object { $_.PowerState -eq "PoweredOn" } | Select -Expand UsedSpaceGB) | `
                                                Measure-Object -Sum).Sum, 2) ;

        $DatastoreClusterProvisionedSpace = [Math]::Round((($VMDatastoreProperties | Select -Expand ProvisionedSpaceGB) | `
                                                    Measure-Object -Sum).Sum, 2) ;

        # Building a custom object specific to the -Cluster parameter
        $ClusterProperties = [Ordered] `
                @{

                'Cluster Name' = $Cluster ;

                'Cluster ESXi Host Names' = $VMHostPropertiesCollection.'ESXi Hostname' ;
            
                'Cluster CPU Cores' = $ClusterTotalCPUCores ;
            
                'Cluster Total Allocated vCPUs' = ($VMHostPropertiesCollection.'Total Allocated vCPUs' | `
                                                    Measure-Object -Sum).Sum ;
            
                'Cluster Total PoweredOn vCPUs' = If($ClusterTotalPoweredOnGuestvCPUs) { `
                                                    $ClusterTotalPoweredOnGuestvCPUs ; `
                                                    } Else { [Int] "0" ; } ;

                'Cluster Total PoweredOff vCPUs' = If($ClusterTotalPoweredOnGuestvCPUs) { `
                                                    (($VMHostPropertiesCollection.'Total Allocated vCPUs' | `
                                                        Measure-Object -Sum).Sum - $ClusterTotalPoweredOnGuestvCPUs) ; `
                                                    } Else { [Int] "0" ; } ;

                'Cluster vCPU/Core Ratio' = If($ClusterTotalPoweredOnGuestvCPUs) { `
                                                [Math]::Round(($ClusterTotalPoweredOnGuestvCPUs / $ClusterTotalCPUCores), 3) ; `
                                            } Else { Out-Null ; } ;

                'Cluster CPU Overcommit (%)' = If($ClusterTotalPoweredOnGuestvCPUs) { `
                                                    [Math]::Round(100*(( $ClusterTotalPoweredOnGuestvCPUs - $ClusterTotalCPUCores) / $ClusterTotalCPUCores), 3) ; `
                                                } Else { Out-Null ; } ;

                'Cluster Physical RAM (GB)' = $ClusterTotalPhysicalRAM ;

                'Cluster Total Allocated vRAM (GB)' = [Math]::Round(($VMHostPropertiesCollection.'Total Allocated vRAM (GB)' | `
                                                        Measure-Object -Sum).Sum, 2) ;
            
                'Cluster Total PoweredOn vRAM (GB)' = If($ClusterTotalPoweredOnGuestvRAM) { `
                                                        $ClusterTotalPoweredOnGuestvRAM `
                                                        } Else { [Int] "0" ; } ;

                'Cluster vRAM/Physical RAM Ratio' = If($ClusterTotalPoweredOnGuestvRAM) { `
                                                        [Math]::Round(($ClusterTotalPoweredOnGuestvRAM / $ClusterTotalPhysicalRAM), 3) ; `
                                                    } Else { Out-Null ; } ;
            
                'Cluster RAM Overcommit (%)' = If($ClusterTotalPoweredOnGuestvRAM) { `
                                                    [Math]::Round(100*(( $ClusterTotalPoweredOnGuestvRAM - $ClusterTotalPhysicalRAM) / $ClusterTotalPhysicalRAM), 2) ; `
                                                } Else { Out-Null ; } ;
            
                'Datastore Cluster Name' = $DatastoreCluster ;

                'Datastore Cluster Datastore Names' = $DatastoresProperties.Name ;

                'Datastore Cluster Capacity (GB)' = $DatastoreClusterCapacity ;
            
                'Datastore Cluster Reservation (GB)' = [Math]::Round(($DatastoreClusterCapacity * 0.1), 2) ;

                'Datastore Cluster Usable Capacity (GB)' = [Math]::Round(($DatastoreClusterCapacity - ($DatastoreClusterCapacity * 0.1)), 2) ;
                            
                'Datastore Cluster PoweredOn Guest Used Space (GB)' = $DatastoreClusterPoweredOnGuestUsedSpace ;

                'Datastore Cluster PoweredOff Guest Used Space (GB)' = [Math]::Round(($DatastoreClusterCapacity - $DatastoreClusterPoweredOnGuestUsedSpace), 2) ;

                'Datastore Cluster Used Space (GB)' = If($DatastoreClusterUsedSpace){ `
                                                        $DatastoreClusterUsedSpace ; `
                                                        } Else { [Int] "0" ; } ;
            
                'Datastore Cluster Provisioned Space (GB)' = If($DatastoreClusterProvisionedSpace) { `
                                                                $DatastoreClusterProvisionedSpace ; `
                                                                } Else { [Int] "0" ; } ;

                'Datastore Cluster Provisioned / Capacity Ratio' = If($DatastoreClusterProvisionedSpace) { `
                                                                        [Math]::Round(($DatastoreClusterProvisionedSpace / $DatastoreClusterCapacity), 3) ; `
                                                                    } Else { Out-Null ; } ;
                
                'Datastore Cluster Provisioned / Capacity Ratio - Reservation' = If($DatastoreClusterProvisionedSpace) { `
                                                                                    [Math]::Round(($DatastoreClusterProvisionedSpace / ($DatastoreClusterCapacity - ($DatastoreClusterCapacity * 0.1 ))), 3) ; `
                                                                                    } Else { Out-Null ; } ;

                'Datastore Cluster Storage Overcommit (%)' = If($DatastoreClusterProvisionedSpace) { `
                                                                [Math]::Round(100*(( $DatastoreClusterProvisionedSpace - $DatastoreClusterCapacity) / $DatastoreClusterCapacity), 2) ; `
                                                                } Else { Out-Null ; } ;

                } ;

        # Construct a custom object contain the list of properties above
        $ObjClusterProperties = New-Object `
                                    -TypeName PSObject `
                                    -Property $ClusterProperties ;

        #$ClusterPropertiesCollection += $ObjClusterProperties ;
        Return $ObjClusterProperties ;

    } ;

    END {

        # Disconnect from the vSphere vCenter
        Disconnect-VIServer `
            -Server $vCenterName `
            -Confirm:$False ;

        # Remove VMware PowerShell CLI Snapin
        Remove-PSSnapin `
            -Name VMware.VimAutomation.Core `
            -Confirm:$False ;

    } ;
}
