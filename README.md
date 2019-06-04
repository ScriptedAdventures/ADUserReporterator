#ADUserReporterator.ps1

Requirements: 
- Run on Domain Controller, or computer with ADTools installed
- You will need to set your SearchBase (this should be the top level OU for your User Accounts ie. OU=Users,OU=Corp,DC=SA,DC=local. You can find this by locating the OU where all your users fall under, and finding the distinguishedName attribute (you will need Advanced Features enabled in Active Directory Users and Computers) )

Currently, the following attributes are reported on:
- User OU
- Account DisplayName
- Account SamAccountName
- Account Email Address (if no email, entry reads "No Email Address")
- Account Created
- Account Last Logon
- Account Password Last Changed
- Account Lockout Status
- Account Active (shows if account is disabled)