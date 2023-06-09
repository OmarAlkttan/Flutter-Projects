import 'package:car_rental/providers/cars.dart';
import 'package:car_rental/screens/edit_add_car_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserCarItem extends StatelessWidget {
  final String? id;
  final String? title;
  final String? imageUrl;

  UserCarItem({
    @required this.id,
    @required this.title,
    @required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title!),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl!),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => Navigator.of(context)
                    .pushNamed(EditCarScreen.routeName, arguments: id)),
            IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).errorColor,
                ),
                onPressed: () async {
                  try {
                    await Provider.of<Cars>(context, listen: false).deleteCar(id!);
                  } catch (e) {
                    // ignore: deprecated_member_use
                    Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(
                          'Error occurred, Can\'t delete',
                          textAlign: TextAlign.center,
                        )));
                  }
                })
          ],
        ),
      ),
    );
  }
}
