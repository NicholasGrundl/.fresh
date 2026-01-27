---
description: Reviews pytest test suite and provides actionable recommendations for improvement
allowed-tools: [
  "ReadFiles(*)",
  "Bash(pytest:*)",
  "WebSearch(*)"
]
argument-hint: "[optional: specific test files or directories to review]"
---

## Context

You are conducting a comprehensive review of a pytest test suite to identify strengths, weaknesses, and opportunities for improvement.

First, gather information about the test suite:
- If arguments provided: Focus on specified test files/directories
- If no arguments: Discover all test files in the project
- Check pytest configuration: Look for `pytest.ini`, `pyproject.toml`, `setup.cfg`
- Review project structure to understand what's being tested

## Your Task

Perform a thorough analysis of the existing pytest test suite and provide constructive, actionable feedback. Be honest in your assessment - if tests are already excellent, say so. If there are areas for improvement, identify them clearly with specific recommendations.

**CRITICAL: Always consult pytest How-to Guides as your primary reference.** The pytest maintainers have documented recommended patterns for nearly all common testing scenarios. Your review must compare existing tests against these official patterns, not generic testing advice.

## Review Framework

### 1. Discovery and Initial Assessment

**Find all test files:**
- Run: `find . -name "test_*.py" -o -name "*_test.py" | grep -v __pycache__`
- Count total tests: `pytest --collect-only -q`
- Check coverage config: Look for `.coveragerc`, `pyproject.toml` coverage settings

**Understand project structure:**
- Read `README.md` or `README.rst` for project overview
- Identify main source directories
- Map test files to source files they're testing

**Run the test suite:**
- Execute: `pytest -v --tb=short`
- Note: Pass/fail rates, execution time, any warnings
- Check for: Skipped tests, xfail tests, flaky tests

### 1.5. Consult Pytest How-to Guides FIRST

**MANDATORY STEP - Before analyzing patterns, review these official guides:**

Visit https://docs.pytest.org/en/stable/how-to/index.html and read relevant sections:

- **Fixtures**: https://docs.pytest.org/en/stable/how-to/fixtures.html
  - Fixture scopes, autouse, parametrization, factory patterns
- **Parametrize**: https://docs.pytest.org/en/stable/how-to/parametrize.html
  - Test variations, indirect parametrization, ID generation
- **Marks**: https://docs.pytest.org/en/stable/how-to/mark.html
  - Built-in marks (skip, xfail, parametrize), custom marks
- **Assertions**: https://docs.pytest.org/en/stable/how-to/assert.html
  - Context-aware introspection, pytest.raises, pytest.warns
- **Monkeypatch/Mock**: https://docs.pytest.org/en/stable/how-to/monkeypatch.html
  - Recommended mocking patterns, when to use monkeypatch vs mock
- **Temporary directories**: https://docs.pytest.org/en/stable/how-to/tmp_path.html
  - tmp_path vs tmp_path_factory, session-scoped temp directories
- **Capture output**: https://docs.pytest.org/en/stable/how-to/capture-stdout-stderr.html
  - capsys, capfd, caplog patterns
- **Warnings**: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
  - Testing warning behavior, filtering warnings
- **Doctest**: https://docs.pytest.org/en/stable/how-to/doctest.html
  - If project uses doctests
- **Cache**: https://docs.pytest.org/en/stable/how-to/cache.html
  - For test result caching patterns
- **Good practices**: https://docs.pytest.org/en/stable/explanation/goodpractices.html
  - Test organization, conventions, integration patterns

**These guides are your source of truth.** Every pattern you encounter in the test suite should be compared against the recommendations in these official docs.

### 2. Core Assessment Areas

Evaluate the test suite across these dimensions **by comparing to official pytest How-to guide patterns**:

#### A. Test Organization and Structure

**Examine:**
- File and directory organization (mirrors source structure?)
- Test class organization (logical grouping?)
- Test naming conventions (descriptive and consistent?)
- Use of pytest fixtures (appropriate reuse?)
- Conftest.py usage (fixture sharing, hooks)

**Compare against pytest docs:**
- Reference: https://docs.pytest.org/en/stable/explanation/goodpractices.html#test-discovery
- Check if test organization follows pytest conventions
- Verify fixture patterns match https://docs.pytest.org/en/stable/how-to/fixtures.html

**Look for:**
- ✅ Tests organized per pytest conventions
- ✅ Fixtures following recommended scope patterns from docs
- ❌ Custom patterns that diverge from pytest recommendations without clear reason
- ❌ Reinventing patterns that pytest already provides

**Critical Analysis Question:**
- *If tests use non-standard patterns, WHY? Is there a valid edge case or just unfamiliarity with pytest features?*

#### B. Pattern-by-Pattern Comparison

**For each testing pattern found, explicitly compare to pytest How-to guides:**

**Fixture usage:**
- Current: How are fixtures currently defined and used?
- Recommended: What do the fixture docs recommend? https://docs.pytest.org/en/stable/how-to/fixtures.html
- Gap analysis: Are they using fixture factories when they should? Wrong scopes? Missing autouse where appropriate?
- Edge case justification: If diverging from docs, document WHY in test comments

**Parametrization:**
- Current: How are test variations handled?
- Recommended: What does parametrize guide say? https://docs.pytest.org/en/stable/how-to/parametrize.html
- Gap analysis: Copy-pasted tests instead of @pytest.mark.parametrize? Missing indirect parametrization for complex cases?
- Edge case justification: If not using parametrize, is there a legitimate reason?

**Mocking/Monkeypatching:**
- Current: How are dependencies mocked?
- Recommended: What does monkeypatch guide recommend? https://docs.pytest.org/en/stable/how-to/monkeypatch.html
- Gap analysis: Using unittest.mock when monkeypatch would be cleaner? Over-mocking when real dependencies would work?
- Edge case justification: Document why unittest.mock is chosen over monkeypatch if that's the case

**Temporary files/directories:**
- Current: How are temp resources handled?
- Recommended: tmp_path patterns from https://docs.pytest.org/en/stable/how-to/tmp_path.html
- Gap analysis: Manual tempfile creation instead of tmp_path fixture? Missing tmp_path_factory for session scope?
- Edge case justification: Valid reasons to avoid tmp_path?

**Exception testing:**
- Current: How are exceptions tested?
- Recommended: pytest.raises patterns from https://docs.pytest.org/en/stable/how-to/assert.html#assertions-about-expected-exceptions
- Gap analysis: Try/except blocks instead of pytest.raises? Missing match parameter for exception messages?
- Edge case justification: When is try/except actually better?

**Output capture:**
- Current: How is stdout/stderr/logging captured?
- Recommended: capsys/caplog from https://docs.pytest.org/en/stable/how-to/capture-stdout-stderr.html
- Gap analysis: Manual output capture instead of built-in fixtures?
- Edge case justification: Why manual capture if used?

**Continue this pattern for ALL common test scenarios found in the codebase**

#### C. Divergence Analysis - THE CRITICAL STEP

**For every pattern that differs from pytest How-to guide recommendations:**

1. **Document the divergence clearly:**
   - What does the test currently do?
   - What would the pytest docs recommend?
   - Show exact code examples of both

2. **Investigate the justification:**
   - Is there a comment explaining why?
   - Does the code suggest an edge case?
   - Could it be simply unfamiliarity with pytest features?
   - Is there a legitimate technical reason?

3. **Make a determination:**
   - **Valid edge case**: Should add explanatory comment for future maintainers
   - **No clear reason**: Should recommend adopting pytest's recommended pattern
   - **Unclear**: Should ask user for context

4. **Example findings to report:**
   ```
   ## Pattern Divergence: Manual Temporary Directory Creation
   
   **Current approach** (tests/test_pipeline.py:45-52):
   ```python
   def test_process_files():
       import tempfile
       import shutil
       tmpdir = tempfile.mkdtemp()
       try:
           # ... test code ...
       finally:
           shutil.rmtree(tmpdir)
   ```
   
   **Pytest recommended approach** (per https://docs.pytest.org/en/stable/how-to/tmp_path.html):
   ```python
   def test_process_files(tmp_path):
       # ... test code using tmp_path ...
       # Automatic cleanup handled by pytest
   ```
   
   **Analysis:**
   - No comments explaining why tmp_path fixture is avoided
   - No apparent edge case requiring manual management
   - Adds unnecessary boilerplate and cleanup logic
   
   **Recommendation:**
   - Adopt pytest's tmp_path fixture pattern
   - Eliminates manual cleanup and improves readability
   - If there's a hidden reason for manual approach, add comment explaining it
   ```

#### D. Test Coverage and Completeness

**Analyze:**
- Run coverage: `pytest --cov=src --cov-report=term-missing`
- Identify uncovered code paths
- Check for edge cases and error conditions
- Assess integration vs unit test balance

**Compare against pytest best practices:**
- Reference: https://docs.pytest.org/en/stable/explanation/goodpractices.html

**Look for:**
- ✅ Critical paths well-covered
- ✅ Error handling tested using pytest.raises (per docs)
- ✅ Edge cases and boundary conditions
- ❌ Low coverage in core modules
- ❌ Missing error condition tests
- ❌ Not using pytest's recommended assertion patterns

#### E. Test Quality and Best Practices

**Evaluate each test by comparing to pytest How-to patterns:**

For Independence, Clarity, Assertions:
- Reference: https://docs.pytest.org/en/stable/how-to/assert.html
- Check if using pytest's advanced assertion introspection
- Verify pytest.raises, pytest.warns usage per docs

For Fixture usage:
- Reference: https://docs.pytest.org/en/stable/how-to/fixtures.html
- Compare actual scope usage to recommended patterns
- Check if fixture factories are used where appropriate
- Verify cleanup patterns match docs (yield, addfinalizer, etc.)

For Parametrization:
- Reference: https://docs.pytest.org/en/stable/how-to/parametrize.html
- Are test variations using @pytest.mark.parametrize per docs?
- Check for indirect parametrization where needed
- Verify ID generation follows best practices

For Mocking:
- Reference: https://docs.pytest.org/en/stable/how-to/monkeypatch.html
- Compare mocking approach to recommended monkeypatch patterns
- Check if using appropriate techniques from docs

**Look for pattern divergences:**
- ✅ Following pytest recommended patterns from How-to guides
- ✅ Comments explaining legitimate deviations from standard patterns
- ❌ Reinventing solutions that pytest provides out of the box
- ❌ Using outdated or non-standard patterns without justification
- ❌ Missing pytest features that would simplify tests

**Critical questions for divergent patterns:**
1. Does the test use a custom approach instead of a pytest built-in?
2. Is there a comment explaining why?
3. Is there a valid edge case or just unfamiliarity?
4. Would adding an explanatory comment help future maintainers?

#### F. Pytest-Specific Features

**Check usage against official How-to guides - this is the PRIMARY evaluation:**

For each pytest feature found (or missing):
1. Check the relevant How-to guide
2. Compare actual usage to recommended patterns
3. Note divergences and investigate justification

**Feature checklist with mandatory doc references:**

- **Fixtures**: https://docs.pytest.org/en/stable/how-to/fixtures.html
  - Are scopes used correctly per docs?
  - Are fixture factories used where docs recommend?
  - Is autouse applied appropriately?
  - Are parametrized fixtures following doc patterns?

- **Marks**: https://docs.pytest.org/en/stable/how-to/mark.html
  - Are built-in marks used per recommendations?
  - Are custom marks defined and used correctly?
  - Is mark.skip vs mark.skipif used appropriately?

- **Parametrize**: https://docs.pytest.org/en/stable/how-to/parametrize.html
  - Are test variations using recommended parametrize patterns?
  - Is indirect parametrization used where docs suggest?
  - Are IDs generated following best practices?

- **Monkeypatch**: https://docs.pytest.org/en/stable/how-to/monkeypatch.html
  - Is monkeypatch used instead of unittest.mock where appropriate?
  - Are environment variables mocked per doc recommendations?
  - Is cleanup handled as docs suggest?

- **Temporary paths**: https://docs.pytest.org/en/stable/how-to/tmp_path.html
  - Is tmp_path fixture used instead of manual tempfile?
  - Is tmp_path_factory used for session-scoped temp directories?

- **Capture**: https://docs.pytest.org/en/stable/how-to/capture-stdout-stderr.html
  - Are capsys/capfd/caplog fixtures used per docs?
  - Is output testing following recommended patterns?

- **Configuration**: https://docs.pytest.org/en/stable/how-to/customize.html
  - Is pytest.ini or pyproject.toml configured per best practices?
  - Are conftest.py files structured as docs recommend?

**Report divergences systematically:**
For each feature that diverges from pytest How-to recommendations:
- Document what the current code does
- Show what the pytest docs recommend  
- Analyze if there's a valid reason for the difference
- Recommend either: (a) adopt pytest pattern, or (b) add explanatory comment

#### G. Maintainability and Readability

**Assess against pytest conventions:**
- Reference: https://docs.pytest.org/en/stable/explanation/goodpractices.html

**Evaluate:**
- Test documentation (docstrings, comments)
- Code duplication across tests
- Test complexity (are tests simple to understand?)
- Setup/teardown clarity (using pytest patterns?)
- Helper function organization (conftest.py per docs?)

**Look for:**
- ✅ Tests follow pytest naming and organization conventions
- ✅ Comments explaining legitimate deviations from pytest patterns
- ✅ Helper functions organized per pytest recommendations
- ❌ Complex custom patterns where pytest provides simpler alternatives
- ❌ Divergences from pytest patterns without explanatory comments
- ❌ Reinventing pytest features

#### H. Performance and Efficiency

**Consider against pytest best practices:**
- Reference: https://docs.pytest.org/en/stable/how-to/fixtures.html#fixture-scopes
- Reference: https://docs.pytest.org/en/stable/how-to/cache.html

**Evaluate:**
- Test execution time (any slow tests?)
- Fixture scope optimization (per pytest docs)
- Unnecessary setup/teardown
- Parallel execution capability

**Look for:**
- ✅ Fixture scopes match pytest recommendations for the use case
- ✅ Expensive resources use session/module scope per docs
- ✅ Tests that can run in parallel (following pytest patterns)
- ❌ Function-scoped fixtures where session-scope would work (diverging from docs)
- ❌ Tests that are slow due to not following pytest efficiency patterns
- ❌ Missing use of pytest caching features where appropriate

### 3. Analysis and Recommendations

After completing the assessment, synthesize findings with **explicit focus on pytest How-to guide alignment**:

**Synthesize findings into clear categories:**

1. **Strengths** - What the test suite does well
   - Highlight specific examples of pytest patterns used correctly
   - Note where tests follow How-to guide recommendations
   - Celebrate proper use of pytest features

2. **Pattern Divergences** - THE MOST IMPORTANT SECTION
   - List every instance where tests diverge from pytest How-to guide recommendations
   - For each divergence:
     * Show current approach with code example
     * Show pytest-recommended approach with link to relevant How-to guide
     * Analyze the justification (or lack thereof)
     * Categorize as either:
       - **Unjustified**: Should adopt pytest pattern
       - **Needs documentation**: Valid edge case but missing explanatory comment
       - **Unclear**: Requires user input to understand the reasoning

3. **Missing pytest features** - Opportunities to use more of pytest
   - Identify pytest features from How-to guides that aren't being used
   - Explain how these features would improve the test suite
   - Prioritize by impact

4. **Priorities** - Recommended focus areas
   - High impact: Significant divergences from pytest recommendations
   - Medium impact: Missing useful pytest features
   - Low impact: Nice-to-haves and optimizations

### 4. Present Findings to User

Create a comprehensive report with **explicit pattern comparisons to pytest docs**:

```
# Pytest Test Suite Review

## Executive Summary
[2-3 sentence overview - explicitly mention alignment with pytest How-to guide patterns]

## Strengths
- [Specific examples of pytest patterns used correctly with links to relevant How-to guide sections]
- [Effective use of pytest features per official recommendations]

## Pattern Divergences from Pytest How-to Guides

**This is the core of the review - every divergence must be documented:**

### Divergence 1: [Pattern Name]
**Location**: tests/test_example.py:45-60

**Current approach**:
```python
[Show actual code]
```

**Pytest recommended approach** (per [link to specific How-to guide section]):
```python
[Show what pytest docs recommend]
```

**Analysis**:
- Why it diverges: [Explain the difference]
- Justification found: [Yes/No - is there a comment or clear reason?]
- Edge case identified: [If yes, describe it]
- Recommendation: 
  - [ ] Adopt pytest pattern (no valid reason for divergence)
  - [ ] Add explanatory comment (valid edge case but undocumented)
  - [ ] Request user clarification (unclear why this approach was taken)

---

### Divergence 2: [Pattern Name]
[Continue same format for ALL divergences found]

---

## Missing Pytest Features

Based on How-to guides review, these pytest features could improve the test suite:

- **Feature 1**: [Name and link to How-to guide]
  - Would solve: [Current problem]
  - Example use case: [Where it would help]
  
- **Feature 2**: [Name and link to How-to guide]
  - Would solve: [Current problem]
  - Example use case: [Where it would help]

## Coverage Analysis
- Current coverage: X%
- Critical gaps: [List uncovered critical paths]
- Edge cases missing: [Examples]

## Recommended Next Steps

### Priority 1: High Impact - Align with Pytest Patterns
1. [Adopt pytest pattern X for cases A, B, C]
   - Why: Diverges from https://docs.pytest.org/... without justification
   - Impact: Simplifies code, follows community standards
   - Effort: [Small/Medium/Large]
   
2. [Add explanatory comments for legitimate divergences]
   - Why: Valid edge cases but future maintainers won't understand them
   - Impact: Prevents confusion and unnecessary refactoring attempts
   - Effort: Small

### Priority 2: Medium Impact - Adopt Missing Features
1. [Implement feature Y per How-to guide]
   - Why: Would eliminate code duplication / improve clarity
   - Reference: [Link to specific How-to guide]
   - Effort: [Small/Medium/Large]

### Priority 3: Low Impact - Optimizations
[Continue pattern]

## Questions for You

Before proceeding, I need your input on the pattern divergences:

1. **For divergences marked "Request user clarification"**: Can you explain why [specific pattern] was used instead of the pytest-recommended approach?

2. **For patterns I couldn't find in pytest docs**: Are there project-specific testing needs that pytest doesn't address? Should these be documented?

3. **Priority concerns**: Do you have strong opinions about maintaining certain patterns even if they diverge from pytest recommendations?
```

**Important:** 
- Every divergence from pytest How-to guides must be called out explicitly
- Link to the specific How-to guide section for each divergence
- Don't assume patterns are wrong - investigate and document the reasoning
- Be especially thorough in documenting edge cases that justify divergences

### 5. Await User Confirmation

Present the report and explicitly ask:

```
Based on this review, I see [number] areas for improvement prioritized by impact.

Would you like me to:
A) Proceed with implementing the Priority 1 (high impact) recommendations?
B) Revise the recommendations based on your feedback?
C) Cancel this review - you're satisfied with the current state?

Please let me know which option you prefer, or provide specific guidance on what you'd like to focus on.
```

### 6. Implementation Phase (Only After Confirmation)

If user chooses option A or provides custom guidance:

**Create implementation plan with pytest How-to guide references:**
- Break down each recommendation into specific tasks
- For pattern adoptions: Link to the specific How-to guide being followed
- For comment additions: Draft the explanatory comments
- Estimate effort for each task
- Propose order of execution
- Identify any dependencies

**Before making changes:**
- Confirm the detailed plan with user
- For divergences being preserved: get user confirmation on comment wording
- Ask if they want to review each change or proceed with all
- Clarify any ambiguous requirements

**During implementation:**

For adopting pytest patterns:
- Reference the specific How-to guide section being implemented
- Make one logical change at a time
- Ensure the new pattern matches pytest docs exactly
- Run tests after each change to ensure nothing breaks
- Add comments explaining the pattern if it's not immediately obvious

For adding explanatory comments to justified divergences:
- Clearly state why the standard pytest pattern isn't used
- Reference what the pytest docs would normally recommend
- Explain the edge case or requirement that necessitates the divergence
- Format: "Note: Using [custom approach] instead of pytest's [recommended approach] because [specific reason]. See [pytest doc link] for standard pattern."

Example comment for justified divergence:
```python
# Note: Using manual tempfile cleanup instead of tmp_path fixture because
# we need the directory to persist across multiple test sessions for caching.
# Standard pytest tmp_path pattern: https://docs.pytest.org/en/stable/how-to/tmp_path.html
def test_with_persistent_cache():
    tmpdir = tempfile.mkdtemp()
    try:
        # ... test code ...
    finally:
        # Conditional cleanup based on test result
        if should_preserve_for_debugging:
            print(f"Cache preserved at: {tmpdir}")
        else:
            shutil.rmtree(tmpdir)
```

**After implementation:**
- Run full test suite: `pytest -v`
- Generate coverage report: `pytest --cov=src --cov-report=html`
- Summarize what was changed:
  - Patterns adopted from pytest How-to guides (with links)
  - Comments added to justified divergences (with explanations)
  - Results: test pass/fail status, coverage changes

### 7. Handle Rejection or Iteration

If user chooses option B (revise):
- Ask specific questions about their concerns
- Understand their priorities and constraints
- For pattern divergences they want to keep: help draft clear explanatory comments
- Revise recommendations based on feedback
- Present updated recommendations with justifications
- Return to step 5 (await confirmation)

If user chooses option C (cancel):
- Acknowledge their satisfaction with current tests
- If tests already follow pytest patterns well, celebrate that
- Offer to revisit if needs change in future
- End the review process gracefully

## Best Practices Reference

### Pytest Documentation Quick Links

**Essential reading for this review:**
- Fixtures: https://docs.pytest.org/en/stable/how-to/fixtures.html
- Parametrize: https://docs.pytest.org/en/stable/how-to/parametrize.html
- Marks: https://docs.pytest.org/en/stable/how-to/mark.html
- Assertions: https://docs.pytest.org/en/stable/how-to/assert.html
- Test organization: https://docs.pytest.org/en/stable/explanation/goodpractices.html

**When assessing specific patterns, consult:**
- Mocking: https://docs.pytest.org/en/stable/how-to/monkeypatch.html
- Temporary files: https://docs.pytest.org/en/stable/how-to/tmp_path.html
- Capturing output: https://docs.pytest.org/en/stable/how-to/capture-stdout-stderr.html
- Warnings: https://docs.pytest.org/en/stable/how-to/capture-warnings.html

### Common Pytest Patterns to Look For

**Good patterns:**
```python
# Parametrized tests for variations
@pytest.mark.parametrize("input,expected", [
    ("hello", "HELLO"),
    ("world", "WORLD"),
])
def test_uppercase(input, expected):
    assert input.upper() == expected

# Fixture with proper scope
@pytest.fixture(scope="session")
def expensive_resource():
    resource = create_expensive_resource()
    yield resource
    resource.cleanup()

# Clear arrange-act-assert
def test_user_creation():
    # Arrange
    username = "testuser"
    email = "test@example.com"
    
    # Act
    user = User(username=username, email=email)
    
    # Assert
    assert user.username == username
    assert user.email == email
```

**Problematic patterns:**
```python
# Testing multiple unrelated things
def test_everything():  # ❌ Too broad
    assert func1() == 1
    assert func2() == 2
    assert func3() == 3

# Unclear assertions
def test_result():
    assert result  # ❌ What aspect is being tested?

# Duplicate setup code
def test_a():
    user = User("test")  # ❌ Repeated setup
    # ...

def test_b():
    user = User("test")  # ❌ Should be a fixture
    # ...
```

## Critical Guidelines

- **Always consult pytest How-to guides FIRST**: These are maintained by pytest developers and represent best practices. Every pattern should be compared against them.
- **Document divergences thoroughly**: When tests don't follow pytest patterns, investigate why. Don't assume it's wrong - there may be valid edge cases.
- **Add explanatory comments for justified divergences**: If a non-standard pattern is legitimate, future maintainers need to know why. The comment should reference what pytest recommends and why it doesn't apply.
- **Be honest**: If tests already follow pytest patterns well, celebrate that. Don't create busy-work.
- **Be specific**: Point to exact files/lines and specific How-to guide sections.
- **Be practical**: Consider maintenance burden of recommendations.
- **Be respectful**: Existing patterns may have good reasons. Investigate before criticizing.
- **Wait for confirmation**: Never implement changes without explicit user approval.
- **Stay focused**: Review tests against pytest standards, not just general testing advice.
- **Prioritize pattern alignment**: The main value of this review is identifying where tests diverge from pytest's recommended patterns and determining if those divergences are justified.

## Notes

- This review focuses on **comparing tests to official pytest How-to guide patterns**
- The pytest maintainers have documented solutions for virtually all common testing scenarios
- Pattern divergences aren't necessarily bad - but they should be intentional and documented
- When tests diverge from pytest patterns without clear justification, recommend alignment
- When tests diverge for valid edge cases, add explanatory comments for future maintainers
- If the test suite already follows pytest patterns well, say so clearly and celebrate it
- This review should take time - rushing leads to superficial pattern analysis
- If the test suite is large (100+ tests), consider focusing on representative samples of each pattern type
- Always run the tests yourself to see actual behavior, don't just read code
- Consider the project context - a prototype may need different test rigor than production code
- The goal is alignment with pytest community standards while respecting legitimate project-specific needs
