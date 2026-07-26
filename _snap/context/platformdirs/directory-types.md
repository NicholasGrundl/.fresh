# Platformdirs Directory Types

This document provides a more detailed explanation of the different directory types available in `platformdirs`.

## User-Specific Directories

These directories are located within the user's home directory and are private to the user.

-   **`user_data_dir`**: For storing user-specific application data. This is for data that the user has created or that is specific to their use of the application.
-   **`user_config_dir`**: For storing user-specific configuration files.
-   **`user_cache_dir`**: For storing non-essential, temporary data that can be regenerated. The operating system may delete this data at any time.
-   **`user_state_dir`**: For storing data that should persist between application launches, but is not user-facing. For example, the current state of the application's UI.
-   **`user_log_dir`**: For storing log files.
-   **`user_documents_dir`**: The user's "Documents" or "My Documents" directory.
-   **`user_downloads_dir`**: The user's "Downloads" directory.
-   **`user_pictures_dir`**: The user's "Pictures" directory.
-   **`user_videos_dir`**: The user's "Videos" directory.
-   **`user_music_dir`**: The user's "Music" directory.
-   **`user_runtime_dir`**: For storing runtime-specific files, such as sockets or PID files. This directory is often in memory (e.g., `/run/user/1000` on Linux) and is not guaranteed to persist across reboots.

## Site-Wide (Shared) Directories

These directories are accessible by all users on the system. On Unix-like systems, this is typically under `/usr/local` or `/opt`. On Windows, this is typically `C:\ProgramData`.

-   **`site_data_dir`**: For storing data that is shared between all users of the application.
-   **`site_config_dir`**: For storing configuration files that are shared between all users of the application.
