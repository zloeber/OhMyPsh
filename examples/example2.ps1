# create a manifest file for a plugin

[psobject]@{
    Name = 'qod'
    Platform = @('Linux','Windows','OSX')
    Version = '0.0.1'
    Description = 'Quote of the Day. Imports Get-Quote into the session and runs it once when the plugin is loaded. This effectively displays a random quote everytime you load OhMyPsh.'
} | ConvertTo-Json | Out-File 'manifest.json' -Encoding:utf8 -force


[psobject]@{
    Name = 'qod'
    Platform = @('Linux','Windows','OSX')
    Version = '0.0.1'
    Description = 'Quote of the Day. Imports Get-Quote into the session and runs it once when the plugin is loaded. This effectively displays a random quote everytime you load OhMyPsh.'
} | ConvertTo-Json | Out-File 'manifest.json' -Encoding:utf8 -force