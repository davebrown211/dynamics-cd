# SOURCE
# https://github.com/seanmcne/Microsoft.Xrm.Data.PowerShell.Samples/issues/11#issuecomment-196157404
# --------------------------------------------------------------------------------------------------------

PARAM
(
    [parameter(Mandatory=$true)]$path
)

#Import-Module Microsoft.Xrm.Data.Powershell -DisableNameChecking
$ServerUrl = "https://amherst123.crm.dynamics.com"
$OrganizationName = "amherst123"
$SecurePassword = [Microsoft.Xrm.Tooling.Connector.CrmServiceClient]::MakeSecureString("_-zDt4F,+kt5)WD")
$Credentials = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList "dbrown@amherst123.onmicrosoft.com", $SecurePassword
$conn = Get-CrmConnection –ServerUrl $ServerUrl -Credential $Credentials -OrganizationName $OrganizationName
if ($conn.IsReady)
{
    $message = $("Connected to CRM organization: {0} - {1}" -f $conn.ConnectedOrgFriendlyName, $conn.ConnectedOrgVersion)
    Write-Output -InputObject $message
}
else
{
    Exit;
}

# Read WebResource
$file = "";
$position = $path.IndexOf("new_");
if($position -ge 0 ) {
    $file = $path.Substring($position);
    $file = $file.Replace('\', '/');
}
else {
    $message = $("File '{0}' has bad name! Rename webresource and try again." -f $path)
    Write-Output -InputObject $message
    Exit;
}
$wr = Get-CrmRecords -conn $conn -EntityLogicalName webresource name like $file -Fields name,content
if ($wr.Count -eq 0 ) {
    $message = $("Web resource '{0}' not found! Create it and try again." -f $file)
    Write-Output -InputObject $message
    Exit;
}
# Read javascript file
if($path.StartsWith("new_") -eq $false)
{
    $position = $path.LastIndexOf("new_");
    if($position -gt 0)
    {
        $file = $path.Substring($position);
        $file = $file.Replace('\', '/');
    }
}
$content = [System.IO.File]::ReadAllBytes($path);
$content64 = [System.Convert]::ToBase64String($content);
if ($content64 -ne $wr.CrmRecords[0].content) {
    Write-Host "Update it!"
    $wr.CrmRecords[0].content = $content64;
    Set-CrmRecord -conn $conn $wr.CrmRecords[0];
    Publish-CrmAllCustomization -conn $conn;
}
else {
    $message = $("Web resource '{0}' is Up to date!" -f $file)
    Write-Output -InputObject $message
    Exit;
}