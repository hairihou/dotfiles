# Anti-Patterns Reference

## Premature Abstraction

- Interface/protocol with single implementation
- Factory that creates only one type
- Base class with one subclass
- Generic type parameter used with only one concrete type
- Strategy pattern with one strategy

## Speculative Generality

- Config option that is never changed from default
- Unused function parameters kept "for future use"
- Generic where a concrete type suffices
- Plugin system with no plugins
- Event system with one emitter and one listener

## Defensive Excess

- Null check on value that cannot be null (e.g., internal function return)
- Try-catch around code that cannot throw
- Validation of data already validated upstream
- Fallback value for required field
- Retry logic for idempotent, reliable internal calls

## Unnecessary Indirection

- Wrapper that only delegates to inner object
- Middleware/decorator that passes through unchanged
- Repository class that mirrors ORM methods 1:1
- Service class with one method calling one function
- Util file with one function used in one place

## Complexity Signals

- Abstraction named `Manager`, `Handler`, `Processor`, `Helper` with unclear responsibility
- More than 3 layers between caller and actual logic
- Dependency injection for objects that never change
- Module re-exports without transformation
- Constants file with values used once
