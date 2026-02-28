import 'package:equatable/equatable.dart';
import '../../data/models/note_model.dart';

abstract class UpcomingNotesState extends Equatable {
  const UpcomingNotesState();

  @override
  List<Object?> get props => [];
}

class UpcomingNotesInitial extends UpcomingNotesState {
  const UpcomingNotesInitial();
}

class UpcomingNotesLoading extends UpcomingNotesState {
  const UpcomingNotesLoading();
}

class UpcomingNotesLoaded extends UpcomingNotesState {
  final List<NoteModel> notes;
  final int total;
  final int daysWindow;
  final DateTime fetchedAt;

  const UpcomingNotesLoaded({
    required this.notes,
    required this.total,
    required this.daysWindow,
    required this.fetchedAt,
  });

  List<NoteModel> get highlightedNotes => notes.take(5).toList();

  bool get hasAffectedRides => notes.any((note) => note.cancelRides);

  @override
  List<Object?> get props => [notes, total, daysWindow, fetchedAt];
}

class UpcomingNotesEmpty extends UpcomingNotesState {
  const UpcomingNotesEmpty();
}

class UpcomingNotesError extends UpcomingNotesState {
  final String message;

  const UpcomingNotesError(this.message);

  @override
  List<Object?> get props => [message];
}
