import 'package:car_rental/bloc/auth_bloc.dart';
import 'package:car_rental/providers/cars.dart';
import 'package:car_rental/screens/edit_add_car_screen.dart';
import 'package:car_rental/widgets/app_drawer.dart';
import 'package:car_rental/widgets/user_car_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserCarsScreen extends StatefulWidget {
  static final routeName = '/user_cars';

  @override
  _UserCarsScreenState createState() => _UserCarsScreenState();
}

class _UserCarsScreenState extends State<UserCarsScreen> {

  Future<void> _refreshCars(BuildContext context) async {
    /*await Provider.of<Cars>(context, listen: false)
        .fetchAndSetCars(true);*/
    final authBloc = context.read()<AuthBloc>().state;
    if(authBloc is Authenticated && authBloc.token != null){
      Provider.of<Cars>(context, listen: false).fetchAndSetCars(token: authBloc.token!, uId: authBloc.userId!, filterUsers: true);}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Cars'),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () =>
                  Navigator.of(context).pushNamed(EditCarScreen.routeName),),
        ],
      ),
      body: FutureBuilder(
        future: _refreshCars(context),
        builder: (BuildContext context, AsyncSnapshot snapshot) =>
        snapshot.connectionState == ConnectionState.waiting
            ? Center(
          child: CircularProgressIndicator(),
        )
            : RefreshIndicator(
            child: Consumer<Cars>(
              builder: (ctx, carData, _) => Padding(
                padding: EdgeInsets.all(8),
                child: ListView.builder(
                  itemCount: carData.items.length,
                  itemBuilder: (ctx, int index) => Column(
                    children: [
                      UserCarItem(
                          id: carData.items[index].id!,
                          title: carData.items[index].name!,
                          imageUrl:
                          carData.items[index].carImageUrl!),
                      Divider(),
                    ],
                  ),
                ),
              ),
            ),
            onRefresh: () => _refreshCars(context)),),
      drawer: AppDrawer(),
    );
  }
}
