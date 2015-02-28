#Dependency

Add-Type -AssemblyName Microsoft.VisualBasic

#------------------- Select Section
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

#---------------- select section


#---------------- replace section

function Replace-SelectText
{
   param(
   [Parameter(ValueFromPipeline=$true)]
   [string]$newText
   )

   $psISE.CurrentFile.Editor.InsertText($newText)
}



#------------------ InterAction

# Show an InputBox
# Default return is string.Empty
function Show-InputBox
{
   param(
   $Title = "Please Input",
   $Description = "Please Input"
   )
   [Microsoft.VisualBasic.Interaction]::InputBox($Description,$Title)
}

