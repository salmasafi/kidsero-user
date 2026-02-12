# Implementation Plan: Payment System Re-implementation

## Overview

This implementation plan breaks down the payment system re-implementation into discrete, incremental coding tasks. Each task builds on previous work, starting with data models and repository layer, then state management, and finally UI components. The plan includes both core implementation and testing tasks to ensure comprehensive coverage.

## Tasks

- [x] 1. Set up data models and enums
  - Create `PaymentStatus` and `PaymentType` enums with JSON serialization
  - Create `PaymentModel` class with all fields and JSON serialization
  - Create `ServicePaymentModel` class with all fields and JSON serialization
  - Create `PaymentResponseModel` class to wrap API response
  - _Requirements: 8.6, 1.1_

- [ ]* 1.1 Write property test for model serialization
  - **Property 23: Model Serialization Round Trip**
  - **Validates: Requirements 8.6**

- [x] 2. Implement image utilities
  - Create `ImageUtils` class with image picker functionality
  - Implement `imageToBase64` method for encoding images
  - Implement `base64ToImage` method for decoding images
  - Implement `compressImage` method for large images
  - Implement `isImageSizeValid` method for validation
  - _Requirements: 5.1, 5.3, 5.4, 5.5_

- [ ]* 2.1 Write property test for image encoding round trip
  - **Property 10: Image Encoding Round Trip**
  - **Validates: Requirements 3.3, 4.4, 5.3, 5.5**

- [ ]* 2.2 Write unit tests for image utilities edge cases
  - Test image size validation with various sizes
  - Test compression with different quality settings
  - Test handling of invalid image formats
  - _Requirements: 5.4_

- [x] 3. Implement payment repository
  - Create `PaymentRepository` class with API client dependency
  - Implement `getAllPayments()` method
  - Implement `getPaymentById(String id)` method
  - Implement `getServicePaymentById(String id)` method
  - Implement `createPlanPayment()` method
  - Implement `createServicePayment()` method
  - Add proper error handling for all methods
  - _Requirements: 1.1, 2.1, 2.2, 3.1, 4.1, 8.2_

- [ ]* 3.1 Write unit tests for repository methods
  - Test successful API responses
  - Test error handling for network failures
  - Test error handling for API errors (400, 401, 404, 500)
  - _Requirements: 1.5, 2.5, 3.5, 10.1, 10.2_

- [x] 4. Implement payment history cubit
  - Create `PaymentHistoryState` classes (Initial, Loading, Loaded, Error)
  - Create `PaymentHistoryCubit` with repository dependency
  - Implement `loadPayments()` method
  - Implement `refresh()` method
  - Ensure loading state is emitted before API calls
  - Ensure success state is emitted with data on success
  - Ensure error state is emitted on failure
  - _Requirements: 1.1, 1.2, 8.3, 8.4, 8.5_

- [ ]* 4.1 Write property test for payment history retrieval
  - **Property 1: Payment History Retrieval Completeness**
  - **Validates: Requirements 1.1**

- [ ]* 4.2 Write property test for loading state emission
  - **Property 21: Loading State Emission**
  - **Validates: Requirements 8.3**

- [ ]* 4.3 Write property test for success state emission
  - **Property 22: Success State Emission with Data**
  - **Validates: Requirements 8.4**

- [ ]* 4.4 Write unit tests for payment history cubit
  - Test empty payment list handling
  - Test error state emission on API failure
  - _Requirements: 1.4, 1.5_

- [x] 5. Implement payment detail cubit
  - Create `PaymentDetailState` classes (Initial, Loading, Loaded, Error)
  - Create `PaymentDetailCubit` with repository dependency
  - Implement `loadPlanPayment(String id)` method
  - Implement `loadServicePayment(String id)` method
  - Ensure proper state transitions
  - _Requirements: 2.1, 2.2, 8.3, 8.4_

- [ ]* 5.1 Write property tests for payment detail completeness
  - **Property 4: Plan Payment Detail Completeness**
  - **Property 5: Service Payment Detail Completeness**
  - **Validates: Requirements 2.1, 2.2**

- [ ]* 5.2 Write unit tests for payment detail cubit
  - Test error handling for non-existent payments
  - _Requirements: 2.5_

- [x] 6. Implement create plan payment cubit
  - Create `CreatePlanPaymentState` classes (Initial, Loading, Success, Error)
  - Create `CreatePlanPaymentCubit` with repository dependency
  - Implement `createPayment()` method with all parameters
  - Implement form validation for required fields
  - Implement `reset()` method
  - Ensure proper state transitions
  - _Requirements: 3.1, 3.2, 3.4, 3.5, 3.6, 8.3, 8.4_

- [ ]* 6.1 Write property tests for plan payment validation
  - **Property 8: Required Field Validation**
  - **Property 9: Optional Notes Acceptance**
  - **Validates: Requirements 3.1, 3.2, 3.6**

- [ ]* 6.2 Write property test for payment creation success
  - **Property 11: Payment Creation Success State**
  - **Validates: Requirements 3.4, 4.5**

- [ ]* 6.3 Write unit tests for create plan payment cubit
  - Test validation error display
  - Test error state on API failure
  - _Requirements: 3.5, 3.6_

- [x] 7. Implement create service payment cubit
  - Create `CreateServicePaymentState` classes (Initial, Loading, Success, Error)
  - Create `CreateServicePaymentCubit` with repository dependency
  - Implement `createPayment()` method with all parameters
  - Implement form validation for required fields
  - Implement conditional validation for installment payments
  - Implement `reset()` method
  - Ensure proper state transitions
  - _Requirements: 4.1, 4.2, 4.3, 4.5, 4.6, 4.7, 8.3, 8.4_

- [ ]* 7.1 Write property tests for service payment validation
  - **Property 12: Installment Payment Validation**
  - **Property 13: One-Time Payment Validation**
  - **Validates: Requirements 4.2, 4.3, 7.3**

- [ ]* 7.2 Write unit tests for create service payment cubit
  - Test validation for missing installment number when type is installment
  - Test validation accepts missing installment number when type is onetime
  - Test error state on API failure
  - _Requirements: 4.2, 4.3, 4.6_

- [x] 8. Checkpoint - Ensure all cubit tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 9. Create payment status badge widget
  - Create `PaymentStatusBadge` widget
  - Implement visual indicators for pending status (yellow)
  - Implement visual indicators for completed status (green)
  - Implement visual indicators for rejected status (red)
  - Use localized strings for status labels
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 9.2_

- [ ]* 9.1 Write property tests for status display
  - **Property 15: Payment Status Display**
  - **Property 16: Pending Status Visual Indicator**
  - **Property 17: Completed Status Visual Indicator**
  - **Validates: Requirements 6.1, 6.2, 6.3**

- [ ]* 9.2 Write unit tests for payment status badge
  - Test each status renders with correct color
  - Test localized text is used
  - _Requirements: 6.1, 6.2, 6.3, 9.2_

- [x] 10. Create receipt image picker widget
  - Create `ReceiptImagePicker` widget
  - Implement image selection from gallery and camera
  - Implement image preview display
  - Implement remove image functionality
  - Implement image size validation with error display
  - Integrate with `ImageUtils` for encoding
  - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [ ]* 10.1 Write property test for image preview
  - **Property 14: Image Preview Display**
  - **Validates: Requirements 5.2**

- [ ]* 10.2 Write unit tests for receipt image picker
  - Test image source selection (gallery vs camera)
  - Test image size validation error display
  - Test remove image functionality
  - _Requirements: 5.1, 5.4_

- [x] 11. Create installment selector widget
  - Create `InstallmentSelector` widget
  - Implement payment type radio buttons (onetime/installment)
  - Implement conditional display of installment number field
  - Implement validation for positive integer installments
  - Use localized strings for labels
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 9.4_

- [ ]* 11.1 Write property test for installment field conditional display
  - **Property 19: Installment Field Conditional Display**
  - **Validates: Requirements 7.2, 7.4**

- [ ]* 11.2 Write unit tests for installment selector
  - Test field visibility when onetime is selected
  - Test field visibility when installment is selected
  - Test validation for invalid installment numbers
  - _Requirements: 7.2, 7.3, 7.4_

- [x] 12. Create payment list item widget
  - Create `PaymentListItem` widget
  - Display payment amount, status badge, and creation date
  - Implement tap handler for navigation
  - Use localized strings for labels
  - _Requirements: 1.3, 9.4_

- [ ]* 12.1 Write property test for payment list item information
  - **Property 3: Payment List Item Information Completeness**
  - **Validates: Requirements 1.3**

- [x] 13. Implement payment history screen
  - Create `PaymentHistoryScreen` with BlocProvider
  - Implement separate sections for plan and service payments
  - Implement pull-to-refresh functionality
  - Implement empty state display
  - Implement loading state display
  - Implement error state display with retry button
  - Use `PaymentListItem` widget for list items
  - Implement navigation to payment detail screens
  - Use localized strings for all text
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 9.4_

- [ ]* 13.1 Write property test for payment organization
  - **Property 2: Payment Organization Separation**
  - **Validates: Requirements 1.2**

- [ ]* 13.2 Write widget tests for payment history screen
  - Test empty state is displayed when no payments
  - Test loading state is displayed during fetch
  - Test error state with retry button
  - Test navigation to detail screen on item tap
  - _Requirements: 1.4, 1.5_

- [x] 14. Implement payment detail screen
  - Create `PaymentDetailScreen` with BlocProvider
  - Support both plan and service payment types
  - Display all payment fields based on type
  - Display receipt image using `base64ToImage` if available
  - Display rejection reason prominently for rejected payments
  - Use `PaymentStatusBadge` widget
  - Implement loading and error states
  - Use localized strings for all labels
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 9.4_

- [ ]* 14.1 Write property tests for payment detail display
  - **Property 6: Receipt Image Decoding**
  - **Property 7: Rejection Reason Display**
  - **Validates: Requirements 2.3, 2.4, 6.4**

- [ ]* 14.2 Write widget tests for payment detail screen
  - Test all fields are displayed for plan payment
  - Test all fields are displayed for service payment
  - Test receipt image is displayed when present
  - Test rejection reason is displayed for rejected payment
  - Test error state display
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 15. Implement create plan payment screen
  - Create `CreatePlanPaymentScreen` with BlocProvider
  - Implement form with plan selector, payment method selector, amount input
  - Implement optional notes field
  - Integrate `ReceiptImagePicker` widget
  - Implement form validation with error display
  - Implement submit button with loading state
  - Prevent duplicate submissions during loading
  - Display success message and navigate to payment history on success
  - Display error message on failure
  - Use localized strings for all text
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 9.4, 10.4, 10.5_

- [ ]* 15.1 Write property tests for form validation
  - **Property 24: Form Validation Error Display**
  - **Property 25: Loading State Duplicate Prevention**
  - **Validates: Requirements 10.4, 10.5**

- [ ]* 15.2 Write widget tests for create plan payment screen
  - Test form validation prevents submission with missing fields
  - Test success navigation to payment history
  - Test error message display on failure
  - Test duplicate submission prevention during loading
  - _Requirements: 3.5, 3.6, 10.4, 10.5_

- [x] 16. Implement create service payment screen
  - Create `CreateServicePaymentScreen` with BlocProvider
  - Implement form with service selector, student selector, payment method selector, amount input
  - Integrate `ReceiptImagePicker` widget
  - Integrate `InstallmentSelector` widget
  - Implement form validation with conditional installment validation
  - Implement submit button with loading state
  - Prevent duplicate submissions during loading
  - Display success message and navigate to payment history on success
  - Display error message on failure
  - Use localized strings for all text
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 7.1, 7.2, 7.3, 7.4, 9.4, 10.4, 10.5_

- [ ]* 16.1 Write property test for installment display
  - **Property 20: Installment Display in Service Payment**
  - **Validates: Requirements 7.5**

- [ ]* 16.2 Write widget tests for create service payment screen
  - Test form validation for installment payments
  - Test form validation for onetime payments
  - Test success navigation to payment history
  - Test error message display on failure
  - Test duplicate submission prevention during loading
  - _Requirements: 4.2, 4.3, 4.6, 4.7, 10.4, 10.5_

- [ ] 17. Add localization strings
  - Add all payment-related strings to localization files
  - Include status labels (pending, completed, rejected)
  - Include form labels and buttons
  - Include error messages
  - Include success messages
  - Include empty state messages
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [x] 18. Update navigation and routing
  - Add routes for all payment screens
  - Implement navigation from payment history to detail screens
  - Implement navigation from create payment screens to history
  - Ensure proper parameter passing between screens
  - _Requirements: 3.4, 4.5_

- [ ] 19. Final checkpoint - Integration testing
  - Ensure all tests pass, ask the user if questions arise.

- [ ]* 19.1 Write integration tests for complete payment flows
  - Test complete plan payment creation flow
  - Test complete service payment creation flow
  - Test payment history viewing and detail navigation
  - Test error handling across screens
  - _Requirements: 1.1, 2.1, 2.2, 3.1, 4.1_

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at key milestones
- Property tests validate universal correctness properties (minimum 100 iterations each)
- Unit tests validate specific examples and edge cases
- All property tests must include the tag format: `// Feature: payment-system-reimplementation, Property {number}: {property_text}`
- The implementation follows Flutter best practices with BLoC pattern using Cubit
- All user-facing text must use the app's localization system
