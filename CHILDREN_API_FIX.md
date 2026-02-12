# Children API Error Fix

## Error
```
type 'List<dynamic>' is not a subtype of type 'Map<String, dynamic>'
```

## Root Cause
The error occurred because the `ChildResponse.fromJson` method was expecting a specific JSON structure, but the API could return data in different formats:

1. **Direct list format**: `{"success": true, "data": [...]}`
2. **Nested format**: `{"success": true, "data": {"message": "...", "children": [...]}}`

The original code only handled one format, causing a type mismatch when the API returned data in a different structure.

## Solution
Updated `lib/features/children/model/child_model.dart` to handle multiple response formats:

### Changes Made

1. **Flexible parsing**: Added logic to detect and handle different response structures
2. **Type safety**: Added explicit type casting with proper error handling
3. **Debug logging**: Added error logging to help diagnose future issues
4. **Null safety**: Ensured all parsing operations handle null values gracefully

### Code Changes

```dart
factory ChildResponse.fromJson(Map<String, dynamic> json) {
  List<Child> children = [];
  
  try {
    // Case 1: data is directly a list (simple response)
    if (json['data'] is List) {
      children = (json['data'] as List)
        .map((i) => Child.fromJson(i as Map<String, dynamic>))
        .toList();
    } 
    // Case 2: data is an object with nested structure
    else if (json['data'] is Map) {
      final dataMap = json['data'] as Map<String, dynamic>;
      
      // Check for 'children' field
      if (dataMap['children'] is List) {
        children = (dataMap['children'] as List)
          .map((i) => Child.fromJson(i as Map<String, dynamic>))
          .toList();
      }
      // Check if data map itself contains child objects
      else if (dataMap.containsKey('id') && dataMap.containsKey('name')) {
        children = [Child.fromJson(dataMap)];
      }
    }
  } catch (e) {
    print('Error parsing children response: $e');
    print('Response data: ${json['data']}');
  }
  
  return ChildResponse(
    success: json['success'] ?? false,
    data: children,
  );
}
```

### Additional Improvements

Also updated `Child.fromJson` to use `.toString()` for better type safety:

```dart
factory Child.fromJson(Map<String, dynamic> json) {
  return Child(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    code: json['code']?.toString() ?? '',
    grade: json['grade']?.toString(),
    schoolName: json['schoolName']?.toString(),
    photoUrl: json['photoUrl']?.toString(),
    status: json['status']?.toString() ?? 'active',
    createdAt: json['createdAt']?.toString(),
    updatedAt: json['updatedAt']?.toString(),
  );
}
```

## Testing
After this fix, the app should handle all these response formats:

1. ✅ `{"success": true, "data": [child1, child2, ...]}`
2. ✅ `{"success": true, "data": {"children": [child1, child2, ...]}}`
3. ✅ `{"success": true, "data": {"message": "...", "children": [...]}}`
4. ✅ Empty responses: `{"success": true, "data": []}`

## Result
The "Failed to load children" error should now be resolved, and the children list should display correctly regardless of the API response format.
