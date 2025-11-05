# Post-Task Code Review Workflow (Scoped & Background)

**Purpose**: Run automated AI-powered code review on ONLY the files you modified, in the background.

**When to use**: After completing task implementation, before marking the task as done.

**Prerequisites**:
- CodeRabbit CLI must be installed and authenticated
- Changes must be uncommitted (CodeRabbit reviews uncommitted changes)
- `enable_coderabbit: true` in config.yml
- `MY_FILES` environment variable set (from implement-tasks.md)

---

## Workflow Steps

### 1. Review ONLY Your Modified Files (Scoped Review)

**Problem Solved**: When multiple agents work in parallel, each agent should review ONLY their own files, not everyone's files.

**Solution**: Use the `MY_FILES` list captured during implementation to scope the review.

```bash
# Check if we have tracked files
if [ -z "$MY_FILES" ] || [ ! -f "$MY_FILES" ]; then
    echo "WARNING: No file tracking found. Falling back to full review."
    echo "This may review files modified by other agents."
    coderabbit --prompt-only --type uncommitted
    exit 0
fi

# Build scoped CodeRabbit command
CODERABBIT_CMD="coderabbit --prompt-only --type uncommitted"

while IFS= read -r file; do
    if [ -n "$file" ] && [ -f "$file" ]; then
        CODERABBIT_CMD="$CODERABBIT_CMD --path \"$file\""
    fi
done < "$MY_FILES"

echo "Reviewing $(wc -l < "$MY_FILES") files you modified..."
```

### 2. Run Review in Background

**Problem Solved**: Agents were blocking for 7-60 minutes during reviews instead of doing productive work.

**Solution**: Start review in background, do documentation work, then check results.

```bash
# Start review in background
REVIEW_LOG="/tmp/coderabbit_review_$(date +%s).log"
REVIEW_PID_FILE="/tmp/coderabbit_pid_$(date +%s).txt"

eval "$CODERABBIT_CMD" > "$REVIEW_LOG" 2>&1 &
REVIEW_PID=$!
echo $REVIEW_PID > "$REVIEW_PID_FILE"

echo "CodeRabbit review started in background (PID: $REVIEW_PID)"
echo "Review log: $REVIEW_LOG"
```

### 3. Do Productive Work While Review Runs

Instead of waiting idle, proceed with:
- Update `agent-os/specs/[this-spec]/tasks.md` (mark tasks complete)
- Document your implementation
- Prepare context for next task
- Write test documentation

**Important**: Do NOT start implementing the next task yet. These are documentation activities only.

### 4. Periodically Check for Completion

```bash
echo "Doing productive work while review runs..."
echo "Will check every 2 minutes for completion."

WAIT_COUNT=0
MAX_WAIT=30  # 60 minutes maximum (30 × 2 min)

while kill -0 $REVIEW_PID 2>/dev/null; do
    WAIT_COUNT=$((WAIT_COUNT + 1))

    if [ $WAIT_COUNT -ge $MAX_WAIT ]; then
        echo "ERROR: Review timed out after 60 minutes"
        echo "Log file: $REVIEW_LOG"
        kill $REVIEW_PID 2>/dev/null
        exit 1
    fi

    ELAPSED=$((WAIT_COUNT * 2))
    echo "CodeRabbit review in progress... ${ELAPSED} minutes elapsed ($(date +%H:%M:%S))"

    # Do a quick documentation check or similar productive task
    sleep 120  # Wait 2 minutes before checking again
done

echo "CodeRabbit review completed!"
```

### 5. Process Review Results

```bash
# Read and display results
echo "=== CodeRabbit Review Results ==="
cat "$REVIEW_LOG"

# Save to permanent location
mkdir -p agent-os/code-reviews
REVIEW_FILE="agent-os/code-reviews/review-$(date +%Y%m%d-%H%M%S).txt"
cp "$REVIEW_LOG" "$REVIEW_FILE"
echo "Review saved to: $REVIEW_FILE"
```

### 6. Categorize Findings

Examine the review output and categorize by severity:
- **Critical**: Security vulnerabilities, data corruption risks, critical bugs
- **High**: Significant bugs, performance issues, incorrect logic
- **Medium**: Code quality issues, maintainability concerns, minor bugs
- **Low**: Style issues, documentation improvements, suggestions

### 7. Handle Critical/High Issues

If critical or high-priority issues are found:
1. **Stop immediately** - Do not proceed with other tasks
2. **Follow auto-fix workflow** - See `auto-fix-critical.md` (it will use your scoped file list)
3. **Re-review after fixes** - Run CodeRabbit again on the same files
4. Only proceed when no critical/high issues remain

### 8. Document Medium/Low Issues

For medium and low-priority issues:
1. Note them in the implementation documentation
2. Consider addressing them if time permits
3. Add to technical debt backlog if not addressed immediately
4. These do not block task completion

---

## Why Scoped Review Matters

**Without scoping** (old approach):
```bash
# Problem: Reviews ALL uncommitted changes
coderabbit --prompt-only --type uncommitted

# If 4 agents working in parallel:
# - Database agent reviews UI changes ❌
# - API agent reviews database changes ❌
# - UI agent reviews API changes ❌
# - Same code reviewed 4+ times ❌
```

**With scoping** (new approach):
```bash
# Solution: Reviews ONLY files this agent modified
coderabbit --prompt-only --type uncommitted \
  --path src/models/user.rb \
  --path src/migrations/001_add_users.rb \
  --path spec/models/user_spec.rb

# Each agent reviews different files ✅
# No duplicate reviews ✅
# Correct domain expertise applied ✅
```

---

## Performance Comparison

**Before (synchronous, unscoped)**:
- 4 agents × 15 min sequential reviews = 60 minutes
- All agents review all code (400% duplication)
- Agents blocked during entire review
- Total: 60 minutes of wasted time

**After (background, scoped)**:
- 4 agents × 6 min scoped reviews = 24 minutes wall time
- Each reviews only ~25% of files
- Agents productive during review (documentation)
- Zero duplicate reviews
- Total: 24 minutes actual work, no blocking

**Improvement**: 60% faster, 100% more efficient

---

## Integration with Implementation Workflow

This workflow is automatically integrated when `enable_coderabbit: true`:

**Standard implementation flow**:
1. Track starting state
2. Implement task
3. Track your changes
4. **→ Run scoped review in background** (this workflow)
5. **→ Do documentation while review runs**
6. **→ Process results and auto-fix critical issues**
7. Update tasks.md
8. Proceed to next task

---

## Troubleshooting

### No Files Tracked

**Problem**: `MY_FILES` not set or empty

**Solution**: Ensure you ran the file tracking commands in `implement-tasks.md` step 3 and step 5.

**Fallback**: Review runs on all uncommitted changes (old behavior).

### Review Takes Too Long

**Problem**: Review exceeds 60 minutes

**Solution**:
- Break changes into smaller tasks
- Exclude unnecessary files from git tracking
- Check CodeRabbit service status

### Background Process Lost

**Problem**: Lost track of review PID

**Solution**:
```bash
# Find CodeRabbit processes
ps aux | grep coderabbit

# Check log file
tail -f $REVIEW_LOG
```

---

## Notes

- CodeRabbit requires active internet connection
- Scoped reviews are faster (fewer files to analyze)
- Always address critical/high issues before proceeding
- Medium/low issues can be addressed later
- Reviews are most effective on focused, single-responsibility changes
- Background execution allows agents to be productive during reviews

---

## Skipping Reviews

If you need to skip the review (e.g., documentation-only changes):
1. Consider if the change truly needs no review
2. Document why the review was skipped
3. Ensure no code logic was modified

**When skipping is appropriate**:
- Pure documentation changes (README, comments only)
- Configuration file updates with no logic
- Asset files (images, icons, etc.)

**When skipping is NOT appropriate**:
- Any code logic changes
- API modifications
- Database schema changes
- Security-related updates
