## MCP Server Setup

Model Context Protocol (MCP) servers extend Claude's capabilities by providing real-time access to external data sources and tools.

### Context7 MCP (Documentation Provider)

Context7 is an **REQUIRED** MCP server that provides up-to-date, version-specific documentation for libraries and frameworks, preventing outdated API usage and reducing hallucinations.

#### Why Context7 is Required

- **Prevents outdated library usage**: Accesses current documentation from official sources
- **Version-specific examples**: Provides code examples for the exact library version in use
- **Reduces hallucinations**: Eliminates guessing about API signatures and patterns
- **Real-time updates**: Always has the latest documentation, even for recently released versions

#### Installation

**Method 1: Claude Code (Recommended)**

```bash
claude mcp add context7 -- npx -y @upstash/context7-mcp --api-key YOUR_API_KEY
```

**Method 2: HTTP Transport (Alternative)**

```bash
claude mcp add --transport http context7 https://mcp.context7.com/mcp --header "CONTEXT7_API_KEY: YOUR_API_KEY"
```

**Method 3: Manual Configuration**

Edit your Claude Code config file (`~/.claude/config.json` or `claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp", "--api-key", "YOUR_API_KEY"]
    }
  }
}
```

#### Getting an API Key

While Context7 works without an API key (with rate limits), an API key is **highly recommended** for Agent-OS workflows:

1. Visit https://context7.com/dashboard
2. Sign up for a free account (GitHub auth available)
3. Generate an API key
4. Use the key in installation command

**Benefits with API key:**
- Higher rate limits for automated workflows
- Access to private repository documentation
- Priority support
- Usage analytics

#### Requirements

- **Node.js**: Version 18.0.0 or higher
- **Internet connection**: Required for documentation fetching
- **Claude Code**: Latest version recommended

#### Verification

After installation, verify Context7 is working:

1. **Restart Claude Code** completely (close and reopen)

2. **Check available tools**:
   ```bash
   claude mcp list
   ```

   You should see context7 in the list of MCP servers.

3. **Test Context7**:

   Open Claude Code and try a query like:
   ```
   Create a Next.js API route with authentication. use context7
   ```

   Context7 should automatically fetch relevant Next.js documentation.

#### Troubleshooting

**Context7 not showing up:**
- Ensure Node.js >= 18.0.0: `node --version`
- Completely restart Claude Code (not just reload)
- Check for typos in API key
- Verify internet connection

**Rate limit errors:**
- Sign up for API key at context7.com/dashboard
- Ensure API key is correctly added to configuration

**Documentation not found:**
- Context7 may not have coverage for all libraries (focuses on popular ones)
- Fallback to WebFetch with official docs URL
- Report missing libraries at context7.com for future addition

#### Usage in Agent-OS

Once Context7 is installed, Agent-OS agents will automatically use it when:
- Working with libraries, frameworks, or APIs
- Implementing features that require library-specific patterns
- Setting up or configuring tools
- Looking up current best practices

See `tool-preferences.md` for detailed usage guidelines.

#### Alternative MCP Servers (Optional)

While Context7 is required, you may also want to install:

- **Filesystem MCP**: Access local files and directories
- **GitHub MCP**: Interact with GitHub repositories and issues
- **Database MCP**: Query databases directly
- **Custom MCP servers**: Build your own for project-specific needs

Refer to MCP documentation for installation: https://modelcontextprotocol.io
