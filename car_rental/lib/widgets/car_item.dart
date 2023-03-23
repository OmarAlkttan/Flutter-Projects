import 'package:car_rental/providers/cars.dart';
import 'package:car_rental/screens/car_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CarItem extends StatefulWidget {
  final String? id;

  CarItem({
    @required this.id,
  });

  @override
  _CarItemState createState() => _CarItemState();
}

class _CarItemState extends State<CarItem> {

  Car? car;

  @override
  void initState() {
    car = Provider.of<Cars>(context, listen: false).findById(widget.id!);
    super.initState();
  }

  void _selectCar (BuildContext ctx){
    Navigator.of(ctx).pushNamed(
        CarDetailsScreen.routeName,
        arguments: widget.id
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()=> _selectCar(context),
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
        ),
        elevation: 4,
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                    child: Hero(tag: widget.id!,child: Image.network(car!.carImageUrl!,height: 200, width: double.infinity, fit: BoxFit.cover,))),
                Positioned(
                  child: Container(
                    child: Text('\$${car!.price}', style: TextStyle(fontSize: 24, color: Theme.of(context).accentColor),),
                    color: Colors.black54,
                    width: 150,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  ),
                  right: 20,
                  bottom: 10,
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Icon(Icons.directions_car),
                      SizedBox(width: 6,),
                      Text(car!.name!, style: TextStyle(fontSize: 20, color: Theme.of(context).accentColor),)
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 6,),
                      Text(car!.model!, style: TextStyle(fontSize: 20, color: Theme.of(context).accentColor),)
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 6,),
                      Text(car!.year!, style: TextStyle(fontSize: 20, color: Theme.of(context).accentColor),)
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

