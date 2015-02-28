﻿# when you want fresh a function's definition:
# put your caret inside the definition of the function, press "ctrl+shift+space"
 

#TODO: every time you want refresh the function, we record the snapshot of the current function

#this module require:
# PSAstCore.ps1

function Get-CurrentFunctionAst
{
   $currentAst = New-PsAst -text $psISE.CurrentFile.Editor.Text
   $caretLineNumber = $psISE.CurrentFile.Editor.CaretLine
   $caretColumNumber = $psISE.CurrentFile.Editor.CaretColumn

   $functionAst =  ($currentAst | findAst -type FunctionDefinition -Depth Last -contains $caretLineNumber,$caretColumNumber)
}

function Run-FunctionDefinition
{
    param(
    [System.Management.Automation.Language.Ast]$PsAst
    )
    Invoke-Expression $PsAst.ToString()
}



$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("run definition", {
    $functionAst = Get-CurrentFunctionAst  
    if ($functionAst -ne $null)
    {
        Run-FunctionDefinition $functionAst
    }

 },"ctrl+shift+space")  
