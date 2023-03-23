import 'package:car_rental/bloc/auth_bloc.dart' as bloc;
import 'package:car_rental/cubit/auth_cubit.dart';
import 'package:car_rental/providers/auth.dart';
import 'package:car_rental/providers/cars.dart';
import 'package:car_rental/providers/profile.dart';
import 'package:car_rental/providers/requests.dart';
import 'package:car_rental/screens/auth_screen.dart';
import 'package:car_rental/screens/car_details_screen.dart';
import 'package:car_rental/screens/car_overview_screen.dart';
import 'package:car_rental/screens/edit_add_car_screen.dart';
import 'package:car_rental/screens/splash_screen.dart';
import 'package:car_rental/screens/user_cars_screen.dart';
import 'package:car_rental/screens/add_profile_screen.dart';
import 'package:car_rental/screens/user_profile_screen.dart';
import 'package:car_rental/screens/user_requests_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart' as firebase_core;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await firebase_core.Firebase.initializeApp();
  runApp(MyApp());

  String myColor = "red";

  setBackgroundColor(myColor);
}

String backgroundColor = "";

setBackgroundColor(String color) {
  backgroundColor = color;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),

        /*ChangeNotifierProxyProvider<Auth, Cars?>(
          create: (_) => Cars(),
          update: (_, authData, previousCar) => previousCar!
            ..getData(authData.token!, authData.userId, previousCar.items),
        )*/
        ChangeNotifierProvider.value(value: Cars()),
        /*ChangeNotifierProxyProvider<Auth, Requests?>(
          create: (_) => Requests(),
          update: (_, authData, previousRequest) => previousRequest!
            ..getData(authData.token!, authData.userId, previousRequest.items),
        )*/
        ChangeNotifierProvider.value(value: Requests()),
        /*ChangeNotifierProxyProvider<Auth, Profile?>(
          create: (_) => Profile(),
          update: (_, authData, previousProfile) => previousProfile!
            ..getData(
                authData.token!, authData.userId, previousProfile.profile),
        )*/
        ChangeNotifierProvider.value(value: Profile()),
      ],
      child: BlocProvider<bloc.AuthBloc>(
        create: (context) => bloc.AuthBloc(),
        child: BlocBuilder<bloc.AuthBloc, bloc.AuthState>(
          builder: (ctx, state) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              primaryColor: Color.fromRGBO(51, 153, 204, 1),
              accentColor: Color.fromRGBO(204, 102, 51, 1),
              fontFamily: 'Lato',
            ),
            home: AuthScreen(),
            routes: {
              AuthScreen.routeName: (_) => AuthScreen(),
              CarDetailsScreen.routeName: (_) => CarDetailsScreen(),
              EditCarScreen.routeName: (_) => EditCarScreen(),
              UserCarsScreen.routeName: (_) => UserCarsScreen(),
              AddProfileScreen.routeName: (_) => AddProfileScreen(),
              UserRequestsScreen.routeName: (_) => UserRequestsScreen(),
              CarsOverviewScreen.routeName: (_) => CarsOverviewScreen(),
              UserProfileScreen.routeName: (_) => UserProfileScreen(),
              SplashScreen.routeName: (_) => SplashScreen(),
            },
          ),
        ),
      ),
    );
  }
}
