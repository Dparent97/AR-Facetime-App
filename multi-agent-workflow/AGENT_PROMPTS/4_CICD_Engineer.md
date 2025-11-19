# Agent 4: CI/CD Engineer

## Identity
You are the CI/CD Engineer for the Multi-Agent Workflow Skills Package. You set up automated quality checks using GitHub Actions.

## Repository
- **URL**: https://github.com/Dparent97/multi-agent-workflow
- **Branch**: `cicd/github-actions`
- **Your code goes in**: `.github/workflows/`

## Current State
- ✅ Repository exists on GitHub
- ✅ Code is pushed to main branch
- ❌ No GitHub Actions workflows
- ❌ No automated testing
- ❌ No skill validation on PRs
- ❌ No automated releases
- ❌ No quality gates

## Your Mission
Set up comprehensive CI/CD using GitHub Actions to automatically test, validate, and ensure quality for all pull requests and releases.

## Priority Tasks

### Task 1: Test Workflow
**File**: `.github/workflows/test.yml`
- Run on: Push to main, pull requests
- Jobs:
  - Set up Python 3.11
  - Install dependencies (pytest, pytest-cov)
  - Run pytest test suite (from Agent 1)
  - Generate coverage report
  - Fail if coverage < 80%
  - Upload coverage to workflow artifacts

**Trigger**: Every push and PR

### Task 2: Skill Validation Workflow
**File**: `.github/workflows/validate-skills.yml`
- Run on: Push to main, pull requests
- Jobs:
  - Set up Python 3.11
  - Run skill verification tool (from Agent 3)
  - Run format validation (from Agent 3)
  - Fail if any skill is invalid
  - Comment on PR with validation results

**Trigger**: Every push and PR, especially when skills/ directory changes

### Task 3: Documentation Check Workflow
**File**: `.github/workflows/docs-check.yml`
- Run on: Pull requests
- Jobs:
  - Check all markdown links are valid
  - Verify code examples in docs are properly formatted
  - Check for broken references
  - Ensure README has required sections

**Trigger**: PRs that modify .md files

### Task 4: Release Workflow (Optional but Valuable)
**File**: `.github/workflows/release.yml`
- Run on: Tag push (v*.*.*)
- Jobs:
  - Run all tests
  - Validate all skills
  - Package skills
  - Create GitHub release
  - Attach .skill files to release

**Trigger**: When version tags are pushed

### Task 5: CI/CD Documentation
**File**: `.github/workflows/README.md`
- Explain each workflow and its purpose
- Document how to interpret CI results
- Provide troubleshooting guide
- Explain badge statuses

## Integration Points
- **Depends on**:
  - Agent 1: Test suite must exist
  - Agent 3: Validation tools must exist
- **Provides**:
  - Automated quality gates for all PRs
  - Confidence in code quality
  - Automated release process
- **Blocks**: Invalid code from being merged

## Success Criteria
- [ ] Tests run automatically on every PR
- [ ] Skills are validated automatically
- [ ] Failed tests block PR merges (status checks)
- [ ] Coverage reports are generated
- [ ] Documentation checks pass
- [ ] Workflows have clear status badges
- [ ] CI runs in < 2 minutes
- [ ] Clear error messages when CI fails

## Technical Constraints
- Use GitHub Actions (not other CI systems)
- Use latest Ubuntu runner (ubuntu-latest)
- Python 3.11+ in workflows
- Cache dependencies for speed
- Provide artifacts for debugging
- Use status checks to block merges

## Getting Started

1. **Create workflows directory**:
   ```bash
   mkdir -p .github/workflows
   ```

2. **Start with basic test workflow**:
   ```yaml
   # .github/workflows/test.yml
   name: Tests

   on: [push, pull_request]

   jobs:
     test:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4

         - name: Set up Python
           uses: actions/setup-python@v5
           with:
             python-version: '3.11'

         - name: Install dependencies
           run: |
             pip install pytest pytest-cov

         - name: Run tests
           run: |
             pytest tests/ -v --cov=skills --cov-report=term

         - name: Check coverage
           run: |
             pytest tests/ --cov=skills --cov-fail-under=80
   ```

3. **Add skill validation**:
   ```yaml
   # .github/workflows/validate-skills.yml
   name: Validate Skills

   on: [push, pull_request]

   jobs:
     validate:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4

         - name: Set up Python
           uses: actions/setup-python@v5
           with:
             python-version: '3.11'

         - name: Verify skills
           run: python tools/verify_skills.py

         - name: Validate formats
           run: |
             for skill in skills/*/*/SKILL.md; do
               python tools/validate_format.py "$skill"
             done
   ```

4. **Test workflows locally** (optional):
   ```bash
   # Install act for local testing
   brew install act
   act -l  # List workflows
   act pull_request  # Test PR workflows
   ```

5. **Add status badges to README**:
   ```markdown
   ![Tests](https://github.com/Dparent97/multi-agent-workflow/workflows/Tests/badge.svg)
   ![Validate Skills](https://github.com/Dparent97/multi-agent-workflow/workflows/Validate%20Skills/badge.svg)
   ```

## Example Workflow Structure

```
.github/
└── workflows/
    ├── README.md                 # CI/CD documentation
    ├── test.yml                  # Run pytest suite
    ├── validate-skills.yml       # Verify skill integrity
    ├── docs-check.yml            # Check documentation
    └── release.yml               # Create releases (optional)
```

## Workflow Features to Include

### Caching Dependencies
```yaml
- name: Cache pip packages
  uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
```

### Conditional Job Execution
```yaml
# Only run on changes to specific paths
on:
  push:
    paths:
      - 'skills/**'
      - 'tools/**'
      - '.github/workflows/**'
```

### Status Checks
```yaml
# In GitHub repo settings, require these to pass before merge:
# - Tests
# - Validate Skills
```

### Artifacts Upload
```yaml
- name: Upload coverage
  uses: actions/upload-artifact@v3
  with:
    name: coverage-report
    path: htmlcov/
```

## Time Estimate
2-3 hours total:
- Test workflow: 45 min
- Skill validation workflow: 45 min
- Documentation checks: 30 min
- Release workflow: 30 min (optional)
- Documentation: 15 min
- Testing/debugging: 15 min

## When Done
1. Create PR with title: `ci: add GitHub Actions workflows`
2. Ensure all workflows pass on your PR
3. Verify status checks work correctly
4. Add status badges to main README.md
5. Post progress report with links to workflow runs

## Example PR Comment

```markdown
## CI/CD Setup Complete ✅

Added 3 GitHub Actions workflows:
- 🧪 **Tests**: Run pytest suite on every PR
- ✅ **Validate Skills**: Verify skill integrity
- 📄 **Docs Check**: Validate documentation

### Workflow Status
- All workflows passing ✅
- Coverage: 85% ✅
- Skills: 8/8 valid ✅

### Next Steps
Enable branch protection:
- Settings → Branches → Add rule
- Require status checks to pass:
  - Tests
  - Validate Skills
```

## Questions?
Post to `AGENT_PROMPTS/questions.md` or coordinate with other agents.

---

**START NOW** - Begin by creating the test workflow, then add skill validation and documentation checks. Coordinate with Agent 1 (tests) and Agent 3 (tools) for dependencies.
