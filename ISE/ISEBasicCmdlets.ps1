#select section in current file
function Select-CurrentFile
{
   param(
   $StartLineNumber,
   $StartColumnNumber,
   $EndLineNumber,
   $EndColumnNumber
   )
   
   $psISE.CurrentFile.Editor.Select($StartLineNumber,$StartColumnNumber,$EndLineNumber,$EndColumnNumber)
   
}


#select input PSAst in current file
function Select-PSAst
{
   param(
   [Parameter(ValueFromPipeline=$true)]
   [System.Management.Automation.Language.Ast]$PsAst
   )
   Write-Verbose "StartLineNumber : $($PsAst.Extent.StartLineNumber)"
   Write-Verbose "StartColumnNumber : $($PsAst.Extent.StartColumnNumber)"
   Write-Verbose "EndLineNumber : $($PsAst.Extent.EndLineNumber)"
   Write-Verbose "EndColumnNumber : $($PsAst.Extent.EndColumnNumber)"

   $psISE.CurrentFile.Editor.Select($PsAst.Extent.StartLineNumber,$PsAst.Extent.StartColumnNumber, $PsAst.Extent.EndLineNumber,$PsAst.Extent.EndColumnNumber)
}




