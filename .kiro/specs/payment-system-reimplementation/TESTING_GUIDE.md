# Payment System Testing Guide

## Overview

The new payment system is now fully integrated into the app and ready for testing. This guide will help you navigate and test all the payment features.

## How to Access Payment Features

### Method 1: Bottom Navigation (Main Entry Point)
1. Open the app
2. Tap the **Payments** tab in the bottom navigation bar
3. You'll see two tabs:
   - **App Services**: Subscribe to app-wide plans
   - **School Services**: Subscribe to school/organization services for your children

### Method 2: Quick Access Menu
From the Payments screen, tap the **three-dot menu (⋮)** in the top-right corner to access:
- **Payment History**: View all your past payments
- **Create Plan Payment**: Directly create a plan subscription payment
- **Create Service Payment**: Directly create a service payment

### Method 3: History Button
Tap the **history icon (🕐)** in the top-right of the Payments screen to view payment history.

## Testing Scenarios

### 1. Subscribe to a Plan (App Services)

**Steps:**
1. Go to Payments → App Services tab
2. Browse available plans
3. Tap **Subscribe Now** on any plan
4. In the dialog:
   - Select a payment method (Cash, Credit Card, Bank Transfer, or Mobile Wallet)
   - Tap **Tap to choose receipt** to upload a receipt image
   - Select image from gallery or take a photo
5. Tap **Subscribe Now** button
6. Verify success message appears
7. Check that you're navigated to Payment History

**Expected Results:**
- ✅ Payment methods display without errors
- ✅ Payment method logos show correctly (or fallback icon)
- ✅ Image picker works
- ✅ Subscribe button enables when all fields are filled
- ✅ Success message appears
- ✅ Navigation to payment history works

### 2. Subscribe to a Service (School Services)

**Steps:**
1. Go to Payments → School Services tab
2. If you have multiple children, select a child from the chips at the top
3. Browse available services for that child
4. Tap **Subscribe Now** on any service
5. In the dialog:
   - Select a payment method
   - Upload a receipt image
6. Tap **Subscribe Now** button
7. Verify success and navigation

**Expected Results:**
- ✅ Child selector works (if multiple children)
- ✅ Services load for selected child
- ✅ Subscription dialog works same as App Services
- ✅ Payment creation succeeds

### 3. View Payment History

**Steps:**
1. Access Payment History via:
   - History button (🕐) in Payments screen
   - Three-dot menu → Payment History
   - Or navigate directly from bottom nav after creating a payment
2. View the payment list organized into:
   - **Plan Payments** section
   - **Service Payments** section
3. Pull down to refresh the list
4. Tap on any payment to view details

**Expected Results:**
- ✅ Payments are organized into two sections
- ✅ Each payment shows amount, status, and date
- ✅ Pull-to-refresh works
- ✅ Empty state shows if no payments
- ✅ Error state shows with retry button if API fails

### 4. View Payment Details

**Steps:**
1. From Payment History, tap any payment
2. View the payment details screen showing:
   - Payment status badge (Pending/Completed/Rejected)
   - Payment information (amount, date, etc.)
   - Receipt image (if available)
   - Rejection reason (if rejected)
3. For plan payments: Check plan ID and notes
4. For service payments: Check service info, payment type, installments
5. Tap receipt image to view full screen
6. Tap back to return to history

**Expected Results:**
- ✅ Status badge displays with correct color
- ✅ All payment fields are visible
- ✅ Receipt image displays correctly
- ✅ Full-screen image viewer works
- ✅ Rejection reason shows prominently for rejected payments

### 5. Create Plan Payment (Direct)

**Steps:**
1. From Payments screen, tap three-dot menu → Create Plan Payment
2. Fill out the form:
   - Select a plan from dropdown
   - Select payment method
   - Enter amount (auto-filled from plan price)
   - Add optional notes
   - Upload receipt image
3. Tap **Submit** button
4. Verify success and navigation to payment history

**Expected Results:**
- ✅ Form loads with plan and payment method dropdowns
- ✅ Amount auto-fills when plan is selected
- ✅ Form validation works (required fields)
- ✅ Receipt image picker works
- ✅ Submit button shows loading state
- ✅ Success navigation works

### 6. Create Service Payment (Direct)

**Steps:**
1. From Payments screen, tap three-dot menu → Create Service Payment
2. Fill out the form:
   - Select a student (child)
   - Select a service (loads based on student)
   - Select payment method
   - Enter amount (auto-filled from service price)
   - Choose payment type (One-time or Installment)
   - If Installment: Enter number of installments
   - Upload receipt image
3. Tap **Submit** button
4. Verify success and navigation

**Expected Results:**
- ✅ Student dropdown works
- ✅ Services load when student is selected
- ✅ Amount auto-fills when service is selected
- ✅ Payment type selector works
- ✅ Installment field shows/hides based on payment type
- ✅ Installment validation works (positive integer required)
- ✅ Form validation works
- ✅ Submit succeeds

## Known Issues & Fixes Applied

### ✅ Fixed: Subscribe Button Not Working
- **Issue**: Button was disabled due to image loading errors
- **Fix**: Added proper URL validation and error handling for payment method logos
- **Status**: RESOLVED

### ✅ Fixed: Image Loading Errors
- **Issue**: Red error boxes showing "Invalid argument(s): No host specified in URI"
- **Fix**: Validate URLs before loading, show fallback icon for invalid URLs
- **Status**: RESOLVED

### ⚠️ Pending: Payment History API
- **Issue**: Payment history shows "Failed to load payments"
- **Cause**: API endpoint `/api/users/parentpayments` may not exist or returns error
- **Workaround**: Check backend logs for actual error
- **Status**: NEEDS BACKEND VERIFICATION

## API Endpoints Used

1. **GET /api/users/parentpayments** - Get all payments
2. **GET /api/users/parentpayments/:id** - Get plan payment details
3. **GET /api/users/parentpayments/org-service/:id** - Get service payment details
4. **POST /api/users/parentpayments** - Create plan payment
5. **POST /api/users/parentpayments/org-service** - Create service payment
6. **GET /api/users/paymentmethods** - Get available payment methods
7. **GET /api/users/parentplans** - Get available plans
8. **GET /api/users/organizationservices/:studentId** - Get services for student

## Debugging Tips

### Enable Debug Logging
The payment repository and cubit now have debug logging. Check the console for:
- `[PaymentRepository]` - API calls and responses
- `[PaymentHistoryCubit]` - State changes and errors
- `[RidesService]` - (Already present in your logs)

### Common Issues

**Issue**: Payment History shows error
- **Check**: Console logs for `[PaymentRepository]` messages
- **Verify**: API endpoint exists and returns correct format
- **Expected format**:
```json
{
  "success": true,
  "data": {
    "payments": [...],
    "orgServicePayments": [...]
  }
}
```

**Issue**: Subscribe button disabled
- **Check**: Payment method logos loading correctly
- **Verify**: Receipt image selected
- **Look for**: Console errors about image loading

**Issue**: Form validation errors
- **Check**: All required fields are filled
- **Verify**: Amount is positive number
- **For installments**: Number must be positive integer

## Navigation Flow

```
Home Screen (Bottom Nav)
  └─ Payments Tab
      ├─ App Services Tab
      │   └─ Subscribe Now → Subscription Dialog → Payment History
      ├─ School Services Tab
      │   └─ Subscribe Now → Subscription Dialog → Payment History
      ├─ History Button → Payment History
      │   └─ Tap Payment → Payment Detail
      └─ Three-Dot Menu
          ├─ Payment History → Payment History
          ├─ Create Plan Payment → Create Plan Payment Form → Payment History
          └─ Create Service Payment → Create Service Payment Form → Payment History
```

## Success Criteria

✅ All navigation paths work correctly
✅ Subscription dialogs open and function properly
✅ Payment creation forms validate and submit
✅ Payment history displays (when API is working)
✅ Payment details show all information
✅ Images load without errors
✅ No crashes or exceptions during normal use

## Next Steps

1. **Test all scenarios** listed above
2. **Verify backend APIs** are working correctly
3. **Check console logs** for any errors
4. **Report any issues** found during testing
5. **Verify payment status updates** (pending → completed/rejected)

## Support

If you encounter any issues:
1. Check the console logs for error messages
2. Verify you're logged in with a valid token
3. Ensure backend APIs are accessible
4. Check network connectivity
5. Review the error messages in the UI

Happy Testing! 🎉
