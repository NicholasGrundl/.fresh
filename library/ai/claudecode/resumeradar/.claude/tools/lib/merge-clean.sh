#!/usr/bin/env bash
#
# merge-clean.sh - Squash merge a branch, keeping only non-MICRO commit messages
#
# Purpose: Merge a feature branch into target, discarding MICRO commits
#          but preserving MACRO and other meaningful commit messages
#
# Usage: merge-clean.sh <source-branch> [target-branch]
#   source-branch: Branch to merge from (required)
#   target-branch: Branch to merge into (default: main)
#
# Options:
#   -n, --dry-run   Show what would happen without making changes
#   -y, --yes       Skip confirmation prompts (for non-interactive use)
#   --keep-branch   Don't delete source branch after merge
#   -h, --help      Show this help message
#
# Exit codes:
#   0 - Success
#   1 - Error (invalid args, not a git repo, dirty tree, etc.)

set -euo pipefail

# Defaults
DRY_RUN=false
YES_MODE=false
KEEP_BRANCH=false
TARGET_BRANCH="main"
SOURCE_BRANCH=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -y|--yes)
            YES_MODE=true
            shift
            ;;
        --keep-branch)
            KEEP_BRANCH=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 <source-branch> [target-branch]"
            echo ""
            echo "Squash merge a branch, keeping only non-MICRO commit messages"
            echo ""
            echo "Arguments:"
            echo "  source-branch    Branch to merge from (required)"
            echo "  target-branch    Branch to merge into (default: main)"
            echo ""
            echo "Options:"
            echo "  -n, --dry-run    Show what would happen without making changes"
            echo "  -h, --help       Show this help message"
            echo ""
            echo "Example:"
            echo "  $0 feature-branch           # Merge feature-branch into main"
            echo "  $0 feature-branch develop   # Merge feature-branch into develop"
            echo "  $0 -n feature-branch        # Dry run"
            exit 0
            ;;
        -*)
            echo "Error: Unknown option '$1'" >&2
            echo "Use -h for help" >&2
            exit 1
            ;;
        *)
            if [[ -z "$SOURCE_BRANCH" ]]; then
                SOURCE_BRANCH="$1"
            else
                TARGET_BRANCH="$1"
            fi
            shift
            ;;
    esac
done

# Validate source branch provided
if [[ -z "$SOURCE_BRANCH" ]]; then
    echo "Error: Source branch required" >&2
    echo "Use -h for help" >&2
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir &> /dev/null; then
    echo "Error: Not a git repository" >&2
    exit 1
fi

# Verify branches exist
if ! git rev-parse --verify "$SOURCE_BRANCH" &>/dev/null; then
    echo "Error: Branch '$SOURCE_BRANCH' does not exist" >&2
    exit 1
fi

if ! git rev-parse --verify "$TARGET_BRANCH" &>/dev/null; then
    echo "Error: Branch '$TARGET_BRANCH' does not exist" >&2
    exit 1
fi

# Check for clean working tree
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "Error: Working tree has uncommitted changes" >&2
    echo "Please commit or stash changes first" >&2
    exit 1
fi

# Get commit counts
TOTAL_COUNT=$(git log "$TARGET_BRANCH..$SOURCE_BRANCH" --oneline | wc -l | tr -d ' ')
MICRO_COUNT=$(git log "$TARGET_BRANCH..$SOURCE_BRANCH" --oneline --grep="MICRO" | wc -l | tr -d ' ')
NON_MICRO_COUNT=$(git log "$TARGET_BRANCH..$SOURCE_BRANCH" --oneline --grep="MICRO" --invert-grep | wc -l | tr -d ' ')

echo "=== Merge Clean: $SOURCE_BRANCH → $TARGET_BRANCH ==="
echo ""
echo "Commit summary:"
echo "  Total commits:      $TOTAL_COUNT"
echo "  MICRO (discard):    $MICRO_COUNT"
echo "  Non-MICRO (keep):   $NON_MICRO_COUNT"
echo ""

if [[ "$NON_MICRO_COUNT" -eq 0 ]]; then
    echo "Warning: No non-MICRO commits found"
    echo "The squash commit will have a generic message"
    echo ""
fi

# Get non-MICRO commit messages (oldest first, for logical order)
echo "Non-MICRO commits to include in message:"
echo "---"
git log "$TARGET_BRANCH..$SOURCE_BRANCH" --grep="MICRO" --invert-grep \
    --format="• %s" --reverse
echo "---"
echo ""

# Build the commit message
COMMIT_TITLE="Merge branch '$SOURCE_BRANCH' (squashed, $NON_MICRO_COUNT commits)"
COMMIT_BODY=$(git log "$TARGET_BRANCH..$SOURCE_BRANCH" --grep="MICRO" --invert-grep \
    --format="• %s%n%n%b" --reverse | sed '/^$/N;/^\n$/d')

# Dry run check
if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY RUN] Would create squash commit with message:"
    echo "============================================"
    echo "$COMMIT_TITLE"
    echo ""
    echo "$COMMIT_BODY"
    echo "============================================"
    echo ""
    echo "[DRY RUN] No changes made"
    exit 0
fi

# Confirm before proceeding
if [[ "$YES_MODE" != true ]]; then
    read -p "Proceed with merge? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted"
        exit 0
    fi
fi

# Store current branch
ORIGINAL_BRANCH=$(git branch --show-current)

# Perform the squash merge
echo ""
echo "Switching to $TARGET_BRANCH..."
git checkout "$TARGET_BRANCH"

echo "Squash merging $SOURCE_BRANCH..."
git merge --squash "$SOURCE_BRANCH"

echo "Creating commit..."
git commit -m "$COMMIT_TITLE

$COMMIT_BODY"

echo ""
echo "Merge complete!"
echo ""

# Show result
echo "New commit on $TARGET_BRANCH:"
git log -1 --oneline
echo ""

# Handle source branch cleanup
if [[ "$KEEP_BRANCH" == true ]]; then
    echo "Kept '$SOURCE_BRANCH' (--keep-branch specified)"
elif [[ "$YES_MODE" == true ]]; then
    git branch -D "$SOURCE_BRANCH"
    echo "Deleted '$SOURCE_BRANCH'"
else
    read -p "Delete source branch '$SOURCE_BRANCH'? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git branch -D "$SOURCE_BRANCH"
        echo "Deleted '$SOURCE_BRANCH'"
    else
        echo "Kept '$SOURCE_BRANCH' (you can delete later with: git branch -D $SOURCE_BRANCH)"
    fi
fi

echo ""
echo "=== Done ==="
