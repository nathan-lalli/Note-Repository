<#
.SYNOPSIS
This script provides functions to interact with Active Directory using LDAP. 
Using only the ADSI Search/Diretory services functionality.
It allows for querying users, groups, and computers in the directory.

.DESCRIPTION
This script contains several functions that utilize the System.DirectoryServices namespace to interact with Active Directory.

.PARAMETER <ParameterName>
Describes the purpose and usage of a specific parameter. Repeat this section for each parameter in the script or function.

.EXAMPLE
Provides an example of how to use the script or function, including input and expected output. Repeat this section for multiple examples if necessary.

.INPUTS
Specifies the types of input objects that the script or function accepts, if applicable.

.OUTPUTS
Specifies the types of output objects that the script or function produces, if applicable.

.NOTES
Includes any additional information, such as author name, creation date, or version history.

.LINK
Provides references to related scripts, functions, or online documentation.

.AUTHOR
NeonSamurai
#>

function Get-DomainADSI {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Domain
    )

    # Create a DirectoryEntry object for the specified domain
    $domainEntry = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$Domain")
    
    # Return the DirectoryEntry object
    return $domainEntry
}
function Get-ADUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Username
    )

    # Create a DirectorySearcher object to search for the user
    $searcher = New-Object System.DirectoryServices.DirectorySearcher
    $searcher.Filter = "(&(objectClass=user)(sAMAccountName=$Username))"
    
    # Perform the search and return the result
    return $searcher.FindOne()
}
function Get-ADGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$GroupName
    )

    # Create a DirectorySearcher object to search for the group
    $searcher = New-Object System.DirectoryServices.DirectorySearcher
    $searcher.Filter = "(&(objectClass=group)(sAMAccountName=$GroupName))"
    
    # Perform the search and return the result
    return $searcher.FindOne()
}
function Get-ADComputer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName
    )

    # Create a DirectorySearcher object to search for the computer
    $searcher = New-Object System.DirectoryServices.DirectorySearcher
    $searcher.Filter = "(&(objectClass=computer)(sAMAccountName=$ComputerName))"
    
    # Perform the search and return the result
    return $searcher.FindOne()
}
function Get-ADGroupMember {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$GroupName
    )

    # Create a DirectorySearcher object to search for the group
    $searcher = New-Object System.DirectoryServices.DirectorySearcher
    $searcher.Filter = "(&(objectClass=group)(sAMAccountName=$GroupName))"
    
    # Perform the search and get the group object
    $group = $searcher.FindOne()
    
    # Check if the group was found
    if ($group -eq $null) {
        Write-Error "Group '$GroupName' not found."
        return
    }
    # Get the members of the group
    $members = $group.GetDirectoryEntry().Invoke("Members")
    $memberList = @()
    foreach ($member in $members) {
        $memberList += $member.GetDirectoryEntry()
    }
    # Return the list of members
    return $memberList
}
function Get-ADUserGroups {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Username
    )

    # Create a DirectorySearcher object to search for the user
    $searcher = New-Object System.DirectoryServices.DirectorySearcher
    $searcher.Filter = "(&(objectClass=user)(sAMAccountName=$Username))"
    
    # Perform the search and get the user object
    $user = $searcher.FindOne()
    
    # Check if the user was found
    if ($user -eq $null) {
        Write-Error "User '$Username' not found."
        return
    }
    # Get the groups the user is a member of
    $groups = $user.GetDirectoryEntry().Invoke("MemberOf")
    $groupList = @()
    foreach ($group in $groups) {
        $groupList += $group.GetDirectoryEntry()
    }
    # Return the list of groups
    return $groupList
}
function Get-ADUserProperties {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Username
    )

    # Create a DirectorySearcher object to search for the user
    $searcher = New-Object System.DirectoryServices.DirectorySearcher
    $searcher.Filter = "(&(objectClass=user)(sAMAccountName=$Username))"
    
    # Perform the search and get the user object
    $user = $searcher.FindOne()
    
    # Check if the user was found
    if ($user -eq $null) {
        Write-Error "User '$Username' not found."
        return
    }
    # Return the properties of the user
    return $user.Properties
}
function Get-ADGroupProperties {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$GroupName
    )

    # Create a DirectorySearcher object to search for the group
    $searcher = New-Object System.DirectoryServices.DirectorySearcher
    $searcher.Filter = "(&(objectClass=group)(sAMAccountName=$GroupName))"
    
    # Perform the search and get the group object
    $group = $searcher.FindOne()
    
    # Check if the group was found
    if ($group -eq $null) {
        Write-Error "Group '$GroupName' not found."
        return
    }
    # Return the properties of the group
    return $group.Properties
}

function Get-ADComputerProperties {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName
    )

    # Create a DirectorySearcher object to search for the computer
    $searcher = New-Object System.DirectoryServices.DirectorySearcher
    $searcher.Filter = "(&(objectClass=computer)(sAMAccountName=$ComputerName))"
    
    # Perform the search and get the computer object
    $computer = $searcher.FindOne()
    
    # Check if the computer was found
    if ($computer -eq $null) {
        Write-Error "Computer '$ComputerName' not found."
        return
    }
    # Return the properties of the computer
    return $computer.Properties
}

function Get-AllComputer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Domain
    )

    # Create a DirectorySearcher object to search for all computers
    $searcher = New-Object System.DirectoryServices.DirectorySearcher
    $searcher.Filter = "(&(objectClass=computer))"
    
    # Perform the search and return the results
    return $searcher.FindAll()
}

function Get-AllUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Domain
    )

    # Create a DirectorySearcher object to search for all users
    $searcher = New-Object System.DirectoryServices.DirectorySearcher
    $searcher.Filter = "(&(objectClass=user))"
    
    # Perform the search and return the results
    return $searcher.FindAll()
}
function Get-AllGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Domain
    )

    # Create a DirectorySearcher object to search for all groups
    $searcher = New-Object System.DirectoryServices.DirectorySearcher
    $searcher.Filter = "(&(objectClass=group))"
    
    # Perform the search and return the results
    return $searcher.FindAll()
}
function Get-AllGroupPolicy {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Domain
    )

    # Create a DirectorySearcher object to search for all group policies
    $searcher = New-Object System.DirectoryServices.DirectorySearcher
    $searcher.Filter = "(&(objectClass=groupPolicyContainer))"
    
    # Perform the search and return the results
    return $searcher.FindAll()
}
function Get-CollectionData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Domain,
        [Parameter(Mandatory = $true)]
        [string]$OutputFile
    )

    # Initialize a hashtable to store all data
    $data = @{
        Users       = @()
        Computers   = @()
        Groups      = @()
        Policies    = @()
        Objects     = @()
        Certificates = @()
    }

    # Helper function to convert search results to a hashtable
    function Convert-SearchResultToHashtable {
        param([System.DirectoryServices.SearchResult]$SearchResult)
        $result = @{}
        foreach ($property in $SearchResult.Properties.PropertyNames) {
            $result[$property] = $SearchResult.Properties[$property]
        }
        return $result
    }

    # Get all users
    $userSearcher = New-Object System.DirectoryServices.DirectorySearcher
    $userSearcher.Filter = "(&(objectClass=user))"
    $userResults = $userSearcher.FindAll()
    foreach ($user in $userResults) {
        $data.Users += Convert-SearchResultToHashtable -SearchResult $user
    }

    # Get all computers
    $computerSearcher = New-Object System.DirectoryServices.DirectorySearcher
    $computerSearcher.Filter = "(&(objectClass=computer))"
    $computerResults = $computerSearcher.FindAll()
    foreach ($computer in $computerResults) {
        $data.Computers += Convert-SearchResultToHashtable -SearchResult $computer
    }

    # Get all groups
    $groupSearcher = New-Object System.DirectoryServices.DirectorySearcher
    $groupSearcher.Filter = "(&(objectClass=group))"
    $groupResults = $groupSearcher.FindAll()
    foreach ($group in $groupResults) {
        $data.Groups += Convert-SearchResultToHashtable -SearchResult $group
    }

    # Get all group policies
    $policySearcher = New-Object System.DirectoryServices.DirectorySearcher
    $policySearcher.Filter = "(&(objectClass=groupPolicyContainer))"
    $policyResults = $policySearcher.FindAll()
    foreach ($policy in $policyResults) {
        $data.Policies += Convert-SearchResultToHashtable -SearchResult $policy
    }

    # Get all objects
    $objectSearcher = New-Object System.DirectoryServices.DirectorySearcher
    $objectSearcher.Filter = "(&(objectClass=*))"
    $objectResults = $objectSearcher.FindAll()
    foreach ($object in $objectResults) {
        $data.Objects += Convert-SearchResultToHashtable -SearchResult $object
    }

    # Get all certificates
    $certificateSearcher = New-Object System.DirectoryServices.DirectorySearcher
    $certificateSearcher.Filter = "(&(objectClass=certificationAuthority))"
    $certificateResults = $certificateSearcher.FindAll()
    foreach ($certificate in $certificateResults) {
        $data.Certificates += Convert-SearchResultToHashtable -SearchResult $certificate
    }

    # Convert the data to JSON
    $jsonData = $data | ConvertTo-Json -Depth 10

    # Write the JSON data to the output file
    Set-Content -Path $OutputFile -Value $jsonData

    Write-Host "Data exported to $OutputFile in BloodHound-compatible JSON format."
}