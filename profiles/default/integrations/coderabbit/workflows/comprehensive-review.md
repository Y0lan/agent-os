# Comprehensive Integration Review Workflow

**Purpose**: After all agents/tasks complete, run ONE final review of ALL changes to catch cross-agent integration issues.

**When to use**: After Phase 2 (implementation) completes, before Phase 3 (verification).

**Prerequisites**:
- All individual agent implementations complete
- All scoped reviews passed (no critical/high issues in individual work)
- `enable_coderabbit: true` in config.yml

---

## Why This Is Needed

**Problem**: Individual scoped reviews catch issues within each agent's domain, but miss:
- **Integration issues**: API calls UI component that doesn't exist
- **Cross-cutting concerns**: Security patterns across all layers
- **Architectural inconsistencies**: Database schema doesn't match API contract
- **Dependency conflicts**: One agent's changes break another agent's code

**Solution**: ONE final comprehensive review of all uncommitted changes together.

---

## Workflow Steps

### 1. Verify All Agents Completed

Before running comprehensive review, ensure:
- All tasks in tasks.md are marked complete
- All agent-scoped reviews passed
- No critical/high issues outstanding in individual work

```bash
# Check if any tasks remain
if grep -q "\- \[ \]" agent-os/specs/*/tasks.md; then
    echo "ERROR: Not all tasks are complete"
    echo "Complete all tasks before comprehensive review"
    exit 1
fi
```

### 2. Run Comprehensive Review

Now review ALL uncommitted changes (not scoped to specific files):

```bash
echo "=== Running Comprehensive Integration Review ==="
echo "This reviews ALL changes from all agents to catch integration issues..."

# Review everything
coderabbit --prompt-only --type uncommitted > /tmp/comprehensive_review_$(date +%s).log

COMPREHENSIVE_LOG="/tmp/comprehensive_review_$(date +%s).log"
cat "$COMPREHENSIVE_LOG"

# Save to permanent location
mkdir -p agent-os/code-reviews
REVIEW_FILE="agent-os/code-reviews/comprehensive-$(date +%Y%m%d-%H%M%S).txt"
cp "$COMPREHENSIVE_LOG" "$REVIEW_FILE"
echo "Comprehensive review saved to: $REVIEW_FILE"
```

### 3. Analyze Cross-Agent Issues

Focus on integration and cross-cutting concerns:

**Integration Issues to Look For**:
- API endpoints that don't match UI expectations
- Database models missing fields required by API
- Components referencing non-existent services
- Authentication/authorization gaps across layers

**Cross-Cutting Concerns**:
- Consistent error handling across all files
- Security patterns (input validation, auth checks) applied everywhere
- Performance considerations (N+1 queries, inefficient loops)
- Logging and monitoring coverage

**Architectural Consistency**:
- Naming conventions followed
- Code organization patterns maintained
- Dependency directions correct (no circular dependencies)
- Separation of concerns respected

### 4. Handle Critical/High Issues

If critical or high-priority issues found:

**Step A: Identify Responsible Agent**

Determine which agent's domain the issue falls into:
- Database issues → database-engineer
- API issues → api-engineer
- UI issues → ui-designer
- Test issues → testing-engineer

**Step B: Re-Delegate Fix**

```markdown
The comprehensive review found a critical issue in [domain]:

**Issue**: [Description from CodeRabbit]
**File**: [file path]
**Severity**: Critical/High
**Responsible Agent**: [agent-id]

[Agent-id], please:
1. Fix this issue in your files
2. Re-run your scoped review
3. Report when complete
```

**Step C: Re-Run Comprehensive Review**

After fixes:
```bash
# Re-review everything
coderabbit --prompt-only --type uncommitted
```

**Maximum iterations**: 2 comprehensive reviews

If issues persist after 2 iterations:
- Major architectural problem likely exists
- May need to redesign approach
- Escalate to team lead or architect

### 5. Verify Success

Comprehensive review passes when:
- ✅ No critical issues found
- ✅ No high-priority issues found
- ✅ All integration points validated
- ✅ Cross-cutting concerns addressed
- ✅ Architectural consistency confirmed

Medium/low issues are acceptable and can be tracked as technical debt.

### 6. Mark Review Complete

Once comprehensive review passes:

```bash
# Create marker file to indicate all reviews complete
touch agent-os/code-reviews/.all-agents-reviewed
echo "$(date): Comprehensive review passed" >> agent-os/code-reviews/.all-agents-reviewed

echo "✅ Comprehensive integration review complete!"
echo "   Ready for Phase 3 (verification)"
```

---

## Comparison: Scoped vs Comprehensive

**Scoped Reviews** (during implementation):
```bash
# Database agent reviews only database files
coderabbit --prompt-only --type uncommitted \
  --path src/models/user.rb \
  --path src/migrations/001_add_users.rb

# Catches: SQL injection, migration issues, model validation
# Misses: API expecting user.email but model doesn't have it
```

**Comprehensive Review** (after all agents done):
```bash
# Reviews ALL files together
coderabbit --prompt-only --type uncommitted

# Catches: Integration mismatches, cross-layer issues
# Example: Detects that UI calls /api/users/:id but API only has /api/user/:id
```

Both are needed for complete coverage.

---

## Performance Optimization

**Why wait until all agents done?**

Running comprehensive review after each agent would:
- Review same files multiple times (wasteful)
- Miss issues that only appear when all code is together
- Take much longer overall

Running once at the end:
- Reviews everything once (efficient)
- Sees the complete picture (effective)
- Catches true integration issues

**Estimated time**:
- Comprehensive review: 15-20 minutes
- Much faster than 4× individual full reviews (60 minutes)

---

## Integration with Implementation Flow

```
PHASE 1: Planning
  ↓
PHASE 2: Implementation
  ├─ Agent 1: Implement → Scoped Review → Fix Critical
  ├─ Agent 2: Implement → Scoped Review → Fix Critical
  ├─ Agent 3: Implement → Scoped Review → Fix Critical
  └─ Agent 4: Implement → Scoped Review → Fix Critical
  ↓
PHASE 2.5: Comprehensive Review ← YOU ARE HERE
  └─ Review all changes together
  └─ Fix integration issues
  └─ Re-review if needed
  ↓
PHASE 3: Verification
  └─ Run tests, check requirements
```

---

## Marker File Usage

The `.all-agents-reviewed` marker file serves two purposes:

**1. Skip redundant pre-commit review**

Pre-commit hook checks for this file:
```bash
if [ -f "agent-os/code-reviews/.all-agents-reviewed" ]; then
    echo "✅ Already reviewed in comprehensive review"
    echo "   Skipping redundant pre-commit review"
    exit 0
fi
```

**2. Track review completion**

Verifier agents can check this file to confirm comprehensive review completed.

**When to remove**:
- After git commit (in post-commit hook)
- At start of next implementation phase
- When starting work on new spec

---

## Troubleshooting

### Too Many Issues Found

**Problem**: Comprehensive review finds dozens of issues

**Likely cause**: Individual scoped reviews didn't run properly or were incomplete

**Solution**:
1. Check each agent's scoped review logs
2. Verify all critical/high issues were fixed
3. May need to fix architectural issues and start over

### Review Takes Too Long

**Problem**: Comprehensive review exceeds 30 minutes

**Solution**:
- Break spec into smaller phases
- Use more granular task breakdown
- Exclude large generated files from review

### Can't Determine Responsible Agent

**Problem**: Issue spans multiple domains

**Solution**:
- Assign to most relevant agent based on file location
- Or assign to most senior/experienced agent
- Document that it's a cross-cutting concern

---

## Success Metrics

**Before comprehensive review**:
- Individual agent work validated ✅
- Each domain has quality code ✅
- Unknown integration issues ❓

**After comprehensive review**:
- Integration validated ✅
- Cross-cutting concerns addressed ✅
- Architectural consistency confirmed ✅
- Ready for Phase 3 verification ✅

---

## Notes

- This is the ONLY place where full `coderabbit --type uncommitted` runs (without --path)
- All other reviews are scoped to specific files
- This catches the 20% of issues that scoped reviews miss
- Essential for multi-agent workflows
- Single-agent workflows can skip this (already reviewing all files)
