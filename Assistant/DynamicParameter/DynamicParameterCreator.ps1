
function New-RuntimeDefinedParameterDictionary
{
   param(
   [scriptblock]$RuntimeDefinedParamtersBlock
   )

   $runtimeDefinedParameterDictionary = New-Object Management.Automation.RuntimeDefinedParameterDictionary

   function New-RuntimeDefinedParameter
    {
       param(
       [string]$parameterType,
       [Parameter(Mandatory=$true)]
       [string]$parameterName,
       [scriptblock]$ParameterAttributeScript
       )
       $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

       function New-ParameterAttribute
        {
           param(
           [string]$ParameterSet,
           [switch]$Mandatory,
           [switch]$ValueFromPipeline
           )

           $attr = New-Object System.Management.Automation.ParameterAttribute

           if ($ParameterSet)
           {
               $attr.ParameterSetName = $ParameterSet
           }

           if($Mandatory)
           {
               $attr.Mandatory = $true
           }

           if ($ValueFromPipeline)
           {
               $attr.ValueFromPipeline = $true
           }

           $attributeCollection.Add($attr)
        }

        & $ParameterAttributeScript

        $dynParameter = New-Object System.Management.Automation.RuntimeDefinedParameter  $parameterName,$parameterType, $attributeCollection

        $runtimeDefinedParameterDictionary.Add($parameterName, $dynParameter)
    }
  & $RuntimeDefinedParamtersBlock

  $runtimeDefinedParameterDictionary
}


function New-RuntimeDefinedParameter
{ 
       param(
       [string]$parameterType,
       [Parameter(Mandatory=$true)]
       [string]$parameterName,
       [scriptblock]$ParameterAttributeScript
       )

}

function New-ParameterAttribute
{
   param(
   [string]$ParameterSet,
   [switch]$Mandatory,
   [switch]$ValueFromPipeline
   )

   $attr = New-Object System.Management.Automation.ParameterAttribute

   if ($ParameterSet)
   {
       $attr.ParameterSetName = $ParameterSet
   }

   if($Mandatory)
   {
       $attr.Mandatory = $true
   }

   if ($ValueFromPipeline)
   {
       $attr.ValueFromPipeline = $true
   }
}

function New-RuntimeDefinedParameterDictionary
{
   param(
   [scriptblock]$RuntimeDefinedParamtersBlock
   )

   $runtimeDefinedParameterBlock = New-Object Management.Automation.RuntimeDefinedParameterDictionary
}