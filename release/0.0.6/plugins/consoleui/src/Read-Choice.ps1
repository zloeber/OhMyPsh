function Global:Read-Choice {     
    Param(
        [Parameter(Position=0)]
        [System.String]$Message, 
         
        [Parameter(Position=1)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]$Choices = @('&Yes','&No','Yes to &All','No &to All'),
         
        [Parameter(Position=2)]
        [System.Int32]$DefaultChoice = 0, 
         
        [Parameter(Position=3)]
        [System.String]$Title = [string]::Empty 
    )        
    [System.Management.Automation.Host.ChoiceDescription[]]$Poss = $Choices | ForEach-Object {            
        New-Object System.Management.Automation.Host.ChoiceDescription "$($_)", "Sets $_ as an answer."      
    }       
    $Host.UI.PromptForChoice( $Title, $Message, $Poss, $DefaultChoice )     
}