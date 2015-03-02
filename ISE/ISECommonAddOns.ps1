#dependency:
,"D:\Repository\Powershell\ISE\ISEBasicCmdlets.ps1"

function comment
{
    $selectedLines = (Get-ISESelectedText) -split $RegexNewLine

    $result = $selectedLines | Select-String -Pattern "^\s*#"
    if ($result)
    {
        # has comment
        $noCommentLines = $selectedLines | %{$_ -replace "^\s*#",""}

        $noCommentText = $noCommentLines -join $NewLine

        Insert-ISEText $noCommentText
    }
    else
    {
        # no comment
        $commentLines = $selectedLines | %{ if($_ -notmatch "^\s*$") {"#$_"}else{$_} }
        $commentText = $commentLines -join $NewLine

        Insert-ISEText $commentText
    }
    
}


#12
#22
#33