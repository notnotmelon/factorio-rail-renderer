cd $PSScriptRoot
$jobs = @()

foreach ($folder in (Get-ChildItem *.scad)) {
    Write-Host $folder.Name
    $command = "openscad -o stl --export-format binstl $folder"
    Write-Host "Running command: $command"
    $job = Start-Job -ScriptBlock { Invoke-Expression $args[0] } -ArgumentList $command
    $job.Name = $folder.Name
    $jobs += $job
}

while ($jobs.HasMoreData) {
    $completedJobs = $jobs | Where-Object { $_.State -eq 'Completed' }
    foreach ($job in $completedJobs) {
        $output = Receive-Job $job
        Write-Host $job.Name $output
        $jobs = $jobs | Where-Object { $_ -ne $job }
    }
    Start-Sleep -Milliseconds 500
}

Read-Host -Prompt "Press Enter to exit"