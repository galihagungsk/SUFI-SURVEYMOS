import 'package:prototype/domain/entities/user_entities.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.name,
    required super.organitationId,
    super.alamat,
    super.nohp,
    super.email,
    required super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      organitationId: json['organitation_id']?.toString() ?? '',
      alamat: json['alamat']?.toString(),
      nohp: json['nohp']?.toString(),
      email: json['email']?.toString(),
      token: json['token']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'name': name,
    'organitation_id': organitationId,
    'alamat': alamat,
    'nohp': nohp,
    'email': email,
    'token': token,
  };
}
