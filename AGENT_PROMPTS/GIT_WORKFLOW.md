# Git Workflow for Multi-Agent Development
**Project:** Aria's Magic SharePlay App

---

## Branch Structure

```
main (protected - production-ready code)
├── core-enhancements (iOS Core Engineer)
├── 3d-assets (3D Assets Engineer)
├── ui-polish (UI/UX Engineer)
├── test-suite (QA Engineer)
└── documentation (Technical Writer)
```

---

## Initial Setup

### Create Feature Branches

```bash
cd "/Users/dp/Projects/Aria's Magic SharePlay App"

# Ensure we're on main and up to date
git checkout main
git pull origin main

# Create agent branches
git checkout -b core-enhancements
git push -u origin core-enhancements

git checkout main
git checkout -b 3d-assets
git push -u origin 3d-assets

git checkout main
git checkout -b ui-polish
git push -u origin ui-polish

git checkout main
git checkout -b test-suite
git push -u origin test-suite

git checkout main
git checkout -b documentation
git push -u origin documentation

# Return to main
git checkout main
```

---

## Agent Workflows

### For Each Agent

**Starting Work:**
```bash
# Check out your branch
git checkout [your-branch-name]

# Pull latest changes
git pull origin [your-branch-name]

# Also pull from main to stay updated
git merge main

# Resolve any conflicts
```

**During Development:**
```bash
# Stage your changes
git add path/to/changed/files

# Or stage all changes
git add .

# Commit with descriptive message
git commit -m "[Component] Brief description

Detailed explanation if needed

Relates to: [integration point or requirement]"

# Push to your branch
git push origin [your-branch-name]
```

**Commit Often:**
- Commit working code frequently
- Small, focused commits better than large ones
- Push at least at end of each day

---

## Commit Message Format

### Standard Format
```
[Component] Brief description

Longer explanation if needed (optional)

- Bullet points for details (optional)
- Multiple lines ok

Addresses: [Integration point / requirement]
Fixes: [Issue number if applicable]
```

### Examples

**Good:**
```
[Models] Add CharacterProtocols with AnimatableCharacter

Creates protocol system for 3D character integration.
Allows 3D Engineer to implement without tight coupling.

Addresses: Core → 3D integration point
```

```
[UI] Implement CharacterPickerView with card layout

- Horizontal scrolling card picker
- Bounce animations on selection
- Integration with CharacterViewModel
- Haptic feedback

Addresses: Phase 1 Task 1 - Character Picker
```

**Less Good:**
```
fix bug
```

```
wip
```

```
changes
```

---

## Pull Request Process

### Creating a Pull Request

When your work is ready to merge into `main`:

**1. Ensure Code is Ready:**
```bash
# All tests pass
# Code reviewed (self-review first)
# Documentation updated
# No merge conflicts with main
```

**2. Create PR:**
```bash
# Via GitHub CLI
gh pr create \
  --base main \
  --head [your-branch-name] \
  --title "[Component] Feature Description" \
  --body "$(cat <<'EOF'
## Summary
- Implemented X
- Added Y
- Enhanced Z

## Changes
- `File1.swift`: Added new feature
- `File2.swift`: Refactored existing code

## Integration Points
- Works with: [Other agent's component]
- Provides: [API/interface for others]

## Testing
- [ ] Unit tests added
- [ ] UI tests added (if applicable)
- [ ] Manual testing complete

## Documentation
- [ ] Code comments added
- [ ] API docs updated
- [ ] User docs updated (if applicable)

## Screenshots
[If UI changes]

🤖 Generated with Claude Code
EOF
)"
```

**Or via GitHub Web Interface:**
- Go to repository
- Click "Pull Requests"
- Click "New Pull Request"
- Select base: `main`, compare: `[your-branch]`
- Fill in template above

---

### PR Review Checklist

**Before Requesting Review:**
- [ ] All tests pass locally
- [ ] No merge conflicts with main
- [ ] Code follows project style
- [ ] All new code has tests
- [ ] Documentation updated
- [ ] Commit messages clear
- [ ] PR description complete

**Coordinator Reviews:**
- Code quality
- Integration points
- Testing coverage
- Documentation
- Performance implications

---

## Merge Policy

### Requirements for Merge
✅ All of these must be true:
- [ ] All tests pass (local + CI)
- [ ] Code reviewed and approved
- [ ] No merge conflicts
- [ ] Documentation updated
- [ ] Integration points verified
- [ ] Quality gates passed

### Who Merges?
- **Coordinator** merges all PRs to main
- Agents do NOT merge their own PRs
- Squash and merge for clean history

### After Merge
```bash
# Agent updates local main
git checkout main
git pull origin main

# Update your branch with latest main
git checkout [your-branch-name]
git merge main
git push origin [your-branch-name]
```

---

## Handling Merge Conflicts

**If conflicts occur:**

```bash
# On your branch
git checkout [your-branch-name]
git merge main

# Git will show conflicts
# CONFLICT (content): Merge conflict in File.swift

# Open conflicted files
# Look for conflict markers:
# <<<<<<< HEAD
# Your changes
# =======
# Changes from main
# >>>>>>> main

# Edit to resolve (keep both, keep one, or combine)

# Stage resolved files
git add File.swift

# Complete the merge
git commit -m "Merge main into [your-branch], resolve conflicts"

# Push
git push origin [your-branch-name]
```

**Preventing Conflicts:**
- Merge main into your branch frequently
- Coordinate file ownership (see COORDINATION.md)
- Communicate in questions.md if touching shared files

---

## Daily Workflow

### Morning
```bash
# Start of day - get latest
git checkout [your-branch]
git pull origin [your-branch]
git merge main  # Stay up to date with main
```

### During Day
```bash
# Commit frequently
git add [files]
git commit -m "[Component] Description"

# Push periodically
git push origin [your-branch]
```

### End of Day
```bash
# Ensure all work pushed
git push origin [your-branch]

# Update daily log with commit references
```

---

## File Ownership (Prevent Conflicts)

See COORDINATION.md for detailed ownership.

**General Rule:**
- Each agent owns specific files/directories
- Avoid editing files owned by other agents
- If you must, coordinate in questions.md first

**Example Ownership:**

```
iOS Core Engineer owns:
├── Models/
├── Services/
└── ViewModels/

3D Engineer owns:
├── Resources/Characters/
├── Resources/Sounds/
└── Effects/

UI Engineer owns:
├── Views/
└── App/

QA Engineer owns:
├── Tests/

Technical Writer owns:
├── docs/
├── README.md
└── CONTRIBUTING.md
```

---

## Tagging Releases

### Phase Milestones
```bash
# After Phase 1 complete
git tag -a v0.1.0-phase1 -m "Phase 1: Foundation Enhancement Complete"
git push origin v0.1.0-phase1

# After Phase 2 complete
git tag -a v0.2.0-phase2 -m "Phase 2: Production Features Complete"
git push origin v0.2.0-phase2

# After Phase 3 complete (App Store ready)
git tag -a v1.0.0 -m "v1.0.0 - App Store Release"
git push origin v1.0.0
```

---

## Useful Git Commands

### Status & Info
```bash
git status                  # See current changes
git log --oneline -10       # Recent commits
git diff                    # See unstaged changes
git diff --staged           # See staged changes
git branch -a               # List all branches
```

### Undoing Changes
```bash
git checkout -- File.swift  # Discard changes to file
git reset HEAD File.swift   # Unstage file
git reset HEAD~1            # Undo last commit (keep changes)
git reset --hard HEAD~1     # Undo last commit (lose changes - careful!)
```

### Stashing
```bash
git stash                   # Save work temporarily
git stash pop               # Restore stashed work
git stash list              # See stashed items
```

### Cleaning
```bash
git clean -n                # Preview files to delete
git clean -fd               # Delete untracked files and directories
```

---

## CI/CD Integration

### GitHub Actions (Set up by QA Engineer)

**Triggers:**
- Push to any agent branch
- Pull request to main

**Actions:**
- Run unit tests
- Run UI tests (on PRs only)
- Generate code coverage
- Report results

**Blocking:**
- PRs cannot merge if tests fail
- Coverage must be >= 80%

---

## Tips for Success

### Do ✅
- Commit frequently with good messages
- Pull from main regularly
- Push at end of each day
- Coordinate in questions.md before touching shared files
- Review your own code before PR
- Write clear PR descriptions

### Don't ❌
- Don't commit broken code
- Don't merge main yourself (coordinator does this)
- Don't force push (unless you really know why)
- Don't commit secrets or sensitive data
- Don't commit generated files (build artifacts)
- Don't create new branches without coordination

---

## Getting Help

**Git Issues:**
- Check `git status` first
- Google the error message
- Ask in questions.md
- Escalate to coordinator if stuck

**Merge Conflicts:**
- Don't panic
- Ask for help if unsure
- Coordinator can assist

**Lost Work:**
- Git rarely loses committed work
- Check `git reflog`
- Ask coordinator for help

---

## .gitignore

Ensure these are ignored:
```gitignore
# Xcode
*.xcworkspace
xcuserdata/
*.xcuserstate
DerivedData/

# Swift Package Manager
.swiftpm/
.build/

# Generated files
*.generated.swift

# OS Files
.DS_Store
*.swp

# Secrets
.env
secrets/
*.pem
*.p12

# Build artifacts
build/
```

---

## Quick Reference

### Common Commands
```bash
# Switch branches
git checkout [branch-name]

# See what changed
git status
git diff

# Commit
git add .
git commit -m "Message"
git push

# Update from main
git checkout main
git pull
git checkout [your-branch]
git merge main

# Create PR
gh pr create
```

---

**Questions?** Post in `questions.md`

**Git Help:** `git help [command]` or `man git-[command]`

---

**Last Updated:** November 17, 2025
**Maintained by:** Coordinator
