function Reset-OMPConsoleOverride {
    <#
    .SYNOPSIS
    Resets various registry setting overrides for default console color values.
    .DESCRIPTION
    Resets various registry setting overrides for default console color values. This can be useful if console theming on windows just doesn't seem to work the way you would expect. Use at your own risk!
    .LINK
    https://github.com/lukesampson/concfg
    .LINK
    https://github.com/zloeber/OhMyPsh
    .EXAMPLE
    Reset-OMPConsoleOverride
    #>

    [CmdletBinding()]
    param(
    )
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."

        function linksto($path, $target) {
            if(!(isshortcut $path)) { return $false }

            $path = "$(resolve-path $path)"

            $shell = new-object -com wscript.shell -strict
            $shortcut = $shell.createshortcut($path)

            $result = $shortcut.targetpath -eq $target
            [Runtime.Interopservices.Marshal]::ReleaseComObject($shortcut) > $null
            return $result
        }

        function isshortcut($path) {
            if(!(test-path $path)) { return $false }
            if($path -notmatch '\.lnk$') { return $false }
            return $true
        }

        # based on code from coapp:
        # https://github.com/coapp/coapp/tree/master/toolkit/Shell
        $cs = @"
        using System;
        using System.Runtime.InteropServices;
        using System.Runtime.InteropServices.ComTypes;
        namespace concfg {
            public static class Shortcut {
                public static void RmProps(string path) {
                    var NT_CONSOLE_PROPS_SIG = 0xA0000002;
                    var STGM_READ = 0;
                    var lnk = new ShellLinkCoClass();
                    var data = (IShellLinkDataList)lnk;
                    var file = (IPersistFile)lnk;
                    file.Load(path, STGM_READ);
                    data.RemoveDataBlock(NT_CONSOLE_PROPS_SIG);
                    file.Save(path, true);
                    Marshal.ReleaseComObject(data);
                    Marshal.ReleaseComObject(file);
                    Marshal.ReleaseComObject(lnk);
                }
            }
            [ComImport, Guid("00021401-0000-0000-C000-000000000046")]
            class ShellLinkCoClass { }
            [ComImport,
            InterfaceType(ComInterfaceType.InterfaceIsIUnknown),
            Guid("45e2b4ae-b1c3-11d0-b92f-00a0c90312e1")]
            interface IShellLinkDataList {
                void _VtblGap1_2(); // AddDataBlock, CopyDataBlock
                [PreserveSig]
                Int32 RemoveDataBlock(UInt32 dwSig);
                void _VtblGap2_2(); // GetFlag, SetFlag
            }
        }
"@

        add-type -typedef $cs -lang csharp

        function rmprops($path) {
            if(!(isshortcut $path)) { return $false }

            $path = "$(resolve-path $path)"
            try { [concfg.shortcut]::rmprops($path) }
            catch [UnauthorizedAccessException] {
                return $false
            }
            $true
        }

        $pspath = "$pshome\powershell.exe"
        $pscorepath = "$pshome\pwsh.exe"

        function cleandir($dir) {
            if(!(test-path $dir)) { return }

            gci $dir | % {
                if($_.psiscontainer) { cleandir $_.fullname }
                else {
                    $path = $_.fullname
                    if((linksto $path $pspath) -or (linksto $path $pscorepath)) {
                        if(!(rmprops $path)) {
                            write-host "warning: admin permission is required to remove console props from $path" -f darkyellow
                        }
                    }
                }
            }
        }
    }
    process {
    }
    end {
        if(test-path hkcu:console) {
            gci hkcu:console | % {
                write-host "removing $($_.name)"
                rm "registry::$($_.name)"
            }
        }
        $dirs = @(
            "~\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar",
            "~\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell",
            "\ProgramData\Microsoft\Windows\Start Menu\Programs"
        )

        $dirs | % {	cleandir $_ }
        Write-Verbose "$($FunctionName): End."
    }
}
