## CodeRabbit CLI Setup

CodeRabbit CLI is a **REQUIRED** tool that provides AI-powered code reviews directly in your terminal, catching bugs, security vulnerabilities, and quality issues before they're committed.

### Why CodeRabbit CLI is Required

- **Prevents bug accumulation**: Catches issues immediately after each task
- **Security scanning**: Identifies vulnerabilities like SQL injection, XSS, CSRF
- **Code quality enforcement**: Ensures consistent standards across all code
- **Pre-commit validation**: Blocks problematic code from entering the repository
- **AI-powered analysis**: Senior developer-level review of every change

### Installation

**One-command installation:**

```bash
curl -fsSL https://cli.coderabbit.ai/install.sh | sh
```

This script:
- Detects your operating system (macOS, Linux, Windows WSL)
- Downloads the appropriate binary
- Installs to your local bin directory
- Adds CodeRabbit to your PATH

**After installation, reload your shell:**

```bash
# For Zsh (macOS default, many Linux distros)
source ~/.zshrc

# For Bash
source ~/.bashrc

# Or simply close and reopen your terminal
```

### Authentication

Link your CodeRabbit account to enable CLI access:

```bash
coderabbit auth login
```

Or use the short alias:

```bash
cr auth login
```

This command will:
1. Open your browser to CodeRabbit authentication page
2. Prompt you to log in or create an account (free tier available)
3. Generate an authentication token
4. Save the token locally for future use

**Account Options:**
- **Free tier**: Available for personal projects and open source
- **Team plans**: Enhanced features for collaborative development
- **Enterprise**: Custom deployment and advanced security features

### Requirements

- **Operating System**: macOS (Intel/Apple Silicon), Linux, or Windows (WSL required)
- **Internet connection**: Required for AI-powered analysis
- **Git repository**: CodeRabbit works with git repositories
- **Disk space**: ~50MB for CLI tool and cache

### Verification

Verify CodeRabbit CLI is installed and configured:

```bash
# Check version
coderabbit --version

# Check authentication status
coderabbit auth status

# Test with a simple review (if you have uncommitted changes)
coderabbit --prompt-only --type uncommitted
```

Expected output for `auth status`:
```
✅ Authenticated as: your-email@example.com
📊 Plan: Free / Team / Enterprise
🔄 Token expires: [date]
```

### Usage in Agent-OS

Agent-OS integrates CodeRabbit CLI into the implementation workflow:

#### 1. Post-Task Reviews

After completing each task, CodeRabbit automatically reviews uncommitted changes:

```bash
coderabbit --prompt-only --type uncommitted
```

See `workflows/implementation/post-task-review.md` for details.

#### 2. Auto-Fix Critical Issues

Critical and high-priority issues are automatically fixed by agents:

See `workflows/implementation/auto-fix-critical.md` for details.

#### 3. Pre-Commit Hooks

Git pre-commit hook runs CodeRabbit before allowing commits:

```bash
# Installed automatically by agent-os/hooks/install-hooks.sh
```

#### 4. Manual Reviews

Use `/review-code` command to manually trigger CodeRabbit at any time:

```bash
# In Claude Code
/review-code
```

### CodeRabbit CLI Commands

**Review Types:**

```bash
# Review all changes (committed + uncommitted)
coderabbit --type all

# Review only committed changes
coderabbit --type committed

# Review only uncommitted changes (staged + unstaged)
coderabbit --prompt-only --type uncommitted
```

**Output Modes:**

```bash
# Interactive mode (full TUI interface)
coderabbit

# Plain text mode (detailed, human-readable)
coderabbit --plain

# Prompt-only mode (minimal output for AI agents) - USED BY AGENT-OS
coderabbit --prompt-only --type uncommitted
```

**Advanced Options:**

```bash
# Specify base branch for comparison
coderabbit --base develop --type committed

# Include custom config files
coderabbit --config .coderabbit.yaml --config project-rules.md

# Limit to specific paths
coderabbit --path src/components --path src/services
```

**Alias Commands:**

```bash
# Short alias for all commands
cr --prompt-only --type uncommitted
cr auth status
cr --version
```

### Configuration

Create `.coderabbit.yaml` in your project root for custom settings:

```yaml
# Example configuration
reviews:
  # Focus areas
  security: high
  performance: medium
  style: low

  # Ignore patterns
  exclude:
    - "*.test.js"
    - "*.spec.ts"
    - "dist/**"
    - "build/**"
    - "node_modules/**"

  # Custom rules
  rules:
    - no-console-log
    - require-error-handling
    - enforce-type-safety
```

### Performance Considerations

**Review Duration:**
- Small changes (< 100 lines): 7-15 minutes
- Medium changes (100-500 lines): 15-30 minutes
- Large changes (500+ lines): 30-60 minutes

**Optimization Tips:**
- Review after each task (smaller scope = faster reviews)
- Use `.coderabbit.yaml` to exclude test files and build artifacts
- Run reviews in background during other work
- Cache is used for unchanged files (faster subsequent reviews)

### Troubleshooting

**Installation Issues:**

```bash
# Check if install script completed
which coderabbit

# If not found, manually add to PATH
export PATH="$HOME/.coderabbit/bin:$PATH"

# Make permanent (add to ~/.zshrc or ~/.bashrc)
echo 'export PATH="$HOME/.coderabbit/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**Authentication Problems:**

```bash
# Clear existing auth and re-login
coderabbit auth logout
coderabbit auth login

# Check token file
cat ~/.coderabbit/credentials.json
```

**Review Failures:**

- **No changes detected**: Ensure you have uncommitted changes with `git status`
- **API timeout**: Check internet connection, retry with `--retry` flag
- **Rate limit**: Upgrade to paid plan or wait for rate limit reset
- **Invalid git repo**: Ensure you're in a git repository with `git rev-parse --is-inside-work-tree`

**Permission Errors:**

```bash
# Fix permissions on CodeRabbit binary
chmod +x ~/.coderabbit/bin/coderabbit

# Fix permissions on config directory
chmod 700 ~/.coderabbit/
chmod 600 ~/.coderabbit/credentials.json
```

### Rate Limits and Quotas

**Free Tier:**
- Reviews per day: 10
- Max file size: 5MB
- Max files per review: 50

**Paid Tiers:**
- Reviews per day: Unlimited
- Max file size: 50MB
- Max files per review: 500
- Priority processing
- Team collaboration features

For Agent-OS automated workflows, **paid tier is recommended** to avoid hitting rate limits during active development.

### Integration with Git

CodeRabbit CLI integrates seamlessly with git workflows:

```bash
# Review changes before staging
coderabbit --type uncommitted

# Review staged changes before commit
git add .
coderabbit --type uncommitted

# Review last commit
git log -1 --name-only
coderabbit --type committed --base HEAD~1

# Review entire branch before PR
git checkout feature-branch
coderabbit --type committed --base main
```

### Security and Privacy

- **Code transmission**: Code sent to CodeRabbit servers for analysis (encrypted in transit)
- **Data retention**: Analysis results cached temporarily, not stored permanently
- **Private repositories**: Supported with authentication (enterprise plans include private deployment)
- **Sensitive data**: Exclude files containing secrets via `.coderabbit.yaml`

**For maximum security (enterprise only):**
- Self-hosted CodeRabbit instance
- Air-gapped deployment options
- Custom security policies

### Support and Resources

- **Documentation**: https://docs.coderabbit.ai/cli
- **GitHub Issues**: https://github.com/coderabbitai/cli/issues
- **Discord Community**: https://discord.gg/coderabbit
- **Email Support**: support@coderabbit.ai

### Updating CodeRabbit CLI

Keep CodeRabbit CLI up-to-date for latest features and bug fixes:

```bash
# Check for updates
coderabbit --version

# Update to latest version
coderabbit update

# Or reinstall
curl -fsSL https://cli.coderabbit.ai/install.sh | sh
```

Agent-OS will notify you if a CodeRabbit CLI update is available during tool validation.
