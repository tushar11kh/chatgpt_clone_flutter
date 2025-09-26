import 'package:equatable/equatable.dart';

abstract class ModelState extends Equatable {
  const ModelState();

  @override
  List<Object?> get props => [];
}

class ModelInitial extends ModelState {
  final String model;
  
  const ModelInitial({this.model = 'sonar'});

  @override
  List<Object?> get props => [model];
}