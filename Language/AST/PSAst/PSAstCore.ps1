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
   [string]$text,
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

# 修改ancestor参数为[switch]，统一使用$type来指定类型

function find
{
    [OutputType([System.Management.Automation.Language.Ast])]
    param(
    [Parameter(ValueFromPipeline=$true)]
    [System.Management.Automation.Language.Ast]$PsAst,
    [switch]$Only,
    [ValidateSet("ArrayExpression", "ArrayLiteral", "AssignmentStatement", "Attribute", "AttributeBase", "AttributedExpression", "BinaryExpression", "BlockStatement", "BreakStatement", "CatchClause", "Command", "CommandBase", "CommandElement", "CommandExpression", "CommandParameter", "ConstantExpression", "ContinueStatement", "ConvertExpression", "DataStatement", "DoUntilStatement", "DoWhileStatement", "ErrorExpression", "ErrorStatement", "ExitStatement", "ExpandableStringExpression", "Expression", "FileRedirection", "ForEachStatement", "ForStatement", "FunctionDefinition", "Hashtable", "IfStatement", "IndexExpression", "InvokeMemberExpression", "LabeledStatement", "LoopStatement", "MemberExpression", "MergingRedirection", "NamedAttributeArgument", "NamedBlock", "ParamBlock", "Parameter", "ParenExpression", "Pipeline", "PipelineBase", "Redirection", "ReturnStatement", "ScriptBlock", "ScriptBlockExpression", "Statement", "StatementBlock", "StringConstantExpression", "SubExpression", "SwitchStatement", "ThrowStatement", "TrapStatement", "TryStatement", "TypeConstraint", "TypeExpression", "UnaryExpression", "UsingExpression", "VariableExpression", "WhileStatement")]
    [Parameter(ParameterSetName="type")]
    [string]$Type,
    [Parameter(ParameterSetName="predicate")]
    [scriptblock]$Predicate,
    [Parameter(ParameterSetName="ancestor")]
    [ValidateSet("ArrayExpression", "ArrayLiteral", "AssignmentStatement", "Attribute", "AttributeBase", "AttributedExpression", "BinaryExpression", "BlockStatement", "BreakStatement", "CatchClause", "Command", "CommandBase", "CommandElement", "CommandExpression", "CommandParameter", "ConstantExpression", "ContinueStatement", "ConvertExpression", "DataStatement", "DoUntilStatement", "DoWhileStatement", "ErrorExpression", "ErrorStatement", "ExitStatement", "ExpandableStringExpression", "Expression", "FileRedirection", "ForEachStatement", "ForStatement", "FunctionDefinition", "Hashtable", "IfStatement", "IndexExpression", "InvokeMemberExpression", "LabeledStatement", "LoopStatement", "MemberExpression", "MergingRedirection", "NamedAttributeArgument", "NamedBlock", "ParamBlock", "Parameter", "ParenExpression", "Pipeline", "PipelineBase", "Redirection", "ReturnStatement", "ScriptBlock", "ScriptBlockExpression", "Statement", "StatementBlock", "StringConstantExpression", "SubExpression", "SwitchStatement", "ThrowStatement", "TrapStatement", "TryStatement", "TypeConstraint", "TypeExpression", "UnaryExpression", "UsingExpression", "VariableExpression", "WhileStatement")]
    [string]$AncestorType,
    [Parameter(ParameterSetName="contains")]
    [int]$LineNumber,
    [Parameter(ParameterSetName="contains")]
    [int]$ColumnNumber
    )
    switch ($PSCmdlet.ParameterSetName)
    {
        'type' {
            $PsAst.FindAll({$args[0] -is $Name_Ast_map[$Type]},$true)
        }
        'predicate' {
            $PsAst.FindAll($predicate,$true)
        }    
        'ancestor'  {
            if ($Only)
            {
                if($PsAst.Parent -eq $null)
                {
                    return $null
                }

                if ($PsAst.Parent -isnot $Name_Ast_map[$AncestorType])
                {
                    find -PsAst $PsAst.Parent -AncestorType $AncestorType
                }

                return $PsAst.Parent
            }
            else
            {
                #TODO: find all Ast
            }
           
        }
        'contains'{
            $PsAst.FindAll({
                $extent = $args[0].Extent
                ($LineNumber -ge $extent.StartLineNumber) -and ($LineNumber -le $extent.EndLineNumber)
            },$true)
        }
        Default {}
    }
    
}

#? 从管道中输入一个数组，却只返回一个单值，这时为什么？
function which
{
    param(
    [Parameter(ValueFromPipeline=$true)]
    $PsAsts,
    [ValidateSet("ArrayExpression", "ArrayLiteral", "AssignmentStatement", "Attribute", "AttributeBase", "AttributedExpression", "BinaryExpression", "BlockStatement", "BreakStatement", "CatchClause", "Command", "CommandBase", "CommandElement", "CommandExpression", "CommandParameter", "ConstantExpression", "ContinueStatement", "ConvertExpression", "DataStatement", "DoUntilStatement", "DoWhileStatement", "ErrorExpression", "ErrorStatement", "ExitStatement", "ExpandableStringExpression", "Expression", "FileRedirection", "ForEachStatement", "ForStatement", "FunctionDefinition", "Hashtable", "IfStatement", "IndexExpression", "InvokeMemberExpression", "LabeledStatement", "LoopStatement", "MemberExpression", "MergingRedirection", "NamedAttributeArgument", "NamedBlock", "ParamBlock", "Parameter", "ParenExpression", "Pipeline", "PipelineBase", "Redirection", "ReturnStatement", "ScriptBlock", "ScriptBlockExpression", "Statement", "StatementBlock", "StringConstantExpression", "SubExpression", "SwitchStatement", "ThrowStatement", "TrapStatement", "TryStatement", "TypeConstraint", "TypeExpression", "UnaryExpression", "UsingExpression", "VariableExpression", "WhileStatement")]
    [Parameter(ParameterSetName="type")]
    [string]$Type
    )
    
   
    $PsAsts
}



$t = {$t = 1}.Ast