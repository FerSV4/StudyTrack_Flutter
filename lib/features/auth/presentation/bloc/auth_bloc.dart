import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase; // ⬅️ NUEVA DEPENDENCIA

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
  }) : super(AuthInitial()) {
    
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await loginUseCase(event.email, event.password);
        emit(AuthAuthenticated(token));
      } catch (e) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        emit(AuthError(errorMsg));
      }
    });

    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await registerUseCase(event.fullName, event.email, event.password);
        emit(AuthAuthenticated(token));
      } catch (e) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        emit(AuthError(errorMsg));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      emit(AuthUnauthenticated()); 
    });
  }
}