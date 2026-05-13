import 'package:equatable/equatable.dart';

class Team extends Equatable {
  const Team({required this.id, required this.name, required this.logo});

  final int id;
  final String name;
  final String logo;

  @override
  List<Object?> get props => [id, name, logo];
}
