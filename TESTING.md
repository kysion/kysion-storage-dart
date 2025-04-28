# Kysion Storage Testing Documentation

[English](TESTING.md) | [中文](TESTING.zh-CN.md)

## Overview

The Kysion Storage library contains comprehensive unit tests to ensure stable and reliable functionality. Our goal is to maintain high test coverage (above 80%) and high-quality test cases.

## Test Scope

The test suite covers the following key aspects:

- **Basic Storage Operations** - Store, read, delete, and clear operations
- **Type Safety** - Storage and retrieval of different data types
- **Storage Engine Selection** - Automatic and forced selection of storage engines
- **Expiration Mechanism** - Automatic data expiration functionality
- **Encryption Features** - Encryption and decryption at different security levels
- **Builder Pattern** - Chained call API and configuration settings

## Running Tests

### Local Run

```bash
# Run in the kysion_storage directory
./tool/run_tests.sh
```

The above script will:

1. Install necessary dependencies
2. Generate mockito Mock classes
3. Run tests and collect coverage
4. Generate HTML coverage report if lcov is installed

### CI Environment

We use GitHub Actions to automatically run tests. Every commit and PR triggers the testing process.

You can simulate the CI environment test locally:

```bash
./tool/ci_test.sh
```

## Adding New Tests

When adding new features, please add corresponding tests:

1. Create a separate test method for a feature point
2. Use helper functions in `test_helpers.dart` to simplify test setup
3. Ensure coverage of normal cases and edge cases

For example:

```dart
test('Store and read object', () async {
  final user = TestUser(id: 1, name: 'Test User');
  await storageService.set('userKey', user);
  
  final retrievedUser = await storageService.get<TestUser>(
    'userKey',
    fromJson: (map) => TestUser.fromMap(map),
  );
  
  expect(retrievedUser?.id, 1);
  expect(retrievedUser?.name, 'Test User');
});
```

## Mock Objects

To isolate test dependencies, we use the following Mock objects:

- **MockSharedPreferences** - Simulates SharedPreferences behavior
- **MockHiveBox** - Simulates Hive Box behavior

To modify or enhance Mock objects, please edit the `mocks.dart` file.

## Testing Environment Considerations

When testing, please note the following:

1. Use the `markInitialized()` method to skip actual platform initialization
2. Use the `setDependencies()` method to inject Mock objects
3. Avoid direct imports from internal implementation classes (classes under the `src/` directory)
4. For complex object testing, use explicit deserialization functions

## Coverage Reports

Test coverage reports are available at the following locations:

- **Local**: `coverage/html/index.html` (requires lcov)
- **CI**: View via Codecov [![codecov](https://img.shields.io/badge/codecov-1.1.0+-blue)](https://codecov.io/gh/kysion/kysion_storage)

## Best Practices

- At least one test for each feature point
- Test names should clearly describe the behavior being tested
- Use `group` to organize related tests
- Each test should focus on one aspect, don't test multiple feature points in one test
- Use `setUp` and `tearDown` to manage the test environment
