import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import '../models/product.dart';
import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    //you can wrap only component that has data change with consumer in this case is Favorite
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          //FadeInImage also takes an image argument which is the image you actually want to render
          child: Hero(
            tag: product.id,
            //use on the new page which is loaded because hero animation is always used between two different pages
            //it's used on the new screen which is loaded to know which image on the old screen to float over
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (ctx, product, _) => IconButton(
              //use _ when we donn't use that argument
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              color: Theme.of(context).accentColor,
              onPressed: () {
                product.toggleFavoriteStatus(authData.token, authData.userId);
              },
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
            ),
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              Scaffold.of(context).hideCurrentSnackBar();
              //there is a snack bar already, this will be hidden before the new one is shown
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.grey[700],
                  content: Text(
                    'Added item to cart!',
                  ),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      cart.removeSingleItem(product.id);
                    },
                  ),
                ),
              );
              //snackbar is a material design object which is shown at the bottom of the screen
              //it's an info modal, an in fo popup which comes in from the bottom of the screen
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
    //build-in widget which can be used anywhere but which works particularly well inside of grids
  }
}
