part of 'currentindex_bloc.dart';

@immutable
abstract class CurrentindexEvent {}

class IncrementEvent extends CurrentindexEvent {}

class DecrementEvent extends CurrentindexEvent {}
