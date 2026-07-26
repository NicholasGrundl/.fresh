# ty Environment Variables

**Source:** https://docs.astral.sh/ty/reference/environment/

## ty-Defined Variables

### TY_LOG

Sets the log level for verbose output. Accepts filters compatible with the `tracing_subscriber` crate.

Examples:
- `TY_LOG=uv=debug` (equivalent to `-vv`)
- `TY_LOG=trace` (enables all trace-level logging)

### TY_LOG_PROFILE

When set to `"1"` or `"true"`, enables flamegraph profiling that creates a `tracing.folded` file for performance analysis and flame graph generation.

### TY_MAX_PARALLELISM

"Specifies an upper limit for the number of tasks ty is allowed to run in parallel." Controls file-checking parallelism without limiting spawned threads for file system watching or UI operations.

---

## Externally-Defined Variables

### CONDA_DEFAULT_ENV

Determines the name of the active Conda environment.

### CONDA_PREFIX

Detects the path of an active Conda environment. `VIRTUAL_ENV` takes precedence when both are present.

### PYTHONPATH

Adds directories to ty's search paths using OS-appropriate separators (colons on Unix, semicolons on Windows).

### RAYON_NUM_THREADS

"Specifies an upper limit for the number of threads ty uses when performing work in parallel." A standard Rayon environment variable equivalent to `TY_MAX_PARALLELISM`.

### VIRTUAL_ENV

Detects an activated Python virtual environment.

### XDG_CONFIG_HOME

Path to user-level configuration directory on Unix systems.

### _CONDA_ROOT

Determines the root installation path of Conda.
