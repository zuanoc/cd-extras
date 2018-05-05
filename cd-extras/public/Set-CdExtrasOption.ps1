<#
.SYNOPSIS
Update cd-extras option ('AUTO_CD' or 'CD_PATH')

.PARAMETER Option
The option to set

.PARAMETER Value
The option value

.EXAMPLE
PS C:\> Set-CdExtrasOption -Option AUTO_CD -Value $false

.EXAMPLE
PS C:\> Set-CdExtrasOption -Option CD_PATH -Value @('/temp')
#>
function Set-CdExtrasOption {

  [CmdletBinding()]
  param (
    [ValidateSet(
      'AUTO_CD',
      'CD_PATH',
      'NOARG_CD')]
    $Option,
    $Value)

  $Global:cde.$option = $value

  $Script:fwd = 'forward'
  $Script:back = 'back'

  $helpers = @{
    raiseLocation = {Step-Up @args}
    setLocation = {SetLocationEx @args}
    expandPath = {Expand-Path @args}
    transpose = {Switch-LocationPart @args}
    isUnderTest = {$Global:__cdeUnderTest -and !($Global:__cdeUnderTest = $false)}
  }

  $commandsToComplete = @('Push-Location', 'Set-Location')
  $commandsToAutoExpand = @('cd', 'Set-Location')
  RegisterArgumentCompleter $commandsToComplete
  PostCommandLookup $commandsToAutoExpand $helpers

  if ($cde.AUTO_CD) {
    CommandNotFound @(AutoCd $helpers) $helpers
  }
  else {
    CommandNotFound @() $helpers
  }
}