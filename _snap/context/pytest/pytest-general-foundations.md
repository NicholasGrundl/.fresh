# Pytest Architecture & Best Practices

This guide explains how to structure tests, create fixtures, design test architecture, and apply common pytest patterns. It draws from the official pytest documentation:

* [https://docs.pytest.org/en/stable/](https://docs.pytest.org/en/stable/)
* [https://docs.pytest.org/en/stable/example/index.html](https://docs.pytest.org/en/stable/example/index.html)
* [https://docs.pytest.org/en/stable/how-to/index.html](https://docs.pytest.org/en/stable/how-to/index.html)
* [https://docs.pytest.org/en/stable/explanation/index.html](https://docs.pytest.org/en/stable/explanation/index.html)

---

## 1. How pytest discovers and organizes tests

### 1.1 Default discovery rules

Pytest finds tests by:

* Looking in the working directory (or `testpaths` if configured)
* Recursing into subdirectories
* Selecting files that match:

  * `test_*.py`
  * `*_test.py`
* Detecting tests as:

  * Functions starting with `test_`
  * Classes named `Test*` (without `__init__`)

### 1.2 Recommended layout (separate test folder)

Most modern Python projects use:

```
project/
  pyproject.toml
  src/
    mypkg/
      ...
  tests/
    test_*.py
    conftest.py
```

Advantages:

* Tests run against the *installed* version of your package
* Imports are cleaner (especially with `--import-mode=importlib`)
* Tools like `tox` and CI behave more predictably

### 1.3 Alternative layout (tests in package)

Useful if you *ship* tests within your package:

```
mypkg/
  __init__.py
  module.py
  tests/
    test_something.py
```

Useful when distributing tests to users.

---

## 2. Fixture architecture

### 2.1 What fixtures are

Fixtures:

* Provide **arrange** (and sometimes cleanup) logic for tests
* Are discovered in:

  * The same file
  * `conftest.py` in the test folder hierarchy
  * External pytest plugins

### 2.2 Fixture scopes

Scopes control how often fixtures run:

* `function` (default)
* `class`
* `module`
* `package`
* `session`

Guidelines:

* Prefer **function scope** unless you have performance reasons.
* Use **session** scope sparingly (for expensive shared resources).

### 2.3 Using `conftest.py`

`conftest.py`:

* Makes fixtures available to all tests below its folder level
* Allows fixture overriding:

  * Folder-level override via nested `conftest.py`
  * Module override by redefining a fixture of the same name
  * Parametrization override

Avoid “mega” conftests that know everything—keep fixtures organized by folder.

### 2.4 Factories as fixtures

Factory fixtures create objects on demand:

```python
@pytest.fixture
def make_user():
    def _factory(name="Alice"):
        return User(name=name)
    return _factory
```

Useful when tests require multiple similar objects with variations.

### 2.5 Fixture composition

Fixtures can depend on each other:

```python
@pytest.fixture
def db():
    return setup_db()

@pytest.fixture
def client(db):
    return APIClient(db)
```

This encourages small, composable units rather than monolithic fixtures.

---

## 3. Test design patterns

### 3.1 Anatomy of a test

Pytest encourages:

1. **Arrange**
2. **Act**
3. **Assert**
4. **Cleanup** (usually via fixture teardown)

### 3.2 Good assertion practices

* Use **plain `assert`** — pytest shows introspective diffs
* Assert on **observable behavior**, not internal implementation
* Keep tests focused; split multi-behavior tests

### 3.3 Parametrization

Helps test many inputs cleanly:

```python
@pytest.mark.parametrize("input, expected", [
    (1, 2),
    (2, 3),
])
def test_increment(input, expected):
    assert increment(input) == expected
```

### 3.4 Assertion helpers

Custom helpers can hide internal frames:

```python
def assert_configured(x):
    __tracebackhide__ = True
    assert hasattr(x, "config")
```

Improves readability of tracebacks.

---

## 4. Configuring pytest for clean test architecture

### 4.1 Example `pytest.toml`

```toml
[pytest]
addopts = ["-ra", "--import-mode=importlib"]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*", "Describe*"]
python_functions = ["test_*", "it_*"]
```

### 4.2 Customizing discovery

* ignore directories: `--ignore=PATH`
* ignore patterns: `--ignore-glob="*_slow.py"`
* customize naming via `python_files`, etc.

---

## 5. Checklist

### Test layout

* [ ] Use `tests/` folder at project root
* [ ] One test file per module or feature
* [ ] Keep static data in `tests/data/`

### Fixtures

* [ ] Use small, composable fixtures
* [ ] Organize shared fixtures in `conftest.py`
* [ ] Override fixtures when needed per-folder or per-test
* [ ] Use factory fixtures for variable object creation

### Test design

* [ ] Tests follow Arrange–Act–Assert
* [ ] Assertions emphasize behavior
* [ ] Use parametrization for multi-input tests
* [ ] Avoid side effects and global state

---

