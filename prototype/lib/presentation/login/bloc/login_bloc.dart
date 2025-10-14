import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:prototype/domain/usecase/user_usecase.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserUsecase userUsecase;
  LoginBloc({required this.userUsecase}) : super(LoginInitial()) {
    on<LoginPressed>((event, emit) async {
      emit(LoginLoading());
      try {
        var userName = event.username;
        var password = event.password;
        final user = await userUsecase.call(userName, password);
        emit(LoginSuccess(user));
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });
  }
}
