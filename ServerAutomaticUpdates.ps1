# Configure Automatic Updates to be as automatic as possible
#
# https://support.microsoft.com/en-gb/help/328010/how-to-configure-automatic-updates-by-using-group-policy-or-registry-s
# https://www.rootusers.com/configure-automatic-updates-for-windows-server-2016/
# https://docs.microsoft.com/fr-fr/security-updates/windowsupdateservices/18127152

# 4: Automatically download and scheduled installation.
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" –Value 4
# Silently install minor updates
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AutoInstallMinorUpdates" –Value 1
# Enable Automatic Updates
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" –Value 0
# Install during automatic maintenance
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AutomaticMaintenanceEnabled" –Value 1
# Time: Every day
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "ScheduledInstallDay" –Value 0
# Time: 03:00
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "ScheduledInstallTime" –Value 3
# Install updates for other Microsoft products
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AllowMUUpdateService" –Value 1
