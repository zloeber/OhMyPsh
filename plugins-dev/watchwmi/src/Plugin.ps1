
#A quick template function
function Global:New-EventSubscriberMonitor {
    <#
    .SYNOPSIS
    Create a new Event Subscriber to monitor for newly created WMI Event Consumers and processes.

    .DESCRIPTION
    New-EventSubscriberMonitor will create an Event Subscriber to monitor for newly created WMI Event Consumers and processes. Each event will be logged in the application event log as Event ID 8 and source of "WSH"
    .LINK
    https://www.fireeye.com/blog/threat-research/2016/08/wmi_vs_wmi_monitor.html
    .NOTES
    1) Execute the script from an Administrative PowerShell console "Import-Module ./WMIMonitor.ps1"
    The functions "New-EventSubscriberMonitor" and "Remove-SubscriberMonitor" will now be loaded into your system's PowerShell instance
    2) Type "New-EventSubscriberMonitor" to invoke the function and start recording WMI process creations and Consumers
    3) Type "Remove-SubscriberMonitor" to remove the WMI subscriber created and discontinue logging the events
    4) In a new PowerShell window, test a process call create function "wmic process call create "notepad.exe"" and check the Application Event Log to ensure the script is logging

    Author: Tim Parisi
    License: BSD 3-Clause
    Required Dependencies: None
    Optional Dependencies: None
    #>

    #ConsumerFilterArguments
    $ConsumerFilterNamespace = 'root/subscription'
   	$ConsumerFilterClass = '__EventFilter'
    $ConsumerFilterArgs = @{
        EventNamespace = 'root/subscription'
        Name = '_PersistenceEvent_'
        Query = 'SELECT * FROM __InstanceCreationEvent WITHIN 5 Where TargetInstance ISA "__EventConsumer"'
        QueryLanguage = 'WQL'
    }

    #ProcessCallFilter Arguments
    $ProcessCallFilterNamespace = 'root/subscription'
    $ProcessCallFilterClass = '__EventFilter'
    $ProcessCallFilterArgs = @{
        EventNamespace = 'root/cimv2'
        Name = '_ProcessCreationEvent_'
        Query = 'SELECT * FROM MSFT_WmiProvider_ExecMethodAsyncEvent_Pre WHERE ObjectPath="Win32_Process" AND MethodName="Create"'
        QueryLanguage = 'WQL'
    }

    #Create Consumer and Process Call Filters
    $ConsumerFilter = Set-WmiInstance -Class $ConsumerFilterClass -Namespace $ConsumerFilterNamespace -Arguments $ConsumerFilterArgs
    $ProcessCallFilter = Set-WmiInstance -Class $ProcessCallFilterClass -Namespace $ProcessCallFilterNamespace -Arguments $ProcessCallFilterArgs

    # Define the event log template and parameters
    $ConsumerTemplate = @(
        '==New WMI Consumer Created==',
        'Consumer Name: %TargetInstance.Name%',
        'Command Executed: %TargetInstance.ExecutablePath%'
    )

    $ProcessCallTemplate = @(
        '==WMI Command Executed==',
        'Namespace: %Namespace%',
        'Method Executed: %MethodName%',
        'Command Executed: %InputParameters.CommandLine%'
    )

    #Define the ConsumerEvent Arguments
    $ConsumerEventNamespace = 'root/subscription'
    $ConsumerEventClass = 'NTEventLogEventConsumer'
    $ConsumerEventArgs = @{
        Name = '_LogWMIConsumerEvent_'
        Category = [UInt16] 0
        EventType = [UInt32] 2 # Warning
        EventID = [UInt32] 8
        SourceName = 'WSH'
        NumberOfInsertionStrings = [UInt32] $ConsumerTemplate.Length
        InsertionStringTemplates = [String[]] $ConsumerTemplate
    }

    #Define the ProcessCallEvent Arguments
    $ProcessCallEventNamespace = 'root/subscription'
    $ProcessCallEventClass = 'NTEventLogEventConsumer'
    $ProcessCallEventArgs = @{
        Name = [String] '_LogWMIProcessCreationEvent_'
        Category = [UInt16] 0
        EventType = [UInt32] 2 # Warning
        EventID = [UInt32] 8
        SourceName = [String] 'WSH'
        NumberOfInsertionStrings = [UInt32] $ProcessCallTemplate.Length
        InsertionStringTemplates = [String[]] $ProcessCallTemplate
    }

    #Create the Event Consumers
    $ConsumerConsumer = Set-WmiInstance -Class $ConsumerEventClass -Namespace $ConsumerEventNamespace -Arguments $ConsumerEventArgs
    $ProcessCallConsumer = Set-WmiInstance -Class $ProcessCallEventClass -Namespace $ProcessCallEventNamespace -Arguments $ProcessCallEventArgs

    #Define the Consumer Binding Arguments
    $ConsumerBindingNamespace = 'root/subscription'
    $ConsumerBindingClass = '__FilterToConsumerBinding'
    $ConsumerBindingArgs = @{
        Filter = $ConsumerFilter
        Consumer = $ConsumerConsumer
    }

    #Define the ProcessCall Binding Arguments
    $ProcessCallBindingNamespace = 'root/subscription'
    $ProcessCallBindingClass = '__FilterToConsumerBinding'
    $ProcessCallBindingArgs = @{
        Filter = $ProcessCallFilter
        Consumer = $ProcessCallConsumer
    }

    # Register the bindings
    $ConsumerBinding = Set-WmiInstance -Class $ConsumerBindingClass -Namespace $ConsumerBindingNamespace -Arguments $ConsumerBindingArgs
    $ProcessCallBinding = Set-WmiInstance -Class $ProcessCallBindingClass -Namespace $ProcessCallBindingNamespace -Arguments $ProcessCallBindingArgs

    Write-Output 'The new event subscriber has been successfully created!'
    Write-Output 'Check the Application Event Log for Event ID 8 and source of "WSH"'
}

function Global:Remove-SubscriberMonitor {
    <#
    .SYNOPSIS
    Will remove the Event Subscriber that monitors for newly created WMI Event Consumers and processes.
    .DESCRIPTION
    Remove-SubscriberMonitor removes all event consumer bindings, consumers, and filters that were created.
    .LINK
    https://www.fireeye.com/blog/threat-research/2016/08/wmi_vs_wmi_monitor.html
    .NOTES
    Author: Evan Pena
    License: BSD 3-Clause
    Required Dependencies: None
    Optional Dependencies: None
    #>

	Get-WmiObject __eventFilter -namespace root/subscription -filter "name='_PersistenceEvent_'"| Remove-WmiObject
	Get-WmiObject __eventFilter -namespace root/subscription -filter "name='_ProcessCreationEvent_'"| Remove-WmiObject

	Remove-WmiObject -Path "ROOT/subscription:NTEventLogEventConsumer.Name='_LogWMIConsumerEvent_'"
	Remove-WmiObject -Path "ROOT/subscription:NTEventLogEventConsumer.Name='_LogWMIProcessCreationEvent_'"

	Get-WmiObject __FilterToConsumerBinding -Namespace root/subscription | Where-Object { $_.filter -match '_ProcessCreationEvent_'} | Remove-WmiObject
	Get-WmiObject __FilterToConsumerBinding -Namespace root/subscription | Where-Object { $_.filter -match '_PersistenceEvent_'} | Remove-WmiObject

	Write-Output 'The event subscriber and all associating WMI objects have been successfully removed.'
}

function Global:Detect-SubscriberPersistentEvents {
    <#
    .SYNOPSIS
    Detects several different subscriber events.

    .DESCRIPTION
    Detects several different subscriber events.
    .LINK
    NA
    #>
    [cmdletbinding()]
    Param ()
    begin {
        Function Get-WMIEventSubscription {
            <#
            .SYNOPSIS
            Query to find all permament WMI subscriptions on a local or remote system

            .DESCRIPTION
            Query to find all permament WMI subscriptions on a local or remote system. Lists
            all Filters, Consumers and Bindings.

            .PARAMETER Computername
            The computer or list of computers to perform query against.

            .NOTES
            Name: Get-WMIEventSubscription
            Author: Boe Prox
            Version History:
                1.0 //Boe Prox //30 Sept 2015
                    -Initial build

            .OUTPUT
            System.WMI.Subscription

            .EXAMPLE
            Get-WMIEventSubscription

            Computername        Filter              Consumer            Binding
            ------------        ------              --------            -------
            BOE-PC              {\\BOE-PC\ROOT\S... {\\BOE-PC\ROOT\S... {\\BOE-PC\ROOT\S...

            Description
            -----------
            Gets the permanent WMI subscriptions of the local system.
            #>
            [OutputType('System.WMI.Subscription')]
            [cmdletbinding()]
            Param (
                [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
                $Computername = $env:COMPUTERNAME
            )
            Begin {
                $WMIParams = @{
                    NameSpace = 'root/Subscription'
                    ErrorAction = 'Stop'
                }
            }
            Process {
                ForEach ($Computer in $Computername) {
                    $WMIParams.Computername = $Computer
                    $Object = [pscustomobject]@{
                        Computername = $Computername
                        Filter = New-Object System.Collections.ArrayList
                        Consumer = New-Object System.Collections.ArrayList
                        Binding = New-Object System.Collections.ArrayList
                    }
                    #Event Consumers
                    Try {
                        $WMIParams.Class = '__EventConsumer'
                        Get-WMIObject @WMIParams  | ForEach {
                            [void]$Object.Consumer.Add($_)
                        }

                        #Event Filters
                        $WMIParams.Class = '__EventFilter'
                        Get-WMIObject @WMIParams | ForEach {
                            [void]$Object.Filter.Add($_)
                        }

                        #Event Bindings
                        $WMIParams.Class = '__FilterToConsumerBinding'
                        Get-WMIObject @WMIParams | ForEach {
                            [void]$Object.Binding.Add($_)
                        }
                    } Catch {
                        Throw $_
                    }
                    $Object.PSTypeNames.Insert(0,'System.WMI.Subscription')
                    $Object
                }
            }
        }
    }
    process {}
    end {
        Get-WMIEventSubscription | ForEach-Object {
            # Filters
            if (($_.Filter).Count -gt 0 ) {
                Write-Output 'Persistent WMI Filters:'

                $_.Filter | Select-object Name,Query | Format-Table -AutoSize
            }
            # Consumers
            if (($_.Consumer).Count -gt 0 ) {
                Write-Output 'Persistent WMI Consumers:'

                $_.Consumer | Select-object Name,SourceName | Format-Table -AutoSize
            }
            # Bindings
            if (($_.Binding).Count -gt 0 ) {
                Write-Output 'Persistent WMI Bindings:'

                $_.Binding | Select-object Filter
            }
        }
    }
}