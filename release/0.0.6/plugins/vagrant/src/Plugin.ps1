# Based on the great work by Posh-git!
#
# Vagrant status is slower then is resonable for a prompt to render. I am making some assumptions
# by scraping the .vagrant folder for any id files that should represent active/aborted some sort
# of Vagrant machine activity.
function Global:Get-VagrantFile {
    $fileName = 'Vagrantfile'
    $base = Get-Item -Force .
    if ($base.PSProvider.Name -ne 'FileSystem'){
        return $FALSE
    }
    $vagrantFile = Join-Path $base.FullName $fileName
    if(Test-Path -LiteralPath $vagrantFile)
    {
        return $TRUE
    }
    return $FALSE
}

function Global:Get-VagrantDir {
    $dirName = '.vagrant'
    $base = Get-Item -Force .
    if($base.PSProvider.Name -ne 'FileSystem'){
        return $FALSE
    }
    $vagrantDir = Join-Path $base.FullName $dirName
    if(Test-Path -LiteralPath $vagrantDir)
    {
        return $vagrantDir
    }
    return $FALSE
}

function Global:Get-VagrantEnvIndex {
    $vagrantEnvVar = [environment]::GetEnvironmentVariable("VAGRANT_HOME","User")
    $dirName = '.vagrant.d'
    if($vagrantEnvVar)
    {
        if($vagrantEnvVar -contains $dirName)
        {
          $base = Get-Item -Force $vagrantEnvVar
          $vagrantEnvDir = Join-Path $base.FullName
        }
        else
        {
          $base = Get-Item -Force $vagrantEnvVar
          $vagrantEnvDir = Join-Path $base.FullName $dirName
        }
        if(Test-Path -LiteralPath $vagrantEnvDir)
        {
          $machineIndex = Get-ChildItem -Path $vagrantEnvDir -Recurse -File -Filter 'index' | % { $_.FullName }
        }
        return $machineIndex
    }
    else
    {
        $base = Get-Item -Force $env:USERPROFILE
        $vagrantEnvDir = Join-Path $base.FullName $dirName
        if(Test-Path -LiteralPath $vagrantEnvDir)
        {
           $machineIndex = Get-ChildItem -Path $vagrantEnvDir -Recurse -File -Filter 'index' | % { $_.FullName }
        }
        return $machineIndex
    }
}

function Global:Write-VagrantStatusSimple {
    $vagrantFolder = Get-VagrantDir
    if((Test-Path $vagrantFolder) -and (Get-VagrantFile))
    {
        $vagrantActive = $FALSE
        $items = Get-ChildItem -Path $vagrantFolder -Recurse -File -Filter 'id'
        foreach($item in $items)
        {
            if($item.ToString().Contains("id"))
            {
                $vagrantActive = $TRUE
            }
            else
            {
                $vagrantActive = $FALSE
            }
        }
        if($vagrantActive)
        {
            Write-Host ' [' -NoNewline
            Write-Host '^' -ForegroundColor Green -NoNewline
            Write-Host ']' -NoNewline
        }
        else
        {
            Write-Host ' [' -NoNewline
            Write-Host '-' -ForegroundColor Gray -NoNewline
            Write-Host ']' -NoNewline

        }
    }
    elseif(Get-VagrantFile)
    {
      Write-Host ' [' -NoNewline
      Write-Host '-' -ForegroundColor Gray -NoNewline
      Write-Host ']' -NoNewline
    }
}

function Global:Write-VagrantStatusDetailed {
  $vagrantFolder = Get-VagrantDir
  $vagrantEnvJson = Get-Content(Get-VagrantEnvIndex -Raw) | ConvertFrom-Json
  $machines = @()
  $d = 0
  $r = 0
  $a = 0
  if((Test-Path $vagrantFolder) -and (Get-VagrantFile))
  {
    $items = Get-ChildItem -Path $vagrantFolder -Recurse -File -Filter 'index_uuid' | % { $_.FullName }
    if($items)
    {
      foreach($item in $items)
      {
          if($item.ToString().Contains("index_uuid"))
          {
              $machines = $machines + (get-content $item)
          }
      }

      foreach($machine in $machines)
      {
        foreach($envMachine in $vagrantEnvJson.machines)
        {
          $stateTemp = $envMachine.$machine | select -ExpandProperty state
          switch($stateTemp){
                  'aborted' { $d += 1; break}
                  'running' {$r += 1; break}
                  'poweroff' {$d += 1; break}
                  default { break}
          }
        }
      }
      Write-Host ' [' -NoNewline
      Write-Host "D:${d} " -ForegroundColor Gray -NoNewline
      Write-Host "R:${r}" -ForegroundColor Green -NoNewline
      Write-Host ']' -NoNewline
    }
    else
    {
      Write-Host ' [' -NoNewline
      Write-Host "-" -ForegroundColor Gray -NoNewline
      Write-Host ']' -NoNewline
    }
  }
  elseif(Get-VagrantFile)
  {
    Write-Host ' [' -NoNewline
    Write-Host "-" -ForegroundColor Gray -NoNewline
    Write-Host ']' -NoNewline
  }
}