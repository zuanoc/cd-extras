cd-extras
===

* [What is it?](#what-is-it)
  * [Navigation helpers](#navigation-helpers)
  * [AUTO_CD](#auto_cd)
  * [CD_PATH](#cd_path)
  * [CDABLE_VARS](#cdable_vars)
  * [Path expansion](#path_expansion)
  * [No argument cd](#no-argument-cd)
  * [Two argument cd](#two-argument-cd)
  * [Additional helpers](#additional-helpers)
* [Get started](#get-started)
  * [Install](#install)
  * [Configure](#configure)

What is it?
==========
general conveniences for the `cd` command in PowerShell inspired by bash and zsh

Navigation helpers
---------

Provides the following aliases (and functions):

* cd- (Undo-Location)
* cd+ (Redo-Location)
* cd: (Switch-LocationPart)
* up, .. (Step-Up)

Examples:

```sh

[C:\Windows\System32]> up # or ..
[C:\Windows]> cd-
[C:\Windows\System32]> cd+
[C:\Windows]> _
```

Note that the aliases are `cd-` and `cd+` *not* `cd -` and `cd +`.
Repeated uses of `cd-` will keep moving backwards towards the beginning of the stack
rather than toggling between the two most recent directories as in vanilla bash.

Each of these functions except `cd:` takes an optional parameter, `n`,
used to specify the number of levels or locations to traverse.

```sh

[C:\Windows\System32]> .. 2 # or `up 2`
[C:\]> cd temp
[C:\temp]> cd- 2
[C:\Windows\System32]> cd+ 2
[C:\temp]> _
```

The `Step-Up` (`up`, `..`) function alternatively supports passing a string parameter
to change to the first ancestor directory which contains the given string.

```sh

[C:\Windows\System32\drivers\etc]> up win # or `.. win`
[C:\Windows]> _
```

When the [AUTO_CD](#auto_cd) option is enabled, multiple dot syntax for `up` is supported
as an alternative to `up [n]` or `.. [n]`.

```sh

[C:\Windows\System32\drivers\etc]> ... # same as `up 2` or `.. 2`
[C:\Windows\System32]> cd-
[C:\Windows\System32\drivers\etc>] .... # same as `up 3` or `.. 3`
[C:\Windows]> _
```

The `Export-Up` (`xup`) function recursively expands each parent path into a global variable
with a corresponding name. Why? It can be useful for navigating a deeply nested folder structure without
needing to count `..`s. For example:

```sh

[C:\projects\powershell\src\Modules\Unix]> Export-Up

Name                           Value
----                           -----
Unix                           C:\temp\powershell\src\Modules\Unix
Modules                        C:\temp\powershell\src\Modules
src                            C:\temp\powershell\src
powershell                     C:\temp\powershell
temp                           C:\temp

[C:\projects\powershell\src\Modules\Unix]> cd $p<[Tab]>
[C:\projects\powershell\src\Modules\Unix]> cd $powershell/<[Tab]>
[C:\projects\powershell\src\Modules\Unix]> cd C:\projects\powershell\<[Tab]>
.git     .github  .vscode  assets   demos    docker   docs     src      test     tools
‾‾‾‾‾‾‾‾
```

is likely easier than:

```sh

[C:\projects\powershell\src\Modules\Unix]> cd ../../../<[Tab]>
[C:\projects\powershell\src\Modules\Unix]> cd C:\projects\powershell\
.git     .github  .vscode  assets   demos    docker   docs     src      test     tools
‾‾‾‾‾‾‾‾
```

When combined with the [CDABLE_VARS](#cdable_vars) option, it's even easier.

```sh

[C:\projects\powershell\src\Modules\Unix]> cd pr<[Tab]>
[C:\projects\powershell\src\Modules\Unix]> cd C:\projects\
```

AUTO_CD
-------

Change directory without typing `cd`.

```sh

[~]> projects
[~/projects]> cd-extras
[~/projects/cd-extras]> ..
[~/projects]> _
```

CD_PATH
--------

Search additional locations for candidate directories.

```sh

[~]> $cde.CD_PATH += '~/documents'
[~]> cd WindowsPowerShell
[~/documents/WindowsPowerShell]> _
```

Note that CD_PATHs are _not_ searched when an absolute or relative path is given.

```sh

[~]> $cde.CD_PATH += '~/documents'
[~]> cd ./WindowsPowerShell
Set-Location : Cannot find path '~\WindowsPowerShell' because it does not exist.
```

CDABLE_VARS
-----------

Save yourself a `$` and cd directly into folders using a variable name instead of a folder path.
Given a variable containing the path to a folder (configured, for example, in your `$PROFILE`
or by first invoking `Export-Up`), you can cd into it using the name of the variable.

```sh
[~]> $power = '~/projects/powershell'
[~]> cd power
[~/projects/powershell]> _

```

This also works with relative paths so if you find yourself frequently `cd`ing into the same
subdirectories you could create a corresponding variable.

```sh
[~/projects/powershell]> $gh = './.git/hooks'
[~/projects/powershell]> cd gh
[~/projects/powershell/.git/hooks]> _

```


Path expansion
-----------

`cd` will provide tab expansions by expanding all path segments so that
you don't have to individually tab through each one.

```sh

[~]> cd /w/s/set<[Tab]><[Tab]>
C:\Windows\System32\setup\  C:\Windows\SysWOW64\setup\
                            ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
```

Periods (`.`) are expanded around so a segment containing `.sdk` is expanded into `*.sdk*`.

```sh

[~]> cd proj/pow/s/.sdk<[Tab]>
[~]> cd .\projects\powershell\src\Microsoft.PowerShell.SDK\
[~\projects\powershell\src\Microsoft.PowerShell.SDK]> cd..
[~\projects\powershell\src]> cd .SDK
[~\projects\powershell\src\Microsoft.PowerShell.SDK]> _

```

If an unambiguous match is available then `cd` can be used directly, without first invoking tab expansion.

```sh

[~]> cd /w/s/d/et<[Return]>
[C:\Windows\System32\drivers\etc]> _
```

Paths within the `$cde.CD_PATH` array will be considered for expansion.

```sh

[~]> $cde.CD_PATH += "~\Documents\"
[~]> cd win/mod
[~\Documents\WindowsPowerShell\Modules]> _
```

No argument cd
----------

If the option `$cde.NOARG_CD` is defined then `cd` with no arguments
will change to the nominated directory. Defaults to `'~'`.

```sh

[C:\Windows\System32\]> cd
[~]> _
```

Two argument cd
----------

Replaces all instances of the first argument in the current path with the second argument,
changing to the resulting directory if it exists. Uses the `Switch-LocationPart` (`cd:`) function.

```sh

[~\Modules\Unix\Microsoft.PowerShell.Utility]> cd unix shared
[~\Modules\Shared\Microsoft.PowerShell.Utility]> _
```

Additional helpers
---------

* Show-Stack: view contents of undo (`cd-`) and redo (`cd+`) stacks
* Get-Up: get the path of an ancestor directory, either by name or by traversing upwards n levels
* Expand-Path: helper used for path segment expansion
* Set-CdExtrasOption: enable or disable `AUTO_CD`, etc. after the module has loaded

Get started
=======

Install
-------

```sh

Install-Module cd-extras
Import-Module cd-extras

# add to profile by hand or:
Add-Content $PROFILE @("`n", "Import-Module cd-extras")
```

Configure
--------

Four options are currently provided:

* AUTO_CD: `[bool] = $true`
  * Any truthy value will enable auto_cd.
* CD_PATH: `[array] = @()`
  * Paths to be searched by cd and tab expansion. This is an array, not a delimited string.
* NOARG_CD: `[string] = '~'`
  * If specified, `cd` command with no arguments will change to this directory.
* Completable: `[array] = @('Push-Location', 'Set-Location', 'Get-ChildItem')`
  * Commands that participate in advanced tab expansion.

Either create a global hashtable, `cde`, with one or more of these keys _before_ importing the cd-extras module:

```sh

$global:cde = @{
  AUTO_CD = $false
  CD_PATH = @('~\Documents\')
  NOARG_CD = '/',
  Completable = @('Set-Location)
}

Import-Module cd-extras
```

or call the `Set-CdExtrasOption` function after importing the module:

```sh
Import-Module cd-extras
Set-CdExtrasOption -Option AUTO_CD -Value $false
Set-CdExtrasOption -Option NOARG_CD -Value '~'
```