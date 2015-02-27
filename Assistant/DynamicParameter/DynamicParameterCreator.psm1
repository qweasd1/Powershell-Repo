#将所有的脚本改为只有不为空时才运行
#TODO: 增加ValidateAttribute
#TODO：增加New-XXX的Alias



## 如果要使用dynamic Parameter你必须具具备以下几个条件：
    # 1.param上面要有[cmdletbinding()]
    # 2.RuntimeDefinedParameter 的Attribute中必须有一个ParameterAttribute（已在代码中检查此点） 

#？ 假设有两个dynamic parameter 当输入一个dynamic Parameter时，在输入第二个parameter时能否捕获第一个dynamic parameter的值。并由捕获值来约束第二个

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
   $attr
}

function New-ValidateSet
{
    param(
    [array]$enums
    )
    New-Object System.Management.Automation.ValidateSetAttribute $enums
}


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

        function New-ValidateSet
        {
            param(
            [array]$validValues
            )
            $validateSet =  New-Object System.Management.Automation.ValidateSetAttribute $validValues
            $attributeCollection.Add($validateSet)
        }


       if($ParameterAttributeScript){ & $ParameterAttributeScript}

       if (-not($attributeCollection| ?{$_ -is [System.Management.Automation.ParameterAttribute]}))
       {
           $attributeCollection.Add((New-ParameterAttribute))
       }

        $dynParameter = New-Object System.Management.Automation.RuntimeDefinedParameter  $parameterName,$parameterType,$attributeCollection
        
        $runtimeDefinedParameterDictionary.Add($parameterName, $dynParameter)
    }
  & $RuntimeDefinedParamtersBlock
  
  $runtimeDefinedParameterDictionary
}


