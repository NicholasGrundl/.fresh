# Pytest Illustrative Examples for a Bookmarks Analyzer Project

This guide provides a test architecture tailored to a project that:

* Parses a Chrome bookmarks HTML file
* Uses **Pydantic** for models
* Uses **BeautifulSoup + lxml** for HTML parsing
* Uses **Loguru** for logging
* Fetches and checks bookmarked websites
  → Network calls are mocked in tests

We assume a **separate `tests/` directory layout**.

---

## 1. Project layout

```
project/
  pyproject.toml
  src/
    bookmarks_analyzer/
      __init__.py
      models.py
      bookmarks_io.py
      parser.py
      fetcher.py
      checker.py
      logging_config.py
  tests/
    conftest.py
    test_models.py
    test_bookmarks_io.py
    test_parser.py
    test_fetcher.py
    test_checker.py
    data/
      chrome_bookmarks_small.html
      page_ok.html
      page_redirect.html
      page_error.html
```

---

## 2. Pytest configuration (`pytest.toml`)

```toml
[pytest]
addopts = ["-ra", "--import-mode=importlib"]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
```

---

## 3. Fixtures in `tests/conftest.py`

Your test suite will use:

* Loguru configuration fixture
* Chrome bookmarks data fixtures
* BeautifulSoup + parsed Pydantic fixtures
* Static HTML pages for testing the fetcher
* Monkeypatched fake fetcher

---

### 3.1 Loguru test configuration

```python
@pytest.fixture(autouse=True, scope="session")
def configure_loguru_for_tests():
    logger.remove()
    logger.add(
        sys.stderr,
        level="DEBUG",
        format="<green>{time:HH:mm:ss}</green> | "
               "<level>{level: <8}</level> | "
               "<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - "
               "<level>{message}</level>",
    )
```

Ensures all tests show clear DEBUG logs.

---

### 3.2 Chrome bookmarks fixtures

```python
@pytest.fixture(scope="session")
def data_dir():
    return Path(__file__).parent / "data"

@pytest.fixture(scope="session")
def chrome_bookmarks_path(data_dir):
    return data_dir / "chrome_bookmarks_small.html"

@pytest.fixture(scope="session")
def chrome_bookmarks_html(chrome_bookmarks_path):
    return chrome_bookmarks_path.read_text()

@pytest.fixture(scope="session")
def chrome_bookmarks_soup(chrome_bookmarks_html):
    return BeautifulSoup(chrome_bookmarks_html, "lxml")

@pytest.fixture(scope="session")
def bookmarks_tree(chrome_bookmarks_path):
    html = bookmarks_io.read_bookmarks_file(chrome_bookmarks_path)
    return parser.parse_bookmarks_html(html)
```

You can now test:

* Raw HTML parsing
* BeautifulSoup helpers
* Pydantic normalization of parsed data
* Full IO + parse pipeline

---

### 3.3 Sample fetched HTML pages

In `tests/data/`:

* `page_ok.html`
* `page_redirect.html`
* `page_error.html`

Fixtures:

```python
@pytest.fixture(scope="session")
def page_ok_html(data_dir):
    return (data_dir / "page_ok.html").read_text()

@pytest.fixture(scope="session")
def page_redirect_html(data_dir):
    return (data_dir / "page_redirect.html").read_text()

@pytest.fixture(scope="session")
def page_error_html():
    return """
    <html>
      <head><title>404 Not Found</title></head>
      <body><h1>Not Found</h1></body>
    </html>
    """
```

---

### 3.4 Fake network / fetcher mocking

Factory of URL → HTML mappings:

```python
@pytest.fixture
def fake_html_responses(page_ok_html, page_redirect_html, page_error_html):
    return {
        "https://example.com/ok": page_ok_html,
        "https://example.com/redirect": page_redirect_html,
        "https://example.com/error": page_error_html,
    }
```

Monkeypatch fetcher:

```python
@pytest.fixture
def patch_fetch_html(monkeypatch, fake_html_responses):
    from bookmarks_analyzer import fetcher

    def _fake_fetch(url, timeout=5.0):
        if url not in fake_html_responses:
            raise RuntimeError(f"Unknown fake URL: {url}")
        return fake_html_responses[url]

    monkeypatch.setattr(fetcher, "fetch_html", _fake_fetch)
```

---

## 4. Example tests

### 4.1 Pydantic model tests

```python
def test_bookmark_model_valid():
    b = Bookmark(
        title="Example",
        url="https://example.com",
        add_date=12345,
        tags=["test"],
    )
    assert b.url.startswith("https://")
```

---

### 4.2 Parser tests

```python
def test_parser_extracts_urls(chrome_bookmarks_html):
    tree = parser.parse_bookmarks_html(chrome_bookmarks_html)
    urls = {b.url for b in tree.iter_bookmarks()}
    assert "https://example.com" in urls
```

---

### 4.3 Fetcher tests

```python
def test_fetcher_returns_fake_ok(page_ok_html, patch_fetch_html):
    html = fetcher.fetch_html("https://example.com/ok")
    assert "OK page" in html
```

---

### 4.4 Checker tests (integration)

```python
def test_checker_finds_broken_links(patch_fetch_html, bookmarks_tree):
    report = checker.check_all(bookmarks_tree)
    broken = {item.url for item in report.broken}
    assert "https://example.com/error" in broken
```

---

## 5. Best practices for this project

### HTML parsing tests

* Keep sample HTML small but realistic.
* Use different snippets to represent typical page states.
* Test multiple levels:

  * raw HTML → soup
  * soup → Pydantic
  * IO → complete parse pipeline

### Network mocking

* Never hit the real internet in tests.
* Centralize fake responses in fixtures.
* Use monkeypatch to override the fetcher.

### Logging

* Loguru shouldn’t depend on prod configuration in tests.
* Autouse fixture gives clear rich logs for debugging.

---