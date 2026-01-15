import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../network/cache_helper.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  void _loadSavedLocale() {
    final cachedLanguageCode = CacheHelper.getData(key: 'languageCode');
    if (cachedLanguageCode != null) {
      emit(Locale(cachedLanguageCode as String));
    }
  }

  Future<void> changeLocale(String languageCode) async {
    await CacheHelper.saveData(key: 'languageCode', value: languageCode);
    emit(Locale(languageCode));
  }
}
