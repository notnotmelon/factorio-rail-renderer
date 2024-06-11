cd $PSScriptRoot

foreach ($folder in (Get-ChildItem *.scad)) {
    if ($folder.Name -ne 'generator.scad') {
        Write-Host $folder.Name
        $output = "$($folder.BaseName).stl"
        $command = "openscad -o $output --export-format binstl $folder"
        Write-Host "Running command: $command"
        Invoke-Expression $command
    }
}

Read-Host -Prompt "Press Enter to exit"