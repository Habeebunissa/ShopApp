import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './screens/cart_screen.dart';
import 'package:provider/provider.dart';
import './providers/product_provider.dart';
import './providers/cart.dart';
import 'product_detail_screen.dart';
import 'providers/order.dart';
import 'providers/auth.dart';
import './screens/orders_screen.dart';
import './screens/user_products_Screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import 'screens/splashscreen.dart';

Future<bool> checkuserlogin() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  bool isLoggedIn = pref.getBool('userLoggedIn') ?? false;
  return isLoggedIn;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Myshop());
}

class Myshop extends StatelessWidget {
  const Myshop({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: checkuserlogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(
              home: Scaffold(body: CircularProgressIndicator()),
            );
          } else {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (context) => Auth()),
                ChangeNotifierProvider(
                  create: (context) => Products(),
                ),
                ChangeNotifierProvider(
                  create: (context) => Cart(),
                ),
                ChangeNotifierProvider(
                  create: (context) => Orders(),
                ),
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: "Myshop",
                theme: ThemeData(
                  primaryColor: Colors.deepOrange,
                  primarySwatch: Colors.deepOrange,
                  fontFamily: "Lato",
                ),
                home: snapshot.data == true ? Splashscreen() : AuthScreen(),
                routes: {
                  ProductDetailScreen.routeName: (context) =>
                      ProductDetailScreen(),
                  CartScreen.routeName: (context) => CartScreen(),
                  OrderScreen.routeName: (context) => OrderScreen(),
                  UserProductsScreen.routeName: (context) =>
                      UserProductsScreen(),
                  EditProductScreen.routeName: (context) => EditProductScreen(),
                },
              ),
            );
          }
        });
  }
}
