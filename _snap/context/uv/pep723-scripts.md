# PEP 723 - Inline Script Metadata with uv

PEP 723 allows you to define dependencies and Python requirements directly within a single Python file. `uv` provides first-class support for this, making it easy to create and run portable, standalone scripts.

## Metadata Block Format

Add a `# /// script` block at the top of your `.py` file:

```python
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "httpx",
#     "rich",
# ]
# ///

import httpx
from rich import print

print("Hello from a PEP 723 script!")
```

## Running Scripts

To run a script with inline metadata, use:

```bash
uv run script.py
```

`uv` will automatically:
1. Create a temporary, cached virtual environment.
2. Install the specified dependencies.
3. Execute the script.

## Managing Dependencies

You can use `uv` to manage the metadata block without manual editing:

```bash
# Add a dependency to a script
uv add --script script.py requests

# Remove a dependency from a script
uv remove --script script.py requests
```

## Shebang for Direct Execution

To make a script executable directly (e.g., `./script.py`), add a shebang line:

```python
#!/usr/bin/env uv run
# /// script
# ...
```

Then make the file executable:
```bash
chmod +x script.py
```

## Best Use Cases
- Single-file utilities and tools.
- Demos and examples.
- Scripts shared via Gists or Pastebin.
- Tasks that should remain isolated from a project's main pyproject.toml.
