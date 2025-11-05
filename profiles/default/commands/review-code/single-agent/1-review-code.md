# Manual Code Review with CodeRabbit CLI

This command guides you through running a CodeRabbit CLI code review on your uncommitted changes.

## Overview

CodeRabbit CLI provides AI-powered code review that catches:
- Security vulnerabilities (SQL injection, XSS, CSRF)
- Logic errors and bugs
- Performance issues
- Code quality problems
- Best practice violations

## Prerequisites

Before running a code review, ensure:

1. **CodeRabbit CLI is installed**
   ```bash
   which coderabbit
   ```

   If not installed, see: `{{integrations/coderabbit/standards/setup}}`

2. **CodeRabbit is authenticated**
   ```bash
   coderabbit auth status
   ```

   If not authenticated:
   ```bash
   coderabbit auth login
   ```

3. **You have uncommitted changes**
   ```bash
   git status
   ```

## Running the Review

### Step 1: Check what will be reviewed

See what files have changed:

```bash
git status
```

Count changed files and lines:

```bash
git diff --stat
```

**Estimated review time:**
- Small changes (< 100 lines): 7-15 minutes
- Medium changes (100-500 lines): 15-30 minutes
- Large changes (500+ lines): 30-60 minutes

### Step 2: Run CodeRabbit

Execute the review:

```bash
coderabbit --prompt-only --type uncommitted
```

**Note:** This command may take several minutes to complete. CodeRabbit analyzes your code in the cloud.

### Step 3: Review the output

CodeRabbit will return a report with issues categorized by severity:

- **Critical**: Security vulnerabilities, data corruption risks (MUST fix)
- **High**: Unhandled exceptions, logic errors (MUST fix)
- **Medium**: Code style, missing edge cases (should fix)
- **Low**: Formatting, naming suggestions (optional)

### Step 4: Address findings

For each critical and high-priority issue:

1. **Read the issue description carefully**
   - Understand what the problem is
   - Review the suggested fix
   - Check the file and line number

2. **Fix the issue**
   - Follow the recommended approach
   - Use Context7 MCP if you need current library documentation
   - Test your fix mentally (think through edge cases)

3. **Verify the fix**
   - Re-read the modified code
   - Ensure no new issues introduced

### Step 5: Re-run review (optional)

After fixing critical/high issues, re-run CodeRabbit to confirm:

```bash
coderabbit --prompt-only --type uncommitted
```

Expected outcome: No critical or high-priority issues remaining.

## Workflow Integration

### When to use manual review:

- **Before committing**: Quick check of your work
- **Work-in-progress**: Get feedback on partial implementations
- **After major changes**: Verify quality before moving forward
- **Bug fixing**: Confirm fixes don't introduce new issues

### How it complements automated reviews:

- **Automated reviews**: Run after each task during `implement-spec`
- **Manual reviews**: Run on-demand via this command
- **Pre-commit hooks**: Run automatically before commits

All three layers ensure comprehensive code quality.

## Example Review Output

```
=== Code Review Results ===
Total Issues: 5

[CRITICAL] app/controllers/auth_controller.rb:45
  Issue: SQL injection vulnerability in user lookup
  Suggestion: Use parameterized queries
  Impact: Attackers could access or modify database

[HIGH] app/models/user.rb:23
  Issue: Password stored in plain text
  Suggestion: Use bcrypt for password hashing
  Impact: Passwords exposed if database compromised

[MEDIUM] app/services/email_sender.rb:67
  Issue: Missing error handling for email failures
  Suggestion: Add try/catch block and log errors

[LOW] app/helpers/format_helper.rb:12
  Issue: Method name could be more descriptive
  Suggestion: Rename `fmt` to `format_currency`

[LOW] app/controllers/users_controller.rb:89
  Issue: Line exceeds 100 characters
  Suggestion: Break into multiple lines
```

## Addressing Each Issue Type

### Critical Issues - MUST FIX IMMEDIATELY

Example: SQL Injection

**Before:**
```ruby
User.where("email = '#{params[:email]}'")
```

**After:**
```ruby
User.where(email: params[:email])
```

Ask yourself:
- Does this fix completely eliminate the vulnerability?
- Are there other places with similar issues?
- Should this pattern be documented in our standards?

### High Priority Issues - MUST FIX BEFORE COMMIT

Example: Unhandled Exception

**Before:**
```ruby
def process_payment(amount)
  response = HTTParty.post(url, body: { amount: amount })
  response.parsed_response
end
```

**After:**
```ruby
def process_payment(amount)
  response = HTTParty.post(url, body: { amount: amount })
  response.parsed_response
rescue HTTParty::Error, Net::OpenTimeout => e
  Rails.logger.error("Payment failed: #{e.message}")
  { error: "Payment processing unavailable" }
end
```

### Medium Priority Issues - SHOULD FIX

These improve code quality but don't block functionality:
- Code style inconsistencies
- Missing edge case handling
- Suboptimal patterns
- Incomplete error messages

Fix time permitting, or document for later cleanup.

### Low Priority Issues - OPTIONAL

Minor improvements:
- Formatting
- Variable naming
- Comment additions
- Refactoring opportunities

Fix if you have time, otherwise ignore.

## Configuration

Customize CodeRabbit behavior with `.coderabbit.yaml` in your project root:

```yaml
reviews:
  security: high     # Focus on security
  performance: medium
  style: low         # De-prioritize style

  exclude:
    - "*.test.js"    # Skip test files
    - "dist/**"      # Skip build artifacts
    - "node_modules/**"
```

## Troubleshooting

### "CodeRabbit not found"

Install CodeRabbit CLI:
```bash
curl -fsSL https://cli.coderabbit.ai/install.sh | sh
source ~/.zshrc  # or ~/.bashrc
```

### "Not authenticated"

Log in to CodeRabbit:
```bash
coderabbit auth login
```

This opens your browser to complete authentication.

### "No changes detected"

Ensure you have uncommitted changes:
```bash
git status --porcelain
```

If you want to review committed changes instead:
```bash
coderabbit --prompt-only --type committed --base main
```

### "Rate limit exceeded"

Free tier limits:
- 10 reviews per day
- 50 files per review

Solutions:
- Wait for rate limit reset
- Upgrade to paid plan
- Review smaller changesets

### Review takes too long

Large changesets (500+ lines) can take 30-60 minutes.

Solutions:
- Break changes into smaller reviews
- Exclude test files and build artifacts with `.coderabbit.yaml`
- Review only specific paths: `coderabbit --path src/components`

## Tips for Best Results

1. **Review frequently**: Small, frequent reviews are faster and catch issues earlier

2. **Fix critical/high immediately**: Don't accumulate security issues

3. **Document medium issues**: Create tasks for later cleanup

4. **Learn from patterns**: If CodeRabbit finds the same issue repeatedly, update your standards

5. **Use Context7**: When fixing library-specific issues, use Context7 MCP to ensure you're using current APIs

6. **Re-review after fixes**: Confirm your fixes don't introduce new problems

## Next Steps

After reviewing and fixing issues:

1. **Run tests** (if available):
   ```bash
   npm test  # or your test command
   ```

2. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Your commit message"
   ```

   Note: Pre-commit hook will run CodeRabbit automatically.

3. **Push to remote**:
   ```bash
   git push
   ```

## Additional Resources

- CodeRabbit CLI docs: https://docs.coderabbit.ai/cli
- Agent-OS standards: `agent-os/standards/`
- Post-task review workflow: `{{integrations/coderabbit/workflows/post-task-review}}`
- Auto-fix workflow: `{{integrations/coderabbit/workflows/auto-fix-critical}}`
