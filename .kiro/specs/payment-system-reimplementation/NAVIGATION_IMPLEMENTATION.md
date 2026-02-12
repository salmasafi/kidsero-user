# Payment System Navigation Implementation

## Overview

This document describes the navigation and routing implementation for the payment system feature.

## Routes Added

The following routes have been added to `lib/core/routing/routes.dart`:

1. **Payment History** (`/payment-history`)
   - Displays all parent payments (plan and service)
   - Entry point for the payment system

2. **Payment Detail** (`/payment-detail`)
   - Shows detailed information about a specific payment
   - Requires parameters: `paymentId` (String) and `isPlanPayment` (bool)

3. **Create Plan Payment** (`/create-plan-payment`)
   - Form for creating a new plan subscription payment

4. **Create Service Payment** (`/create-service-payment`)
   - Form for creating a new organization service payment

## Navigation Flow

### From Payment History to Payment Detail

```dart
context.push(
  Routes.paymentDetail,
  extra: {
    'paymentId': payment.id,
    'isPlanPayment': true, // or false for service payments
  },
);
```

### From Create Payment Screens to Payment History

After successful payment creation:

```dart
context.go(Routes.paymentHistory);
```

This uses `context.go()` instead of `context.push()` to replace the current route, preventing users from navigating back to the form after submission.

## Parameter Passing

### Payment Detail Screen

The payment detail screen requires two parameters passed via the `extra` parameter:

- `paymentId`: String - The ID of the payment to display
- `isPlanPayment`: bool - Whether this is a plan payment (true) or service payment (false)

Example:
```dart
final params = state.extra as Map<String, dynamic>;
final paymentId = params['paymentId'] as String;
final isPlanPayment = params['isPlanPayment'] as bool;
```

## Router Configuration

All payment routes are configured in `lib/core/routing/app_router.dart` using GoRouter:

- Routes are protected by authentication (requires valid token)
- All routes use custom page transitions (fade + slide)
- Payment detail route extracts parameters from the `extra` field

## Updated Files

1. `lib/core/routing/routes.dart` - Added payment route constants
2. `lib/core/routing/app_router.dart` - Added payment route configurations
3. `lib/features/payments/ui/view/payment_history_view.dart` - Updated to use GoRouter navigation
4. `lib/features/payments/ui/view/create_plan_payment_view.dart` - Updated to use GoRouter navigation
5. `lib/features/payments/ui/view/create_service_payment_view.dart` - Updated to use GoRouter navigation

## Requirements Satisfied

✅ **Requirement 3.4**: Payment creation success navigates to payment history
✅ **Requirement 4.5**: Service payment creation success navigates to payment history

## Testing Navigation

To test the navigation:

1. Navigate to payment history screen
2. Tap on a payment item to view details
3. Navigate back to payment history
4. Navigate to create plan payment screen
5. Submit a payment and verify navigation to payment history
6. Navigate to create service payment screen
7. Submit a payment and verify navigation to payment history

## Notes

- All navigation uses GoRouter for consistency with the rest of the application
- Parameter passing uses the `extra` field for type-safe parameter passing
- Success navigation uses `context.go()` to prevent back navigation to forms
- Detail navigation uses `context.push()` to allow back navigation
