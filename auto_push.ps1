<#
================================================================================
 Auto Git Push Script for D:\avi\sql
 Target Branch: mcc_sql (Remote: origin)
 
 Functionality:
 - Monitors D:\avi\sql recursively for new files, folders, and modifications.
 - Automatically tracks newly created empty folders by creating a .gitkeep.
 - Debounces rapid edits (waiting 3 seconds after the last file change).
 - Formats commit message: "<file_name> - yyyy-MM-dd HH:mm:ss"
 - Ensures current branch is 'mcc_sql' and pushes to 'origin mcc_sql'.
================================================================================
#>

[CmdletBinding()]
param(
    [string]$RepoPath = "D:\avi\sql",
    [string]$Branch = "mcc_sql",
    [string]$Remote = "origin",
    [int]$DebounceSeconds = 3
)

# Set working directory to the repo folder
Set-Location -Path $RepoPath

# 1. Verification of Git repository
if (-not (Test-Path (Join-Path $RepoPath ".git"))) {
    Write-Host "[ERROR] '$RepoPath' is not a Git repository!" -ForegroundColor Red
    exit 1
}

# 2. Check and switch to the target branch 'mcc_sql'
$currentBranch = (git branch --show-current).Trim()
if ($currentBranch -ne $Branch) {
    Write-Host "[INFO] Currently on branch '$currentBranch'. Switching to '$Branch'..." -ForegroundColor Cyan
    git checkout $Branch
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Failed to switch to branch '$Branch'. Please check your repository branches." -ForegroundColor Red
        exit 1
    }
}

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "         AUTO GIT PUSH SERVICE RUNNING                   " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host " Monitoring Path : $RepoPath" -ForegroundColor White
Write-Host " Target Branch   : $Branch (not main)" -ForegroundColor Cyan
Write-Host " Remote Target   : $Remote" -ForegroundColor White
Write-Host " Debounce Time   : $DebounceSeconds seconds" -ForegroundColor White
Write-Host " Started At      : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "==========================================================" -ForegroundColor Green
Write-Host " Press [Ctrl + C] in this window at any time to stop." -ForegroundColor Yellow
Write-Host ""

# Function to commit and push changes
function Invoke-AutoPush {
    # Step A: Check for empty folders and add .gitkeep so Git can track them
    $emptyDirs = Get-ChildItem -Path $RepoPath -Directory -Recurse | Where-Object { 
        $_.FullName -notmatch '[\\/]\.git' -and (Get-ChildItem -Path $_.FullName -Force).Count -eq 0 
    }
    foreach ($dir in $emptyDirs) {
        $keepFile = Join-Path $dir.FullName ".gitkeep"
        if (-not (Test-Path $keepFile)) {
            New-Item -Path $keepFile -ItemType File -Force | Out-Null
        }
    }

    # Step B: Check git status
    $statusOutput = git status --porcelain
    if ([string]::IsNullOrWhiteSpace($statusOutput)) {
        return
    }

    # Step C: Parse modified / created / deleted files from status
    $statusLines = $statusOutput -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    $changedItems = @()

    foreach ($line in $statusLines) {
        if ($line.Length -ge 3) {
            $rawPath = $line.Substring(3).Trim()
            # Handle renames e.g. "old.sql -> new.sql"
            if ($rawPath -match "->") {
                $rawPath = ($rawPath -split "->")[-1].Trim()
            }
            # Remove surrounding quotes and normalize slashes
            $cleanPath = $rawPath.Trim('"').Replace('\', '/')

            # If it's a folder's .gitkeep, represent as folder name
            if ($cleanPath -match "^(.+)/\.gitkeep$") {
                $changedItems += $Matches[1]
            } else {
                $changedItems += $cleanPath
            }
        }
    }

    $changedItems = @($changedItems | Select-Object -Unique)

    if ($changedItems.Count -eq 0) {
        return
    }

    # Step D: Construct commit message
    $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    if ($changedItems.Count -eq 1) {
        $commitMsg = "$($changedItems[0]) - $now"
    } elseif ($changedItems.Count -le 3) {
        $commitMsg = "$($changedItems -join ', ') - $now"
    } else {
        $firstTwo = ($changedItems | Select-Object -First 2) -join ', '
        $remaining = $changedItems.Count - 2
        $commitMsg = "$firstTwo (+$remaining files) - $now"
    }

    Write-Host "----------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "[$now] Changes detected in: $($changedItems -join ', ')" -ForegroundColor Cyan
    Write-Host "[$now] Staging changes (git add -A)..." -ForegroundColor Gray
    git add -A

    Write-Host "[$now] Committing: '$commitMsg'..." -ForegroundColor Gray
    git commit -m $commitMsg

    if ($LASTEXITCODE -eq 0) {
        Write-Host "[$now] Pushing to $Remote $Branch..." -ForegroundColor Yellow
        git push $Remote $Branch
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[$now] [SUCCESS] Pushed to $Branch successfully!" -ForegroundColor Green
        } else {
            Write-Host "[$now] [ERROR] Git push failed. Please verify network or credentials." -ForegroundColor Red
        }
    } else {
        Write-Host "[$now] [WARNING] Commit skipped or nothing to commit." -ForegroundColor DarkYellow
    }
    Write-Host "----------------------------------------------------------`n" -ForegroundColor DarkGray
}

# 3. Setup FileSystemWatcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $RepoPath
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true
$watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName, DirectoryName, LastWrite, CreationTime'

# Register event identifiers
Register-ObjectEvent $watcher "Created" -SourceIdentifier "Watcher_Created" | Out-Null
Register-ObjectEvent $watcher "Changed" -SourceIdentifier "Watcher_Changed" | Out-Null
Register-ObjectEvent $watcher "Deleted" -SourceIdentifier "Watcher_Deleted" | Out-Null
Register-ObjectEvent $watcher "Renamed" -SourceIdentifier "Watcher_Renamed" | Out-Null

$changePending = $false
$lastEventTime = [DateTime]::MinValue
$lastPeriodicCheck = [DateTime]::UtcNow

try {
    while ($true) {
        Start-Sleep -Milliseconds 500

        # Check for FileSystemWatcher events
        $events = Get-Event | Where-Object { $_.SourceIdentifier -like "Watcher_*" }
        $hasNewEvent = $false

        if ($events.Count -gt 0) {
            foreach ($evt in $events) {
                $itemPath = $evt.SourceEventArgs.FullPath
                # Ignore .git directory internals
                if ($itemPath -and ($itemPath -like "*\.git\*" -or $itemPath -like "*\.git")) {
                    continue
                }
                $hasNewEvent = $true
            }
            $events | Remove-Event
        }

        if ($hasNewEvent) {
            $changePending = $true
            $lastEventTime = [DateTime]::UtcNow
        }

        # Periodic fallback check every 5 seconds in case of missed OS notifications
        $timeSinceCheck = ([DateTime]::UtcNow - $lastPeriodicCheck).TotalSeconds
        if (-not $changePending -and $timeSinceCheck -ge 5) {
            $lastPeriodicCheck = [DateTime]::UtcNow
            $quickStatus = git status --porcelain
            if (-not [string]::IsNullOrWhiteSpace($quickStatus)) {
                $changePending = $true
                $lastEventTime = [DateTime]::UtcNow
            }
        }

        # Debounce: wait until no new events have occurred for $DebounceSeconds
        if ($changePending) {
            $elapsedSinceEvent = ([DateTime]::UtcNow - $lastEventTime).TotalSeconds
            if ($elapsedSinceEvent -ge $DebounceSeconds) {
                $changePending = $false
                $lastPeriodicCheck = [DateTime]::UtcNow
                Invoke-AutoPush
            }
        }
    }
}
finally {
    # Unregister events and clean up watcher on exit
    Unregister-Event -SourceIdentifier "Watcher_*" -ErrorAction SilentlyContinue
    $watcher.EnableRaisingEvents = $false
    $watcher.Dispose()
    Write-Host "`nAuto Push Service has been stopped." -ForegroundColor Yellow
}
