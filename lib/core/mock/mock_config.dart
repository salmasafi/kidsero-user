/// Configuration for mock data system
/// 
/// Set [enableMockData] to true to use mock data instead of real API calls.
/// This is useful for testing and development when the backend is not available.
class MockConfig {
  /// Master switch for mock data
  static const bool enableMockData = true;
  
  /// Simulate network delay for realistic testing (in milliseconds)
  static const int mockDelayMs = 800;
  
  /// Enable console logging for mock responses
  static const bool enableLogging = true;
  
  /// Mock parent user ID
  static const String mockParentId = 'mock-parent-001';
  
  /// Mock auth token
  static const String mockToken = 'mock_jwt_token_for_testing_only';
}
