import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './product_item.dart';
import '../providers/products.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;

  ProductsGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = showFavs ? productsData.favoriteItems : productsData.items;
    //inside <> let us lnow which type of data you actually want to listen to
    //provider package allows us to set up a connection to one of provided classes
    //So this build method of this widget where i'm using provider off
    //only this build method and all child in this build method will rebuild whenever the object
    //i'm listening to change the build methodr
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: products[i],
        child: ProductItem(
            // products[i].id,
            // products[i].title,
            // products[i].imageUrl,
            ),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      //crossAxisCount that is amount of columns i want to have
      //crossAxisSpacing that is a space between the column
      //mainAxisSpacing that is the space between the rows

      //in single product here is actually only needed in every product item list
      //so i want to set up new provider here above my ProductItem
      //so that inside of the product item, we can then listen to changes in that product

      //ChangeNotifierProvider has a clean up data when you doesn't in this screen for reducing memory data
    );
  }
}
