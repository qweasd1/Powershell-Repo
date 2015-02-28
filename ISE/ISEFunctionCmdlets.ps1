# when you want fresh a function's definition:
# put your caret inside the definition of the function, press "ctrl+shift+space"



## Module require:
#FunctionCmdletDomainModel.dll
Add-Type -Path D:\Repository\Powershell\ISE\FunctionCmdletDomainModel\FunctionCmdletDomainModel\bin\Debug\FunctionCmdletDomainModel.dll

# PSAstCore.ps1
## TODO: how to load the module
#Import-Module PSAstCore.ps1
# TODO: ISEBasicCmdlets.ps1



#------------------------initialization
$Script:funcInfoRepo = New-Object PSCore.PSFunctionInfoRepository

#TODO: use Template file to replace this hard code
$script:newFunctionTemplate = @"
"function `$inputFuncName
{
    param(

    )

}"
"@

#-------------------------


 
## TODO List:
#TODO: ctrl+shift+f: create a new function
#TODO: ctrl+shift+d: delete a new function
#TODO: ctrl+shift+n: rename an existing function
#TODO: ctrl+shift+h: switch a function but not delete the history of the function
    #TODO: ctrl+shift+m: iterate a function's key part in intelligence
#TODO: ctrl+shift+z: move back to a former version
#TODO: ctrl+shift+x: move forward to a new version

#------------------------helper functions
function Get-CurrentFunctionAst
{
    [outputType([System.Management.Automation.Language.FunctionDefinitionAst])]
    param(
    )
   $currentAst = New-PsAst -text $psISE.CurrentFile.Editor.Text
   $caretLineNumber = $psISE.CurrentFile.Editor.CaretLine
   $caretColumNumber = $psISE.CurrentFile.Editor.CaretColumn

   $functionAst =  ($currentAst | findAst -type FunctionDefinition -Depth Last -contains $caretLineNumber,$caretColumNumber)
   $functionAst
}

#--------------------------------------------------------

#---------------------------- add-on
# Run and record function Definition
$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Intelligence Run Function Definition", {
    $functionAst = (Get-CurrentFunctionAst)  
    if ($functionAst -ne $null)
    {
        #run function definition
        Invoke-Expression ($functionAst.ToString())
    }

 },"ctrl+shift+space")  

# Create function Definition
#TODO: when function already exist please redirect to that function
#TODO: when you are already in an function and this function has not add to repository, please add it, 
#      if it already in Repository, show message error
$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("new function", {
    $funcAst = Get-CurrentFunctionAst
    if ($funcAst -eq $null)
    {
        $inputFuncName = Show-InputBox -Title "new function" -Description "please enter new funtion name"
        if ($inputFuncName -ne "")
        {
            if ($funcInfoRepo.HasFunction($inputFuncName))
            {
                throw "function has already exist!"
            }
            else
            {
                $newFuncDefinition = Invoke-Expression $script:newFunctionTemplate
                $funcInfoRepo.NewFunction($inputFuncName,$newFuncDefinition)

                $caretPos = Get-Caret
                $formattedNewFuncDefinition = Format-ISEText $newFuncDefinition -StartColumn $caretPos.ColumnNumber           
                Insert-ISEText $formattedNewFuncDefinition
            }          

        }
    }
    else
    {
        Show-MessageBox -Title "waring" -Description "you are in an function. Now we don't support record function in the body of another function"
    }
},"ctrl+shift+f")

#delete function: when you are in a function definition, when you press ctrl+shift+d,
#                 if the function is in repo, pop up a window to ask if delete it along with its history
#                 if the function is not in repo, delete it silently
#TODO 1: when the caret not in a function definition, show GridView with all functions in current file and delete the selected
$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("delete function",{
$funcAst = Get-CurrentFunctionAst
if ($funcAst -ne $null)
{
    $funcName =  $funcAst.Name

    #delete history
    if ($funcInfoRepo.HasFunction($funcName))
    {
        [System.Windows.MessageBoxResult]$result = Show-MessageBox -Title "Delete Function" -Description "This is function with history. `r`nIf you delete it, it will also delete the history"
        if ($result -eq [System.Windows.MessageBoxResult]::Yes)
        {
            $funcInfoRepo.Delete($funcName)                      
        }
    }

    Delete-ISEText -PsAst $funcAst 
}
else
{
    #TODO 1 
}
},"ctrl+shift+alt+d")   




