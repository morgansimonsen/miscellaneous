Remove-Item "C:\Program Files\Google\Chrome" -recurse -force
Remove-Item $env:USERPROFILE\AppData\Local\Google -recurse -force

& 'C:\Users\morga\OneDrive\PortableApps\SetACL\64 bit\SetACL.exe' -on "HKEY_LOCAL_MACHINE\SOFTWARE\Google" -ot reg -actn setowner -ownr "n:Administrators" -rec cont_obj
& 'C:\Users\morga\OneDrive\PortableApps\SetACL\64 bit\SetACL.exe' -on "HKEY_LOCAL_MACHINE\SOFTWARE\Google" -ot reg -actn ace -ace "n:Administrators;p:full" -rec cont_obj

Remove-Item HKCU:\Software\Google\ -Recurse -Force
Remove-Item HKLM:\Software\Google\ -Recurse -Force
