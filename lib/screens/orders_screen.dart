import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

//if you had a scenario data which it could be rebuild and you don't want to fetch new orders again
//just because something else changed, then using this spproach is better and ensures that no
//unneccesary http request are sent again
class _OrdersScreenState extends State<OrdersScreen> {
  Future _ordersFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    //getting out future ans storing it in a property when this widget is created
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('building order just once!');
    //this code show the more elegant alternative to using a stateful widget just to fetch orders and show
    //a loading spinner.

    //we also don't have to manage the loading state on our own because we're letting the future builder do
    //that by checking the connections state.

    //then change statefulWidget to statelessWidget to get clean widget in this screen

    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: _ordersFuture,
          //By using this approach, you ensure that no new future is created just because
          //your Widget rebuilds
          builder: (ctx, dataSnapshot) {
            //dataSnapshot here is of type snapshot, and if you add a dot after it
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              //check if dataSnapshot connection state is currently equal to ConnectionState.waiting
              //which mean we're currently loading
              return Center(child: CircularProgressIndicator());
            } else {
              if (dataSnapshot.error != null) {
                return Center(
                  child: Text('An error occurred!'),
                );
              } else {
                return Consumer<Orders>(
                  //set up which actually works and our order without entering an infifite loop
                  builder: (ctx, orderData, child) => ListView.builder(
                    itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                    itemCount: orderData.orders.length,
                  ),
                );
              }
            }
          },
        ));
  }
}
