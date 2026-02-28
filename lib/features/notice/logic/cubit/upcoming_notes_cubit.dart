import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/note_model.dart';
import '../../data/notes_repository.dart';
import 'upcoming_notes_state.dart';

class UpcomingNotesCubit extends Cubit<UpcomingNotesState> {
  final NotesRepository _repository;
  final int defaultDays;
  List<NoteModel> _cachedNotes = const [];
  DateTime? _lastFetched;

  UpcomingNotesCubit(
    this._repository, {
    this.defaultDays = 7,
  }) : super(const UpcomingNotesInitial());

  Future<void> loadUpcomingNotes({int? days}) async {
    final requestedDays = days ?? defaultDays;
    emit(const UpcomingNotesLoading());
    try {
      final response = await _repository.getUpcomingNotes(days: requestedDays);
      _cachedNotes = response.notes;
      _lastFetched = DateTime.now();

      if (response.notes.isEmpty) {
        emit(const UpcomingNotesEmpty());
      } else {
        emit(
          UpcomingNotesLoaded(
            notes: response.notes,
            total: response.total,
            daysWindow: requestedDays,
            fetchedAt: _lastFetched!,
          ),
        );
      }
    } catch (error) {
      emit(UpcomingNotesError(error.toString()));
    }
  }

  Future<void> refresh({int? days}) async {
    await loadUpcomingNotes(days: days ?? defaultDays);
  }

  List<NoteModel> get cachedNotes => _cachedNotes;

  DateTime? get lastFetched => _lastFetched;
}
