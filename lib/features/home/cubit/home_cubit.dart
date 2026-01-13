import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/home_model.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  void loadHomeData() async {
    emit(HomeLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      final data = HomeModel(title: "Welcome Driver", description: "Ready to start your journey?");
      emit(HomeLoaded(data));
    } catch (e) {
      emit(const HomeError("Failed to load data"));
    }
  }
}
