# Agent OS Integration Guide (v2.2.0)

This guide covers setup and usage of optional third-party integrations in Agent OS v2.2.0.

## Available Integrations

Agent OS v2.2.0 introduces two optional integrations:

1. **CodeRabbit CLI** - Automated AI-powered code review
2. **Context7 MCP** - Up-to-date library documentation via Model Context Protocol

**Both integrations are completely optional and disabled by default.**

---

## Quick Start

### Check What's Enabled

```bash
cat ~/.agent-os/config.yml | grep enable_
```

Default output:
```yaml
enable_coderabbit: false
enable_context7: false
```

### Validate Installation

```bash
~/.agent-os/scripts/validate-tools.sh
```

This script checks:
- Which integrations are enabled
- Whether required tools are installed
- Provides installation instructions if tools are missing

---

## CodeRabbit CLI Integration

### What It Does

CodeRabbit provides AI-powered code review that automatically:
- Detects security vulnerabilities (SQL injection, XSS, auth bypass, etc.)
- Identifies bugs and logic errors
- Suggests performance improvements
- Enforces best practices and coding standards
- Provides actionable fix suggestions

### Installation

#### 1. Install CodeRabbit CLI

```bash
curl -fsSL https://cli.coderabbit.ai/install.sh | sh
```

This installs the `coderabbit` command globally.

#### 2. Authenticate

```bash
coderabbit auth login
```

This opens your browser to complete authentication. You'll need a CodeRabbit account (free tier available).

#### 3. Verify Installation

```bash
coderabbit --version
coderabbit auth status
```

#### 4. Enable in Agent OS

Edit `~/.agent-os/config.yml`:
```yaml
enable_coderabbit: true
```

#### 5. Re-install in Projects

```bash
cd ~/your-project
~/.agent-os/scripts/project-install.sh
```

This updates workflows with CodeRabbit integration steps.

### How It Works

#### Automatic Post-Task Review

After implementing each task, CodeRabbit automatically reviews your changes:

```
1. Implement task
2. CodeRabbit review runs (7-60 min depending on change size)
3. Critical/high issues are auto-fixed
4. Task marked complete
```

**Review is scoped to only the files YOU modified** - prevents reviewing other agents' work.

#### Manual Review

You can also run reviews manually:

```bash
# Review uncommitted changes
coderabbit --prompt-only --type uncommitted

# Review specific files
coderabbit --prompt-only --type uncommitted --path src/api/users.js

# Review PR before pushing
coderabbit --prompt-only --type pr
```

Or use the `/review-code` command within Agent OS.

#### Optional Pre-Commit Hooks

CodeRabbit can block commits with critical/high priority issues:

```bash
cd ~/your-project
~/.agent-os/profiles/default/integrations/coderabbit/hooks/install-hooks.sh
```

This installs git hooks that:
- Run CodeRabbit before allowing commits
- Block commits with critical or high-priority issues
- Allow commits with only medium/low issues (with warning)
- Can be bypassed with `git commit --no-verify` (not recommended)

**Smart Caching**: If a comprehensive review already passed, pre-commit hook skips redundant review.

### Understanding Review Severity

CodeRabbit classifies issues by severity:

- **🔴 Critical**: Security vulnerabilities, data corruption (blocks commit)
- **🟠 High**: Significant bugs, incorrect logic (blocks commit)
- **🟡 Medium**: Code quality, maintainability (warning only)
- **🟢 Low**: Style, formatting, minor improvements (warning only)

### Multi-Agent Workflows

In multi-agent workflows (4+ agents working in parallel), CodeRabbit uses scoped reviews to prevent duplication:

**Without scoping (v2.1.1 and earlier)**:
```
Agent 1: Reviews ALL files (400% duplication)
Agent 2: Reviews ALL files (wrong expertise)
Agent 3: Reviews ALL files (60 min wasted)
Agent 4: Reviews ALL files
```

**With scoping (v2.2.0)**:
```
Agent 1: Reviews only their files (correct expertise)
Agent 2: Reviews only their files (0% duplication)
Agent 3: Reviews only their files (48% faster)
Agent 4: Reviews only their files

Comprehensive Review: Reviews everything together (integration issues)
```

See [CODERABBIT_SCOPE_FIX.md](CODERABBIT_SCOPE_FIX.md) for technical details.

### Performance

**Single-agent workflow**:
- Review time: 7-60 minutes per task (depends on change size)
- Runs in background, so agent stays productive
- Catches issues early (cheaper to fix)

**Multi-agent workflow** (4 agents):
- Before: 60 min (400% duplication)
- After: 24 min + 15 min comprehensive = 39 min
- **48% faster, 0% duplication**

### Costs

CodeRabbit pricing:
- **Free tier**: Limited reviews per month
- **Pro tier**: Unlimited reviews, $15/month
- **Team tier**: Multiple users, $49/month

See https://coderabbit.ai/pricing for current pricing.

### Troubleshooting

#### "CodeRabbit CLI is not installed"

Install it:
```bash
curl -fsSL https://cli.coderabbit.ai/install.sh | sh
source ~/.zshrc  # or ~/.bashrc
```

#### "CodeRabbit CLI is not authenticated"

Authenticate:
```bash
coderabbit auth login
```

#### "Rate limit exceeded"

You've hit your plan's review limit. Either:
- Wait for reset (monthly for free tier)
- Upgrade your plan at https://coderabbit.ai/pricing
- Disable CodeRabbit temporarily in config.yml

#### Review takes too long (>60 minutes)

- Large changesets (500+ lines) can take 30-60 minutes
- Run reviews on smaller chunks
- Consider breaking large tasks into smaller subtasks

#### Pre-commit hook blocks commit

Fix the critical/high issues, or:
```bash
# Skip pre-commit check (NOT RECOMMENDED)
git commit --no-verify
```

---

## Context7 MCP Integration

### What It Does

Context7 is a Model Context Protocol (MCP) tool that provides:
- Up-to-date library documentation
- Version-specific API details
- Current best practices
- Deprecation warnings
- Migration guides

Prevents agents from using outdated documentation or deprecated APIs.

### Installation

#### 1. Install Context7 MCP Server

```bash
# Install via npm
npm install -g @context7/mcp-server

# Or via yarn
yarn global add @context7/mcp-server
```

#### 2. Configure MCP in Claude Code

Add Context7 to your MCP configuration:

**macOS/Linux**: `~/.config/claude-code/mcp.json`

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@context7/mcp-server"]
    }
  }
}
```

#### 3. Verify Installation

Restart Claude Code, then check available tools:
```
/mcp-tools
```

You should see Context7 tools listed.

#### 4. Enable in Agent OS

Edit `~/.agent-os/config.yml`:
```yaml
enable_context7: true
```

#### 5. Re-install in Projects

```bash
cd ~/your-project
~/.agent-os/scripts/project-install.sh
```

### How It Works

Context7 is used automatically during implementation:

```
1. Agent starts implementing feature
2. Agent queries Context7 for current documentation
3. Agent uses up-to-date APIs and patterns
4. Implementation uses current best practices
```

**No manual intervention required** - agents query Context7 as needed.

### Example Usage

Agents can query Context7 for:
```
"What's the current API for React hooks?"
"How do I use async/await in Node.js v20?"
"What's the recommended way to handle errors in Express?"
"Is jQuery still recommended for DOM manipulation?"
```

Context7 returns current, version-specific documentation.

### Performance

- Query time: <5 seconds per query
- Minimal impact on implementation speed
- Prevents hours of debugging from outdated docs

### Costs

Context7 pricing:
- **Free tier**: Limited queries per month
- **Pro tier**: Check https://context7.com/pricing

### Troubleshooting

#### "Context7 MCP server not found"

Install it:
```bash
npm install -g @context7/mcp-server
```

#### "MCP tools not showing in Claude Code"

1. Check MCP configuration: `~/.config/claude-code/mcp.json`
2. Restart Claude Code
3. Verify with `/mcp-tools`

#### Context7 queries failing

- Check internet connection
- Verify API key/authentication (if required)
- Check rate limits

---

## Using Both Integrations Together

Enabling both provides maximum benefits:

**Context7**: Ensures agents use current documentation
**CodeRabbit**: Validates implementation quality and security

**Workflow**:
```
1. Research (with Context7)
   ↓
2. Implement (with current docs)
   ↓
3. Review (with CodeRabbit)
   ↓
4. Fix issues
   ↓
5. Comprehensive review (integration validation)
```

**Time Investment**:
- Context7: +1 min per task
- CodeRabbit: +7-60 min per task
- **Total**: Still faster than fixing bugs in production

---

## Disabling Integrations

To disable an integration:

1. Edit `~/.agent-os/config.yml`:
   ```yaml
   enable_coderabbit: false
   enable_context7: false
   ```

2. Re-install in projects:
   ```bash
   cd ~/your-project
   ~/.agent-os/scripts/project-install.sh
   ```

Workflows will automatically revert to v2.1.1 behavior.

---

## Migration from v2.1.1

### For Users Who Don't Want Integrations

**No action required**. Agent OS v2.2.0 works exactly like v2.1.1 when integrations are disabled (default).

### For Users Who Want Integrations

1. Update Agent OS:
   ```bash
   cd ~/.agent-os
   git pull
   git checkout v2.2.0
   ```

2. Install required tools (CodeRabbit and/or Context7)

3. Enable in config.yml

4. Re-install in projects:
   ```bash
   cd ~/your-project
   ~/.agent-os/scripts/project-install.sh
   ```

5. (Optional) Install git hooks:
   ```bash
   ~/.agent-os/profiles/default/integrations/coderabbit/hooks/install-hooks.sh
   ```

---

## FAQ

### Do I need both integrations?

No. They're completely independent:
- Use CodeRabbit only: Get code review without up-to-date docs
- Use Context7 only: Get current docs without automated review
- Use both: Maximum benefits
- Use neither: Standard Agent OS v2.1.1 experience

### Will integrations slow down my workflow?

**Context7**: Minimal impact (<1 min per task)
**CodeRabbit**: 7-60 min per task, but runs in background and catches issues early (saves time overall)

### Can I use different code review tools?

Yes! The integration framework is extensible. You can:
- Fork Agent OS and add your preferred tool
- Follow the same pattern (integrations directory, conditional workflows)
- Submit PR for community benefit

### Are my API keys/credentials safe?

Yes:
- CodeRabbit: Uses OAuth authentication (no keys stored)
- Context7: Credentials stored locally by MCP
- Agent OS never accesses or stores credentials

### Can I customize review rules?

Yes! CodeRabbit supports custom configuration:
- Create `.coderabbit.yaml` in your project root
- Customize severity levels, rules, auto-fix behavior
- See https://docs.coderabbit.ai for configuration options

### Do integrations work with all languages?

**CodeRabbit**: Supports 50+ languages (JavaScript, Python, Go, Rust, Ruby, Java, etc.)
**Context7**: Supports documentation for most popular libraries and frameworks

### Can I use this in CI/CD?

**CodeRabbit**: Yes, has GitHub Actions integration
**Context7**: Designed for local development, not CI/CD

For CI/CD, consider GitHub Apps integration:
https://docs.coderabbit.ai/github-app

---

## Support

### CodeRabbit Issues

- Documentation: https://docs.coderabbit.ai
- Support: https://support.coderabbit.ai
- GitHub: https://github.com/coderabbitai/cli

### Context7 Issues

- Documentation: https://context7.com/docs
- Support: support@context7.com

### Agent OS Integration Issues

- GitHub: https://github.com/buildermethods/agent-os/issues
- Tag: `integration`, `coderabbit`, or `context7`

---

## What's Next

### Planned Enhancements

- **Phase 3**: Agent-specific CodeRabbit config files
- **More integrations**: ESLint, Prettier, testing frameworks
- **Better caching**: Reuse reviews across agents
- **Metrics**: Track review impact and time savings

### Community Contributions

Want to add more integrations? The framework is designed to be extensible:

1. Create `integrations/[tool]/` directory
2. Add `enable_[tool]: false` to config.yml
3. Create workflow files
4. Update validation script
5. Submit PR!

See [CONTRIBUTING.md](https://github.com/buildermethods/agent-os/blob/main/.github/CONTRIBUTING.md) for guidelines.

---

## Summary

**Agent OS v2.2.0** introduces an optional integration framework that:
- ✅ Enhances workflows without changing core functionality
- ✅ Completely optional (disabled by default)
- ✅ Fully backwards compatible with v2.1.1
- ✅ Extensible for future integrations
- ✅ Well-documented and easy to use

**Start simple**: Try one integration first, see if it fits your workflow.

**Questions?** Check the FAQ above or open an issue on GitHub.

Happy building! 🚀
