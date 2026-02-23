import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_parent/l10n/app_localizations.dart';
import 'package:kidsero_parent/core/theme/app_colors.dart';
import '../../cubit/report_absence_cubit.dart';

/// A reusable dialog widget for reporting student absence
/// 
/// This dialog integrates with [ReportAbsenceCubit] to handle the absence
/// reporting flow including validation, loading states, and error handling.
/// 
/// The dialog will automatically close on successful submission and show
/// appropriate error messages for validation or submission failures.
class ReportAbsenceDialog extends StatefulWidget {
  /// The unique identifier for the ride occurrence
  final String occurrenceId;
  
  /// The unique identifier for the student
  final String studentId;
  
  /// Optional callback invoked when absence is successfully reported
  final VoidCallback? onSuccess;
  
  /// Optional callback invoked when the dialog is dismissed
  final VoidCallback? onDismiss;

  const ReportAbsenceDialog({
    super.key,
    required this.occurrenceId,
    required this.studentId,
    this.onSuccess,
    this.onDismiss,
  });

  @override
  State<ReportAbsenceDialog> createState() => _ReportAbsenceDialogState();
}

class _ReportAbsenceDialogState extends State<ReportAbsenceDialog> {
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ReportAbsenceCubit, ReportAbsenceState>(
      listener: (context, state) {
        if (state is ReportAbsenceSuccess) {
          // Close dialog on success
          Navigator.of(context).pop();
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
          
          // Invoke success callback
          widget.onSuccess?.call();
        } else if (state is ReportAbsenceError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (state is ReportAbsenceValidationError) {
          // Show validation error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ReportAbsenceLoading;

        return PopScope(
          canPop: !isLoading,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              widget.onDismiss?.call();
            }
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.event_busy,
                  color: AppColors.error,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.reportAbsence,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.reportAbsenceDescription,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reasonController,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      labelText: l10n.reason,
                      hintText: 'e.g., Sick, Family emergency, etc.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.edit_note),
                      errorMaxLines: 2,
                    ),
                    maxLines: 3,
                    maxLength: 500,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please provide a reason for the absence';
                      }
                      if (value.trim().length < 3) {
                        return 'Reason must be at least 3 characters';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
            actions: [
              // Cancel button
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        widget.onDismiss?.call();
                      },
                child: Text(
                  l10n.cancel,
                  style: TextStyle(
                    color: isLoading ? Colors.grey : AppColors.secondary,
                  ),
                ),
              ),
              
              // Submit button
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          context.read<ReportAbsenceCubit>().reportAbsence(
                                occurrenceId: widget.occurrenceId,
                                studentId: widget.studentId,
                                reason: _reasonController.text.trim(),
                              );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(l10n.submit),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Helper function to show the report absence dialog
/// 
/// This function ensures the [ReportAbsenceCubit] is properly provided
/// to the dialog context.
/// 
/// Example usage:
/// ```dart
/// showReportAbsenceDialog(
///   context: context,
///   occurrenceId: ride.occurrenceId,
///   studentId: childId,
///   onSuccess: () {
///     // Refresh rides list
///     context.read<ChildRidesCubit>().loadRides();
///   },
/// );
/// ```
Future<void> showReportAbsenceDialog({
  required BuildContext context,
  required String occurrenceId,
  required String studentId,
  VoidCallback? onSuccess,
  VoidCallback? onDismiss,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => BlocProvider.value(
      value: context.read<ReportAbsenceCubit>(),
      child: ReportAbsenceDialog(
        occurrenceId: occurrenceId,
        studentId: studentId,
        onSuccess: onSuccess,
        onDismiss: onDismiss,
      ),
    ),
  );
}
