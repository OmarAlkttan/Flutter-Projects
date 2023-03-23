part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}


class Authenticated extends AuthState {
  final String? token;
  final String? userId;

  Authenticated({
    required this.token,
    required this.userId,
  });

} 

class NotAuthenticated extends AuthState {

}
