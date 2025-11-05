#!/usr/bin/env bash

# =============================================================================
# Install Agent-OS Git Hooks
# Installs pre-commit and other git hooks into the project's .git/hooks directory
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_DIR="${1:-.}"
HOOKS_SOURCE_DIR="${2:-agent-os/hooks}"

# Function to print colored messages
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if we're in a git repository
if [ ! -d "$PROJECT_DIR/.git" ]; then
    print_error "Not a git repository: $PROJECT_DIR"
    echo ""
    print_info "Git hooks can only be installed in git repositories."
    print_info "Initialize git first with: git init"
    echo ""
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p "$PROJECT_DIR/.git/hooks"

echo ""
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Installing Agent-OS Git Hooks${NC}"
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo ""

HOOKS_INSTALLED=0
HOOKS_SKIPPED=0
HOOKS_FAILED=0

# Install pre-commit hook
if [ -f "$PROJECT_DIR/$HOOKS_SOURCE_DIR/pre-commit" ]; then
    DEST_HOOK="$PROJECT_DIR/.git/hooks/pre-commit"

    # Check if hook already exists
    if [ -f "$DEST_HOOK" ]; then
        # Check if it's our hook
        if grep -q "Agent-OS Pre-Commit Hook" "$DEST_HOOK"; then
            print_info "Pre-commit hook already installed (Agent-OS version)"
            HOOKS_SKIPPED=$((HOOKS_SKIPPED + 1))
        else
            print_warning "Pre-commit hook already exists (non-Agent-OS version)"
            echo ""
            print_info "Existing hook found at: $DEST_HOOK"
            echo ""

            # Ask user what to do
            read -p "  Replace with Agent-OS hook? (y/n): " -n 1 -r
            echo ""

            if [[ $REPLY =~ ^[Yy]$ ]]; then
                # Backup existing hook
                BACKUP_FILE="$DEST_HOOK.backup-$(date +%Y%m%d-%H%M%S)"
                cp "$DEST_HOOK" "$BACKUP_FILE"
                print_info "Backed up existing hook to: $BACKUP_FILE"

                # Install our hook
                cp "$PROJECT_DIR/$HOOKS_SOURCE_DIR/pre-commit" "$DEST_HOOK"
                chmod +x "$DEST_HOOK"
                print_success "Installed pre-commit hook"
                HOOKS_INSTALLED=$((HOOKS_INSTALLED + 1))
            else
                print_info "Keeping existing pre-commit hook"
                HOOKS_SKIPPED=$((HOOKS_SKIPPED + 1))
            fi
        fi
    else
        # Install hook
        cp "$PROJECT_DIR/$HOOKS_SOURCE_DIR/pre-commit" "$DEST_HOOK"
        chmod +x "$DEST_HOOK"
        print_success "Installed pre-commit hook"
        HOOKS_INSTALLED=$((HOOKS_INSTALLED + 1))
    fi
else
    print_warning "Pre-commit hook source not found: $PROJECT_DIR/$HOOKS_SOURCE_DIR/pre-commit"
    HOOKS_FAILED=$((HOOKS_FAILED + 1))
fi

# Summary
echo ""
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo "  Summary:"
echo "    Installed: $HOOKS_INSTALLED"
echo "    Skipped:   $HOOKS_SKIPPED"
echo "    Failed:    $HOOKS_FAILED"
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo ""

# Provide information about the hooks
if [ $HOOKS_INSTALLED -gt 0 ]; then
    echo "Git hooks have been installed:"
    echo ""
    echo "📋 Pre-commit Hook:"
    echo "   - Runs CodeRabbit CLI review before each commit"
    echo "   - Blocks commits with critical or high-priority issues"
    echo "   - Allows commits with medium/low priority issues (with warning)"
    echo "   - Saves review reports to: agent-os/code-reviews/"
    echo ""
    echo "To bypass the hook (NOT RECOMMENDED):"
    echo "   git commit --no-verify"
    echo ""
    echo "To uninstall hooks:"
    echo "   rm .git/hooks/pre-commit"
    echo ""
fi

if [ $HOOKS_FAILED -gt 0 ]; then
    print_error "Some hooks failed to install"
    exit 1
fi

print_success "Git hooks setup complete"
echo ""

exit 0
