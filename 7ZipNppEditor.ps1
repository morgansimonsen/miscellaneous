<#
Configure 7-zip to use Notepad++ as editor, viewer and diff

Reference:
https://help.github.com/articles/associating-text-editors-with-git/
https://stackoverflow.com/questions/30395402/use-notepad-as-git-bash-editor
#>

$nppPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\notepad++.exe").'(default)'
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
