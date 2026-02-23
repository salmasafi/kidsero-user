import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer' as dev;
import '../../../core/network/error_handler.dart';
import '../data/rides_repository.dart';

// ============================================================
// STATES
// ============================================================

abstract class ReportAbsenceState extends Equatable {
  const ReportAbsenceState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any absence reporting action
class ReportAbsenceInitial extends ReportAbsenceState {}

/// State when absence report is being submitted
class ReportAbsenceLoading extends ReportAbsenceState {}

/// State when absence report is successfully submitted
class ReportAbsenceSuccess extends ReportAbsenceState {
  final String message;

  const ReportAbsenceSuccess({
    this.message = 'Absence reported successfully',
  });

  @override
  List<Object?> get props => [message];
}

/// State when absence report fails
class ReportAbsenceError extends ReportAbsenceState {
  final String message;

  const ReportAbsenceError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State for validation errors before submission
class ReportAbsenceValidationError extends ReportAbsenceState {
  final String message;

  const ReportAbsenceValidationError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================
// CUBIT
// ============================================================

class ReportAbsenceCubit extends Cubit<ReportAbsenceState> {
  final RidesRepository _repository;

  ReportAbsenceCubit({required RidesRepository repository})
      : _repository = repository,
        super(ReportAbsenceInitial());

  /// Report absence for a specific ride occurrence
  /// 
  /// Parameters:
  /// - [occurrenceId]: The unique identifier for the ride occurrence
  /// - [studentId]: The unique identifier for the student
  /// - [reason]: The reason for the absence (must not be empty)
  /// 
  /// Emits:
  /// - [ReportAbsenceValidationError] if validation fails
  /// - [ReportAbsenceLoading] while submitting
  /// - [ReportAbsenceSuccess] on successful submission
  /// - [ReportAbsenceError] on failure
  Future<void> reportAbsence({
    required String occurrenceId,
    required String studentId,
    required String reason,
  }) async {
    // Validate reason is not empty
    if (reason.trim().isEmpty) {
      emit(const ReportAbsenceValidationError(
        'Absence reason cannot be empty',
      ));
      return;
    }

    emit(ReportAbsenceLoading());
    
    try {
      dev.log('Reporting absence for occurrence: $occurrenceId, student: $studentId', 
              name: 'ReportAbsenceCubit');
      
      final response = await _repository.reportAbsence(
        occurrenceId: occurrenceId,
        studentId: studentId,
        reason: reason.trim(),
      );

      if (response.success) {
        dev.log('Absence reported successfully', name: 'ReportAbsenceCubit');
        emit(ReportAbsenceSuccess(
          message: response.message.isNotEmpty 
              ? response.message 
              : 'Absence reported successfully',
        ));
      } else {
        dev.log('Absence report failed: ${response.message}', 
                name: 'ReportAbsenceCubit');
        emit(ReportAbsenceError(
          response.message.isNotEmpty 
              ? response.message 
              : 'Failed to report absence',
        ));
      }
    } catch (e, stackTrace) {
      dev.log('Error reporting absence', 
              name: 'ReportAbsenceCubit', 
              error: e, 
              stackTrace: stackTrace);
      final errorMessage = ErrorHandler.handle(e);
      emit(ReportAbsenceError(errorMessage));
    }
  }

  /// Reset the cubit to initial state
  /// Useful for clearing error/success messages after they've been displayed
  void reset() {
    emit(ReportAbsenceInitial());
  }
}
