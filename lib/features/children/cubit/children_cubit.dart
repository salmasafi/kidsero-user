import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_parent/core/network/api_service.dart';
import 'package:kidsero_parent/features/children/model/child_model.dart' show Child;

// --- STATES ---
abstract class ChildrenState {}
class ChildrenInitial extends ChildrenState {}
class ChildrenLoading extends ChildrenState {}
class ChildrenLoaded extends ChildrenState {
  final List<Child> children;
  ChildrenLoaded(this.children);
}
class ChildrenError extends ChildrenState {
  final String message;
  ChildrenError(this.message);
}
// State specifically for the "Add Child" action
class ChildAddLoading extends ChildrenState {}
class ChildAddSuccess extends ChildrenState {
  final String message;
  ChildAddSuccess(this.message);
}

// --- CUBIT ---
class ChildrenCubit extends Cubit<ChildrenState> {
  final ApiService apiService;

  ChildrenCubit(this.apiService) : super(ChildrenInitial());

  // Load list
  Future<void> loadChildren() async {
    emit(ChildrenLoading());
    try {
      final children = await apiService.getChildren();
      emit(ChildrenLoaded(children));
    } catch (e) {
      emit(ChildrenError(e.toString()));
    }
  }

  // Add new child
  Future<void> addChild(String code) async {
    // We emit a specific loading state so the UI can show a spinner on the dialog
    emit(ChildAddLoading());
    try {
      await apiService.addChild(code);
      emit(ChildAddSuccess("Child added successfully!"));
      // Refresh the list after adding
      await loadChildren(); 
    } catch (e) {
      emit(ChildrenError(e.toString()));
      // If error, reload the list to show the previous state (or handle differently)
      loadChildren();
    }
  }
}
