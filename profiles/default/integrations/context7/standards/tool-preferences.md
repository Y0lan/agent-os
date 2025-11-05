## Tool usage and MCP preferences

### Context7 MCP Integration

Context7 MCP provides up-to-date, version-specific documentation from official sources to prevent using outdated APIs or deprecated patterns.

#### When to Use Context7

**ALWAYS use Context7 MCP for:**
- Installing or configuring any library, framework, or tool
- Writing code that uses external APIs or third-party libraries
- Implementing patterns from specific framework versions (React, Next.js, Vue, etc.)
- Looking up current best practices and API signatures
- Understanding authentication flows, middleware, or plugins
- Checking if a feature or API exists in a specific version

**Examples of Context7 usage:**
- "Create a Next.js API route with authentication. use context7"
- "Set up Prisma with PostgreSQL connection pooling. use context7"
- "Implement React Query data fetching with error boundaries. use context7"
- "Configure TailwindCSS with custom theme colors. use context7"
- "Create Express middleware for rate limiting. use context7"

#### Context7 Tool Detection

- Look for MCP tools prefixed with: `mcp__context7__*`
- Common Context7 tools include:
  - `mcp__context7__get_docs` - Retrieve documentation for specific topics
  - `mcp__context7__search_docs` - Search across documentation
  - `mcp__context7__get_examples` - Get code examples for patterns

#### Tool Selection Priority

Follow this hierarchical order when researching or implementing features:

1. **Context7 MCP** (if library is supported) - Current, version-specific documentation
2. **Official documentation via WebFetch** (if you have direct URL) - Authoritative source
3. **WebSearch** (last resort only) - Use only for general queries or unsupported libraries

#### Proactive Context7 Usage

**Do NOT wait for explicit user request** - Automatically use Context7 when:
- The task mentions any library, framework, or tool by name
- You need to implement API calls or integrations
- You're unsure about current API signatures or patterns
- The codebase uses a specific version of a library
- You're writing setup, configuration, or installation code

**User phrases that trigger Context7:**
- Any mention of library names (React, Django, FastAPI, Rails, etc.)
- "set up", "configure", "install", "integrate"
- "how do I", "what's the best way to", "implement X with Y"
- References to specific versions ("Next.js 14", "React 18", etc.)

#### Fallback Strategy

If Context7 is unavailable or doesn't have documentation for a specific library:
1. Use WebFetch with the official documentation URL if known
2. Use WebSearch to find the official documentation site
3. Document in your response that Context7 didn't have coverage for this library
