# Simple email notification on disk error on Windows Server

How to:
1. Put PS Script and XML file in C:\Scripts
2. Import task from XML file
   The file needs to be readable by NETWORK SERVICE.  
   If you place it anywhere else; you must update the task XML file.

```powershell
Register-ScheduledTask -TaskPath "\Event Viewer Tasks" -Xml (Get-Content System_Disk.xml| out-string) -Task
Name "Disk Event Notification"
```


3. Edit PowerShell script

   Add your username, credentials etc.
