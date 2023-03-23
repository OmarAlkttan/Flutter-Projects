import 'package:car_rental/bloc/auth_bloc.dart';
import 'package:car_rental/providers/cars.dart';
import 'package:car_rental/providers/profile.dart';
import 'package:car_rental/widgets/app_drawer.dart';
import 'package:car_rental/widgets/car_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class CarsOverviewScreen extends StatefulWidget {
  static final routeName = '/cars_overview';

  @override
  _CarsOverviewScreenState createState() => _CarsOverviewScreenState();
}

class _CarsOverviewScreenState extends State<CarsOverviewScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    _isLoading = true;
    // final authBloc = context.read()<AuthBloc>().state;
    final authBloc = BlocProvider.of<AuthBloc>(context).state;
    if(authBloc is Authenticated && authBloc.token != null){
      print(authBloc.token);
      print(authBloc.userId);
      Provider.of<Cars>(context, listen: false).fetchAndSetCars(token: authBloc.token!, uId: authBloc.userId!).then((value) {
      setState(() {
        print('it should be true: Success');
        _isLoading = false;
      });
    }).catchError((_){
       
       setState(() {
          print('it should be false: Error');
         _isLoading = false;
       });
    });
    }
    /*Provider.of<Cars>(context, listen: false).fetchAndSetCars().then((value) {
      setState(() {
        _isLoading = false;
      });
    }).catchError((_){
      _isLoading = false;
    });*/
    
    
    if(authBloc is Authenticated && authBloc.token != null){
      Provider.of<Profile>(context, listen: false).fetchAndSetProfile(token: authBloc.token!, uId: authBloc.userId!);
    }
    
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    bool isLandScape = MediaQuery.of(context).orientation == Orientation.landscape;
    var dw = MediaQuery.of(context).size.width;
    final cars = Provider.of<Cars>(context, listen: false).items;

    return Scaffold(
        appBar: AppBar(
          title: Text('Home'),
        ),
        body: _isLoading? Center(child: CircularProgressIndicator()) : GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 500,
            childAspectRatio: 500/(500*0.75),
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
          ),
          itemCount: cars.length,
          itemBuilder: (ctx, index){
            return CarItem(
                id: cars[index].id!
            );
          },
        ),
      drawer: AppDrawer(),
    );
  }
}
