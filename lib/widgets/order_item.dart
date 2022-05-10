import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as orderFromProvider;

class OrderItem extends StatefulWidget {
  final orderFromProvider.OrderItem order;

  OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height:
          _expanded ? min(widget.order.products.length * 20.0 + 110, 200) : 95,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                '\$${widget.order.amount}',
              ),
              subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
              ),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: _expanded
                    ? min(widget.order.products.length * 20.0 + 10, 100)
                    : 0,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListView(
                  children: widget.order.products
                      .map(
                        (prod) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              prod.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'x ${prod.quantity} \$${prod.price}',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            )
                          ],
                        ),
                      )
                      .toList(),
                )
                //height depends on the amount of items we have in the list
                //up to a certain point

                //widget.order.products.length * 20 + 100 is s smallest
                )
          ],
        ),
      ),
    );
  }
}
