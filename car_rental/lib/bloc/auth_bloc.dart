import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:car_rental/models/data_provider/authentication.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(NotAuthenticated());

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if(event is Login){
      Authentication authentication = Authentication();
      if(await authentication.authenticate(email: event.email, password: event.password, urlSegment: 'signInWithPassword')){
        yield Authenticated(token: authentication.token, userId: authentication.userId);
        // emit(Authenticated(token: authentication.token, userId: authentication.userId));
      }else {
        yield NotAuthenticated();
      }
    }
    else if(event is SignUp){
      Authentication authentication = Authentication();
      if(await authentication.authenticate(email: event.email, password: event.password, urlSegment: 'signUp')){
        yield Authenticated(token: authentication.token, userId: authentication.userId);
      } else {
        yield NotAuthenticated();
      }
    }
    else if(event is Logout){
      Authentication auth = Authentication();
      auth.logout();
      yield NotAuthenticated();
    }
  }
}
