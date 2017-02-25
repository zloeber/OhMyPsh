Describe 'Testing against PSSA rules' {
    Context 'PSSA Standard Rules' {
        $analysis = Invoke-ScriptAnalyzer -Path  '.\MyScript.ps1'
        $scriptAnalyzerRules = Get-ScriptAnalyzerRule
        forEach ($rule in $scriptAnalyzerRules) {
            It "Should pass $rule" {
                If ($analysis.RuleName -contains $rule) {
                    $analysis | Where RuleName -EQ $rule -outvariable failures | Out-Default
                    $failures.Count | Should Be 0
                }
            }
        }
    }
}