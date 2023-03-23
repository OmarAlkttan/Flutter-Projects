import 'package:car_rental/providers/auth.dart';
import 'package:car_rental/providers/requests.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestItem extends StatefulWidget {
  final String requestId;

  RequestItem(this.requestId);

  @override
  _RequestItemState createState() => _RequestItemState();
}

class _RequestItemState extends State<RequestItem> {
  Request? request;


  @override
  void didChangeDependencies() {
    request = Provider.of<Requests>(context, listen: true)
        .findById(widget.requestId);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final _userId = Provider.of<Auth>(context, listen: false).userId;

    return Column(
      children: [
        if (_userId == request!.ownerId)
          Container(
            height: 100,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: deviceSize.width * 0.25,
                  height: 70,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(request!.renterImageUrl!),
                  ),
                ),
                Container(
                  width: deviceSize.width * 0.2,
                  child: Column(
                    children: [
                      Container(
                        height: 100 * 0.32,
                        child: Text(request!.renterName!),
                      ),
                      Container(
                        height: 100 * 0.32,
                        child: Text(
                            '${request!.rentPeriod} ${request!.rentPeriod !<= 1 ? 'day' : 'days'}'),
                      ),
                      Container(
                        height: 100 * 0.32,
                        child: Text('\$${(request!.price !* request!.rentPeriod!).round()}'),
                      ),
                    ],
                  ),
                ),
                if(request!.state == "Waiting")Container(
                  width: deviceSize.width * 0.3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RaisedButton(
                        onPressed: () {
                          Provider.of<Requests>(context, listen: false)
                              .updateRequest(
                            request!.id!,
                            Request(
                                id: request!.id,
                                renterId: request!.renterId,
                                ownerId: request!.ownerId,
                                rentPeriod: request!.rentPeriod,
                                price: request!.price,
                                state: "Approved",
                                renterImageUrl: request!.renterImageUrl,
                                renterName: request!.renterName,
                                carName: request!.carName,
                                carImageUrl: request!.carImageUrl,
                            ),

                          );
                        },
                        child: Text('Approve'),
                        color: Colors.green,
                      ),
                      RaisedButton(
                        onPressed: () {
                          Provider.of<Requests>(context, listen: false)
                              .updateRequest(
                            request!.id!,
                            Request(
                                id: request!.id,
                                renterId: request!.renterId,
                                ownerId: request!.ownerId,
                                rentPeriod: request!.rentPeriod,
                                price: request!.price,
                                state: "Canceled",
                                renterImageUrl: request!.renterImageUrl,
                                renterName: request!.renterName,
                                carName: request!.carName,
                                carImageUrl: request!.carImageUrl,
                            ),
                          );
                        },
                        child: Text('Cancel'),
                        color: Colors.red,
                      )
                    ],
                  ),
                ),
                if(request!.state == "Approved" || request!.state == "Canceled")Text(
                  request!.state!,
                  style: TextStyle(
                      fontSize: 20,
                      color: request!.state == "Approved"
                          ? Colors.green
                          : Colors.red),
                ),
              ],
            ),
          ),
        if (_userId == request!.renterId)
          Dismissible(
            child: Container(
              height: 100,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: deviceSize.width * 0.25,
                    height: 70,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(request!.carImageUrl!),
                    ),
                  ),
                  Container(
                    width: deviceSize.width * 0.2,
                    child: Column(
                      children: [
                        Container(
                          height: 100 * 0.32,
                          child: Text(request!.carName!),
                        ),
                        Container(
                          height: 100 * 0.32,
                          child: Text(
                              '${request!.rentPeriod} ${request!.rentPeriod !<= 1 ? 'day' : 'days'}'),
                        ),
                        Container(
                          height: 100 * 0.32,
                          child:
                              Text('\$${(request!.price !* request!.rentPeriod!).round()}'),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    request!.state!,
                    style: TextStyle(
                        fontSize: 20,
                        color: request!.state == "Waiting"
                            ? Colors.orange
                            : request!.state == "Approved"
                                ? Colors.green
                                : Colors.red),
                  )
                ],
              ),
            ),
            key: ValueKey(request!.id),
            background: Container(
              color: Theme.of(context).errorColor,
              child: Icon(
                Icons.delete,
                size: 40,
                color: Colors.white,
              ),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              Provider.of<Requests>(context, listen: false).deleteRequest(request!.id!);
            },
            confirmDismiss: (direction) {
              return showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Are you sure!'),
                    content:
                    Text('Do you want to delete this car request ?'),
                    actions: [
                      FlatButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('No')),
                      FlatButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('Yes')),
                    ],
                  ));
            },
          ),
        Divider(),
      ],
    );
  }
}
