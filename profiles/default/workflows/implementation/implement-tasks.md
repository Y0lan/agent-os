Implement all tasks assigned to you and ONLY those task(s) that have been assigned to you.

## Implementation process:

1. Analyze the provided spec.md, requirements.md, and visuals (if any)
2. Analyze patterns in the codebase according to its built-in workflow
3. **Track your starting state** (if CodeRabbit enabled):
   ```bash
   # Save current file list before making changes
   git ls-files > /tmp/files_before_$(date +%s).txt
   export FILES_BEFORE="/tmp/files_before_$(date +%s).txt"
   ```
4. Implement the assigned task group according to requirements and standards
5. **Track your changes** (if CodeRabbit enabled):
   ```bash
   # Capture only files YOU modified
   git ls-files > /tmp/files_after_$(date +%s).txt
   git diff --name-only HEAD > /tmp/modified_$(date +%s).txt

   # Combine new files + modified files = your scope
   cat /tmp/modified_$(date +%s).txt > /tmp/my_files_$(date +%s).txt
   comm -13 "$FILES_BEFORE" /tmp/files_after_$(date +%s).txt >> /tmp/my_files_$(date +%s).txt

   export MY_FILES="/tmp/my_files_$(date +%s).txt"
   ```
{{IF enable_coderabbit}}
4. **Run post-task code review**: Follow {{integrations/coderabbit/workflows/post-task-review}}
5. **Fix critical issues if found**: Follow {{integrations/coderabbit/workflows/auto-fix-critical}}
6. Update `agent-os/specs/[this-spec]/tasks.md` to update the tasks you've implemented to mark that as done by updating their checkbox to checked state: `- [x]`
{{ELSE}}
4. Update `agent-os/specs/[this-spec]/tasks.md` to update the tasks you've implemented to mark that as done by updating their checkbox to checked state: `- [x]`
{{ENDIF enable_coderabbit}}

## Guide your implementation using:
- **The existing patterns** that you've found and analyzed in the codebase.
- **User Standards & Preferences** which are defined below.
{{IF enable_context7}}
- **Context7 MCP for documentation**: Use Context7 MCP to get up-to-date library documentation. See {{integrations/context7/standards/tool-preferences}} for usage guidelines.
{{ENDIF enable_context7}}

## Self-verify and test your work by:
- Running ONLY the tests you've written (if any) and ensuring those tests pass.
- IF your task involves user-facing UI, and IF you have access to browser testing tools, open a browser and use the feature you've implemented as if you are a user to ensure a user can use the feature in the intended way.
