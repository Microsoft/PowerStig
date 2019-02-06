#region Header
$rules = Get-RuleClassData -StigData $stigData -Name IisLoggingRule
#endregion Header

#region Resource
if ($rules)
{
    $logFlags = Get-UniqueStringArray -InputObject $rules.LogFlags -AsString
    $logFormat = Get-UniqueString -InputObject $rules.LogFormat
    $logCustomField = Get-LogCustomField -LogCustomField $rules.LogCustomFieldEntry.Entry -Resource 'xIisLogging'

    $resourceTitle = "[$($rules.id -join ' ')]"

    $scriptBlock = [scriptblock]::Create("
        xIisLogging '$resourceTitle'
        {
            LogPath         = '$LogPath'
            LogFlags        = @($logFlags)
            LogFormat       = '$logFormat'
            LogCustomFields = @($logCustomField)
        }"
    )

    & $scriptBlock
}
#endregion Resource
