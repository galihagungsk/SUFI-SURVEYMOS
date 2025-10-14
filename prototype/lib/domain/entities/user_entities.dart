import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String name;
  final String organitationId;
  final String? alamat;
  final String? nohp;
  final String? email;
  final String token;

  const UserEntity({
    required this.id,
    required this.username,
    required this.name,
    required this.organitationId,
    this.alamat,
    this.nohp,
    this.email,
    required this.token,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    name,
    organitationId,
    alamat,
    nohp,
    email,
    token,
  ];
}
