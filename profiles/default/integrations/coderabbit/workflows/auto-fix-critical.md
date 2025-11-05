# Auto-Fix Critical Issues Workflow

**Purpose**: Automatically fix critical and high-priority issues found by CodeRabbit.

**When to use**: Immediately after post-task review identifies critical or high-priority issues.

**Prerequisites**:
- CodeRabbit post-task review has been run
- Critical or high-priority issues have been identified
- `enable_coderabbit: true` in config.yml

---

## Workflow Steps

### 1. Prioritize Critical Issues

Review the CodeRabbit output and identify:
- **Critical severity**: Security vulnerabilities, data corruption, critical bugs
- **High severity**: Significant bugs, incorrect logic, major performance issues

**Examples of critical/high issues**:
- SQL injection vulnerabilities
- XSS (Cross-Site Scripting) vulnerabilities
- Authentication bypass bugs
- Data validation failures
- Null pointer dereferences
- Resource leaks
- Race conditions

### 2. Fix Issues Systematically

For each critical/high issue:

**a) Understand the issue**:
- Read the CodeRabbit explanation carefully
- Locate the problematic code
- Understand why it's a problem
- Consider the suggested fix

**b) Implement the fix**:
- Apply the fix following coding standards
- Ensure the fix doesn't introduce new issues
- Maintain code readability and maintainability
- Add comments if the fix is non-obvious

**c) Verify the fix**:
- Test the fixed code
- Ensure original functionality is preserved
- Check for edge cases
- Run relevant tests if available

### 3. Re-run CodeRabbit Review (Scoped to Your Files)

After fixing all critical/high issues, re-review ONLY the files you modified:

```bash
# Use the same scoped file list from implementation
if [ -n "$MY_FILES" ] && [ -f "$MY_FILES" ]; then
    CODERABBIT_CMD="coderabbit --prompt-only --type uncommitted"

    while IFS= read -r file; do
        if [ -n "$file" ] && [ -f "$file" ]; then
            CODERABBIT_CMD="$CODERABBIT_CMD --path \"$file\""
        fi
    done < "$MY_FILES"

    eval "$CODERABBIT_CMD"
else
    # Fallback to full review if file tracking not available
    coderabbit --prompt-only --type uncommitted
fi
```

**Purpose**: Verify that:
- All critical/high issues IN YOUR FILES are resolved
- No new critical/high issues were introduced by the fixes
- Fixes don't create additional problems
- You're not reviewing other agents' files again

### 4. Iterate If Needed (Maximum 2 Iterations)

**If new critical/high issues are found**:
- Return to Step 2
- Fix the new issues
- Re-review again

**Maximum iterations**: 2 full fix-and-review cycles

**If issues persist after 2 iterations**:
1. Document the situation
2. Consider if the approach is fundamentally flawed
3. May need to refactor or redesign the solution
4. Consult with team or seek additional guidance

### 5. Final Verification

Once no critical/high issues remain:
- Document what was fixed
- Note any remaining medium/low issues
- Proceed with standard implementation workflow
- Mark task as ready for completion

---

## Integration with Post-Task Review

This workflow is automatically triggered when post-task review finds critical/high issues:

**Automatic flow**:
1. Post-task review runs
2. Critical/high issues detected
3. **→ This auto-fix workflow activates**
4. Issues are fixed and verified
5. Return to standard workflow

---

## Handling Common Critical Issues

### SQL Injection

**Problem**: User input directly in SQL queries
**Fix**: Use parameterized queries or prepared statements

```javascript
// Bad
const query = `SELECT * FROM users WHERE id = ${userId}`;

// Good
const query = 'SELECT * FROM users WHERE id = ?';
db.query(query, [userId]);
```

### XSS (Cross-Site Scripting)

**Problem**: Unescaped user input in HTML
**Fix**: Properly escape or sanitize output

```javascript
// Bad
div.innerHTML = userInput;

// Good
div.textContent = userInput;
// or use proper escaping library
```

### Authentication Bypass

**Problem**: Missing or incorrect authentication checks
**Fix**: Add proper authentication middleware

```javascript
// Bad
app.get('/api/admin', (req, res) => {
  // No auth check
});

// Good
app.get('/api/admin', requireAuth, requireAdmin, (req, res) => {
  // Protected route
});
```

### Null/Undefined Handling

**Problem**: Accessing properties on potentially null/undefined values
**Fix**: Add null checks or use optional chaining

```javascript
// Bad
const name = user.profile.name;

// Good
const name = user?.profile?.name ?? 'Unknown';
```

---

## When to Escalate

**Escalate to team/lead if**:
- Issue is complex and you're unsure of the fix
- Fix requires architectural changes
- Multiple failed fix attempts
- Security implications are unclear
- Breaking changes would be required

---

## Notes

- Always prioritize critical issues over high issues
- Security issues take absolute priority
- Don't rush fixes - ensure they're correct
- Test thoroughly after fixing
- Document non-obvious fixes with comments
- If unsure, ask for help rather than guessing

---

## Success Criteria

✓ All critical issues resolved
✓ All high-priority issues resolved
✓ Re-review shows no new critical/high issues
✓ Original functionality preserved
✓ Tests pass (if applicable)
✓ Code remains maintainable and readable
