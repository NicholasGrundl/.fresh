---
description: Updates module docstrings to follow sklearn-style documentation standards
allowed-tools: [
  "Bash(grep:*)",
  "Read",
  "Edit"
]
argument-hint: "[module paths or patterns, e.g., src/[module]/*.py]"
---

## Context

You are tasked with improving Python module docstrings to follow a sklearn-inspired documentation style that balances thoroughness with pragmatism.

First, identify the target modules:
- If arguments provided: Use the specified paths/patterns
- If no arguments: Ask user which modules to update
- Read all target module files to understand their current state

## Your Task

Update docstrings for Python modules and their key functions/classes to be:
1. **Human-readable**: Clear explanations of purpose, arguments, return values
2. **AI agent-friendly**: Explicit intent, parameter types, usage patterns
3. **Balanced**: Thorough enough to be useful, concise enough to maintain

## Documentation Style Guide

### Module-Level Docstrings

Should include:
- **Brief summary** (1-2 sentences): What the module does
- **Longer description** (1-2 paragraphs): Key concepts, use cases, how it fits in the project
- **Key classes/functions** (optional): Brief mention of main exports
- **Example usage** (optional): Simple import/usage example if helpful

### Class Docstrings

Should include:
- **Brief summary** (1 sentence): What the class represents/does
- **Longer description** (1-2 paragraphs): Purpose, key behaviors, design intent
- **Parameters section**: Constructor arguments with types and descriptions
- **Attributes section**: Key instance attributes with types and descriptions
- **Example**: Simple usage example (2-5 lines)

### Function/Method Docstrings

Should include:
- **Brief summary** (1 sentence): What the function does
- **Longer description** (optional, 1 paragraph): Additional context if needed
- **Parameters section**: Each argument with type, description, default if applicable
- **Returns section**: Return type and description
- **Raises section** (if applicable): Exceptions that may be raised
- **Example** (optional): Simple usage for complex functions

## Formatting Standards

### Style Template (sklearn-inspired)

```python
"""
Brief one-line summary of what this module/class/function does.

Longer description that provides context, explains the purpose, and
describes key concepts or usage patterns. This should help developers
understand when and how to use this code.

For classes/functions, explain the design intent and how it fits into
the larger system. Keep this pragmatic - 1-2 paragraphs maximum.

Parameters
----------
param_name : type
    Description of the parameter. Include information about valid
    values, defaults, and any constraints or special behavior.
another_param : type, default=None
    Another parameter description. Note the default value in the
    type specification.

Returns
-------
return_type
    Description of what is returned. Be specific about the structure
    for complex return types.

Raises
------
ExceptionType
    When this exception is raised and why.

Attributes
----------
attr_name : type
    Description of this attribute (for classes).

Examples
--------
>>> from module import ClassName
>>> obj = ClassName(param="value")
>>> result = obj.method()
>>> print(result)
'expected output'

Notes
-----
Additional information that doesn't fit elsewhere, such as:
- Performance considerations
- Thread safety
- Relationship to other modules
- Historical context or design decisions
"""
```

### Key Formatting Rules

1. **Use numpy-style docstrings** (not Google or reStructuredText style)
2. **Section headers**: Use underlines with dashes (e.g., `Parameters\n----------`)
3. **Parameter format**: `name : type` on first line, indented description below
4. **Be specific with types**: Use `str`, `int`, `Path`, `list[str]`, `dict[str, Any]`, etc.
5. **Include defaults**: Show default values in the type line when present
6. **Keep examples short**: 2-5 lines that demonstrate basic usage
7. **Indent consistently**: 4 spaces for description blocks under section headers

## Workflow

### 1. Analysis Phase

For each target module:
- Read the current file content
- Identify all docstring locations:
  - Module-level (at the top)
  - Classes (each class definition)
  - Functions/Methods (public functions and key methods)
- Assess current docstring quality:
  - Missing entirely?
  - Too brief/vague?
  - Missing key sections (Parameters, Returns)?
  - Poor formatting?

### 2. Docstring Generation

For each docstring to update:
- **Analyze the code**: Understand what it does by reading implementation
- **Identify all parameters**: Extract from function/method signatures
- **Infer types**: Use type hints if present, otherwise infer from usage
- **Understand returns**: Determine return type and meaning from code
- **Find exceptions**: Look for raised exceptions in the code
- **Create example**: Write a minimal, realistic usage example

### 3. Writing Guidelines

**DO:**
- Explain *why* something exists, not just *what* it is
- Use clear, direct language
- Include practical examples
- Document edge cases and constraints
- Mention related functions/classes when relevant
- Use proper type annotations

**DON'T:**
- Write overly verbose descriptions that restate the obvious
- Include implementation details that may change
- Use vague language like "handles stuff" or "processes data"
- Skip parameter descriptions for "obvious" parameters
- Create examples that won't actually run

### 4. Review and Update

Before writing changes:
- Present proposed docstring updates to user
- Ask for feedback on level of detail
- Confirm which modules/functions to update

After confirmation:
- Write updated files with new docstrings
- Preserve all existing code and comments
- Maintain existing file structure and imports

## Quality Checklist

Before finalizing, verify each docstring has:
- [ ] Clear one-line summary
- [ ] Parameters section with types (if applicable)
- [ ] Returns section with type (if applicable)
- [ ] At least one simple example (for complex items)
- [ ] Proper numpy-style formatting
- [ ] No obvious typos or formatting errors
- [ ] Accurate reflection of the actual code behavior

## Example Transformation

### Before (inadequate)
```python
def process_paths(input_dir, output_dir):
    """Process paths."""
    # ... implementation
```

### After (sklearn-inspired)
```python
def process_paths(input_dir, output_dir):
    """
    Process and validate input/output directory paths for pipeline execution.

    Ensures directories exist, converts to absolute paths, and validates
    that output directory is writable. This is typically called during
    pipeline initialization to catch configuration errors early.

    Parameters
    ----------
    input_dir : str or Path
        Path to directory containing input files. Must exist and be readable.
    output_dir : str or Path
        Path to directory for output files. Will be created if it doesn't exist.
        Must be writable.

    Returns
    -------
    tuple[Path, Path]
        Absolute paths for (input_dir, output_dir) as Path objects.

    Raises
    ------
    FileNotFoundError
        If input_dir does not exist.
    PermissionError
        If output_dir is not writable.

    Examples
    --------
    >>> input_path, output_path = process_paths("./data", "./results")
    >>> print(input_path.exists())
    True
    """
    # ... implementation
```

## Notes

- Focus on modules that will be used by other developers or AI coding agents
- Prioritize public APIs over internal helper functions
- Balance detail with maintainability - docstrings should be kept up to date
- When in doubt, provide more context rather than less
- For complex modules, consider adding a module-level example that shows typical workflows
