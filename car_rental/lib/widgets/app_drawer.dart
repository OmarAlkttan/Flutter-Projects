
import 'package:car_rental/bloc/auth_bloc.dart';
import 'package:car_rental/cubit/auth_cubit.dart';
import 'package:car_rental/providers/profile.dart';
import 'package:car_rental/screens/user_cars_screen.dart';
import 'package:car_rental/screens/user_profile_screen.dart';
import 'package:car_rental/screens/user_requests_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final _userName = Provider.of<Profile>(context, listen: false).profile.name;

    return  Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('Hello $_userName!'),
            automaticallyImplyLeading: false,
          ),
          SizedBox(height: 20,),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: ()=> Navigator.of(context).pushReplacementNamed('/'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.directions_car),
            title: Text('My Cars'),
            onTap: ()=> Navigator.of(context).pushReplacementNamed(UserCarsScreen.routeName),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Requests'),
            onTap: ()=> Navigator.of(context).pushReplacementNamed(UserRequestsScreen.routeName),
          ),
          Divider(),
          /*ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Profile'),
            onTap: ()=> Navigator.of(context).pushReplacementNamed(UserProfileScreen.routeName),
          ),
          Divider(),*/
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: (){
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              context.read<AuthBloc>().add(Logout());
              //context.read<AuthCubit>().logout();
              // Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
