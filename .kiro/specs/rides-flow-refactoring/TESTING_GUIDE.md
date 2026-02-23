# Rides Flow Refactoring - Testing Guide

## Quick Start

### Running the App

```bash
# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Run in release mode for performance testing
flutter run --release
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/integration/rides_flow_integration_test.dart

# Run tests with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Test Status

### ✅ Implementation Complete
All code is implemented and compiles without errors:
- ✅ Data models (API response models)
- ✅ Services (RidesService with all endpoints)
- ✅ Repository (RidesRepository with caching)
- ✅ Cubits (Dashboard, ChildRides, Tracking, Absence)
- ✅ UI Screens (Dashboard, Schedule, Tracking, Upcoming)
- ✅ Localization (English, Arabic, French, German)
- ✅ Error handling (Network, Server, Auth errors)

### ⚠️ Tests Need Attention
- ⚠️ Existing tests have dependency issues (need mockito package)
- ⚠️ Integration tests need model alignment
- ⚠️ Test coverage is below 80% target
- ⚠️ Manual testing not yet executed

## Manual Testing

### Prerequisites
1. Test device or emulator running
2. Test account with:
   - Multiple children registered
   - Active rides scheduled
   - Past ride history
3. Network connectivity available

### Testing Process
1. Open `.kiro/specs/rides-flow-refactoring/task-20-manual-testing-checklist.md`
2. Follow each test case in order
3. Mark each test as passed/failed
4. Document any issues found
5. Take screenshots of issues
6. Report to development team

### Key Areas to Test

#### 1. Dashboard (Priority: HIGH)
- Children display correctly
- Active rides count is accurate
- Tracking buttons enable/disable correctly
- Pull-to-refresh works

#### 2. Child Schedule (Priority: HIGH)
- Today/Upcoming/History tabs work
- Ride details are complete
- Status colors are correct
- Absence reporting works

#### 3. Live Tracking (Priority: MEDIUM)
- Map displays bus location
- Auto-refresh works (10 seconds)
- Bus info is accurate

#### 4. Timeline Tracking (Priority: MEDIUM)
- Events in chronological order
- Pickup points display correctly
- Current child is highlighted

#### 5. Localization (Priority: HIGH)
- Switch to Arabic
- Verify RTL layout
- Check all translations
- Verify date/time formatting

#### 6. Error Handling (Priority: HIGH)
- Turn off network
- Verify error messages
- Test retry functionality

## Automated Testing

### Integration Tests
Location: `test/integration/rides_flow_integration_test.dart`

**Status**: Created but needs model fixes to compile

**Test Coverage**:
- Dashboard → Child Schedule flow
- Dashboard → Live Tracking flow
- Dashboard → Timeline Tracking flow
- Child Schedule → Absence Reporting flow
- Caching behavior
- Error recovery
- State transitions

**To Fix**:
1. Align mock models with actual API models
2. Fix constructor parameters
3. Update property names
4. Run tests to verify

### Unit Tests
**Status**: Need to be created

**Recommended Tests**:
- Data model JSON parsing
- Repository caching logic
- Cubit state transitions
- Error handler utility
- L10n utility functions

### Widget Tests
**Status**: Need to be created

**Recommended Tests**:
- RidesScreen widget
- ChildScheduleScreen widget
- Absence reporting dialog
- Error display widget
- Empty state widgets

## Test Dependencies

### Required Packages
Add to `pubspec.yaml` under `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
  bloc_test: ^9.1.0
```

### Install Dependencies
```bash
flutter pub get
```

### Generate Mocks
```bash
flutter pub run build_runner build
```

## Common Issues

### Issue: Tests won't compile
**Solution**: 
1. Check package names (should be `kidsero_parent`, not `kidsero_driver`)
2. Verify all imports are correct
3. Run `flutter pub get`
4. Run `flutter clean` and rebuild

### Issue: Mock generation fails
**Solution**:
1. Add `@GenerateMocks` annotation to test file
2. Run `flutter pub run build_runner build --delete-conflicting-outputs`

### Issue: Integration tests fail
**Solution**:
1. Check API model constructors match test mocks
2. Verify all required parameters are provided
3. Check property names match actual models

## Performance Testing

### Metrics to Measure
- Dashboard load time: < 2 seconds
- Child schedule load time: < 1 second
- Tracking screen load time: < 1 second
- Cache hit rate: > 80%
- Auto-refresh impact: < 5% CPU

### Tools
```bash
# Profile app performance
flutter run --profile

# Analyze build size
flutter build apk --analyze-size

# Check for performance issues
flutter analyze
```

## Deployment Checklist

Before deploying to production:

- [ ] All manual tests pass
- [ ] No critical issues found
- [ ] Performance metrics meet targets
- [ ] Localization verified for all languages
- [ ] Error handling tested thoroughly
- [ ] QA sign-off obtained
- [ ] Product owner approval
- [ ] Release notes prepared

## Support

### Documentation
- Requirements: `.kiro/specs/rides-flow-refactoring/requirements.md`
- Design: `.kiro/specs/rides-flow-refactoring/design.md`
- Tasks: `.kiro/specs/rides-flow-refactoring/tasks.md`
- Manual Testing: `.kiro/specs/rides-flow-refactoring/task-20-manual-testing-checklist.md`

### Contact
- Development Team: [Contact Info]
- QA Team: [Contact Info]
- Product Owner: [Contact Info]

## Notes

- The implementation is complete and ready for testing
- Focus on manual testing first to catch UI/UX issues
- Automated tests can be added incrementally
- Prioritize high-impact areas (Dashboard, Child Schedule, Localization)
- Document all issues with screenshots and steps to reproduce

