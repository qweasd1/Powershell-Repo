New-IseSnippet -Title "fn" -Description "create new function" -Text @"
function Name
{
   
}
"@ -CaretOffset 9

New-IseSnippet -Title "fn-p" -Description "create new function" -Text @"
function Name
{
   param(

   )

}
"@ -CaretOffset 9

New-IseSnippet -Title "fn-p-dy" -Description "create new function with 'param' block and 'dynamicparam' block" -Text @"
function Name
{
    [cmdletbinding()]
    param(

    )

    dynamicparam {
        New-RuntimeDefinedParameterDictionary {
            New-RuntimeDefinedParameter string Name {
                
            }
        }
    }
}
"@ -CaretOffset 9

New-IseSnippet -Title "vs" -Description "ValidatSet Attribute" -Text "[ValidateSet()]" -CaretOffset 13
New-IseSnippet -Title "p" -Description "Parameter Attribute" -Text "[Parameter()]" -CaretOffset 11
New-IseSnippet -Title "p-vfp" -Description "Parameter Attribute + ValueFromPipeline" -Text "[Parameter(ValueFromPipeline=`$true)]" -CaretOffset 34
#New-IseSnippet -Title  "pos" -Description "Position Property" -Text "Position"



