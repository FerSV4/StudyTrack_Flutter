import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart'; 
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // En el futuro inyectaremos: final LoginUseCase loginUseCase;

  AuthBloc() : super(AuthInitial()) {
    
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        // Aquí llamaremos al caso de uso real de NestJS luego
        // await loginUseCase(event.email, event.password);
        await Future.delayed(const Duration(seconds: 2)); // Simulando red
        emit(AuthAuthenticated('token_jwt_falso_para_ui'));
      } catch (e) {
        emit(AuthError('Credenciales inválidas'));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      // Aquí llamaremos al caso de uso para borrar Shared Preferences
      emit(AuthUnauthenticated()); 
    });
    
  }
}