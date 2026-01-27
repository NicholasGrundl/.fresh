## Background

This prompt lets a agentic AI access and manage github WITHOUT needing to install the gh cli. Most agents have a cUrl tool or the like and should be able to operate this way.

As a prerequisite you will need to create a short lived PAT token for the agent.
- Github->settings-> developer settings (very bottom)

Then create a new fine grane access token for the SPECIFIC REPO only
- lifetime your choice but short ideally
- permissions include:
    - Content -> read + write
    - Metadata -> read
    - Issues -> read + write
    - Pull -> read + write

## Prompt

<repository>
[paste repository ssh here]
</repository>
<pat_token>

I'm giving you a GitHub personal access token to work with the <repository> 

Token: 
[paste PAT token here]

STRICT RULES:
1. Only work with repository: <repository> 
2. Never use DELETE operations - only GET, POST, PATCH, PUT
3. Never delete branches, files, or issues
4. Use curl with the GitHub REST API instead of gh CLI
5. Always show me the curl command before executing

Example API calls:
- List files: curl -H "Authorization: token $TOKEN" https://api.github.com/repos/OWNER/REPO/contents/path
- Create/update file: Use PUT to /repos/OWNER/REPO/contents/path
- Create issue: POST to /repos/OWNER/REPO/issues

Documentation: https://docs.github.com/en/rest

You only have the following permissions:
- Contents: Read and write (for reading/creating/updating files, NOT deleting)
- Issues: Read and write (if needed)
- Pull requests: Read and write (if needed)
- Metadata: Read-only (automatically included)

When creating issues use the <tags> below to add context and metadata to the issues. If the <tags> do not exist create them first.

<tags>
Priority Labels
P0-critical - Color: d73a4a - Description: "Critical priority - must fix immediately"
P1-high - Color: ff9800 - Description: "High priority - important features"
P2-medium - Color: ffd700 - Description: "Medium priority - enhancements"
P3-low - Color: 0366d6 - Description: "Low priority - nice to have"
Type Labels
bug - Color: d73a4a - Description: "Something isn't working"
enhancement - Color: a2eeef - Description: "New feature or request"
feature - Color: 00ff00 - Description: "New feature implementation"
documentation - Color: 0075ca - Description: "Documentation improvements"
infrastructure - Color: 9b59b6 - Description: "CI/CD, tooling, infrastructure"
tooling - Color: 7f8c8d - Description: "Development tools and workflow"
dependencies - Color: 8b4513 - Description: "Dependency updates"
type-safety - Color: 663399 - Description: "Type hints and mypy"
Special Labels
epic - Color: 9b59b6 - Description: "Large feature spanning multiple issues"
good-first-issue - Color: 7057ff - Description: "Good for newcomers"
</tags>