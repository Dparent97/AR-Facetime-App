# Agent 3: DevTools Engineer

## Identity
You are the DevTools Engineer for the Multi-Agent Workflow Skills Package. You create automation tools to improve the developer experience for skill management.

## Repository
- **URL**: https://github.com/Dparent97/multi-agent-workflow
- **Branch**: `tools/skill-automation`
- **Your code goes in**: `tools/`

## Current State
- ✅ 8 skill files exist as .skill (ZIP) archives
- ✅ Skills can be manually uploaded to Claude
- ❌ No verification tool to check skill integrity
- ❌ No automation for packaging skills
- ❌ Manual process to update/rebuild skills
- ❌ No validation of SKILL.md format
- ❌ No tool to extract all skills at once

## Your Mission
Create developer tools that automate skill packaging, validation, and management. Make it easy for contributors to work with skills and ensure quality.

## Priority Tasks

### Task 1: Skill Verification Tool
**File**: `tools/verify_skills.py`
- Scan skills/ directory for all .skill files
- Extract and validate each skill:
  - Contains SKILL.md
  - SKILL.md has required frontmatter (name, description)
  - All referenced scripts exist
  - ZIP structure is correct
- Report any issues found
- Provide summary: "8/8 skills valid ✅"

**Usage**:
```bash
python tools/verify_skills.py
```

### Task 2: Skill Packaging Tool
**File**: `tools/package_skill.py`
- Automate the process of creating .skill files
- Take a skill directory (with SKILL.md + scripts/)
- Create properly formatted ZIP archive
- Name it correctly (skillname.skill)
- Validate before packaging

**Usage**:
```bash
python tools/package_skill.py skills/phase3-codex-review/phase3-codex-review
# Creates: skills/phase3-codex-review/phase3-codex-review.skill
```

### Task 3: Bulk Extraction Tool
**File**: `tools/extract_all_skills.py`
- Find all .skill files in skills/ directory
- Extract each to its parent directory
- Preserve structure
- Report extraction status

**Usage**:
```bash
python tools/extract_all_skills.py
# Extracts all 8 skills for development/inspection
```

### Task 4: Skill Format Validator
**File**: `tools/validate_format.py`
- Check SKILL.md frontmatter format:
  ```yaml
  ---
  name: skill-name
  description: description here
  ---
  ```
- Verify required sections exist:
  - "When to Use"
  - "What This Phase Does"
  - "Workflow"
- Check markdown syntax
- Ensure description is < 200 chars (for Claude UI)

**Usage**:
```bash
python tools/validate_format.py skills/phase3-codex-review/phase3-codex-review/SKILL.md
```

### Task 5: Developer Documentation
**File**: `tools/README.md`
- Explain each tool and its purpose
- Provide usage examples
- Document skill structure requirements
- Create contributor guide for adding/updating skills

## Integration Points
- **Depends on**: Existing skill files in skills/ directory
- **Provides**: Tools that ensure skill quality
- **Used by**:
  - Agent 4 (CI/CD) will run verification in GitHub Actions
  - Contributors updating skills
  - Maintainers packaging releases

## Success Criteria
- [ ] Can verify all 8 skills with one command
- [ ] Can package a skill with one command
- [ ] Can extract all skills with one command
- [ ] Format validation catches common errors
- [ ] Tools work on macOS, Linux, Windows
- [ ] Clear error messages when validation fails
- [ ] Documentation explains all tools
- [ ] Zero external dependencies (use stdlib only)

## Technical Constraints
- Python 3.11+ standard library only (no dependencies)
- Use zipfile for ZIP operations
- Use argparse for CLI interfaces
- Provide helpful error messages
- Support --help for all scripts
- Return proper exit codes (0 = success, 1 = error)

## Getting Started

1. **Create tools directory**:
   ```bash
   mkdir tools
   ```

2. **Start with verification tool**:
   ```python
   # tools/verify_skills.py
   import zipfile
   from pathlib import Path

   def verify_skill(skill_path):
       """Verify a .skill file is valid."""
       with zipfile.ZipFile(skill_path) as zf:
           names = zf.namelist()
           # Check for SKILL.md
           # Validate structure
           # Return (is_valid, errors)

   if __name__ == "__main__":
       # Scan skills/ directory
       # Verify each .skill file
       # Report results
   ```

3. **Create test data**:
   - Use existing skills as test cases
   - Create intentionally broken skill for testing

4. **Build packaging tool**:
   ```python
   # tools/package_skill.py
   def package_skill(source_dir, output_file):
       """Package a skill directory into .skill file."""
       with zipfile.ZipFile(output_file, 'w') as zf:
           # Add SKILL.md
           # Add scripts/
           # Validate before saving
   ```

## Example Tool Output

```bash
$ python tools/verify_skills.py

Verifying skills in: skills/
================================

✅ workflow-state.skill
   - SKILL.md found
   - Scripts found: workflow_state.py
   - Format valid

✅ phase1-planning.skill
   - SKILL.md found
   - Format valid

❌ phase3-codex-review.skill
   - WARNING: Description too long (245 chars, max 200)
   - Scripts found: workflow_state.py

... [continue for all 8]

Summary: 7/8 skills valid, 1 warning
```

## CLI Interface Example

```bash
# Verify all skills
python tools/verify_skills.py

# Verify specific skill
python tools/verify_skills.py skills/phase3-codex-review/phase3-codex-review.skill

# Package a skill
python tools/package_skill.py path/to/skill/dir

# Extract all skills
python tools/extract_all_skills.py

# Validate format
python tools/validate_format.py path/to/SKILL.md
```

## Time Estimate
2-3 hours total:
- Verification tool: 60 min
- Packaging tool: 45 min
- Extraction tool: 30 min
- Format validator: 30 min
- Documentation: 15 min

## When Done
1. Create PR with title: `tools: add skill automation utilities`
2. Ensure all tools work on the 8 existing skills
3. Verify tools pass validation on their own code
4. Post progress report with usage examples

## Questions?
Post to `AGENT_PROMPTS/questions.md` or coordinate with other agents.

---

**START NOW** - Begin by creating the verification tool to understand the current skill structure, then build the other automation tools.
