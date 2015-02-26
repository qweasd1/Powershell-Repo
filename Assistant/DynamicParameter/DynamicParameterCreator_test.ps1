
function tt
{
New-Object System.Management.Automation.ParameterAttribute `
        -Property @{
        ParameterSetName = "set1"
        }
}

function dynamicParameterExample
{
    [cmdletbinding()]
    param (
    [String]$name,
    [String]$path
    )
    dynamicparam
    {
    
        
        $attributeCollection = New-Object `
        System.Collections.ObjectModel.Collection[System.Attribute]
        $attributeCollection.Add($attributes)
        $dynParam1 = New-Object `
        System.Management.Automation.RuntimeDefinedParameter `
        dp1,int, $attributeCollection
        $paramDictionary = New-Object `
        Management.Automation.RuntimeDefinedParameterDictionary
        $paramDictionary.Add("dp1", $dynParam1)
        
        $paramDictionary
    
    }
end { $psboundparameters }

}



function dynamicParameterExample
{
    [cmdletbinding()]
    param (
    [String]$name,
    [String]$path
    )
    dynamicparam
    {
    
         New-RuntimeDefinedParameterDictionary {
           New-RuntimeDefinedParameter -parameterName dp1 -parameterType int {
                New-ParameterAttribute -ParameterSet tt1
           }

           New-RuntimeDefinedParameter -parameterName dp2 -parameterType int {
                New-ParameterAttribute -ParameterSet tt1
           }
        }
    
        
    
    }
end { $psboundparameters }

}

