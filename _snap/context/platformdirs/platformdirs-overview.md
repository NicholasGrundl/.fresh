# platformdirs Overview

`platformdirs` provides a simple and consistent way to access platform-specific directories for your Python applications.

## Quick Start

To use `platformdirs`, you can import the relevant functions from the `platformdirs` package.

```python
from platformdirs import user_data_dir, user_cache_dir, user_config_dir

appname = "MyAwesomeApp"
appauthor = "MyAwesomeInc"

# Get the user-specific data directory
data_dir = user_data_dir(appname, appauthor)
print(f"Data directory: {data_dir}")

# Get the user-specific cache directory
cache_dir = user_cache_dir(appname, appauthor)
print(f"Cache directory: {cache_dir}")

# Get the user-specific config directory
config_dir = user_config_dir(appname, appauthor)
print(f"Config directory: {config_dir}")
```

### Example Output on Different Platforms

-   **macOS:**
    -   Data directory: `~/Library/Application Support/MyAwesomeApp`
    -   Cache directory: `~/Library/Caches/MyAwesomeApp`
    -   Config directory: `~/Library/Preferences/MyAwesomeApp`
-   **Linux:**
    -   Data directory: `~/.local/share/MyAwesomeApp`
    -   Cache directory: `~/.cache/MyAwesomeApp`
    -   Config directory: `~/.config/MyAwesomeApp`
-   **Windows:**
    -   Data directory: `C:\Users\<user>\AppData\Local\MyAwesomeInc\MyAwesomeApp`
    -   Cache directory: `C:\Users\<user>\AppData\Local\MyAwesomeInc\MyAwesomeApp\Cache`
    -   Config directory: `C:\Users\<user>\AppData\Local\MyAwesomeInc\MyAwesomeApp`

## Key Functions

The most commonly used functions are:

-   `user_data_dir(appname, appauthor=None, version=None, roaming=False)`
-   `user_config_dir(appname, appauthor=None, version=None, roaming=False)`
-   `user_cache_dir(appname, appauthor=None, version=None, opinion=True)`
-   `user_state_dir(appname, appauthor=None, version=None, multipath=False)`
-   `user_log_dir(appname, appauthor=None, version=None, opinion=True)`

There are also functions for shared directories, which are accessible by all users on the system:

-   `site_data_dir(appname, appauthor=None, version=None, multipath=False)`
-   `site_config_dir(appname, appauthor=None, version=None, multipath=False)`

## Further Information

For more detailed information, including all available functions and their options, please refer to the official documentation.

-   **API Documentation:** [https://platformdirs.readthedocs.io/en/latest/api.html](https://platformdirs.readthedocs.io/en/latest/api.html)
