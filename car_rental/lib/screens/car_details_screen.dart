import 'package:car_rental/providers/auth.dart';
import 'package:car_rental/providers/cars.dart';
import 'package:car_rental/providers/profile.dart';
import 'package:car_rental/providers/requests.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CarDetailsScreen extends StatefulWidget {
  static final routeName = '/car_details';

  @override
  _CarDetailsScreenState createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  DateTime? _fromDate, _toDate;
  int? _rentPeriod;

  @override
  Widget build(BuildContext context) {
    final carId = ModalRoute.of(context)!.settings.arguments as String;
    final carDetail = Provider.of<Cars>(context, listen: false).findById(carId);
    final renterId = Provider.of<Auth>(context, listen: false).userId;
    final renterData = Provider.of<Profile>(context, listen: false).profile;
    final renterImageUrl = renterData.pImageUrl;
    final renterName = renterData.name;
    bool isLandScape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    var dw = MediaQuery.of(context).size.width;
    var dh = MediaQuery.of(context).size.height;

    /*var ingredients = Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: Text('Car Details',style: Theme.of(context).textTheme.title,),
        ),
        Container(
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              border: Border.all(color: Colors.grey)
          ),
          height: isLandScape? dh*0.5: dh*0.25,
          width: isLandScape? dw*0.5-30: dw,
          child: ListView.builder(
            itemBuilder: (ctx, index){
              return Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.circular(8)
                ),
                child: Text(carDetail.ingredients[index]),
              );
            },
            itemCount: mealDetail.ingredients.length,
          ),
        ),
      ],
    );*/
    /*var steps = Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: Text('Steps',style: Theme.of(context).textTheme.title,),
        ),
        Container(
          margin: EdgeInsets.all(15),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              border: Border.all(color: Colors.grey)
          ),
          height: isLandScape? dh*0.5: dh*0.25,
          width: isLandScape? dw*0.5-30: dw,
          child: ListView.builder(
            itemBuilder: (ctx, index){
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text('# ${index+1}'),
                    ),
                    title: Text(mealDetail.steps[index]),
                  ),
                  Divider()
                ],
              );
            },
            itemCount: mealDetail.steps.length,
          ),
        ),
      ],
    );*/

    return Scaffold(
      appBar: AppBar(
        title: Text('More Details'),
      ),
      body: Column(
        children: [
          Container(
            child: Hero(
              tag: carId,
              child: Image.network(
                carDetail.carImageUrl!,
                height: 300,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Expanded(
              child: Stack(
                  children: [
                    Container(
                      child: ListView(
                        children: [
                          ListTile(
                            leading: Text(
                              'Name',
                              style: TextStyle(
                                  fontSize: 20, color: Theme.of(context).accentColor),
                            ),
                            trailing: Text(
                              '${carDetail.name}',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Divider(),
                          ListTile(
                            leading: Text(
                              'Model',
                              style: TextStyle(
                                  fontSize: 20, color: Theme.of(context).accentColor),
                            ),
                            trailing: Text(
                              '${carDetail.model}',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Divider(),
                          ListTile(
                            leading: Text(
                              'Year',
                              style: TextStyle(
                                  fontSize: 20, color: Theme.of(context).accentColor),
                            ),
                            trailing: Text(
                              '${carDetail.year}',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Divider(),
                          Container(
                            padding: EdgeInsets.only(left: 15),
                            height: 70,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Description',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Theme.of(context).accentColor)),
                                SizedBox(
                                  width: 30,
                                ),
                                Column(

                                  children: [
                                    Container(
                                      width: 240,
                                      child: Text(
                                        '${carDetail.description}',
                                        style: TextStyle(fontSize: 18),
                                        maxLines: 5,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Divider(),
                          ListTile(
                            leading: Text(
                              'Color',
                              style: TextStyle(
                                  fontSize: 20, color: Theme.of(context).accentColor),
                            ),
                            trailing: Text(
                              '${carDetail.color}',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Divider(),
                          ListTile(
                            leading: Text(
                              'Price',
                              style: TextStyle(
                                  fontSize: 20, color: Theme.of(context).accentColor),
                            ),
                            trailing: Text(
                              '\$${carDetail.price}',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(child: RaisedButton(onPressed: (){
                      showDialog(
                          context: context,
                          builder: (ctx) => StatefulBuilder(
                            builder:(context, setState) => AlertDialog(
                              title: Text('Request this car'),
                              content: Container(
                                height: 100,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        RaisedButton(
                                          onPressed: () {
                                            showDatePicker(
                                                context: ctx,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime(2022))
                                                .then((value) {
                                              setState(() {
                                                _fromDate = value;
                                              });
                                            });
                                          },
                                          child: Text(
                                            _fromDate == null
                                                ? 'From'
                                                : DateFormat('dd/MM/yy')
                                                .format(_fromDate!),
                                          ),
                                        ),
                                        RaisedButton(
                                          onPressed: () {
                                            showDatePicker(
                                                context: ctx,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime(2022))
                                                .then((value) {
                                              setState(() {
                                                _toDate = value;
                                              });
                                            });
                                          },
                                          child: Text(
                                            _toDate == null
                                                ? 'To'
                                                : DateFormat('dd/MM/yy').format(_toDate!),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                        'Good choice by renting this awesome car')
                                  ],
                                ),
                              ),
                              actions: [
                                FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _fromDate = null;
                                      _toDate = null;
                                    },
                                    child: Text('Cancel')),
                                FlatButton(
                                    onPressed: () {
                                      if(_fromDate == null || _toDate == null){
                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please pick a date')));
                                      }else {
                                        _rentPeriod = (_toDate!.difference(_fromDate!).inDays + 1);
                                        Provider.of<Requests>(context, listen: false)
                                            .addRequest(Request(
                                            renterId: renterId,
                                            ownerId: carDetail.ownerId,
                                            rentPeriod: _rentPeriod,
                                            price: carDetail.price,
                                            state: "Waiting",
                                            renterImageUrl: renterImageUrl,
                                            renterName:  renterName,
                                            carImageUrl: carDetail.carImageUrl,
                                            carName: carDetail.name,
                                        ));
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                        _fromDate = null;
                                        _toDate = null;
                                        /*Scaffold.of(context).showSnackBar(SnackBar(content: Text('you request a car for $_rentPeriod'),),);*/
                                      }
                                    
                                    },
                                    child: Text('Approve')),
                              ],
                            ),
                          ));
                    }, child: Text('Request Now!'), color: Theme.of(context).accentColor,), left: dw * 0.33, bottom: dh * 0.02,)
                  ]
              ),),
          /*if(isLandScape) Row(children: [ingredients, steps],),
          if(!isLandScape) ingredients,
          if(!isLandScape) steps,*/
        ],
      ),
    );
  }
}
