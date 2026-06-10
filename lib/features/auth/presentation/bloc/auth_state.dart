import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final String token;
  AuthAuthenticated(this.token);
  @override
  List<Object?> get props => [token];
}
class AuthUnauthenticated extends AuthState {} // Dispara la limpieza de Tareas en la UI
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override
  List<Object?> get props => [message];
}