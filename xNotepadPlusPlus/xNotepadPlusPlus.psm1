# https://winaero.com/blog/replace-notepad-notepad-plus-plus/
Function Initialize-NotepadPlusPlus
{
    $script:NotepadRegPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe"
    $script:nppPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\notepad++.exe").'(default)'
}

Function Enable-xNotepadPlusPlus
{
    Initialize-NotepadPlusPlus
    If (!( Test-Path -Path $NotepadRegPath ))
    {
        new-Item -Path $NotepadRegPath -Force
    }
    New-ItemProperty -Path $NotepadRegPath `
                    -Name "Debugger" `
                    -Value "$nppPath -notepadStyleCmdline -z" `
                    -PropertyType String `
                    -Force
    #reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" /v "Debugger" /t REG_SZ /d "\"%ProgramFiles%\Notepad++\notepad++.exe\" -notepadStyleCmdline -z" /f
}

Function Disable-xNotepadPlusPlus
{
    Initialize-NotepadPlusPlus
    Remove-ItemProperty -Path $NotepadRegPath `
                        -Name "Debugger" `
                        -Force
    #reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" /v "Debugger" /f
}

Function Set-NotepadPlusPlus47Zip
{
    <#
    Configure 7-zip to use Notepad++ as editor, viewer and diff

    Reference:
    https://help.github.com/articles/associating-text-editors-with-git/
    https://stackoverflow.com/questions/30395402/use-notepad-as-git-bash-editor
    #>

    Initialize-NotepadPlusPlus
    #$nppAgruments = "-multiInst -notabbar -nosession -noPlugin"
    $nppAgruments = "-multiInst -nosession"
    $editorpath = """$nppPath"" $nppAgruments"
    $regpath = "HKCU:\Software\7-Zip\FM"
    $values = @("Diff","Editor","Viewer")

    ForEach ( $value in $values)
    {
        Write-Output "Setting NPP as $value..."
        Set-ItemProperty -Path $regpath -Name $value -Value $editorpath -Force
    }

}

Export-ModuleMember -Function * -Cmdlet * -Variable *