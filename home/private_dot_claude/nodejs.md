# Node.js & JavaScript Guidelines

## Core Principles
- Use async/await over Promise.then() chains
- Prefer ES6+ modules over CommonJS when possible
- Use TypeScript for larger projects
- Follow semantic versioning for packages
- Keep functions pure and side-effect-free when possible

## Conventions

### Code Style
- Use semicolons consistently
- Prefer `const` over `let`, avoid `var`
- Use template literals over string concatenation
- Use destructuring for object/array extraction
- Use arrow functions for callbacks and short functions

### File Organization
- `index.js` - main entry point
- `package.json` - dependencies and scripts
- `src/` - source code directory
- `test/` or `__tests__/` - test files
- `.env` - environment variables (never commit)
- `.gitignore` - include node_modules, .env, dist/

### Naming Conventions
- **Files**: kebab-case (`user-service.js`)
- **Variables/Functions**: camelCase (`getUserName`)
- **Constants**: SCREAMING_SNAKE_CASE (`MAX_RETRIES`)
- **Classes**: PascalCase (`UserService`)

## Best Practices

### Error Handling
```javascript
// Good: Specific error handling
try {
  const data = await fetchUserData(id);
  return data;
} catch (error) {
  if (error.code === 'USER_NOT_FOUND') {
    return null;
  }
  throw error;
}

// Good: Early returns
function processUser(user) {
  if (!user) {
    return null;
  }

  if (!user.isActive) {
    return { status: 'inactive' };
  }

  return processActiveUser(user);
}
```

### Async Operations
```javascript
// Good: Use Promise.all for parallel operations
const [users, posts, comments] = await Promise.all([
  fetchUsers(),
  fetchPosts(),
  fetchComments()
]);

// Good: Handle errors in async functions
async function saveUser(userData) {
  try {
    const user = await User.create(userData);
    return user;
  } catch (error) {
    logger.error('Failed to save user:', error);
    throw new Error('User creation failed');
  }
}
```

### Environment Configuration
```javascript
// config.js
const config = {
  port: process.env.PORT || 3000,
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'dev-secret'
  }
};

module.exports = config;
```

## TypeScript Integration
- Use `.ts` extension for TypeScript files
- Define interfaces for complex objects
- Use union types for multiple possible values
- Leverage type inference, don't over-type
- Use `strict` mode in tsconfig.json

```typescript
interface User {
  id: string;
  email: string;
  profile?: UserProfile;
}

type UserStatus = 'active' | 'inactive' | 'pending';

async function getUserById(id: string): Promise<User | null> {
  const user = await db.user.findUnique({ where: { id } });
  return user;
}
```

## Package Management
- Use `npm` or `yarn` consistently within a project
- Lock versions with `package-lock.json` or `yarn.lock`
- Use `npm ci` in CI/CD for faster, reliable installs
- Keep dependencies up to date with security patches
- Separate `dependencies` from `devDependencies`

## Testing
- Use Jest for unit/integration testing
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)
- Mock external dependencies
- Test error cases and edge conditions

```javascript
describe('UserService', () => {
  test('should return user when valid ID provided', async () => {
    // Arrange
    const userId = '123';
    const expectedUser = { id: userId, email: 'test@example.com' };
    mockDb.user.findUnique.mockResolvedValue(expectedUser);

    // Act
    const result = await UserService.getUserById(userId);

    // Assert
    expect(result).toEqual(expectedUser);
  });
});
```

## Quick Reference

### Common Commands
```bash
# Initialize project
npm init -y

# Install dependencies
npm install express
npm install -D jest nodemon

# Run scripts
npm run dev
npm test
npm run build

# Security audit
npm audit
npm audit fix
```

### Essential Dependencies
- **Express**: Web framework
- **Jest**: Testing framework
- **Nodemon**: Development auto-restart
- **ESLint**: Code linting
- **Prettier**: Code formatting
- **Dotenv**: Environment variables