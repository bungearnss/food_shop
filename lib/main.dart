import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/splash_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './screens/cart_screen.dart';
import './providers/orders.dart';
import './screens/orders_screen.dart';
import './screens/user_product_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './providers/auth.dart';
import './helpers/custom_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //instead return with MaterialApp, will actually wrap this into another widget
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: Auth(),
          ),
          // ignore: missing_required_param
          ChangeNotifierProxyProvider<Auth, Products>(
            //ChangeNotifierProvider it allow us to register a class to which you can then listrn in child widgets
            //and whenever that class updates the widget which are listening, and only these not all child widgets
            //only child widgets which are listening will rebuild
            update: (ctx, auth, previousProducts) => Products(
              auth.token,
              auth.userId,
              previousProducts == null ? [] : previousProducts.items,
            ),
            //use previousProducts to give a initial data to not null

            //the create method here is the right method to choose

            //if your value that you want to provide doesn't depend on the context
            //use ChangeNotifierProvider.value and change create to value
            //use when you have to provider package and you're providing your data on a single list or grid

            //in this case you should use only ChangeNotifierProvider because whenever you instantiate a class
            //so whenever you create a new object based on a class use ChangeNotifierProvider for more efficiency
          ),
          ChangeNotifierProvider.value(
            value: Cart(),
          ),
          // ignore: missing_required_param
          ChangeNotifierProxyProvider<Auth, Orders>(
            update: (ctx, auth, previousOrders) => Orders(
              auth.token,
              auth.userId,
              previousOrders == null ? [] : previousOrders.orders,
            ),
          ),
        ],
        //we will rebuild the MaterialApp so let take a Consumer Object wrap to MaterialApp
        //to ensure that the MaterialApp is rebuilt whenever auth changes, whenever that Auth Object changes
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'MyShop',
            theme: ThemeData(
                primarySwatch: Colors.purple,
                accentColor: Colors.deepOrange,
                fontFamily: 'Lato',
                //use to change the transition for all your routes if you wanted to
                pageTransitionsTheme: PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: CustomPageTransitionBuilder(),
                    TargetPlatform.iOS: CustomPageTransitionBuilder(),
                  },
                )),
            home: auth.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    //try to login again if we in wait state to login show SplashScreen
                    //if we done to login, show AuthScreen
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
            },
          ),
        ));
  }
}
