---
description: Run CodeRabbit CLI code review on uncommitted changes
---

# Manual Code Review Command

Run CodeRabbit CLI to perform AI-powered code review on uncommitted changes and provide interactive feedback to the user.

## Purpose

This command allows users to manually trigger a CodeRabbit code review at any point during development, outside of the automated workflow reviews.

**Use cases:**
- Quick check before committing manually
- Review work-in-progress changes
- Get feedback on partial implementations
- Verify fixes for previously identified issues

## Workflow

### Step 1: Verify CodeRabbit CLI Installation

Check if CodeRabbit CLI is installed and configured:

```bash
which coderabbit
```

**If not installed:**
- Provide installation instructions from `{{integrations/coderabbit/standards/setup}}`
- Exit with error message
- **Do not proceed without CodeRabbit installed**

**If installed, verify authentication:**

```bash
coderabbit auth status
```

**If not authenticated:**
- Provide authentication instructions: `coderabbit auth login`
- Exit with error message
- **Do not proceed without authentication**

### Step 2: Check for Uncommitted Changes

Verify there are uncommitted changes to review:

```bash
git status --porcelain
```

**If no changes found:**
- Inform user: "No uncommitted changes found. All code is committed."
- Ask if they want to review committed changes instead
- If yes, proceed with `--type committed` flag
- If no, exit gracefully

**If changes found:**
- Count the number of changed files
- Estimate review time based on scope:
  - Small (1-5 files, < 100 lines): 7-15 minutes
  - Medium (6-20 files, 100-500 lines): 15-30 minutes
  - Large (20+ files, 500+ lines): 30-60 minutes

### Step 3: Run CodeRabbit Review

Execute CodeRabbit CLI with prompt-only flag for agent-friendly output:

```bash
coderabbit --prompt-only --type uncommitted
```

**During review:**
- Inform user that review is in progress
- Note: "CodeRabbit is analyzing your code... This may take several minutes."
- You can optionally run the command in the background and periodically check for completion

### Step 4: Parse and Present Results

Once CodeRabbit completes, parse the output and categorize findings:

**Parse for:**
- Total number of issues
- Issues by severity: Critical, High, Medium, Low
- File paths and line numbers for each issue
- Issue descriptions and recommendations

**Present in user-friendly format:**

```markdown
## Code Review Results

**Review completed at:** [timestamp]
**Files reviewed:** [count]
**Total issues found:** [count]

### Summary by Severity

- 🔴 Critical: [count] - Security vulnerabilities, data corruption risks
- 🟠 High: [count] - Unhandled exceptions, logic errors
- 🟡 Medium: [count] - Code style, missing edge cases
- 🟢 Low: [count] - Formatting, naming suggestions

### Critical Issues (if any)

1. **[Issue Title]** in `file/path.ext:line`
   - **Problem:** [Description]
   - **Recommendation:** [Suggested fix]
   - **Impact:** [Why this matters]

[Repeat for each critical issue]

### High Priority Issues (if any)

[Same format as critical issues]

### Medium/Low Priority Issues

[Brief summary, full details available if user requests]
```

### Step 5: Offer Next Actions

Based on the findings, present options to the user:

**If critical or high-priority issues found:**

```
Would you like me to:
1. Fix all critical issues automatically
2. Fix specific issues (you select which ones)
3. Show me the details for a specific issue
4. Save this report for later review
5. Do nothing right now
```

**If only medium/low priority issues:**

```
Would you like me to:
1. Fix these issues now
2. Document these for future cleanup
3. Show me details for specific issues
4. Do nothing right now (issues are minor)
```

**If no issues found:**

```
✅ Excellent! CodeRabbit found no issues with your code.

Your uncommitted changes are ready to commit.
```

### Step 6: Handle User Choice

Implement the user's selected action:

**Option 1: Auto-fix issues**
- Follow the workflow in `{{integrations/coderabbit/workflows/auto-fix-critical}}`
- Fix issues one by one
- Re-run CodeRabbit to verify fixes
- Present updated results

**Option 2: Fix specific issues**
- Let user select which issues to address
- Fix selected issues following best practices
- Update user on progress
- Re-run review on fixed items

**Option 3: Show details**
- Display full context for the requested issue
- Show surrounding code (10 lines before/after)
- Explain the problem in detail
- Suggest multiple possible solutions
- Return to action menu

**Option 4: Save report**
- Create file in `agent-os/code-reviews/review-[timestamp].md`
- Include full findings and recommendations
- Inform user where report was saved

**Option 5: Do nothing**
- Confirm user wants to proceed without fixes
- Remind them issues will still be caught by pre-commit hook
- Exit gracefully

## Error Handling

### CodeRabbit CLI Errors

**Authentication expired:**
```
Your CodeRabbit authentication has expired.
Please re-authenticate: coderabbit auth login
```

**Rate limit exceeded:**
```
CodeRabbit rate limit exceeded.
Wait: [time until reset]
Or upgrade your plan at: https://coderabbit.ai/pricing
```

**Network timeout:**
```
CodeRabbit analysis timed out.
This might be due to:
- Large change set (try reviewing smaller batches)
- Network connectivity issues
- CodeRabbit service availability

Try again in a few minutes, or review in smaller increments.
```

**Invalid git repository:**
```
Not a git repository.
CodeRabbit requires a git repository to function.
Initialize git: git init
```

### Parsing Errors

If CodeRabbit output format is unexpected:
- Show raw output to user
- Note: "CodeRabbit output format may have changed"
- Suggest updating agent-os: `~/agent-os/scripts/update.sh`
- Still allow user to review raw findings

## Configuration Options

Users can customize review behavior with `.coderabbit.yaml`:

**Example configuration:**
```yaml
reviews:
  security: high     # Prioritize security issues
  performance: medium
  style: low        # De-prioritize style issues

  exclude:
    - "*.test.js"   # Skip test files
    - "dist/**"     # Skip build output
    - "*.generated.*" # Skip generated code
```

If `.coderabbit.yaml` exists, inform user it's being used.

## Integration with Workflow

This manual review command complements the automated reviews:

- **Automated reviews:** Run after each task during implementation
- **Manual reviews:** Run on-demand anytime via `/review-code`
- **Pre-commit hooks:** Run automatically before git commits

All three work together to ensure comprehensive code quality.

## Output Example

```markdown
# Code Review Report
Generated: 2025-11-04 14:23:45

## Files Reviewed (12 files)
- app/controllers/users_controller.rb
- app/models/user.rb
- app/services/auth_service.rb
[... 9 more files]

## Summary
- 🔴 Critical: 1
- 🟠 High: 2
- 🟡 Medium: 4
- 🟢 Low: 8

## Critical Issues

### 1. SQL Injection Vulnerability
**File:** app/controllers/users_controller.rb:45
**Severity:** Critical
**Description:** User input directly interpolated into SQL query, allowing SQL injection attacks.

**Current code:**
```ruby
User.where("email = '#{params[:email]}'")
```

**Recommended fix:**
```ruby
User.where(email: params[:email])
```

**Impact:** Attackers could access, modify, or delete database records.

---

## High Priority Issues

[... details ...]

## Medium Priority Issues

[... details ...]

## Low Priority Issues

[... summary ...]
```

## Notes

- CodeRabbit reviews are cached for ~15 minutes for same file state
- Running review twice in quick succession will be fast (cached results)
- Reviews analyze both staged and unstaged changes
- To review only staged changes, specify: `coderabbit --type staged`
