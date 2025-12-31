---
name: python-development
description: Use when working on Python projects, setting up Python environments, choosing Python tooling, or implementing Python patterns. Covers uv, ruff, mypy, pytest, and modern Python practices.
---

# Python Development Standards

## Overview

Modern Python development with uv, ruff, mypy, and pytest. Python 3.12+ required.

**Core principle:** Type safety, strict linting, and fast dependency management.

## Environment Setup

| Tool | Purpose |
|------|---------|
| Python | >=3.12 |
| Package Manager | uv (NEVER pip, poetry, or venv) |
| Dependencies | pyproject.toml + uv.lock |

## Essential Commands

```bash
# Install dependencies
uv sync --dev

# Run application
uv run python -m app.main

# Run tests
uv run pytest

# Format code
uv run ruff format .

# Lint code
uv run ruff check .

# Lint and auto-fix
uv run ruff check --fix .

# Type check
uv run mypy src/
```

## Code Quality Tools

| Tool | Purpose | Config |
|------|---------|--------|
| Ruff | Linting + formatting | pyproject.toml |
| MyPy | Type checking | --strict flag |
| pytest | Testing | 90% coverage target |

## Python-Specific Standards

### Type Hints

All functions require type hints including return types:

```python
def process_user(user_id: int, options: dict[str, str] | None = None) -> User:
    ...
```

### Data Structures

Prefer in order:
1. `dataclasses` for simple data
2. `Pydantic` models for validation
3. `TypedDict` for dictionary shapes

### File Operations

Always use `pathlib`:

```python
from pathlib import Path

config_path = Path("config") / "settings.json"
content = config_path.read_text()
```

Never use `os.path`.

### Resource Handling

Context managers for all resources:

```python
with open(path) as f:
    data = f.read()
```

### Async/Await

Use for I/O operations when beneficial:

```python
async def fetch_data(url: str) -> dict[str, Any]:
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return await response.json()
```

## Naming Conventions

| Element | Style | Example |
|---------|-------|---------|
| Functions/Variables | snake_case | `get_user_data` |
| Classes | PascalCase | `UserManager` |
| Constants | UPPER_SNAKE | `MAX_RETRIES` |
| Modules | snake_case | `user_service.py` |

## Common Patterns

```python
# Entry points
if __name__ == "__main__":
    main()

# String formatting (f-strings)
message = f"User {user.name} logged in at {timestamp}"

# Iteration
for index, item in enumerate(items):
    process(index, item)

# Comprehensions for simple transforms
names = [user.name for user in users if user.active]

# Generators for memory efficiency
def process_large_file(path: Path) -> Iterator[str]:
    with open(path) as f:
        for line in f:
            yield line.strip()
```

## Error Handling

```python
# Specific exceptions, never bare except
try:
    result = process(data)
except ValueError as e:
    logger.error("Invalid data: %s", e)
    raise

# Use logging, not print
import logging
logger = logging.getLogger(__name__)
logger.info("Processing started")

# Raise early with clear messages
if not user_id:
    raise ValueError("user_id is required")
```

## Docstrings

Google-style for all public APIs:

```python
def calculate_score(user: User, weights: dict[str, float]) -> float:
    """Calculate weighted score for a user.

    Args:
        user: The user to score.
        weights: Weight values by category.

    Returns:
        The calculated score between 0.0 and 1.0.

    Raises:
        ValueError: If weights sum to zero.
    """
```

## Quick Reference

| Need | Use |
|------|-----|
| Install deps | `uv sync --dev` |
| Run tests | `uv run pytest` |
| Format | `uv run ruff format .` |
| Lint | `uv run ruff check .` |
| Type check | `uv run mypy src/` |
| File paths | `pathlib.Path` |
| Data classes | `@dataclass` or Pydantic |
| Async I/O | `async/await` |
