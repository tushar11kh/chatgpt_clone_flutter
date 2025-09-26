import 'package:equatable/equatable.dart';

abstract class ModelEvent extends Equatable {
  const ModelEvent();

  @override
  List<Object?> get props => [];
}

class ChangeModel extends ModelEvent {
  final String model;
  
  const ChangeModel(this.model);

  @override
  List<Object?> get props => [model];
}