﻿function Convert-UserAccountControl {
    <#
    .SYNOPSIS
    Converts the UserAccountControl flags to their corresponding names.

    .DESCRIPTION
    This function takes a UserAccountControl value and converts it into a human-readable format by matching the flags to their corresponding names.

    .PARAMETER UserAccountControl
    Specifies the UserAccountControl value to be converted.

    .PARAMETER Separator
    Specifies the separator to use when joining the converted flags. If not provided, the flags will be returned as a list.

    .EXAMPLE
    Convert-UserAccountControl -UserAccountControl 66048
    Outputs: "DONT_EXPIRE_PASSWORD, PASSWORD_EXPIRED"

    .EXAMPLE
    Convert-UserAccountControl -UserAccountControl 512 -Separator ', '
    Outputs: "NORMAL_ACCOUNT"

    #>
    [cmdletBinding()]
    param(
        [alias('UAC')][int] $UserAccountControl,
        [string] $Separator
    )
    $UserAccount = [ordered] @{
        "SCRIPT"                         = 1
        "ACCOUNTDISABLE"                 = 2
        "HOMEDIR_REQUIRED"               = 8
        "LOCKOUT"                        = 16
        "PASSWD_NOTREQD"                 = 32
        "ENCRYPTED_TEXT_PWD_ALLOWED"     = 128
        "TEMP_DUPLICATE_ACCOUNT"         = 256
        "NORMAL_ACCOUNT"                 = 512
        "INTERDOMAIN_TRUST_ACCOUNT"      = 2048
        "WORKSTATION_TRUST_ACCOUNT"      = 4096
        "SERVER_TRUST_ACCOUNT"           = 8192
        "DONT_EXPIRE_PASSWORD"           = 65536
        "MNS_LOGON_ACCOUNT"              = 131072
        "SMARTCARD_REQUIRED"             = 262144
        "TRUSTED_FOR_DELEGATION"         = 524288
        "NOT_DELEGATED"                  = 1048576
        "USE_DES_KEY_ONLY"               = 2097152
        "DONT_REQ_PREAUTH"               = 4194304
        "PASSWORD_EXPIRED"               = 8388608
        "TRUSTED_TO_AUTH_FOR_DELEGATION" = 16777216
        "PARTIAL_SECRETS_ACCOUNT"        = 67108864
    }
    $Output = foreach ($_ in $UserAccount.Keys) {
        $binaryAnd = $UserAccount[$_] -band $UserAccountControl
        if ($binaryAnd -ne "0") {
            $_
        }
    }
    if ($Separator) {
        $Output -join $Separator
    } else {
        $Output
    }
}