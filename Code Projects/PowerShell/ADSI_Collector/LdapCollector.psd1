@{
    ModuleVersion = '1.0.0'
    GUID = '12345678-1234-1234-1234-123456789abc'
    Author = 'NeonSamurai'
    Description = 'A module for interacting with Active Directory using LDAP and the ADSI Directory Services.'
    CompanyName = ''
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Get-DomainADSI',
        'Get-ADUser',
        'Get-ADGroup',
        'Get-ADComputer',
        'Get-ADGroupMember',
        'Get-ADUserGroups',
        'Get-ADUserProperties',
        'Get-ADGroupProperties',
        'Get-ADComputerProperties',
        'Get-AllComputer',
        'Get-AllUser',
        'Get-AllGroup',
        'Get-AllGroupPolicy',
        'Get-CollectionData'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
}