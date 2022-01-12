# Contributing Guidelines

*If you're on the team: please don't push to master directly. Create a new branch and make a pull request.*

please run your code through the appropriate linter before you commit:

- bash:
    1. install [shellcheck](https://github.com/koalaman/shellcheck) via `apt`, `brew`, `pacman`, etc.
    2. run shellcheck via `shellcheck <filename>`
- powershell:
    1. install [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) with `Install-Module -Name PSScriptAnalyzer`
    2. run via `Invoke-ScriptAnalyzer <filename>`
- markdown (optional):
    1. install [markdownlint](https://github.com/igorshubovych/markdownlint-cli)
    2. run via `markdownlint <filename>`

It's okay if you don't know how to fix the warnings that the linter throws, just write a comment in the code or on your commit
