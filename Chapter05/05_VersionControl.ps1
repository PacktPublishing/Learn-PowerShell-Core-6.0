# Everything starts with an empty repo
mkdir MyNewRepository
cd MyNewRepository
git init

# Use git status to find out more
git status

# Add a new file
New-Item NewScript.ps1

# Confirm that it is an untracked change
git status

# Add this file to the next commit (staging)
git add NewScript.ps1

# Commit your files to source control.
# Until now, nothing was tracked. once committed, changes will be tracked
git commit -m 'Added new script to do stuff'

# Verify with git status that the working copy is clean
git status

# Add a gitignore file that ignores all tmp files
New-Item .gitignore -Value '*.tmp'

# Stage and commit
git add .gitignore
git commit -m 'Added .gitignore file'

# Test the file. file.tmp should not appear when looking
# at the output of git status
New-Item file.tmp
git status

# Get the commit history
git log

# How about a nicer format?
git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(white)<%an>%Creset' --abbrev-commit

# Configure an alias to make it easier to use
git config --global alias.prettylog "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(white)<%an>%Creset' --abbrev-commit"

# Recovery

# Changes to a file that need to be rolled back
Add-Content -Path .\NewScript.ps1 -Value 'Get-Process -Id $pid'
git add .
git commit -m 'Added get-process to script'

Add-Content -Path .\NewScript.ps1 -Value 'Restart-Computer -Force'
git add .
git commit -m 'Added restart-computer to script'

# Revert last two changes as a new commit
git log

# Revert all changes within this commit
git revert 02fdabc

# Verify that your change is gone
Get-Content .\NewScript.ps1

# Checkout

# Bring code from commit into working copy
git checkout 02fdabc NewScript.ps1

# Commit "old" code
git add .
git commit -m 'Reapplied changes'

# Reset

# Reset the repository to the commit before our changes
git log

git reset 23e16ac822dab6f7674608b58fe46a7b9bf038b8 --hard

# Git log now only shows commits up until the commit you reset HEAD to
git log

# New branch
git branch develop
git checkout develop

New-Item NewFile2.ps1 -Value 'Restart-Computer'
git add NewFile2.ps1
git commit -m 'Implemented new awesome feature'

# Merge changes back to master
git checkout master
git merge develop

# Git log shows that master and develop are pointing to the same commit
git log

# Provoking a merge conflict
# File change on master
Add-Content .\NewFile2.ps1 -Value 'I can change'
git add .
git commit -m 'New release!'

# File change on dev
git checkout develop
Add-Content .\NewFile2.ps1 -Value 'I hate change'
git add .
git commit -m 'Sweet new feature'

# All hell breaks loose
git checkout master
git merge develop