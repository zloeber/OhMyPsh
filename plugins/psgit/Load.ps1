$PreLoad = {
    Import-OMPModule 'PSGit'
}
$PostLoad = {}
$Shutdown = {
    Remove-Module 'PSGit' -force
}