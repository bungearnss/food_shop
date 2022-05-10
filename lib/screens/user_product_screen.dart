import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import './edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
    //pass true in fetchAndSetProducts to filter by user
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products>(context);
    print('rebuild..... in user product');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        //add const then these widgets will not get rebuild
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        //FutureBuilder fetch data when this first load, when this first builds before we refresh
        //product by myself
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    //once you refresh or once the initial loading is done in the end
                    //that list here will be built and rebuilt
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products>(
                      builder: (ctx, productsData, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemBuilder: (_, i) => Column(children: [
                            UserProductsItem(
                              productsData.items[i].id,
                              productsData.items[i].title,
                              productsData.items[i].imageUrl,
                            ),
                            Divider(),
                          ]),
                          itemCount: productsData.items.length,
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
