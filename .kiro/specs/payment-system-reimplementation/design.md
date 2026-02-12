# Design Document: Payment System Re-implementation

## Overview

This design document outlines the re-implementation of the payment system in the Kidsero Driver/Parent Flutter application. The system will be restructured to align with updated backend APIs that support both plan subscription payments and organization service payments with installment options.

The implementation follows Flutter best practices using the BLoC pattern with Cubit for state management, a repository pattern for data access, and a clean separation between UI, business logic, and data layers.

### Key Features
- Unified payment history view for plan and service payments
- Detailed payment information screens
- Payment creation forms with receipt image upload
- Support for one-time and installment payment options
- Real-time payment status tracking (pending, completed, rejected)
- Base64 image encoding/decoding for receipts
- Comprehensive error handling and user feedback
- Full localization support

## Architecture

### Layer Structure

The payment system follows a three-layer architecture:

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│  (Screens, Widgets, Cubits)        │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│         Domain Layer                │
│  (Models, Entities)                 │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│         Data Layer                  │
│  (Repository, API Client)           │
└─────────────────────────────────────┘
```

### Directory Structure

```
lib/features/payments/
├── data/
│   ├── models/
│   │   ├── payment_model.dart
│   │   ├── service_payment_model.dart
│   │   └── payment_response_model.dart
│   └── repositories/
│       └── payment_repository.dart
├── domain/
│   └── entities/
│       ├── payment.dart
│       ├── service_payment.dart
│       └── payment_status.dart
├── presentation/
│   ├── cubits/
│   │   ├── payment_history_cubit.dart
│   │   ├── payment_detail_cubit.dart
│   │   ├── create_plan_payment_cubit.dart
│   │   └── create_service_payment_cubit.dart
│   ├── screens/
│   │   ├── payment_history_screen.dart
│   │   ├── payment_detail_screen.dart
│   │   ├── create_plan_payment_screen.dart
│   │   └── create_service_payment_screen.dart
│   └── widgets/
│       ├── payment_list_item.dart
│       ├── payment_status_badge.dart
│       ├── receipt_image_picker.dart
│       └── installment_selector.dart
└── utils/
    └── image_utils.dart
```

## Components and Interfaces

### 1. Data Models

#### PaymentModel
Represents a plan subscription payment.

```dart
class PaymentModel {
  final String id;
  final String parentId;
  final double amount;
  final String? receiptImage; // base64 encoded
  final PaymentStatus status;
  final String? rejectedReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? planId;
  final String? notes;

  PaymentModel({
    required this.id,
    required this.parentId,
    required this.amount,
    this.receiptImage,
    required this.status,
    this.rejectedReason,
    required this.createdAt,
    required this.updatedAt,
    this.planId,
    this.notes,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

#### ServicePaymentModel
Represents an organization service payment.

```dart
class ServicePaymentModel {
  final String id;
  final String parentId;
  final String serviceId;
  final String studentId;
  final double amount;
  final String? receiptImage; // base64 encoded
  final PaymentStatus status;
  final String? rejectedReason;
  final PaymentType paymentType; // onetime or installment
  final int? requestedInstallments;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServicePaymentModel({
    required this.id,
    required this.parentId,
    required this.serviceId,
    required this.studentId,
    required this.amount,
    this.receiptImage,
    required this.status,
    this.rejectedReason,
    required this.paymentType,
    this.requestedInstallments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServicePaymentModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

#### PaymentResponseModel
Wraps the response from the payment history endpoint.

```dart
class PaymentResponseModel {
  final List<PaymentModel> payments;
  final List<ServicePaymentModel> orgServicePayments;

  PaymentResponseModel({
    required this.payments,
    required this.orgServicePayments,
  });

  factory PaymentResponseModel.fromJson(Map<String, dynamic> json);
}
```

#### Enums

```dart
enum PaymentStatus {
  pending,
  completed,
  rejected;

  factory PaymentStatus.fromString(String value);
  String toJson();
}

enum PaymentType {
  onetime,
  installment;

  factory PaymentType.fromString(String value);
  String toJson();
}
```

### 2. Repository Layer

#### PaymentRepository
Handles all API communications for payments.

```dart
class PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepository(this._apiClient);

  // Get all parent payments (both plan and service)
  Future<PaymentResponseModel> getAllPayments();

  // Get specific plan payment by ID
  Future<PaymentModel> getPaymentById(String id);

  // Get specific service payment by ID
  Future<ServicePaymentModel> getServicePaymentById(String id);

  // Create plan subscription payment
  Future<PaymentModel> createPlanPayment({
    required String planId,
    required String paymentMethodId,
    required double amount,
    required String receiptImage, // base64
    String? notes,
  });

  // Create organization service payment
  Future<ServicePaymentModel> createServicePayment({
    required String serviceId,
    required String studentId,
    required String paymentMethodId,
    required double amount,
    required String receiptImage, // base64
    required PaymentType paymentType,
    int? numberOfInstallments,
  });
}
```

### 3. State Management (Cubits)

#### PaymentHistoryCubit
Manages the state for the payment history screen.

```dart
abstract class PaymentHistoryState {}

class PaymentHistoryInitial extends PaymentHistoryState {}

class PaymentHistoryLoading extends PaymentHistoryState {}

class PaymentHistoryLoaded extends PaymentHistoryState {
  final List<PaymentModel> planPayments;
  final List<ServicePaymentModel> servicePayments;

  PaymentHistoryLoaded({
    required this.planPayments,
    required this.servicePayments,
  });
}

class PaymentHistoryError extends PaymentHistoryState {
  final String message;
  PaymentHistoryError(this.message);
}

class PaymentHistoryCubit extends Cubit<PaymentHistoryState> {
  final PaymentRepository _repository;

  PaymentHistoryCubit(this._repository) : super(PaymentHistoryInitial());

  Future<void> loadPayments();
  Future<void> refresh();
}
```

#### PaymentDetailCubit
Manages the state for payment detail screens.

```dart
abstract class PaymentDetailState {}

class PaymentDetailInitial extends PaymentDetailState {}

class PaymentDetailLoading extends PaymentDetailState {}

class PaymentDetailLoaded extends PaymentDetailState {
  final dynamic payment; // PaymentModel or ServicePaymentModel
  PaymentDetailLoaded(this.payment);
}

class PaymentDetailError extends PaymentDetailState {
  final String message;
  PaymentDetailError(this.message);
}

class PaymentDetailCubit extends Cubit<PaymentDetailState> {
  final PaymentRepository _repository;

  PaymentDetailCubit(this._repository) : super(PaymentDetailInitial());

  Future<void> loadPlanPayment(String id);
  Future<void> loadServicePayment(String id);
}
```

#### CreatePlanPaymentCubit
Manages the state for creating plan payments.

```dart
abstract class CreatePlanPaymentState {}

class CreatePlanPaymentInitial extends CreatePlanPaymentState {}

class CreatePlanPaymentLoading extends CreatePlanPaymentState {}

class CreatePlanPaymentSuccess extends CreatePlanPaymentState {
  final PaymentModel payment;
  CreatePlanPaymentSuccess(this.payment);
}

class CreatePlanPaymentError extends CreatePlanPaymentState {
  final String message;
  CreatePlanPaymentError(this.message);
}

class CreatePlanPaymentCubit extends Cubit<CreatePlanPaymentState> {
  final PaymentRepository _repository;

  CreatePlanPaymentCubit(this._repository) : super(CreatePlanPaymentInitial());

  Future<void> createPayment({
    required String planId,
    required String paymentMethodId,
    required double amount,
    required String receiptImageBase64,
    String? notes,
  });

  void reset();
}
```

#### CreateServicePaymentCubit
Manages the state for creating service payments.

```dart
abstract class CreateServicePaymentState {}

class CreateServicePaymentInitial extends CreateServicePaymentState {}

class CreateServicePaymentLoading extends CreateServicePaymentState {}

class CreateServicePaymentSuccess extends CreateServicePaymentState {
  final ServicePaymentModel payment;
  CreateServicePaymentSuccess(this.payment);
}

class CreateServicePaymentError extends CreateServicePaymentState {
  final String message;
  CreateServicePaymentError(this.message);
}

class CreateServicePaymentCubit extends Cubit<CreateServicePaymentState> {
  final PaymentRepository _repository;

  CreateServicePaymentCubit(this._repository) : super(CreateServicePaymentInitial());

  Future<void> createPayment({
    required String serviceId,
    required String studentId,
    required String paymentMethodId,
    required double amount,
    required String receiptImageBase64,
    required PaymentType paymentType,
    int? numberOfInstallments,
  });

  void reset();
}
```

### 4. Presentation Layer

#### PaymentHistoryScreen
Main screen displaying payment history with tabs/sections for plan and service payments.

**Features:**
- Pull-to-refresh functionality
- Separate sections for plan payments and service payments
- Empty state when no payments exist
- Navigation to payment detail screens
- Loading and error states

#### PaymentDetailScreen
Screen showing detailed information about a specific payment.

**Features:**
- Display all payment attributes
- Show receipt image (if available)
- Highlight payment status with appropriate styling
- Display rejection reason for rejected payments
- Support for both plan and service payment types

#### CreatePlanPaymentScreen
Form screen for creating plan subscription payments.

**Features:**
- Form fields: plan selector, payment method selector, amount input, notes (optional)
- Receipt image picker with preview
- Form validation
- Submit button with loading state
- Error display
- Success navigation to payment history

#### CreateServicePaymentScreen
Form screen for creating organization service payments.

**Features:**
- Form fields: service selector, student selector, payment method selector, amount input
- Payment type selector (one-time vs installment)
- Conditional installment number input
- Receipt image picker with preview
- Form validation
- Submit button with loading state
- Error display
- Success navigation to payment history

### 5. Utility Components

#### ImageUtils
Utility class for image handling.

```dart
class ImageUtils {
  // Pick image from gallery or camera
  static Future<File?> pickImage(ImageSource source);

  // Convert image file to base64 string
  static Future<String> imageToBase64(File imageFile);

  // Decode base64 string to image
  static Uint8List base64ToImage(String base64String);

  // Compress image if needed
  static Future<File> compressImage(File imageFile, {int quality = 85});

  // Validate image size
  static bool isImageSizeValid(File imageFile, {int maxSizeInMB = 5});
}
```

#### Widgets

**PaymentListItem**: Reusable widget for displaying payment in a list
- Shows amount, date, status badge
- Tap handler for navigation to detail screen

**PaymentStatusBadge**: Widget for displaying payment status with appropriate styling
- Color-coded badges (yellow for pending, green for completed, red for rejected)
- Localized status text

**ReceiptImagePicker**: Widget for selecting and previewing receipt images
- Image picker button
- Image preview
- Remove image option
- Error display for invalid images

**InstallmentSelector**: Widget for selecting payment type and installment count
- Radio buttons for one-time vs installment
- Conditional number input for installments
- Validation display

## Data Models

### Payment Entity Relationships

```
PaymentResponseModel
├── payments: List<PaymentModel>
│   ├── id: String
│   ├── parentId: String
│   ├── amount: double
│   ├── receiptImage: String? (base64)
│   ├── status: PaymentStatus
│   ├── rejectedReason: String?
│   ├── createdAt: DateTime
│   ├── updatedAt: DateTime
│   ├── planId: String?
│   └── notes: String?
│
└── orgServicePayments: List<ServicePaymentModel>
    ├── id: String
    ├── parentId: String
    ├── serviceId: String
    ├── studentId: String
    ├── amount: double
    ├── receiptImage: String? (base64)
    ├── status: PaymentStatus
    ├── rejectedReason: String?
    ├── paymentType: PaymentType
    ├── requestedInstallments: int?
    ├── createdAt: DateTime
    └── updatedAt: DateTime
```

### API Request/Response Formats

#### GET /api/users/parentpayments
**Response:**
```json
{
  "payments": [
    {
      "id": "string",
      "parentId": "string",
      "amount": number,
      "receiptImage": "string (base64)",
      "status": "pending|completed|rejected",
      "rejectedReason": "string?",
      "createdAt": "ISO8601",
      "updatedAt": "ISO8601"
    }
  ],
  "orgServicePayments": [
    {
      "id": "string",
      "parentId": "string",
      "serviceId": "string",
      "studentId": "string",
      "amount": number,
      "receiptImage": "string (base64)",
      "status": "pending|completed|rejected",
      "rejectedReason": "string?",
      "paymentType": "onetime|installment",
      "requestedInstallments": number?,
      "createdAt": "ISO8601",
      "updatedAt": "ISO8601"
    }
  ]
}
```

#### POST /api/users/parentpayments
**Request:**
```json
{
  "planId": "string",
  "paymentMethodId": "string",
  "amount": number,
  "receiptImage": "string (base64)",
  "notes": "string?"
}
```

#### POST /api/users/parentpayments/org-service
**Request:**
```json
{
  "ServiceId": "string",
  "studentId": "string",
  "paymentMethodId": "string",
  "amount": number,
  "receiptImage": "string (base64)",
  "paymentType": "onetime|installment",
  "numberOfInstallments": number?
}
```


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Payment History Retrieval Completeness
*For any* valid API response from the payment history endpoint, the Payment_System should return both plan payments and service payments in the result.

**Validates: Requirements 1.1**

### Property 2: Payment Organization Separation
*For any* payment response containing both plan and service payments, the organized output should maintain distinct sections for each payment type.

**Validates: Requirements 1.2**

### Property 3: Payment List Item Information Completeness
*For any* payment displayed in a list, the rendered output should contain the payment amount, status, and creation date.

**Validates: Requirements 1.3**

### Property 4: Plan Payment Detail Completeness
*For any* plan payment, the detail view should display all required fields: id, amount, receipt image (if present), status, rejection reason (if rejected), and timestamps.

**Validates: Requirements 2.1**

### Property 5: Service Payment Detail Completeness
*For any* service payment, the detail view should display all required fields: service information, payment type, number of installments (if applicable), status, and rejection reason (if rejected).

**Validates: Requirements 2.2**

### Property 6: Receipt Image Decoding
*For any* payment with a valid base64 receipt image string, the Payment_System should successfully decode and render the image.

**Validates: Requirements 2.3**

### Property 7: Rejection Reason Display
*For any* payment with rejected status, the rendered output should prominently display the rejection reason with an error visual indicator.

**Validates: Requirements 2.4, 6.4**

### Property 8: Required Field Validation
*For any* payment creation attempt (plan or service) missing required fields, the validation should fail and prevent submission with specific error messages.

**Validates: Requirements 3.1, 3.6, 4.1, 4.7**

### Property 9: Optional Notes Acceptance
*For any* plan payment creation with or without optional notes, the Payment_System should accept both cases as valid.

**Validates: Requirements 3.2**

### Property 10: Image Encoding Round Trip
*For any* valid image file, encoding to base64 then decoding should produce an equivalent image that can be displayed.

**Validates: Requirements 3.3, 4.4, 5.3, 5.5**

### Property 11: Payment Creation Success State
*For any* successful payment creation (plan or service), the cubit should emit a success state with the created payment data.

**Validates: Requirements 3.4, 4.5, 10.3**

### Property 12: Installment Payment Validation
*For any* service payment with "installment" payment type, the number of installments must be present and be a positive integer.

**Validates: Requirements 4.2, 7.3**

### Property 13: One-Time Payment Validation
*For any* service payment with "onetime" payment type, the number of installments should be optional or ignored during validation.

**Validates: Requirements 4.3**

### Property 14: Image Preview Display
*For any* selected image file, the Payment_System should display a preview of the image before submission.

**Validates: Requirements 5.2**

### Property 15: Payment Status Display
*For any* payment, the displayed status should be exactly one of: pending, completed, or rejected.

**Validates: Requirements 6.1**

### Property 16: Pending Status Visual Indicator
*For any* payment with pending status, the rendered output should include a distinct visual indicator (e.g., yellow badge).

**Validates: Requirements 6.2**

### Property 17: Completed Status Visual Indicator
*For any* payment with completed status, the rendered output should include a success visual indicator (e.g., green badge).

**Validates: Requirements 6.3**

### Property 18: Payment Status Reactivity
*For any* payment whose status changes, the UI should reflect the updated status in the next render cycle.

**Validates: Requirements 6.5**

### Property 19: Installment Field Conditional Display
*For any* service payment form where "installment" is selected, the number of installments field should be visible; when "onetime" is selected, it should be hidden.

**Validates: Requirements 7.2, 7.4**

### Property 20: Installment Display in Service Payment
*For any* service payment with installment type, the detail view should display the number of requested installments.

**Validates: Requirements 7.5**

### Property 21: Loading State Emission
*For any* API call in progress, the cubit should emit a loading state before the operation completes.

**Validates: Requirements 8.3**

### Property 22: Success State Emission with Data
*For any* successful API call, the cubit should emit a success state containing the returned data.

**Validates: Requirements 8.4**

### Property 23: Model Serialization Round Trip
*For any* payment model (plan or service), serializing to JSON then deserializing should produce an equivalent object with all fields preserved.

**Validates: Requirements 8.6**

### Property 24: Form Validation Error Display
*For any* form with validation errors, the Payment_System should highlight invalid fields and display specific error messages for each invalid field.

**Validates: Requirements 10.4**

### Property 25: Loading State Duplicate Prevention
*For any* operation in progress (loading state), the Payment_System should prevent duplicate submissions until the operation completes.

**Validates: Requirements 10.5**

## Error Handling

### Error Categories

1. **Network Errors**
   - Connection timeout
   - No internet connectivity
   - Server unreachable
   - **Handling**: Display user-friendly message, provide retry option, suggest checking connection

2. **Validation Errors**
   - Missing required fields
   - Invalid field formats
   - Image size too large
   - Invalid installment number
   - **Handling**: Highlight invalid fields, display specific error messages, prevent submission

3. **API Errors**
   - 400 Bad Request: Display validation errors from backend
   - 401 Unauthorized: Redirect to login
   - 403 Forbidden: Display permission error
   - 404 Not Found: Display "payment not found" message
   - 500 Server Error: Display generic error, provide retry option
   - **Handling**: Parse error response, display appropriate message, log for debugging

4. **Image Processing Errors**
   - Image too large
   - Unsupported format
   - Encoding/decoding failure
   - **Handling**: Display specific error, allow user to select different image

### Error State Management

All cubits follow this error handling pattern:

```dart
try {
  emit(LoadingState());
  final result = await _repository.someOperation();
  emit(SuccessState(result));
} on NetworkException catch (e) {
  emit(ErrorState('Network error: ${e.message}'));
} on ValidationException catch (e) {
  emit(ErrorState('Validation error: ${e.message}'));
} catch (e) {
  emit(ErrorState('An unexpected error occurred'));
  // Log error for debugging
}
```

### User Feedback

- **Loading**: Show progress indicator, disable form inputs
- **Success**: Show success snackbar/toast, navigate to appropriate screen
- **Error**: Show error snackbar/dialog with message and retry option
- **Validation**: Inline error messages below invalid fields

## Testing Strategy

### Dual Testing Approach

The payment system will use both unit tests and property-based tests to ensure comprehensive coverage:

- **Unit tests**: Verify specific examples, edge cases, and error conditions
- **Property tests**: Verify universal properties across all inputs

Both testing approaches are complementary and necessary for comprehensive coverage. Unit tests catch concrete bugs in specific scenarios, while property tests verify general correctness across a wide range of inputs.

### Property-Based Testing

**Library**: Use `faker` package for generating random test data in Dart/Flutter

**Configuration**:
- Minimum 100 iterations per property test
- Each property test must reference its design document property
- Tag format: `// Feature: payment-system-reimplementation, Property {number}: {property_text}`

**Property Test Examples**:

```dart
// Feature: payment-system-reimplementation, Property 1: Payment History Retrieval Completeness
test('payment history should contain both plan and service payments', () {
  for (int i = 0; i < 100; i++) {
    final mockResponse = generateRandomPaymentResponse();
    final result = parsePaymentHistory(mockResponse);
    
    expect(result.planPayments, isNotNull);
    expect(result.servicePayments, isNotNull);
  }
});

// Feature: payment-system-reimplementation, Property 10: Image Encoding Round Trip
test('image encoding and decoding should be reversible', () {
  for (int i = 0; i < 100; i++) {
    final originalImage = generateRandomImageBytes();
    final base64String = ImageUtils.imageToBase64(originalImage);
    final decodedImage = ImageUtils.base64ToImage(base64String);
    
    expect(decodedImage, equals(originalImage));
  }
});

// Feature: payment-system-reimplementation, Property 23: Model Serialization Round Trip
test('payment model serialization should be reversible', () {
  for (int i = 0; i < 100; i++) {
    final originalPayment = generateRandomPaymentModel();
    final json = originalPayment.toJson();
    final deserializedPayment = PaymentModel.fromJson(json);
    
    expect(deserializedPayment, equals(originalPayment));
  }
});
```

### Unit Testing

**Focus Areas**:
- Specific examples demonstrating correct behavior
- Edge cases (empty lists, null values, boundary conditions)
- Error conditions (network failures, validation errors)
- Integration between components

**Unit Test Examples**:

```dart
test('empty payment list should show empty state', () {
  final cubit = PaymentHistoryCubit(mockRepository);
  when(mockRepository.getAllPayments()).thenAnswer(
    (_) async => PaymentResponseModel(payments: [], orgServicePayments: [])
  );
  
  cubit.loadPayments();
  
  expect(cubit.state, isA<PaymentHistoryLoaded>());
  final state = cubit.state as PaymentHistoryLoaded;
  expect(state.planPayments, isEmpty);
  expect(state.servicePayments, isEmpty);
});

test('rejected payment should display rejection reason', () {
  final payment = PaymentModel(
    id: '1',
    status: PaymentStatus.rejected,
    rejectedReason: 'Invalid receipt',
    // ... other fields
  );
  
  final widget = PaymentDetailScreen(payment: payment);
  final rendered = renderWidget(widget);
  
  expect(rendered, contains('Invalid receipt'));
  expect(rendered, contains('rejected')); // status badge
});

test('installment payment requires positive number of installments', () {
  final validator = ServicePaymentValidator();
  
  expect(
    validator.validate(
      paymentType: PaymentType.installment,
      numberOfInstallments: 0,
    ),
    throwsValidationException,
  );
  
  expect(
    validator.validate(
      paymentType: PaymentType.installment,
      numberOfInstallments: -1,
    ),
    throwsValidationException,
  );
  
  expect(
    validator.validate(
      paymentType: PaymentType.installment,
      numberOfInstallments: 3,
    ),
    returnsNormally,
  );
});
```

### Integration Testing

**Focus Areas**:
- End-to-end payment creation flow
- Navigation between screens
- State persistence across screen transitions
- API integration with mock server

### Test Coverage Goals

- **Unit tests**: 80%+ code coverage
- **Property tests**: All 25 correctness properties implemented
- **Integration tests**: All critical user flows covered
- **Widget tests**: All custom widgets tested

### Continuous Testing

- Run unit tests on every commit
- Run property tests in CI/CD pipeline
- Run integration tests before deployment
- Monitor test execution time and optimize slow tests
