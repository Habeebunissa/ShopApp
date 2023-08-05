import 'package:flutter/material.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/products_grid.dart';

import '../providers/product_provider.dart';
import '/widgets/app_drawer.dart';

import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/product.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductOverviewScreen extends StatefulWidget {
  const ProductOverviewScreen({super.key});

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void iniState() {
    // Provider.of<Products>(context).fetchAndSetProducts();
// Future.delayed(Duration.zero).then((_){
//Provider.of<Products>(context).fetchAndSetProducts();});
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("MyShop"), actions: <Widget>[
        PopupMenuButton(
          onSelected: (selectedvalue) {
            setState(() {
              if (selectedvalue == FilterOptions.Favorites) {
                _showOnlyFavorites = true;
              } else {
                _showOnlyFavorites = false;
              }
            });

            // Handle selection here.
            // result will contain the value of the selected option.
          },
          icon: Icon(
            Icons.more_vert,
          ),
          itemBuilder: (BuildContext context) =>
              <PopupMenuEntry<FilterOptions>>[
            PopupMenuItem<FilterOptions>(
              value: FilterOptions.Favorites,
              child: Text("Only Favorites"),
            ),
            PopupMenuItem<FilterOptions>(
              value: FilterOptions.All,
              child: Text("Show All"),
            ),
          ],
        ),
        Consumer<Cart>(
          builder: (context, cart, ch) {
            return Badge(
                label: Text(cart.itemCount.toString()),
                child: IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.of(context).pushNamed(CartScreen.routeName);
                  },
                ));
          },
        ),
      ]),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavorites),
    );
  }
}
