# Contributing Guidelines

please run your code through one of the following linters before you commit:

- bash:
    1. install [shellcheck](https://github.com/koalaman/shellcheck) via `apt`, `brew`, `pacman`, etc.
    2. run shellcheck via `shellcheck <filename>`
- powershell:
    1. install [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) with `Install-Module -Name PSScriptAnalyzer`
    2. run via `Invoke-ScriptAnalyzer <filename>`

It's okay if you don't know how to fix the warnings that the linter throws, just write a comment
