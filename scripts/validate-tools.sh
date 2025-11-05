#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

VALIDATION_FAILED=0
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_OS_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$AGENT_OS_DIR/config.yml"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print success message
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to print error message
print_error() {
    echo -e "${RED}❌ $1${NC}"
    VALIDATION_FAILED=1
}

# Function to print warning message
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Function to print info message
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Function to check config.yml setting
check_config_enabled() {
    local setting=$1
    if [ -f "$CONFIG_FILE" ]; then
        grep -q "^${setting}:[[:space:]]*true" "$CONFIG_FILE" 2>/dev/null
        return $?
    fi
    return 1
}

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Agent-OS Tool Validation                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check if config.yml exists
if [ ! -f "$CONFIG_FILE" ]; then
    print_warning "Config file not found at $CONFIG_FILE"
    print_info "Skipping validation. Run project-install.sh to set up."
    exit 0
fi

# Read configuration
ENABLE_CODERABBIT=$(check_config_enabled "enable_coderabbit" && echo "true" || echo "false")
ENABLE_CONTEXT7=$(check_config_enabled "enable_context7" && echo "true" || echo "false")

# Check if any integrations are enabled
if [ "$ENABLE_CODERABBIT" = "false" ] && [ "$ENABLE_CONTEXT7" = "false" ]; then
    print_info "No optional integrations enabled in config.yml"
    print_info "Agent-OS will work with standard features only."
    echo ""
    print_info "To enable integrations, set in config.yml:"
    print_info "  enable_coderabbit: true  # For code review integration"
    print_info "  enable_context7: true    # For documentation integration"
    exit 0
fi

echo "Checking enabled integrations..."
echo ""

# ===========================================
# Check Context7 MCP (if enabled)
# ===========================================
if [ "$ENABLE_CONTEXT7" = "true" ]; then
    echo -e "${BLUE}── Context7 MCP ──${NC}"

    # Check if Claude Code is installed
    if ! command_exists claude; then
        print_error "Claude Code CLI not found"
        print_info "Context7 MCP requires Claude Code to be installed"
        print_info "Install from: https://claude.com/claude-code"
    else
        # Check if Context7 is installed in Claude Code
        if claude mcp list 2>/dev/null | grep -q "context7"; then
            print_success "Context7 MCP is installed"
        else
            print_error "Context7 MCP not installed in Claude Code"
            echo ""
            print_info "To install Context7 MCP:"
            print_info "  claude mcp add context7 -- npx -y @upstash/context7-mcp"
            echo ""
            print_info "Or see: agent-os/integrations/context7/standards/setup.md"
        fi

        # Check Node.js version (required for Context7)
        if command_exists node; then
            NODE_VERSION=$(node --version | cut -d 'v' -f 2 | cut -d '.' -f 1)
            if [ "$NODE_VERSION" -ge 18 ]; then
                print_success "Node.js $NODE_VERSION (required for Context7)"
            else
                print_error "Node.js version $NODE_VERSION found, but Context7 requires Node.js 18+"
                print_info "Update Node.js: https://nodejs.org/"
            fi
        else
            print_error "Node.js not found (required for Context7)"
            print_info "Install Node.js 18+: https://nodejs.org/"
        fi
    fi
    echo ""
fi

# ===========================================
# Check CodeRabbit CLI (if enabled)
# ===========================================
if [ "$ENABLE_CODERABBIT" = "true" ]; then
    echo -e "${BLUE}── CodeRabbit CLI ──${NC}"

    if command_exists coderabbit; then
        print_success "CodeRabbit CLI is installed"

        # Check authentication status
        if coderabbit auth status &>/dev/null; then
            print_success "CodeRabbit is authenticated"
        else
            print_warning "CodeRabbit is installed but not authenticated"
            print_info "Authenticate with: coderabbit auth login"
        fi
    else
        print_error "CodeRabbit CLI not installed"
        echo ""
        print_info "To install CodeRabbit CLI:"
        print_info "  curl -fsSL https://cli.coderabbit.ai/install.sh | sh"
        print_info "  source ~/.zshrc  # or ~/.bashrc"
        echo ""
        print_info "Then authenticate:"
        print_info "  coderabbit auth login"
        echo ""
        print_info "Or see: agent-os/integrations/coderabbit/standards/setup.md"
    fi
    echo ""
fi

# ===========================================
# Summary
# ===========================================
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Validation Summary                      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

if [ $VALIDATION_FAILED -eq 1 ]; then
    print_error "Validation failed. Please install missing tools."
    echo ""
    print_info "You can:"
    print_info "  1. Install the missing tools (recommended)"
    print_info "  2. Disable features in config.yml:"
    print_info "       enable_coderabbit: false"
    print_info "       enable_context7: false"
    echo ""
    exit 1
else
    print_success "All enabled integrations are properly configured!"
    echo ""
    print_info "Enabled integrations:"
    [ "$ENABLE_CONTEXT7" = "true" ] && print_info "  ✓ Context7 MCP (documentation)"
    [ "$ENABLE_CODERABBIT" = "true" ] && print_info "  ✓ CodeRabbit CLI (code review)"
    echo ""
    exit 0
fi
