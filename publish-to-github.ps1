$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$gitDir = Join-Path $root "github-gitdir"
$remoteUrl = "https://github.com/sdmidas-sudo/midas-homepage-upload.git"

Set-Location -LiteralPath $root

Copy-Item -LiteralPath (Join-Path $root "insert-success.html") -Destination (Join-Path $root "index.html") -Force

if (!(Test-Path $gitDir)) {
  git --git-dir=$gitDir --work-tree=$root init
  git --git-dir=$gitDir --work-tree=$root branch -M main
  git --git-dir=$gitDir --work-tree=$root remote add origin $remoteUrl
}

git --git-dir=$gitDir --work-tree=$root config user.name "sdmidas-sudo"
git --git-dir=$gitDir --work-tree=$root config user.email "sdmidas-sudo@users.noreply.github.com"

$remotes = git --git-dir=$gitDir --work-tree=$root remote
if ($remotes -notcontains "origin") {
  git --git-dir=$gitDir --work-tree=$root remote add origin $remoteUrl
}

git --git-dir=$gitDir --work-tree=$root add index.html insert-success.html assets .gitignore publish-to-github.ps1

$pending = git --git-dir=$gitDir --work-tree=$root status --porcelain
if (!$pending) {
  Write-Host "No changes to publish."
  exit 0
}

$stamp = Get-Date -Format "yyyy-MM-dd HH:mm"
git --git-dir=$gitDir --work-tree=$root commit -m "Update homepage $stamp"
git --git-dir=$gitDir --work-tree=$root push origin main
