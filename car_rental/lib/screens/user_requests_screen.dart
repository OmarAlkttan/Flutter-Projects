import 'package:car_rental/providers/auth.dart';
import 'package:car_rental/providers/requests.dart';
import 'package:car_rental/widgets/app_drawer.dart';
import 'package:car_rental/widgets/user_request_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserRequestsScreen extends StatefulWidget {
  static final routeName = '/user_requests';

  @override
  _UserRequestsScreenState createState() => _UserRequestsScreenState();
}

class _UserRequestsScreenState extends State<UserRequestsScreen> {
  Future<void> _refreshRequests(BuildContext context) async {
    await Provider.of<Requests>(context, listen: false)
        .fetchAndSetOwnerRequests();
    await Provider.of<Requests>(context, listen: false)
        .fetchAndSetRenterRequests();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('My Requests'),
      ),
      body: FutureBuilder(
        future: _refreshRequests(context),
        builder: (BuildContext context, AsyncSnapshot snapshot) => snapshot
                    .connectionState ==
                ConnectionState.waiting
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
              child: Consumer<Requests>(
                  builder: (ctx, requestsData, child) => Column(
                    children: [
                      Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: requestsData.items.isEmpty
                                ? Center(child: Text('No Requests now!'))
                                : ListView.builder(
                                    itemCount: requestsData.items.length,
                                    itemBuilder: (ctx, index) =>
                                        RequestItem(requestsData.items[index].id!)),
                          ),
                    ],
                  ),),
              onRefresh: ()=> _refreshRequests(context),
            ),
      ),
      drawer: AppDrawer(),
    );
  }
}
