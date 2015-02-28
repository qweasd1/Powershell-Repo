# when you want fresh a function's definition:
# put your caret inside the definition of the function, press "ctrl+shift+space"



## Module require:
#FunctionCmdletDomainModel.dll
Add-Type -Path D:\Repository\Powershell\ISE\FunctionCmdletDomainModel\FunctionCmdletDomainModel\bin\Debug\FunctionCmdletDomainModel.dll

# PSAstCore.ps1
. "D:\Repository\Powershell\ISE\ISEBasicCmdlets.ps1"
. "D:\Repository\Powershell\Language\AST\PSAst\PSAstCore.ps1"
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
#TODO: ctrl+shift+space: run and record function to repo
 
#Case: ctrl+shift+f: create a new function
#Case: ctrl+shift+d: delete a new function
    #TODO: ctrl+shift+n: rename an existing function
#Case: ctrl+shift+h: switch a function but not delete the history of the function
    #TODO: ctrl+shift+m: iterate a function's key part in intelligence
#Case: ctrl+shift+z: move back to a former version
#Case: ctrl+shift+x: move forward to a new version

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
# Record function Definition(ctrl+shift+space)
# TODO
$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Record Function Definition", {
    $funcAst = Get-CurrentFunctionAst  
    
    if ($funcAst -ne $null)
    {
        $funcName = $funcAst.Name
        $funcDeinitionText = $funcAst.ToString()
        if ($funcInfoRepo.HasFunction($funcName))
        {
            $funcInfoRepo.Record($funcName,$funcDeinitionText)
        }
        #run function definition
        Invoke-Expression ($funcDeinitionText)
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




# Hide function(ctrl+shift+h): 
# When you are in a function you can choose make the current function hide in repo
# When you are in blank

#TODO 1: when the function you are in not a function in repo, you can ask user whether they want to add it into the repo
#TODO 2: when you are not in function, a GridView will show. You can show the function you want
#Case 3: If there is only one function hidden, you can immediately show it, no need to show the GridView

$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("hide/show function", {
    $funcAst = Get-CurrentFunctionAst
    if ($funcAst -ne $null)
    {
        $funcName = $funcAst.Name
        if ($funcInfoRepo.HasFunction($funcName))
        {
            $funcInfoRepo.Hide($funcName)
            Delete-ISEText -PsAst $funcAst
        }
        else
        {
            Show-MessageBox "information" "you can first added it"
            #TODO 1
        }
    }
    else
    {
        $hiddenFuncNames = $funcInfoRepo.GetHiddinFunctions()
        
        if (($hiddenFuncNames.Count) -eq 0)
        {
            Show-MessageBox -Description "no hidden function"
        }
        #Case 3
        elseif       
        (($hiddenFuncNames.Count) -eq 1)
        {
            $onlyHiddenFuncName = $hiddenFuncNames[0]           

            Insert-ISEText ($funcInfoRepo.Show($onlyHiddenFuncName))
        }
        else
        {
            $allHiddenFuncDefinitionTexts = $hiddenFuncNames | %{ $funcInfoRepo.GetCurrentByFuncName($_) }
            BulkInsert-ISEText $allHiddenFuncDefinitionTexts
        }
    }

}, "ctrl+shift+h")

# Bulk Hidden(ctrl+shift+alt+h): 
# when you select an area, you want to hidden all these functions
$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("bulk hidden", {

    $selectFunctions = $psISE.CurrentFile.Editor.SelectedText | New-PsAst |  findAst -type FunctionDefinition

    if ($selectFunctions.count -ne $null)
    {
        $recordedSelectedFuncNames = $selectFunctions |
        select -ExpandProperty Name | 
        ? { $Script:funcInfoRepo.HasFunction($_)}
    }

    

    
},"ctrl+shift+alt+h")

# Rollback function(ctrl+shift+z):
# when you are in function, you can roll back it to the snapshot you just save
# TODO 1: if the function is not in repo, ask user whether they want to record it

$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("rollback function", {
    $funcAst = Get-CurrentFunctionAst
    if ($funcAst -ne $null)
    {
        $funcName = $funcAst.Name
        if ($Script:funcInfoRepo.HasFunction($funcName))
        {
            try
            {
               $previousText = $funcInfoRepo.Rollback($funcName)
               Replace-ISEText -newText $previousText -PsAst $funcAst
            }          
            catch 
            {
                Show-MessageBox -Description "this is the first version"
            }            
        }
        else
        {
            #TODO 1
        }
    }
}, "ctrl+shift+z")


# Redo function(ctrl+shift+x):
# when you are in function, you can redo it to the snapshot you just save
# TODO 1: if the function is not in repo, ask user whether they want to record it

$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("redo function", {
    $funcAst = Get-CurrentFunctionAst
    if ($funcAst -ne $null)
    {
        $funcName = $funcAst.Name
        if ($Script:funcInfoRepo.HasFunction($funcName))
        {
            try
            {
               $nextText = $funcInfoRepo.Redo($funcName)
               Replace-ISEText -newText $nextText -PsAst $funcAst
            }          
            catch 
            {
                Show-MessageBox -Description "this is the latest version"
            }            
        }
        else
        {
            #TODO 1
        }
    }
}, "ctrl+shift+x")
