Get-Project -Domain Midas,CRM -Project IndexOption -Environment st,ua,pp,pr,dv,pv

function Template-Function
{
    param(
    $t
    )

}

$names = dir * | select Name

$funcDefinition = template function {
    template param {
        template para Project -validateSet $projects
        template para Domain -validateSet $domains
        template para IsShow -switch
    }
    
    template switch $names
        
}

Invoke-Expression -Command $funcDefinition


template