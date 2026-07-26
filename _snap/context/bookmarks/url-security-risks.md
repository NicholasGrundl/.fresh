# Security Risks of Sensitive Data in URLs

This document summarizes the research on the security risks associated with sensitive data being present in URLs, a common issue in bookmark files. The primary goal is to identify patterns of information that should not be publicly exposed.

## The Core Problem: URLs are Not Secret

Even when a website uses HTTPS to encrypt traffic, the URL itself can be exposed in various ways, making it a poor choice for transmitting sensitive information.

### Where URLs Get Exposed:

1.  **Browser History:** URLs are stored in plain text in the user's browser history. Anyone with access to the computer can view this history.
2.  **Server Logs:** Web servers almost always log the full URL of every incoming request. These logs can be a treasure trove for attackers if not properly secured.
3.  **Referer Headers:** When you click a link, the browser often sends the current URL in an HTTP `Referer` header to the new site. This can leak sensitive data to third-party services.
4.  **Shared Networks & Proxies:** In corporate or public networks, proxy servers and network monitoring tools can log URLs.
5.  **Shoulder Surfing:** The URL is visible in the browser's address bar, where it can be seen by someone looking over the user's shoulder.
6.  **Copy & Paste:** Users often share URLs via email, instant messaging, or other insecure channels.

## Common Patterns of Sensitive Data in URLs

Based on the research, here are the most common types of sensitive data found in URLs, which can be used to create deterministic checks.

### 1. API Keys and Authentication Tokens

These are credentials that grant access to a user's account or a service's resources.

-   **Common Keywords:** `api_key`, `apikey`, `token`, `auth_token`, `access_token`, `auth`, `key`, `client_id`, `client_secret`
-   **Example:**
    ```
    https://api.example.com/data?api_key=12345abcdef67890
    https://example.com/login?token=z9y8x7w6v5u4t3s2r1q0p
    ```
-   **Detection:**
    -   Scan URL query parameters for the presence of these keywords.
    -   Look for long, high-entropy (random-looking) strings in parameter values, as API keys are often long and complex.

### 2. Personally Identifiable Information (PII)

This is any data that can be used to identify a specific individual.

-   **Common Keywords:** `email`, `user`, `username`, `user_id`, `customer_id`, `ssn`, `password`, `pass`
-   **PII in the Path:** PII can also appear directly in the URL path, not just in query parameters.
-   **Example:**
    ```
    https://example.com/users/john.doe@email.com
    https://example.com/reset_password?user=john.doe@email.com
    https://example.com/profile?customer_id=12345
    ```
-   **Detection:**
    -   Scan URL query parameters for PII-related keywords.
    -   Use regular expressions to detect common PII formats, especially email addresses, within the entire URL string (both path and query).

### 3. Session Identifiers

These are tokens used to track a user's session and keep them logged in. If stolen, an attacker can hijack the user's session.

-   **Common Keywords:** `session_id`, `sid`, `sessionid`, `jsessionid`
-   **Example:**
    ```
    https://example.com/dashboard?session_id=abc123xyz789
    ```
-   **Detection:**
    -   Scan URL query parameters for session-related keywords.

### 4. "Magic Links" and Reset Tokens

These are temporary, single-use links that automatically log a user in or allow them to reset their password.

-   **Common Keywords:** `reset_token`, `login_token`, `magic_link`, `verification_code`
-   **Example:**
    ```
    https://example.com/password_reset?reset_token=a1b2c3d4e5f6g7h8
    ```
-   **Detection:**
    -   Scan URL query parameters for keywords related to single-use authentication links.

## Conclusion for Deterministic Analysis

The presence of any of the keywords or patterns above in a bookmarked URL is a strong indicator of a security risk. A deterministic scanner can be built by:

1.  Parsing the URL to separate the query parameters.
2.  Maintaining a list of "sensitive" parameter keywords to check against.
3.  Using regular expressions to scan the entire URL for common PII formats like email addresses.
4.  Optionally, calculating the entropy of parameter values to guess if they are API keys.
