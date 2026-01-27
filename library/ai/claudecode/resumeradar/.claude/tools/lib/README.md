# Git Context Library - Modular Scripts for Commit Analysis

This directory contains modular, Unix-philosophy scripts for extracting git context, building LLM prompts, and automating MACRO commit generation.

## Philosophy

These scripts follow the Unix philosophy:
- **Do one thing well** - Each script has a single, focused purpose
- **Composable** - Scripts can be chained together via pipes
- **Text streams** - Input/output via stdin/stdout for easy integration
- **Fail gracefully** - Clear error messages, sensible exit codes

## Scripts Overview

### 1. `git-context-macro.sh` - Extract MACRO Commits

**Purpose:** Get non-MICRO commits (semantic work milestones) with full body text

**Usage:**
```bash
./git-context-macro.sh [-n COUNT]
```

**Options:**
- `-n, --count COUNT` - Number of commits to retrieve (default: 5)
- `-h, --help` - Show help message

**Output Format:**
```
=== MACRO COMMITS (Last N) ===

hash|date|subject

full commit body (multiple paragraphs)

---
hash|date|subject

full commit body

---
=== END MACRO COMMITS (N commits) ===
```

**Example:**
```bash
# Get last 3 MACRO commits
./git-context-macro.sh -n 3

# Get last 10 MACRO commits
./git-context-macro.sh --count 10
```

---

### 2. `git-context-micro.sh` - Extract MICRO Commits

**Purpose:** Get MICRO commits (auto file edits) with diff statistics

**Usage:**
```bash
./git-context-micro.sh [-n COUNT]
```

**Options:**
- `-n, --count COUNT` - Number of commits to retrieve (default: 20)
- `-h, --help` - Show help message

**Output Format:**
```
=== MICRO COMMITS (Last N) ===

hash|date|subject

 file1.txt | 10 +++++++---
 file2.py  |  5 ++---
 2 files changed, 9 insertions(+), 6 deletions(-)

hash|date|subject

 file3.sh | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

=== END MICRO COMMITS (N commits) ===
```

**Example:**
```bash
# Get last 15 MICRO commits with stats
./git-context-micro.sh -n 15

# Get default (20 MICRO commits)
./git-context-micro.sh
```

---

### 3. `git-context-status.sh` - Get Current Git Status

**Purpose:** Capture staged, unstaged, and untracked files in structured format

**Usage:**
```bash
./git-context-status.sh
```

**Output Format:**
```
=== CURRENT GIT STATUS ===

Branch: main

--- Staged Files (ready to commit) ---
  + file1.txt
  + file2.py

--- Unstaged Files (modified, not staged) ---
  M file3.sh

--- Untracked Files (not in git) ---
  ? new-file.txt

--- Deleted Files ---
  D old-file.txt

Summary: 2 staged, 1 unstaged, 1 untracked, 1 deleted

=== END GIT STATUS ===
```

**Example:**
```bash
# Get current git status
./git-context-status.sh

# Combine with other context
./git-context-status.sh > current-status.txt
```

---

### 4. `git-context-full.sh` - Complete Project Context

**Purpose:** Orchestrator that combines MACRO, MICRO, and status into complete context

**Usage:**
```bash
./git-context-full.sh [--macro-count N] [--micro-count N]
```

**Options:**
- `--macro-count N` - Number of MACRO commits (default: 5)
- `--micro-count N` - Number of MICRO commits (default: 20)
- `-h, --help` - Show help message

**Output Format:**
```
========================================
GIT PROJECT CONTEXT
Generated: 2025-11-20 13:00:00
========================================

[Current git status section]

[MACRO commits section]

[MICRO commits section]

========================================
END GIT PROJECT CONTEXT
========================================
```

**Example:**
```bash
# Get default context (5 MACRO, 20 MICRO)
./git-context-full.sh

# Get more detailed context (10 MACRO, 50 MICRO)
./git-context-full.sh --macro-count 10 --micro-count 50

# Get quick context (2 MACRO, 5 MICRO)
./git-context-full.sh --macro-count 2 --micro-count 5

# Save to file
./git-context-full.sh > project-context.txt
```

---

### 5. `prompt-build-macro.sh` - Build LLM Prompt

**Purpose:** Combine git context with template to create complete LLM prompt

**Usage:**
```bash
./prompt-build-macro.sh [--template FILE] < git-context
```

**Options:**
- `--template, -t FILE` - Template file (default: `../templates/macro-commit-prompt.txt`)
- `-h, --help` - Show help message

**Template Placeholders:**
- `{{GIT_CONTEXT}}` - Replaced with git context from stdin
- `{{TIMESTAMP}}` - Replaced with current timestamp

**Example:**
```bash
# Use default template
./git-context-full.sh | ./prompt-build-macro.sh

# Use custom template
./git-context-full.sh | ./prompt-build-macro.sh --template my-template.txt

# Save prompt to file
./git-context-full.sh | ./prompt-build-macro.sh > llm-prompt.txt
```

---

### 6. `llm-summarize.sh` - LLM Handler with Fallback

**Purpose:** Send prompt to LLM with graceful fallback chain

**Usage:**
```bash
./llm-summarize.sh [--file FILE] < prompt
echo "prompt text" | ./llm-summarize.sh
```

**Options:**
- `--file, -f FILE` - Read prompt from file instead of stdin
- `-h, --help` - Show help message

**LLM Priority Chain:**
1. **Gemini** - If `gemini` command exists and `GOOGLE_API_KEY` is set
2. **Claude** - If `anthropic` or `claude` command exists and `ANTHROPIC_API_KEY` is set
3. **Ollama** - If `ollama` command exists (uses llama2 model)
4. **Passthrough** - Returns original prompt if all LLMs fail

**Output Format (LLM Success):**
```
<!-- LLM: Gemini -->
<!-- Status: Success -->

[LLM-generated response]
```

**Output Format (Passthrough):**
```
<!-- LLM: None (Passthrough) -->
<!-- Status: No LLM available -->
<!-- Reason: All LLMs failed or unavailable -->

[Original prompt]
```

**Example:**
```bash
# Pipe prompt to LLM
echo "Summarize this session" | ./llm-summarize.sh

# Read from file
./llm-summarize.sh --file prompt.txt

# Full pipeline
./git-context-full.sh | ./prompt-build-macro.sh | ./llm-summarize.sh
```

**Environment Variables:**
- `GOOGLE_API_KEY` - Required for Gemini
- `ANTHROPIC_API_KEY` - Required for Claude

---

## Complete Pipeline Examples

### Basic Auto-Commit Workflow

```bash
# Full pipeline: context → prompt → LLM → output
.claude/tools/lib/git-context-full.sh \
  | .claude/tools/lib/prompt-build-macro.sh \
  | .claude/tools/lib/llm-summarize.sh
```

### Custom Depth Analysis

```bash
# Deep analysis (more history)
.claude/tools/lib/git-context-full.sh --macro-count 10 --micro-count 50 \
  | .claude/tools/lib/prompt-build-macro.sh \
  | .claude/tools/lib/llm-summarize.sh

# Quick analysis (less history)
.claude/tools/lib/git-context-full.sh --macro-count 2 --micro-count 5 \
  | .claude/tools/lib/prompt-build-macro.sh \
  | .claude/tools/lib/llm-summarize.sh
```

### Individual Script Usage

```bash
# Just get MACRO commits for review
./git-context-macro.sh -n 5

# Just get recent MICRO activity
./git-context-micro.sh -n 10

# Just check current status
./git-context-status.sh

# Combine specific parts
{
  ./git-context-status.sh
  echo ""
  ./git-context-macro.sh -n 3
} | ./prompt-build-macro.sh | ./llm-summarize.sh
```

### Debugging and Inspection

```bash
# Save intermediate outputs
./git-context-full.sh > /tmp/context.txt
cat /tmp/context.txt | ./prompt-build-macro.sh > /tmp/prompt.txt
cat /tmp/prompt.txt | ./llm-summarize.sh > /tmp/llm-output.txt

# Check each step
cat /tmp/context.txt    # Review git context
cat /tmp/prompt.txt     # Review complete prompt
cat /tmp/llm-output.txt # Review LLM response or passthrough
```

## Integration with Claude Code

### `/commit-auto` Command

The modular scripts are integrated into the `/commit-auto` command (see `.claude/commands/commit-auto.md`):

1. Snapshots current git state (for async safety)
2. Runs the full pipeline to generate commit message
3. Detects if output is LLM summary or passthrough
4. Stages files safely (only those from snapshot)
5. Creates MACRO commit with `[MACRO]` prefix
6. Reports results to user

**Usage in Claude Code:**
```
/commit-auto
```

## Template Customization

The default template is at `.claude/tools/templates/macro-commit-prompt.txt`

**Creating Custom Templates:**

1. Copy the default template:
```bash
cp .claude/tools/templates/macro-commit-prompt.txt my-template.txt
```

2. Edit placeholders and instructions:
- `{{GIT_CONTEXT}}` will be replaced with git context
- `{{TIMESTAMP}}` will be replaced with current time

3. Use with prompt-build-macro.sh:
```bash
./git-context-full.sh | ./prompt-build-macro.sh --template my-template.txt
```

## Error Handling

All scripts follow consistent error handling:

**Exit Codes:**
- `0` - Success
- `1` - Error (invalid arguments, not a git repo, missing dependencies, etc.)

**Error Messages:**
- Written to stderr (can be captured separately)
- Clear, actionable error descriptions

**Example:**
```bash
# Capture errors separately
./git-context-macro.sh -n 5 2> errors.log

# Check exit code
if ./git-context-full.sh > context.txt; then
    echo "Success"
else
    echo "Failed with exit code $?"
fi
```

## Testing

### Test Individual Scripts

```bash
# Test MACRO extraction
./git-context-macro.sh -n 3

# Test MICRO extraction
./git-context-micro.sh -n 5

# Test status extraction
./git-context-status.sh

# Test full orchestrator
./git-context-full.sh --macro-count 2 --micro-count 3
```

### Test Pipeline

```bash
# Test without LLM (passthrough)
./git-context-full.sh | ./prompt-build-macro.sh | ./llm-summarize.sh

# Test with different depths
./git-context-full.sh --macro-count 1 --micro-count 2 \
  | ./prompt-build-macro.sh \
  | ./llm-summarize.sh
```

### Verify Output Format

```bash
# Check for proper metadata in LLM output
./git-context-full.sh | ./prompt-build-macro.sh | ./llm-summarize.sh \
  | head -5 \
  | grep "<!-- LLM:"
```

## Troubleshooting

### Script Not Found

**Error:** `bash: ./git-context-macro.sh: No such file or directory`

**Solution:** Ensure you're in the correct directory or use full path:
```bash
cd .claude/tools/lib/
./git-context-macro.sh -n 5
```

### Permission Denied

**Error:** `bash: ./git-context-macro.sh: Permission denied`

**Solution:** Make scripts executable:
```bash
chmod +x .claude/tools/lib/*.sh
```

### Not a Git Repository

**Error:** `Error: Not a git repository`

**Solution:** Run scripts from within a git repository:
```bash
cd /path/to/your/git/repo
./.claude/tools/lib/git-context-macro.sh -n 5
```

### Template Not Found

**Error:** `Error: Template file not found`

**Solution:** Check template exists or specify custom template:
```bash
ls .claude/tools/templates/macro-commit-prompt.txt
# Or use custom template
./prompt-build-macro.sh --template /path/to/template.txt
```

### LLM Not Available

**Info:** `<!-- LLM: None (Passthrough) -->`

**Note:** This is expected if no LLM CLI is installed. The script gracefully falls back to returning the original prompt.

**To enable LLM:**
1. Install Gemini CLI: `npm install -g @google/generative-ai-cli` (or similar)
2. Set API key: `export GOOGLE_API_KEY=your_key_here`
3. Test: `gemini "test prompt"`

## Future Enhancements

Potential improvements to consider:

- [ ] Add JSON output format option for programmatic parsing
- [ ] Support for custom git log filters (author, date range, etc.)
- [ ] Parallel execution of MACRO/MICRO/status extraction
- [ ] Caching of git context to avoid repeated queries
- [ ] Progress indicators for long-running LLM calls
- [ ] Support for additional LLM providers (OpenAI, local models, etc.)
- [ ] Configurable timeout for LLM calls
- [ ] Retry logic with exponential backoff for LLM failures

## Related Files

- **Command:** `.claude/commands/commit-auto.md` - Claude Code slash command
- **Template:** `.claude/tools/templates/macro-commit-prompt.txt` - Default LLM prompt template
- **Legacy:** `.claude/hooks/macro-commit.sh` - Original monolithic macro commit script (to be deprecated)

## Contributing

When modifying these scripts:

1. **Maintain backward compatibility** - Don't change output formats without versioning
2. **Test thoroughly** - Test with various repository states (clean, dirty, no commits, etc.)
3. **Document changes** - Update this README and inline help messages
4. **Follow Unix philosophy** - Keep scripts focused and composable
5. **Handle errors gracefully** - Clear messages, proper exit codes
