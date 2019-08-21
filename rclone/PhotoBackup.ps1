## Backup Photos to OneDrive

.\rclone.exe copy E:\Shares\Pictures\ remote-onedrive-personal:Backup/Photos_HOME-NAS/current --backup-dir "remote-onedrive-personal:Backup/Photos_HOME-NAS/$(Get-Date -Format "yyyyMMdd-HHmmss")" --progress