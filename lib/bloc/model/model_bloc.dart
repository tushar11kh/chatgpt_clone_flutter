import 'package:flutter_bloc/flutter_bloc.dart';
import 'model_event.dart';
import 'model_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelBloc extends Bloc<ModelEvent, ModelState> {
  static const String _modelKey = 'selected_model';

  ModelBloc() : super(ModelInitial()) {
    on<ChangeModel>(_onChangeModel);
    _loadSavedModel();
  }

  Future<void> _onChangeModel(ChangeModel event, Emitter<ModelState> emit) async {
    emit(ModelInitial(model: event.model));
    
    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modelKey, event.model);
  }

  Future<void> _loadSavedModel() async {
    final prefs = await SharedPreferences.getInstance();
    final savedModel = prefs.getString(_modelKey) ?? 'sonar';
    emit(ModelInitial(model: savedModel));
  }
}