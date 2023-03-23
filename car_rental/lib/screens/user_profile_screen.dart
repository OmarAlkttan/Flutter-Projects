import 'package:car_rental/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {

  static final routeName = '/user_profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile Screen'),
      ),
      body: Center(
        child: Text('User Profile Screen'),
      ),
      drawer: AppDrawer(),
    );
  }
}

