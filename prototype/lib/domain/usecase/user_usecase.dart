import 'package:prototype/domain/entities/user_entities.dart';
import 'package:prototype/domain/repositories/user_reposito.dart';

class UserUsecase {
  final UserRepository repository;

  UserUsecase(this.repository);

  Future<String> call(String username, String password) {
    return repository.login(username, password);
  }
}
