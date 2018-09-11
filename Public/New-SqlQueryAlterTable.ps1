function New-SqlQueryAlterTable {
    [CmdletBinding()]
    param (
        [Object]$SqlSettings,
        [Object]$TableMapping,
        [string[]] $ExistingColumns
    )
    $ArraySQLQueries = New-ArrayList
    $ArrayMain = New-ArrayList
    $ArrayKeys = New-ArrayList

    foreach ($MapKey in $TableMapping.Keys) {
        if ($ExistingColumns -notcontains $MapKey) {

            $MapValue = $TableMapping.$MapKey

            $Field = $MapValue -Split ','
            if ($Field.Count -eq 1) {
                Add-ToArray -List $ArrayKeys -Element "[$($Field[0])] [nvarchar](max) NULL"
            } elseif ($Field.Count -eq 2) {
                Add-ToArray -List $ArrayKeys -Element "[$($Field[0])] $($Field[1]) NULL"
            } elseif ($Field.Count -eq 3) {
                Add-ToArray -List $ArrayKeys -Element "[$($Field[0])] $($Field[1]) $($Field[2])"
            }

            <#
        $MapValue = $TableMapping.$MapKey
        if ($FieldValue -is [DateTime]) {
            Add-ToArray -List $ArrayKeys -Element "[$MapValue] [DateTime] NULL"
        } elseif ($FieldValue -is [int] -or $FieldValue -is [Int64]) {
            Add-ToArray -List $ArrayKeys -Element "[$MapValue] [bigint] NULL"
        } elseif ($FieldValue -is [bool]) {
            Add-ToArray -List $ArrayKeys -Element "[$MapValue] [bit] NULL"
        } else {
            Add-ToArray -List $ArrayKeys -Element "[$MapValue] [nvarchar](max) NULL"
        }
        #>
        }
    }

    if ($ArrayKeys) {
        Add-ToArray -List $ArrayMain -Element "ALTER TABLE $($SqlSettings.SqlTable) ADD"
        Add-ToArray -List $ArrayMain -Element ($ArrayKeys -join ',')
        Add-ToArray -List $ArrayMain -Element ';'
        Add-ToArray -List $ArraySQLQueries -Element ([string] ($ArrayMain) -replace "`n", "" -replace "`r", "")
    }
    return $ArraySQLQueries
}