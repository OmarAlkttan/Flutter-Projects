part of 'auth_bloc.dart';

@immutable
abstract class AuthState {}

class Authenticated extends AuthState {
  final String? token;
  final String? userId;
  
  Authenticated({
    this.token,
    this.userId,
  });
  
}

class NotAuthenticated extends AuthState {}


