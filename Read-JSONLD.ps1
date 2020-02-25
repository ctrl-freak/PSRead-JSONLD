Param (
    [Parameter(Mandatory=$True)][String] $File = 'organisation.json'
)

$Files = Get-ChildItem -Path '.\' -Filter '*.json'
$Data = @{}

function Get-Hash {
    Param(
        [Parameter(Mandatory=$True)][String] $String
    )

    $MD5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
    $UTF8 = New-Object -TypeName System.Text.UTF8Encoding

    Return [System.BitConverter]::ToString($MD5.ComputeHash($UTF8.GetBytes($String))) -replace '-',''
}

function Search-Data {
    Param (
        [Parameter(Mandatory=$True)][PSObject] $Branch
        ,[Parameter(Mandatory=$True)][Hashtable] $Data
    )

    $BranchKeys = ($Branch.PSObject.Properties | Select-Object -Expand Name)
    ForEach ($Key in $BranchKeys) {
        If ($Branch.$Key -is [Array]) {
            $NewTwigArray = @()
            ForEach ($Twig in $Branch.$Key) {
                $NewTwigArray += Search-Data -Branch $Twig -Data $Data
            }
            $Branch.$Key = $NewTwigArray
        } Else {
            If ($Key -eq '@id' -and $null -ne $Branch.$Key) {
                $BranchData = $Data.(Get-Hash ($Branch.$Key))
                If ($null -ne $BranchData){
                    $Branch = $BranchData
                }
            }
        }
    }

    Return $Branch
}

# Get other JSON files and store in $Data according to MD5 hash of @id
$Files | ForEach-Object {
    If ($_.Name -ne $File) {
        $JSON = Get-Content ('.\'+$_.Name) | Out-String | ConvertFrom-Json
        If ($JSON.'@id' -eq $null) {
            Write-Error -Message ('No @id in root element: '+$_.Name)
        } Else {
            $Data.(Get-Hash -String ($JSON.'@id')) = $JSON
        }
    }
}

$Root = Get-Content ($File) | Out-String | ConvertFrom-Json

$Output = Search-Data -Branch $Root -Data $Data

$Output
