<#
.Synposis

Get users stats from Active Directory
This version groups by OU, using canonical name
#>

<#
.AUTHOR
Matthew Russell
matthew.russell@scriptedadventures.net
www.scriptedadventures.net

matthew.russell@boujeesoft.com
www.boujeesoft.com

#>

<#
.LICENSE
MIT License
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

Import-Module ActiveDirectory

$Table = @()
$PreTable = @()

$Record = [Ordered] @{
    "Users OU"         = ""
    "Full Name"        = ""
    "User Name"        = ""
    "Email Address"    = ""
    "Created"          = ""
    "Last Logon"       = ""
    "Password Changed" = ""
    "Locked Out"       = ""
    "Account Active"   = ""
}
$OutPath = "C:\Temp\ADUserReporterator\"
IF (!(Test-Path $OutPath)) {
    New-Item -ItemType Directory -Path $OutFile
}
$RunDate = Get-Date -Format ddMMyyHHmm
$OutFile = $OutPath + "ADUserReporterator" + $RunDate + ".csv"

$topLevelSearchBase = "<insert your top level User OU here. ie. OU=Users,OU=Corp,DC=SA,DC=local>"

$AllUserOUs = Get-ADOrganizationalUnit -Filter * -Searchbase $topLevelSearchBase | Select -ExpandProperty DistinguishedName | Sort

foreach ($OU in $AllUserOUs) {
    $Users = Get-ADUser -Filter * -Searchbase $OU -SearchScope OneLevel | Select -ExpandProperty SamAccountName 
    foreach ($User in $Users) {
        $Account = Get-ADUser -Identity $User -Properties *
        $AccountOU = $Account.CanonicalName
        $AccountOU = Split-Path $AccountOU
        $AccountOU = Split-Path $AccountOU -Leaf
        $Record["Users OU"] = $AccountOU
        $Record["Full Name"] = $Account.DisplayName
        $Record["User Name"] = $Account.SamAccountName
        if ($Account.EmailAddress -eq $NULL) {
            $Record["Email Address"] = "No Email Address"
        }
        else {
            $Record["Email Address"] = $Account.EmailAddress
        }
        $Record["Created"] = $Account.whenCreated
        if ($Account.LastLogonDate -eq $NULL){
            $Record["Last Logon"] = "No Logon Date Recorded"
        }
        else {
            $Record["Last Logon"] = $Account.LastLogonDate
        }
        $Record["Password Changed"] = $Account.PasswordLastSet
        $Record["Locked Out"] = $Account.LockedOut
        $Record["Account Active"] = $Account.Enabled
        $objRecord = New-Object PSObject -Property $Record
        $Table += $objRecord
    }
}
$Table | Export-CSV -Path $($OutFile) -NoClobber -NoTypeInformation