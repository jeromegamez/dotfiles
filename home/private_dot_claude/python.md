# Python Guidelines

## Core Principles
- Follow PEP 8 style guide
- Use type hints for function parameters and return values
- Write docstrings for modules, classes, and functions
- Prefer explicit over implicit
- Use context managers for resource management
- Keep functions small and focused

## Conventions

### Code Style (PEP 8)
- Indentation: 4 spaces (no tabs)
- Line length: 79 characters for code, 72 for docstrings
- Naming: snake_case for variables/functions, PascalCase for classes
- Import order: standard library, third-party, local imports
- Use `is` for None comparisons, `==` for values

### File Organization
- `main.py` or `__main__.py` - entry point
- `requirements.txt` - dependencies
- `pyproject.toml` - modern project configuration
- `src/` - source code directory
- `tests/` - test files
- `README.md` - project documentation

### Naming Conventions
- **Modules**: lowercase with underscores (`user_service.py`)
- **Classes**: PascalCase (`UserService`)
- **Functions/Variables**: snake_case (`get_user_name`)
- **Constants**: SCREAMING_SNAKE_CASE (`MAX_RETRIES`)
- **Private**: leading underscore (`_private_method`)

## Type Hints
```python
from typing import List, Dict, Optional, Union
from dataclasses import dataclass

@dataclass
class User:
    id: int
    email: str
    name: Optional[str] = None

def get_users_by_status(status: str) -> List[User]:
    """Fetch users with specified status."""
    return database.query_users(status=status)

def process_data(data: Dict[str, Union[str, int]]) -> bool:
    """Process incoming data and return success status."""
    try:
        # Process data
        return True
    except Exception as e:
        logger.error(f"Processing failed: {e}")
        return False
```

## Best Practices

### Error Handling
```python
# Good: Specific exceptions
try:
    user = User.objects.get(id=user_id)
except User.DoesNotExist:
    return None
except DatabaseError as e:
    logger.error(f"Database error: {e}")
    raise

# Good: Early returns
def validate_user(user_data):
    if not user_data:
        return False, "No user data provided"

    if not user_data.get('email'):
        return False, "Email is required"

    return True, "Valid user"
```

### Context Managers
```python
# Good: Use context managers for file operations
with open('data.txt', 'r') as file:
    content = file.read()

# Good: Custom context manager
@contextmanager
def database_transaction():
    trans = db.begin_transaction()
    try:
        yield trans
        trans.commit()
    except Exception:
        trans.rollback()
        raise
    finally:
        trans.close()
```

### List Comprehensions & Generators
```python
# Good: List comprehension for simple transformations
active_users = [user for user in users if user.is_active]

# Good: Generator for memory efficiency
def process_large_dataset(filename):
    with open(filename) as file:
        for line in file:
            yield process_line(line)

# Good: Use built-in functions
total = sum(item.price for item in cart.items)
```

## Virtual Environments
```bash
# Create virtual environment
python -m venv venv
python -m venv .venv  # Hidden directory

# Activate (Unix/macOS)
source venv/bin/activate
source .venv/bin/activate

# Activate (Windows)
venv\Scripts\activate
.venv\Scripts\activate

# Deactivate
deactivate

# Install dependencies
pip install -r requirements.txt

# Freeze dependencies
pip freeze > requirements.txt
```

## Testing with pytest
```python
import pytest
from unittest.mock import Mock, patch

def test_user_creation():
    """Test user creation with valid data."""
    user_data = {"email": "test@example.com", "name": "Test User"}
    user = create_user(user_data)

    assert user.email == "test@example.com"
    assert user.name == "Test User"

def test_user_creation_missing_email():
    """Test user creation fails without email."""
    user_data = {"name": "Test User"}

    with pytest.raises(ValidationError):
        create_user(user_data)

@patch('requests.get')
def test_api_call(mock_get):
    """Test API call with mocked response."""
    mock_response = Mock()
    mock_response.json.return_value = {"status": "success"}
    mock_get.return_value = mock_response

    result = fetch_data_from_api()
    assert result["status"] == "success"
```

## Package Management

### Modern Python (pyproject.toml)
```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "my-package"
version = "0.1.0"
description = "A sample Python project"
dependencies = [
    "requests>=2.28.0",
    "click>=8.0.0"
]

[project.optional-dependencies]
dev = ["pytest>=7.0", "black", "flake8"]
```

### Legacy requirements.txt
```txt
# Production dependencies
requests>=2.28.0,<3.0.0
click>=8.0.0

# Development dependencies (use dev-requirements.txt)
pytest>=7.0
black>=22.0
flake8>=5.0
```

## Code Quality Tools
```bash
# Format code
black .
black --line-length 88 src/

# Lint code
flake8 src/
pylint src/

# Type checking
mypy src/

# Security scan
bandit -r src/

# Sort imports
isort .
```

## Common Patterns

### Dataclasses
```python
from dataclasses import dataclass, field
from typing import List

@dataclass
class Product:
    name: str
    price: float
    tags: List[str] = field(default_factory=list)

    def __post_init__(self):
        if self.price < 0:
            raise ValueError("Price cannot be negative")
```

### Properties
```python
class Temperature:
    def __init__(self, celsius: float):
        self._celsius = celsius

    @property
    def celsius(self) -> float:
        return self._celsius

    @property
    def fahrenheit(self) -> float:
        return (self._celsius * 9/5) + 32

    @celsius.setter
    def celsius(self, value: float):
        if value < -273.15:
            raise ValueError("Temperature below absolute zero")
        self._celsius = value
```

## Quick Reference

### Common Commands
```bash
# Run Python file
python script.py
python -m module_name

# Install packages
pip install package_name
pip install -r requirements.txt

# Run tests
pytest
pytest tests/ -v
pytest --cov=src

# Format and lint
black .
flake8 .
mypy .
```