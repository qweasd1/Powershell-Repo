Add-Type -Path D:\Repository\Refactor\Refactor\Refactor.Test\bin\Debug\Refactor.dll
function BulkInsert-ISEText
{
    param(
    
    )
}




$insert_1 = New-Object Refactor.InsertItem $functionAst.Extent.StartLineNumber,($functionAst.Extent.StartColumnNumber + 9),'New-Name'
$functionAst = findAst -type FunctionDefinition

[Refactor.RefactorUtility]::BulkInsert( $psISE.CurrentFile.Editor.Text,@($insert_1))
