import 'package:flutter/material.dart';
import '../network/error_handler.dart';
import '../network/exceptions.dart';
import 'custom_error_widget.dart';

/// A widget that displays errors with proper localization and retry functionality
class ErrorDisplay extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;

  const ErrorDisplay({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final errorMessage = ErrorHandler.handle(error);
    
    return CustomErrorWidget(
      message: errorMessage,
      error: error,
      onRetry: onRetry,
    );
  }
}

/// Extension to easily convert errors to user-friendly messages
extension ErrorExtension on dynamic {
  String toUserMessage() {
    return ErrorHandler.handle(this);
  }
  
  AppException toAppException() {
    return ErrorHandler.toAppException(this);
  }
}
