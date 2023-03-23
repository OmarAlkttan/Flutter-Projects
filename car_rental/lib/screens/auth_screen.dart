import 'dart:math';
import 'dart:ui';

import 'package:car_rental/bloc/auth_bloc.dart';
import 'package:car_rental/screens/add_profile_screen.dart';
import 'package:car_rental/screens/car_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/http_exception.dart';
import '../providers/auth.dart';

class AuthScreen extends StatelessWidget {
  static final routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/car.jpg'), fit: BoxFit.cover),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      padding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 94),
                      margin: EdgeInsets.only(bottom: 20),
                      /*transform: Matrix4.rotationZ(-8.0 * pi / 180)
                        ..translate(-10.0),*/
                      decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            )
                          ]),
                      child: Text(
                        'Car Rental',
                        style: TextStyle(
                          color:
                          Theme.of(context).accentTextTheme.headline6!.color,
                          fontFamily: 'Anton',
                          fontSize: 50,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: AuthCard(),
                    flex: deviceSize.width > 600 ? 2 : 1,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

enum AuthMode { Login, SignUp }

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;

  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  final _passwordController = TextEditingController();
  var isLoading = false;

  AnimationController? _controller;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _opacityAnimation;

  Future<void> _submit () async {
    if(!_formKey.currentState!.validate()){
      return;
    }
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();
    setState(() {
      isLoading = true;
    });
    try{
      if(_authMode == AuthMode.Login){
        // await Provider.of<Auth>(context, listen: false).login(_authData['email']!, _authData['password']!);
        // context.read<AuthCubit>().login(userEmail: _authData['email'], userPassword: _authData['password']);
        context.read<AuthBloc>().add(Login(email: _authData['email'], password: _authData['password']));
        if(context.read<AuthBloc>().state is Authenticated){
          Navigator.of(context).pushReplacementNamed(CarsOverviewScreen.routeName);
        }
      }else{
        // await Provider.of<Auth>(context, listen: false).signUp(_authData['email']!, _authData['password']!);
        // context.read<AuthCubit>().signUp(userEmail: _authData['email'], userPassword: _authData['password']);
        context.read<AuthBloc>().add(SignUp(email: _authData['email'], password: _authData['password']));
        if(context.read<AuthBloc>().state is Authenticated){
          Navigator.of(context).pushReplacementNamed(AddProfileScreen.routeName);
        }
        
      }

    }on HttpException catch(error){
      var errorMessage = 'Authentication Failed';
      if(error.toString().contains('EMAIL_EXISTS')){
        errorMessage = 'this email address is already in use';
      } else if(error.toString().contains('INVALID_EMAIL')){
        errorMessage = 'this is not a valid email address';
      }else if (error.toString().contains('WEAK_PASSWORD')){
        errorMessage = 'This password is too weak';
      }else if (error.toString().contains('EMAIL_NOT_FOUND')){
        errorMessage = "This email doesn't exist";
      } else if(error.toString().contains('INVALID_PASSWORD')){
        errorMessage = 'Invalid Password';
      }
      showErrorDialog(errorMessage);
    }catch(error){
      const errorMessage = "Can't authenticate you, please try again later";
      showErrorDialog(errorMessage);
    }
    setState(() {
      isLoading = false;
    });
  }

  void showErrorDialog(String errorMessage) {
    showDialog(context: context, builder: (ctx)=> AlertDialog(
      title: Text('An Error Occurred!'),
      content: Text(errorMessage),
      actions: [
        FlatButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('okay!')),
      ],
    ));
  }

  void _switchAuthMode () {
    if(_authMode == AuthMode.Login){
      setState(() {
        _authMode = AuthMode.SignUp;
      });
      _controller!.forward();
    }else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller!.reverse();
    }
  }

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _slideAnimation = Tween<Offset>(begin: Offset(0, -0.15), end: Offset(0, 0))
        .animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.fastOutSlowIn,
    ));

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeIn,
    ));

    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.SignUp ? 320 : 260,
        constraints:
        BoxConstraints(maxHeight: _authMode == AuthMode.SignUp ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val!.isEmpty || !val.contains('@')) {
                      return 'Invalid Email';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _authData['email'] = val!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (val) {
                    if (val!.isEmpty || val.length < 6) {
                      return 'Password is too short';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _authData['password'] = val!;
                  },
                  controller: _passwordController,
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.SignUp ? 60 : 0,
                    maxHeight: _authMode == AuthMode.SignUp ? 120 : 0,
                  ),
                  child: FadeTransition(
                    opacity: _opacityAnimation!,
                    child: SlideTransition(
                      position: _slideAnimation!,
                      child: TextFormField(
                        decoration:
                        InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        enabled: _authMode == AuthMode.SignUp,
                        validator: _authMode == AuthMode.SignUp
                            ? (val) {
                          if (val != _passwordController.text) {
                            return 'Password is not same';
                          }
                          return null;
                        }
                            : null,
                      ),
                    ),
                  ),
                  curve: Curves.easeIn,
                ),
                SizedBox(
                  height: 20,
                ),
                if (isLoading) CircularProgressIndicator(),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  onPressed: _submit,
                  color: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                  child: Text(
                    _authMode == AuthMode.Login ? 'LOGIN' : 'SIGNUP',
                    style: TextStyle(
                      color: Theme.of(context).primaryTextTheme.headline6!.color,
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: _switchAuthMode,
                  textColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 30),
                  child: Text(
                      '${_authMode == AuthMode.SignUp ? 'Login' : 'SingUp'} Instead'),)
              ],
            ),
          ),
        ),
      ),
    );
  }


}
