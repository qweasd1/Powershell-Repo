##TODO: 修改一些Name_Ast_map 中的 key 为variable, function...这些更易使用的名字。同时修改function中$type上的Validateset的对应值
$AllAstTypes = [System.Management.Automation.Language.Ast].Assembly.ExportedTypes | ?{[System.Management.Automation.Language.Ast].IsAssignableFrom($_)}
$Name_Ast_map = @{}
$AllAstTypes | foreach {
    $name = $_.Name -replace "AST$",""
    $Name_Ast_map.Add($name,$_)
}

function New-PsAst
{
   [OutputType([System.Management.Automation.Language.Ast])]
   param(
   [Parameter(ValueFromPipeline=$true)]
   [string]$text = (Get-Clipboard),
   [switch]$ShowErros
   )
   if ($ShowErros)
   {
       [ref]$errors = $null
       [System.Management.Automation.Language.Parser]::ParseInput($text,[ref]$null, $errors)
       $errors.Value
   }
   else
   {
       [System.Management.Automation.Language.Parser]::ParseInput($text,[ref]$null, [ref]$null)
   }
   
}



# 方向，从当前AST 向上找还是向下找
# 寻找的深度：第一个满足条件的，最后一个满足条件的,第几个满足条件的，第一个。
# 寻找单个还是所有
# 所找元素的类型
# 所找元素满足的环境条件
# 是否包含指定坐标（LineNumber ColumnNumber）



# 方向
# 单个还是所有
    # 单个 -> 深度
# 满足的条件（包括元素的类型，是否包含坐标，以及自定义的条件）
function Get-PsAst
{
   [outputType([System.Management.Automation.Language.Ast])]
   [cmdletbinding()]
   param(
   [Parameter(ValueFromPipeline=$true)]
   [System.Management.Automation.Language.Ast]$PsAst,
   [ValidateSet("Descent","Ancestor")]
   [string]$Direction = "Descent",
   [switch]$Single,
   [ValidateSet("First","Last")]
   [string]$Depth = "First",
   [ValidateSet("ArrayExpression", "ArrayLiteral", "AssignmentStatement", "Attribute", "AttributeBase", "AttributedExpression", "BinaryExpression", "BlockStatement", "BreakStatement", "CatchClause", "Command", "CommandBase", "CommandElement", "CommandExpression", "CommandParameter", "ConstantExpression", "ContinueStatement", "ConvertExpression", "DataStatement", "DoUntilStatement", "DoWhileStatement", "ErrorExpression", "ErrorStatement", "ExitStatement", "ExpandableStringExpression", "Expression", "FileRedirection", "ForEachStatement", "ForStatement", "FunctionDefinition", "Hashtable", "IfStatement", "IndexExpression", "InvokeMemberExpression", "LabeledStatement", "LoopStatement", "MemberExpression", "MergingRedirection", "NamedAttributeArgument", "NamedBlock", "ParamBlock", "Parameter", "ParenExpression", "Pipeline", "PipelineBase", "Redirection", "ReturnStatement", "ScriptBlock", "ScriptBlockExpression", "Statement", "StatementBlock", "StringConstantExpression", "SubExpression", "SwitchStatement", "ThrowStatement", "TrapStatement", "TryStatement", "TypeConstraint", "TypeExpression", "UnaryExpression", "UsingExpression", "VariableExpression", "WhileStatement")]
   [string]$type,
   [array]$contains,
   [scriptblock]$selfpredicate
   )

   $condition = Construct-AstPredicate -type $type -contains $contains -selfpredicate $selfpredicate
   Write-Debug $condition.ToString()
   switch ($Direction)
   {
       #向下查找
       'Descent' {
            #返回单个结果
            if ($Single)
            {
                switch ($Depth)
                {
                    'First' {
                        return $PsAst.Find($condition,$true)
                    }
                    'Last' {
                        return ($PsAst.FindAll($condition,$true) | select -Last 1)
                    }
                    Default {}
                }   
            }
            #返回多个结果
            else
            {
                return $PsAst.FindAll($condition,$true)
            }
       }
       #向上查找       
       'Ancestor' {
          switch ($Depth)
          {
              'First' {
              
                  while ($PsAst.Parent)
                  {                    
                       if((& $condition $PsAst.Parent))
                       {
                           return $PsAst.Parent
                       }
                       else
                       {
                           $PsAst = $PsAst.Parent
                       }
                  }
              }
              'Last' {
              
                 while ($PsAst.Parent)
                 {
                     if ((& $condition $PsAst.Parent))
                     {
                        Write-Debug "in loop"
                         $PsAst.Parent                         
                     }
                     $PsAst = $PsAst.Parent
                 }
              }
              Default {}
          }   
       }
       Default {}
   }
}

Set-Alias -Name findAst -Value Get-PsAst


function Construct-AstPredicate
{
    [outputtype([scriptblock])]
    param(
    [string]$type,
    [array]$contains,
    [scriptblock]$selfpredicate
    )
    $predicates = New-Object System.Collections.Generic.List[string]

    if ($type)
    {
        $type_predicate = "`$args[0] -is [$($Name_Ast_map[$type].FullName)]"
        $predicates.Add($type_predicate)
    }

    if ($contains)
    {
        $pos_predicate = "Contains-Position -psAst `$args[0] -LineNumber $($contains[0]) -ColumnNumber $($contains[1])"
        $predicates.Add($pos_predicate)
    }

    if ($selfpredicate)
    {
        $self_predicate = "$($selfpredicate.ToString())"
        $predicates.Add($self_predicate)
    }
    
    #output
    if ($predicates.Count -eq 0)
    {
        {$true}
    }
    else
    {
        $finalPredicate = ($predicates | % {"($_)" }) -join " -and "
        #$finalPredicate
        [scriptblock]::Create($finalPredicate)
    }
}

function Contains-Position
{
   param(
   [System.Management.Automation.Language.Ast]$psAst,
   [int]$LineNumber,
   [int]$ColumnNumber
   )   

   if (($psAst.Extent.StartLineNumber -lt $LineNumber) -and ($psAst.Extent.EndLineNumber -gt $LineNumber))
   {
      return $true
   }
   
   if (($psAst.Extent.StartLineNumber -gt $LineNumber) -or ($psAst.Extent.EndLineNumber -lt $LineNumber))
   {
       return $false
   }

   if ($psAst.Extent.StartLineNumber -eq $psAst.Extent.EndLineNumber)
   {
       return (($ColumnNumber -ge $psAst.Extent.StartColumnNumber) -and ($ColumnNumber -le $psAst.Extent.EndColumnNumber))
   }

   if ($psAst.Extent.StartLineNumber -eq $LineNumber)
   {
       return ($ColumnNumber -ge $psAst.Extent.StartColumnNumber)
   }
   if ($psAst.Extent.EndLineNumber -eq $LineNumber)
   {
       return ($ColumnNumber -le $psAst.Extent.EndColumnNumber)
   }
}

# Which 用来构造PsAst的Predicate条件（scriptblock）
#  
function which
{
   [OutputType([scriptblock])]
   param(
   [Parameter(ValueFromPipeline=$true)]
   $PsAst
   )
   

}


