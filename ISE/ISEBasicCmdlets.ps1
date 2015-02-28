#Dependency

Add-Type -AssemblyName Microsoft.VisualBasic

#------------------- Select Section
#select section in current file
#select 
function Select-ISEText
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
function Select-ISEPSAst
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

#---------------- Caret section

function Get-Caret
{
    [pscustomobject]@{LineNumber = $psISE.CurrentFile.Editor.CaretLine;ColumnNumber=$psISE.CurrentFile.Editor.CaretColumn}    
}

#----------------

#---------------- insert section
function Insert-ISEText
{
   param(
   [Parameter(ValueFromPipeline=$true)]
   [string]$newText
   )

   $psISE.CurrentFile.Editor.InsertText($newText)
}




#--------------------------------

#---------------- replace section

function Replace-ISEText
{
   param(
   [Parameter(ValueFromPipeline=$true)]
   [string]$newText,
   [int]$StartLineNumber,
   [int]$StartColumnNumber,
   [int]$EndLineNumber,
   [int]$EndColumnNumber
   )
   Select-ISEText $StartLineNumber $StartColumnNumber $EndLineNumber $EndColumnNumber
   $psISE.CurrentFile.Editor.InsertText($newText)
}

#-----------------------

#---------------delete

function Delete-ISEText
{
    param(
    [Parameter(ParameterSetName="PsAst")]
    [System.Management.Automation.Language.Ast]$PsAst,
    [Parameter(ParameterSetName="Position")]
    [int]$StartLineNumber,
    [Parameter(ParameterSetName="Position")]
    [int]$StartColumnNumber,
    [Parameter(ParameterSetName="Position")]
    [int]$EndLineNumber,
    [Parameter(ParameterSetName="Position")]
    [int]$EndColumnNumber
    )
    switch ($PSCmdlet.ParameterSetName)
    {
        'PsAst' {
            $PsAst | Select-ISEPSAst
            Insert-ISEText ""
        }
        
        'Position' {
            Replace-ISEText "" $StartLineNumber $StartColumnNumber $EndLineNumber $EndColumnNumber       
        }
        Default {}
    }
    
}

#--------------------

   
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

function Show-MessageBox
{
   param(
   $Title = "Information",
   $Description = "This is a Information"
   )
   [System.Windows.MessageBox]::Show($Description,$Title)
}



#----------------------- format

function Format-ISEText
{
    param(
    [string]$originText,
    [int]$StartColumn = 1,
    [string]$RowDelimiter = "\r\n",
    [string]$NewRowDelimieter = "`r`n"
    )
    [string]$indent = " " * ($StartColumn - 1)
    $firstRow,$rest = ($originText -split $RowDelimiter)
    $firstRow + $NewRowDelimieter + (( $rest| %{ "${indent}$_"}) -join $NewRowDelimieter)
}
            
#------------------------