# QA Quick Start Guide - Rides Flow Refactoring

## Welcome QA Team! 👋

This guide will help you get started testing the refactored rides flow quickly.

## What Changed?

The rides feature has been completely refactored to use new API endpoints while keeping the same UI design. Everything should look familiar, but the underlying code is new and needs thorough testing.

## Before You Start

### What You Need
- [ ] Test device or emulator (iOS or Android)
- [ ] Test account with:
  - At least 2 children registered
  - Some active rides scheduled
  - Some past ride history
- [ ] Network connectivity
- [ ] This testing checklist

### Test Accounts
Ask the development team for test accounts with different scenarios:
- Account with 1 child
- Account with multiple children
- Account with active rides
- Account with no rides
- Account with only past rides

## Quick Test (15 minutes)

If you only have 15 minutes, test these critical flows:

### 1. Dashboard Smoke Test (3 min)
1. Open the app
2. Verify dashboard loads
3. Check children count is correct
4. Check active rides count is correct
5. Verify all children cards display

### 2. Child Schedule Test (3 min)
1. Tap any child card
2. Verify schedule screen opens
3. Check "Today" tab shows today's rides
4. Switch to "Upcoming" tab
5. Switch to "History" tab
6. Verify all tabs load correctly

### 3. Tracking Test (3 min)
1. Go back to dashboard
2. If active rides exist, tap "Live Tracking"
3. Verify tracking screen opens
4. Check map displays
5. Check bus information shows

### 4. Language Test (3 min)
1. Go to settings
2. Switch language to Arabic
3. Verify all text changes to Arabic
4. Verify layout is right-to-left
5. Switch back to English

### 5. Error Test (3 min)
1. Turn off WiFi/network
2. Pull to refresh on dashboard
3. Verify error message shows
4. Verify retry button appears
5. Turn on network
6. Tap retry
7. Verify data loads

**If all 5 tests pass, the basic functionality is working!**

## Full Test (2-3 hours)

For comprehensive testing, use the full checklist:

📄 **File**: `.kiro/specs/rides-flow-refactoring/task-20-manual-testing-checklist.md`

This checklist has 153 test cases covering:
- Dashboard (16 tests)
- Child Schedule (18 tests)
- Live Tracking (15 tests)
- Timeline Tracking (15 tests)
- Upcoming Rides (8 tests)
- Absence Reporting (10 tests)
- Localization (15 tests)
- Error Handling (12 tests)
- Performance (7 tests)
- UI/UX (9 tests)
- Integration Flows (16 tests)
- Edge Cases (12 tests)

## What to Look For

### Critical Issues (Report Immediately)
- ❌ App crashes
- ❌ Data not loading
- ❌ Wrong data displayed
- ❌ Cannot navigate between screens
- ❌ Buttons don't work
- ❌ Network errors not handled

### High Priority Issues
- ⚠️ UI elements misaligned
- ⚠️ Text cutoff or overflow
- ⚠️ Wrong colors or styling
- ⚠️ Slow loading (>3 seconds)
- ⚠️ Missing translations
- ⚠️ Wrong date/time format

### Medium Priority Issues
- 🔸 Minor UI inconsistencies
- 🔸 Unclear error messages
- 🔸 Missing empty states
- 🔸 Animation glitches

### Low Priority Issues
- 🔹 Cosmetic issues
- 🔹 Suggestions for improvement
- 🔹 Nice-to-have features

## How to Report Issues

### Issue Template

```
**Title**: [Brief description]

**Severity**: Critical / High / Medium / Low

**Steps to Reproduce**:
1. 
2. 
3. 

**Expected Result**:
[What should happen]

**Actual Result**:
[What actually happened]

**Screenshots**:
[Attach screenshots]

**Environment**:
- Device: [e.g., iPhone 12, Samsung Galaxy S21]
- OS Version: [e.g., iOS 15.0, Android 12]
- App Version: [e.g., 0.1.0]
- Language: [e.g., English, Arabic]

**Additional Notes**:
[Any other relevant information]
```

### Where to Report
- [Your issue tracking system - Jira, GitHub Issues, etc.]
- Tag issues with: `rides-refactoring`, `qa-testing`

## Test Scenarios

### Scenario 1: Happy Path
**Goal**: Test the most common user journey

1. Open app → Dashboard loads
2. View children and active rides
3. Tap child card → Schedule opens
4. View today's rides
5. Tap "Track All Rides" → Timeline opens
6. View ride progress
7. Go back to dashboard
8. Pull to refresh → Data updates

**Expected**: Everything works smoothly

### Scenario 2: No Active Rides
**Goal**: Test when there are no active rides

1. Use account with no active rides
2. Open dashboard
3. Verify tracking buttons are disabled
4. Verify appropriate message shows
5. Tap child card
6. Verify schedule shows correctly
7. Verify no active ride indicator

**Expected**: UI handles empty state gracefully

### Scenario 3: Network Issues
**Goal**: Test error handling

1. Turn off network
2. Open app
3. Verify error message shows
4. Tap retry (should fail)
5. Turn on network
6. Tap retry again
7. Verify data loads

**Expected**: Clear error messages and recovery

### Scenario 4: Arabic Language
**Goal**: Test localization

1. Switch to Arabic
2. Verify all text is Arabic
3. Verify layout is RTL
4. Test all screens
5. Verify dates format correctly
6. Verify times format correctly

**Expected**: Complete Arabic support

### Scenario 5: Absence Reporting
**Goal**: Test reporting absence

1. Go to child schedule
2. View today's rides
3. Tap report absence
4. Try submitting empty reason (should fail)
5. Enter valid reason
6. Submit
7. Verify success message
8. Verify ride status updates to "excused"

**Expected**: Absence reporting works correctly

## Testing Tips

### Tip 1: Test on Real Devices
- Emulators are good, but real devices are better
- Test on both iOS and Android if possible
- Test on different screen sizes

### Tip 2: Test Different Data States
- Empty states (no children, no rides)
- Single item states (1 child, 1 ride)
- Multiple items (many children, many rides)
- Edge cases (very long names, special characters)

### Tip 3: Test Network Conditions
- Good network (WiFi)
- Slow network (3G)
- No network (offline)
- Intermittent network (switching)

### Tip 4: Test Languages
- English (LTR)
- Arabic (RTL)
- French (LTR with accents)
- German (LTR with long words)

### Tip 5: Take Screenshots
- Screenshot every issue
- Screenshot before and after
- Screenshot error messages
- Screenshots help developers fix issues faster

## Common Questions

### Q: What if I find a critical bug?
**A**: Report it immediately to the development team. Mark it as "Critical" severity.

### Q: Should I test on both iOS and Android?
**A**: Yes, if possible. Some issues only appear on one platform.

### Q: How long should testing take?
**A**: Quick test: 15 minutes. Full test: 2-3 hours. Thorough test: 1 day.

### Q: What if the app crashes?
**A**: Note the steps to reproduce, take a screenshot if possible, and report as critical.

### Q: Can I skip some tests?
**A**: Focus on critical flows first (dashboard, schedule, tracking). Other tests can be done later.

### Q: What if I don't understand a test case?
**A**: Ask the development team for clarification. Better to ask than to skip.

## Success Criteria

The rides flow is ready for production when:

- ✅ All critical flows work correctly
- ✅ No critical or high-priority bugs
- ✅ All languages display correctly
- ✅ Error handling works properly
- ✅ Performance is acceptable
- ✅ UI matches design
- ✅ All test cases pass

## Contact

### Development Team
- [Developer Name/Email]
- [Developer Name/Email]

### Product Owner
- [PO Name/Email]

### QA Lead
- [QA Lead Name/Email]

## Resources

### Documentation
- **Full Testing Checklist**: `task-20-manual-testing-checklist.md`
- **Testing Guide**: `TESTING_GUIDE.md`
- **Project Summary**: `PROJECT_COMPLETION_SUMMARY.md`
- **Requirements**: `requirements.md`
- **Design**: `design.md`

### Tools
- **Issue Tracker**: [Link]
- **Test Management**: [Link]
- **Communication**: [Slack/Teams channel]

## Good Luck! 🚀

Thank you for testing the rides flow refactoring. Your thorough testing will help ensure a great experience for our users!

If you have any questions or need help, don't hesitate to reach out to the development team.

---

**Remember**: It's better to report a false positive than to miss a real bug!

