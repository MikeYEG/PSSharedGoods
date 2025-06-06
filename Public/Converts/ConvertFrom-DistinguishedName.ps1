﻿function ConvertFrom-DistinguishedName {
    <#
    .SYNOPSIS
    Converts a Distinguished Name to CN, OU, Multiple OUs, DC or Container

    .DESCRIPTION
    Converts a Distinguished Name to CN, OU, Multiple OUs, DC or Container

    .PARAMETER DistinguishedName
    Distinguished Name to convert

    .PARAMETER ToOrganizationalUnit
    Converts DistinguishedName to Organizational Unit

    .PARAMETER ToMultipleOrganizationalUnit
    Converts DistinguishedName to Multiple Organizational Units

    .PARAMETER ToDC
    Converts DistinguishedName to DC

    .PARAMETER ToDomainCN
    Converts DistinguishedName to Domain Canonical Name (CN)

    .PARAMETER ToCanonicalName
    Converts DistinguishedName to Canonical Name

    .PARAMETER ToLastName
    Converts DistinguishedName to the last CN or OU part

    .PARAMETER ToContainer
    Converts DistinguishedName to its parent container

    .PARAMETER ToFQDN
    Converts DistinguishedName to Fully Qualified Domain Name (FQDN)
    This will only work for very specific cases, and will not really convert all Distinguished Names to FQDN

    .EXAMPLE
    $DistinguishedName = 'CN=Przemyslaw Klys,OU=Users,OU=Production,DC=ad,DC=evotec,DC=xyz'
    ConvertFrom-DistinguishedName -DistinguishedName $DistinguishedName -ToOrganizationalUnit

    Output:
    OU=Users,OU=Production,DC=ad,DC=evotec,DC=xyz

    .EXAMPLE
    $DistinguishedName = 'CN=Przemyslaw Klys,OU=Users,OU=Production,DC=ad,DC=evotec,DC=xyz'
    ConvertFrom-DistinguishedName -DistinguishedName $DistinguishedName

    Output:
    Przemyslaw Klys

    .EXAMPLE
    ConvertFrom-DistinguishedName -DistinguishedName 'OU=Users,OU=Production,DC=ad,DC=evotec,DC=xyz' -ToMultipleOrganizationalUnit -IncludeParent

    Output:
    OU=Users,OU=Production,DC=ad,DC=evotec,DC=xyz
    OU=Production,DC=ad,DC=evotec,DC=xyz

    .EXAMPLE
    ConvertFrom-DistinguishedName -DistinguishedName 'OU=Users,OU=Production,DC=ad,DC=evotec,DC=xyz' -ToMultipleOrganizationalUnit

    Output:
    OU=Production,DC=ad,DC=evotec,DC=xyz

    .EXAMPLE
    $Con = @(
        'CN=Windows Authorization Access Group,CN=Builtin,DC=ad,DC=evotec,DC=xyz'
        'CN=Mmm,DC=elo,CN=nee,DC=RootDNSServers,CN=MicrosoftDNS,CN=System,DC=ad,DC=evotec,DC=xyz'
        'CN=e6d5fd00-385d-4e65-b02d-9da3493ed850,CN=Operations,CN=DomainUpdates,CN=System,DC=ad,DC=evotec,DC=xyz'
        'OU=Domain Controllers,DC=ad,DC=evotec,DC=pl'
        'OU=Microsoft Exchange Security Groups,DC=ad,DC=evotec,DC=xyz'
    )

    ConvertFrom-DistinguishedName -DistinguishedName $Con -ToLastName

    Output:
    Windows Authorization Access Group
    Mmm
    e6d5fd00-385d-4e65-b02d-9da3493ed850
    Domain Controllers
    Microsoft Exchange Security Groups

    .EXAMPLE
    ConvertFrom-DistinguishedName -DistinguishedName 'DC=ad,DC=evotec,DC=xyz' -ToCanonicalName
    ConvertFrom-DistinguishedName -DistinguishedName 'OU=Users,OU=Production,DC=ad,DC=evotec,DC=xyz' -ToCanonicalName
    ConvertFrom-DistinguishedName -DistinguishedName 'CN=test,OU=Users,OU=Production,DC=ad,DC=evotec,DC=xyz' -ToCanonicalName

    Output:
    ad.evotec.xyz
    ad.evotec.xyz\Production\Users
    ad.evotec.xyz\Production\Users\test

    .EXAMPLE
    ConvertFrom-DistinguishedName -DistinguishedName 'CN=Users,DC=ad,DC=evotec,DC=xyz' -ToContainer
    ConvertFrom-DistinguishedName -DistinguishedName 'CN=Group Policy Creator Owners,CN=Users,DC=ad,DC=evotec,DC=xyz' -ToContainer
    ConvertFrom-DistinguishedName -DistinguishedName 'CN=Admin,OU=Servers,DC=ad,DC=evotec,DC=xyz' -ToContainer
    ConvertFrom-DistinguishedName -DistinguishedName 'OU=Servers,DC=ad,DC=evotec,DC=xyz' -ToContainer

    Output:
    CN=Users,DC=ad,DC=evotec,DC=xyz
    CN=Users,DC=ad,DC=evotec,DC=xyz
    OU=Servers,DC=ad,DC=evotec,DC=xyz
    OU=Servers,DC=ad,DC=evotec,DC=xyz

    .NOTES
    General notes
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(ParameterSetName = 'ToOrganizationalUnit')]
        [Parameter(ParameterSetName = 'ToMultipleOrganizationalUnit')]
        [Parameter(ParameterSetName = 'ToDC')]
        [Parameter(ParameterSetName = 'ToDomainCN')]
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'ToLastName')]
        [Parameter(ParameterSetName = 'ToCanonicalName')]
        [Parameter(ParameterSetName = 'ToFQDN')]
        [Parameter(ParameterSetName = 'ToContainer')]
        [alias('Identity', 'DN')][Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)][string[]] $DistinguishedName,
        [Parameter(ParameterSetName = 'ToOrganizationalUnit')][switch] $ToOrganizationalUnit,
        [Parameter(ParameterSetName = 'ToMultipleOrganizationalUnit')][alias('ToMultipleOU')][switch] $ToMultipleOrganizationalUnit,
        [Parameter(ParameterSetName = 'ToMultipleOrganizationalUnit')][switch] $IncludeParent,
        [Parameter(ParameterSetName = 'ToDC')][switch] $ToDC,
        [Parameter(ParameterSetName = 'ToDomainCN')][switch] $ToDomainCN,
        [Parameter(ParameterSetName = 'ToLastName')][switch] $ToLastName,
        [Parameter(ParameterSetName = 'ToCanonicalName')][switch] $ToCanonicalName,
        [Parameter(ParameterSetName = 'ToContainer')][switch] $ToContainer,
        [Parameter(ParameterSetName = 'ToFQDN')][switch] $ToFQDN
    )
    process {
        foreach ($Distinguished in $DistinguishedName) {
            if ($ToDomainCN) {
                $DN = $Distinguished -replace '.*?((DC=[^=]+,)+DC=[^=]+)$', '$1'
                $CN = $DN -replace ',DC=', '.' -replace "DC="
                if ($CN) {
                    $CN
                }
            } elseif ($ToOrganizationalUnit) {
                <#
                .SYNOPSIS
                Extracts the organizational unit part from a Distinguished Name.

                .DESCRIPTION
                For objects with OU in the path, finds and returns the first OU and everything after it.
                For objects with only CN parts, returns everything after the first CN.
                For objects that are already OUs, returns the original DN.
                #>
                if ($Distinguished -match '.*?(OU=.+)$') {
                    # If the DN contains an OU part, return that part (first OU and everything after)
                    $matches[1]
                } elseif ($Distinguished -match '^CN=[^,\\]+(?:\\,[^,\\]+)*,(.+)$') {
                    # No OU found, but DN starts with CN - return everything after first CN
                    $matches[1]
                } elseif ($Distinguished -match '^(OU=|CN=)') {
                    # Return full string if it starts with OU= or if nothing else matched
                    $Distinguished
                }
            } elseif ($ToMultipleOrganizationalUnit) {
                <#
                .SYNOPSIS
                Extracts multiple organizational unit paths from a Distinguished Name.

                .DESCRIPTION
                Returns an array of organizational unit paths representing each level in the distinguished name.
                - Without IncludeParent: Skips the parent OU level if the input is already an OU
                - With IncludeParent: Includes the original DN as the first element
                Focuses only on OU parts, ignoring CN containers (unless part of the parent DN).
                #>
                # Split the DN by unescaped commas
                $Parts = $Distinguished -split '(?<!\\),'

                # Create results collection
                $Results = [System.Collections.ArrayList]::new()

                # Add parent if requested
                if ($IncludeParent) {
                    $null = $Results.Add($Distinguished)
                }

                # Find the first DC part
                $DCIndex = $Parts.Count - 1
                for ($i = 0; $i -lt $Parts.Count; $i++) {
                    if ($Parts[$i] -match '^DC=') {
                        $DCIndex = $i
                        break
                    }
                }

                # Determine starting index for processing
                # If input starts with OU= and -IncludeParent isn't specified, skip the first OU
                $StartIndex = if ($Parts[0] -match '^OU=' -and -not $IncludeParent) {
                    1  # Skip first OU part without IncludeParent
                } else {
                    if ($Parts[0] -match '^CN=') {
                        0  # For CN objects, process all parts
                    } else {
                        1  # Default starting index
                    }
                }

                # Extract all OU paths by joining from each OU part to the end
                # Skip the parts we've determined should be skipped
                for ($i = $StartIndex; $i -lt $DCIndex; $i++) {
                    # Only process if this part is an OU
                    if ($Parts[$i] -match '^OU=') {
                        $null = $Results.Add(($Parts[$i..$Parts.Count]) -join ',')
                    }
                }

                # Return all results that start with OU=
                $Results | Where-Object { $_ -match '^OU=' }
            } elseif ($ToDC) {
                $Value = $Distinguished -replace '.*?((DC=[^=]+,)+DC=[^=]+)$', '$1'
                if ($Value) {
                    $Value
                }
            } elseif ($ToLastName) {
                $NewDN = $Distinguished -split ",DC="
                if ($NewDN[0].Contains(",OU=")) {
                    [Array] $ChangedDN = $NewDN[0] -split ",OU="
                } elseif ($NewDN[0].Contains(",CN=")) {
                    [Array] $ChangedDN = $NewDN[0] -split ",CN="
                } else {
                    [Array] $ChangedDN = $NewDN[0]
                }
                if ($ChangedDN[0].StartsWith('CN=')) {
                    $ChangedDN[0] -replace 'CN=', ''
                } else {
                    $ChangedDN[0] -replace 'OU=', ''
                }
            } elseif ($ToCanonicalName) {
                $Domain = $null
                $Rest = $null
                foreach ($O in $Distinguished -split '(?<!\\),') {
                    if ($O -match '^DC=') {
                        $Domain += $O.Substring(3) + '.'
                    } else {
                        $Rest = $O.Substring(3) + '\' + $Rest
                    }
                }
                if ($Domain -and $Rest) {
                    $Domain.Trim('.') + '\' + ($Rest.TrimEnd('\') -replace '\\,', ',')
                } elseif ($Domain) {
                    $Domain.Trim('.')
                } elseif ($Rest) {
                    $Rest.TrimEnd('\') -replace '\\,', ','
                }
            } elseif ($ToContainer) {
                <#
                .SYNOPSIS
                Extracts the parent container from a Distinguished Name.

                .DESCRIPTION
                For objects within containers (like "CN=Object,CN=Container,..."), returns the container part.
                For objects within OU containers (like "CN=Object,OU=Container,..."), returns the OU container.
                For container objects directly under the domain (like "CN=Users,DC=..."), returns the full DN.
                For organizational units (like "OU=Container,DC=..."), returns the OU itself.
                #>
                if ($Distinguished -match '^(?:CN|OU)=[^,\\]+(?:\\,[^,\\]+)*,(((?:CN|OU)=[^,\\]+(?:\\,[^,\\]+)*,)+(?:DC=.+))$') {
                    # This is an object within a container, return the parent container part
                    $matches[1]
                } else {
                    # Either this is already a container directly under domain or another type
                    # Return the original DN
                    $Distinguished
                }
            } elseif ($ToFQDN) {
                if ($Distinguished -match '^CN=(.+?),(?:(?:OU|CN).+,)*((?:DC=.+,?)+)$') {
                    $cnPart = $matches[1] -replace '\\,', ','
                    $dcPart = $matches[2] -replace 'DC=', '' -replace ',', '.'
                    "$cnPart.$dcPart"
                } elseif ($Distinguished -match '^CN=(.+?),((?:DC=.+,?)+)$') {
                    $cnPart = $matches[1] -replace '\\,', ','
                    $dcPart = $matches[2] -replace 'DC=', '' -replace ',', '.'
                    "$cnPart.$dcPart"
                }
            } else {
                $Regex = '^CN=(?<cn>.+?)(?<!\\),(?<ou>(?:(?:OU|CN).+?(?<!\\),)+(?<dc>DC.+?))$'
                $Found = $Distinguished -match $Regex
                if ($Found) {
                    $Matches.cn
                }
            }
        }
    }
}