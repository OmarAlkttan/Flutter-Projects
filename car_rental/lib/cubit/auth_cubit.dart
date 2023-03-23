

import 'package:bloc/bloc.dart';
import 'package:car_rental/models/data_provider/authentication.dart';

import 'package:meta/meta.dart';


part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  

  AuthCubit() : super(NotAuthenticated());

  void login({required userEmail, required userPassword}) async {
    Authentication auth = Authentication();
    if (await auth.authenticate(email: userEmail, password: userPassword, urlSegment: 'signInWithPassword')) {
      emit(Authenticated(token: auth.token, userId: auth.userId));
    }
  }

  void signUp({required userEmail, required userPassword})async {
    Authentication auth = Authentication();
    if(await auth.authenticate(email: userEmail, password: userPassword, urlSegment: 'signUp')){
      emit(Authenticated(token: auth.token, userId: auth.userId));
    }

  }

  void logout(){
    Authentication auth = Authentication();
    auth.logout();
    emit(NotAuthenticated());
  }
  
}
