part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginPressed extends LoginEvent {
  final String username;
  final String password;

  const LoginPressed({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}
