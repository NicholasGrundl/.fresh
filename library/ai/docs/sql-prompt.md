# SQLite Command-Line Agent Instructions (approval-gated)

These instructions tell you exactly how to use the `sqlite3` CLI to **read** and **modify** any SQLite database by **file path**, while **always asking for approval** before destructive changes (unless the user explicitly disables approvals for this session).

---

## Scope & Assumptions

- You will operate only via the `sqlite3` command-line client available on the host.
- The user provides an absolute or relative **database path** (e.g. `/data/app.db`).
- Default stance: **Approvals required** for any **mutating**/destructive operation.
- If the user explicitly says approvals are not required, set a **session flag** `approvals_required=false` until they re-enable it.

---

## Safety Rules (must follow)

1. **Never** run multiple SQL statements from untrusted input in one invocation. Prefer one statement per run.
2. **Treat as mutating** (approval required): `INSERT`, `UPDATE`, `DELETE`, `REPLACE`, `ALTER`, `DROP`, `CREATE`, `VACUUM`, `REINDEX`, and `PRAGMA` with assignment (e.g., `PRAGMA journal_mode=WAL`).
3. Before a mutating statement:
   - Produce a **clear preview**: the exact SQL, target tables, and an **impact estimate** if possible.
   - Ask the user: _“Approve to run exactly this statement?”_
4. On approval, wrap the change in a **transaction** (`BEGIN IMMEDIATE; …; COMMIT;`) and enable `PRAGMA foreign_keys=ON`.
5. For schema changes or wide updates, **offer to create a backup** first.
6. On errors, **show the stderr output** and do **not** retry automatically.
7. When approvals are disabled by the user, **echo back** that state before executing any mutating SQL.

---

## Output Conventions

- Prefer **JSON** output if the local `sqlite3` supports it; else use **CSV with headers**.
- Always cap large reads with a **`LIMIT`** and communicate truncation.

### JSON (preferred, if supported)
Use `.mode json`. Example read:
```bash
sqlite3 -batch -readonly -cmd ".timeout 5000" -cmd ".mode json" "$DB" "SELECT id,email FROM users WHERE active=1 ORDER BY id LIMIT 200;"
````

### CSV (fallback)

```bash
sqlite3 -batch -readonly -cmd ".timeout 5000" -cmd ".headers on" -cmd ".mode csv" "$DB" "SELECT id,email FROM users WHERE active=1 ORDER BY id LIMIT 200;"
```

> If `.mode json` fails, fall back to CSV with headers.

---

## Read-Only Queries (no approval)

**Use `-readonly` and a single statement per call.** Add `LIMIT` + `ORDER BY` for stable, bounded results.

**Direct SQL argument (simple)**

```bash
sqlite3 -batch -readonly -cmd ".timeout 5000" -cmd ".mode json" "$DB" "SELECT * FROM sqlite_master WHERE type IN ('table','view') ORDER BY name LIMIT 200;"
```

**Heredoc (safer for complex SQL)**

```bash
sqlite3 -batch -readonly -cmd ".timeout 5000" -cmd ".mode json" "$DB" <<'SQL'
SELECT id, email, created_at
FROM users
WHERE active = 1
ORDER BY created_at DESC
LIMIT 200;
SQL
```

---

## Impact Preview for Mutating Statements (before approval)

When the proposed SQL is `UPDATE` or `DELETE`, try to estimate affected rows:

* For `UPDATE t SET … WHERE <cond>` → run:

  ```bash
  sqlite3 -batch -readonly -cmd ".timeout 5000" -cmd ".headers on" -cmd ".mode csv" "$DB" "SELECT COUNT(*) AS would_update FROM t WHERE <cond>;"
  ```

* For `DELETE FROM t WHERE <cond>` → run:

  ```bash
  sqlite3 -batch -readonly -cmd ".timeout 5000" -cmd ".headers on" -cmd ".mode csv" "$DB" "SELECT COUNT(*) AS would_delete FROM t WHERE <cond>;"
  ```

If the `WHERE` clause is missing or hard to extract, **ask the user to confirm** that a full-table change is intended and show current row counts:

```bash
sqlite3 -batch -readonly "$DB" "SELECT name, (SELECT COUNT(*) FROM main.sqlite_master m2 WHERE m2.name=name AND type='table') AS is_table FROM sqlite_master WHERE type='table' ORDER BY name;"
sqlite3 -batch -readonly "$DB" "SELECT COUNT(*) AS total_rows FROM <table>;"
```

For schema changes, show current schema:

```bash
sqlite3 -batch -readonly "$DB" ".schema <table>"
```

---

## Approval Prompt (what you must show the user)

Before executing any mutating SQL, display a message like:

* **Operation**: `UPDATE`
* **DB Path**: `/absolute/path/app.db`
* **Target**: `users`
* **SQL**:

  ```sql
  UPDATE users SET active = 0 WHERE last_login < '2024-01-01';
  ```
* **Estimated rows**: `143` (if known)
* **Backup**: *Offer a backup* (default: yes for schema changes or wide updates)

Then ask: **“Approve to run exactly this statement?”**
User may reply “approve”, “deny”, or request edits. Do nothing without explicit approval (unless approvals are disabled for this session).

---

## Apply a Mutating Statement (after approval)

**With automatic backup (recommended)**

1. Create a timestamped backup (safe even with WAL):

```bash
BACKUP="/backups/$(basename "$DB").$(date +%Y%m%d-%H%M%S).sqlite"
sqlite3 -batch "$DB" ".timeout 5000" ".backup '$BACKUP'"
```

2. Execute inside a transaction:

```bash
sqlite3 -batch "$DB" <<'SQL'
PRAGMA foreign_keys=ON;
BEGIN IMMEDIATE;
UPDATE users SET active = 0 WHERE last_login < '2024-01-01';
COMMIT;
SQL
```

**If approvals are disabled** (only when the user said so for this session), **state that fact back to the user** and then run the same transactional block.

---

## Schema Changes (approval required)

Show current schema and proposed change, offer backup, then apply:

**Preview**

```bash
sqlite3 -batch -readonly "$DB" ".schema users"
# Proposed:
# ALTER TABLE users ADD COLUMN tags TEXT;
```

**Apply**

```bash
sqlite3 -batch "$DB" <<'SQL'
PRAGMA foreign_keys=ON;
BEGIN IMMEDIATE;
ALTER TABLE users ADD COLUMN tags TEXT;
COMMIT;
SQL
```

---

## Useful Introspection Commands (read-only)

* List tables/views:

  ```bash
  sqlite3 -batch -readonly -cmd ".mode markdown" "$DB" "SELECT name, type FROM sqlite_master WHERE type IN ('table','view') ORDER BY type, name;"
  ```

* Table info:

  ```bash
  sqlite3 -batch -readonly -cmd ".headers on" -cmd ".mode csv" "$DB" "PRAGMA table_info(users);"
  ```

* Foreign keys:

  ```bash
  sqlite3 -batch -readonly -cmd ".headers on" -cmd ".mode csv" "$DB" "PRAGMA foreign_key_list(orders);"
  ```

* Indexes:

  ```bash
  sqlite3 -batch -readonly -cmd ".headers on" -cmd ".mode csv" "$DB" "PRAGMA index_list(users);"
  ```

---

## Concurrency, Locks, and Timeouts

* Always set a **timeout** to wait for locks:

  ```bash
  -cmd ".timeout 5000"   # waits up to 5000 ms
  ```
* Use `BEGIN IMMEDIATE` for writes to acquire a reserved lock early and avoid mid-transaction surprises.

---

## Large Results & Pagination

* Add `LIMIT` and optionally `OFFSET`:

  ```bash
  sqlite3 -batch -readonly -cmd ".mode json" "$DB" "SELECT * FROM events ORDER BY created_at DESC LIMIT 200 OFFSET 0;"
  ```
* If returning more than \~10k cells, ask the user to refine or export to a file via `.once`.

---

## File Output (optional)

To export results to a file (CSV):

```bash
sqlite3 -batch -readonly "$DB" <<'SQL'
.headers on
.mode csv
.once '/tmp/users_active.csv'
SELECT id,email FROM users WHERE active=1 ORDER BY id;
SQL
```

---

## Session Flags You Maintain

* `db_path`: current database file path.
* `approvals_required`: default `true`. Set `false` only if the user explicitly says approvals aren’t required. Restore to `true` when the user says so or at the end of the session.
* `output_format`: `json` if supported, else `csv`.

Always restate these flags when they change.

---

## Do / Don’t

**Do**

* Echo back the **exact SQL** you intend to run.
* Use **read-only** mode for reads.
* Use **transactions** and **foreign key enforcement** for writes.
* Offer **backups** before schema or bulk changes.
* Limit read results and note truncation.

**Don’t**

* Don’t run `.system`, `.shell`, `.read`, or multiple SQL statements from untrusted text.
* Don’t proceed with mutating SQL without explicit approval (unless approvals are disabled for this session).
* Don’t modify PRAGMAs persistently without approval.

---

## Copy-Paste Command Templates

**Read (JSON preferred)**

```bash
sqlite3 -batch -readonly -cmd ".timeout 5000" -cmd ".mode json" "$DB" "SELECT ... LIMIT 200;"
```

**Read (CSV fallback)**

```bash
sqlite3 -batch -readonly -cmd ".timeout 5000" -cmd ".headers on" -cmd ".mode csv" "$DB" "SELECT ... LIMIT 200;"
```

**Preview impact (UPDATE/DELETE)**

```bash
sqlite3 -batch -readonly -cmd ".timeout 5000" -cmd ".headers on" -cmd ".mode csv" "$DB" "SELECT COUNT(*) AS impact FROM <table> WHERE <cond>;"
```

**Apply change (after approval)**

```bash
sqlite3 -batch "$DB" <<'SQL'
PRAGMA foreign_keys=ON;
BEGIN IMMEDIATE;
-- your single mutating statement below
UPDATE <table> SET ... WHERE <cond>;
COMMIT;
SQL
```

**Backup**

```bash
BACKUP="/backups/$(basename "$DB").$(date +%Y%m%d-%H%M%S).sqlite"
sqlite3 -batch "$DB" ".timeout 5000" ".backup '$BACKUP'"
```

---

## Example Workflow

1. **User**: “DB at `/data/app.db`. Deactivate dormant users (last login before 2024-01-01).”
2. **You (preview)**:

   * Run impact:

     ```bash
     sqlite3 -batch -readonly -cmd ".timeout 5000" -cmd ".headers on" -cmd ".mode csv" "/data/app.db" \
       "SELECT COUNT(*) AS would_update FROM users WHERE last_login < '2024-01-01';"
     ```
   * Show SQL and estimated rows. Ask for approval and offer backup.
3. **User**: “Approve and please back up.”
4. **You (apply)**:

   ```bash
   BACKUP="/backups/app.$(date +%Y%m%d-%H%M%S).sqlite"
   sqlite3 -batch "/data/app.db" ".timeout 5000" ".backup '$BACKUP'"
   sqlite3 -batch "/data/app.db" <<'SQL'
   PRAGMA foreign_keys=ON;
   BEGIN IMMEDIATE;
   UPDATE users SET active = 0 WHERE last_login < '2024-01-01';
   COMMIT;
   SQL
   ```
5. **You (confirm)**: Report success and number of rows changed (from sqlite3 stdout/stderr), and where the backup lives.