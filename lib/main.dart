import 'package:customer_estaurant_app/features/auth/controller/auth_controller.dart';
import 'package:customer_estaurant_app/features/branch/controller/branch_controller.dart';
import 'package:customer_estaurant_app/features/cart/controller/cart_controller.dart';
import 'package:customer_estaurant_app/features/coupon/controller/coupon_controller.dart';
import 'package:customer_estaurant_app/features/menu/controller/menu_controller.dart';
import 'package:customer_estaurant_app/features/order_history/controller/order_history_provider.dart';
import 'package:customer_estaurant_app/features/splash/view/splash_screen.dart';
import 'package:customer_estaurant_app/features/home/view/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/storage/shared_pref_service.dart';
import 'features/address/controller/address_controller.dart';
import 'features/location/controller/location_controller.dart';
import 'features/location/view/location_screen.dart';
import 'features/loyalty/provider/loyalty_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  final token = await FirebaseMessaging.instance.getToken();
  print("FCM TOKEN : $token");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthController()..loadSession(),
        ),

        ChangeNotifierProvider(
          create: (context) => BranchController(),
        ),

        ChangeNotifierProvider(
          create: (context) => MenuProvider(),
        ),

        ChangeNotifierProvider(
          create: (context) => LocationController(),
        ),

        ChangeNotifierProvider(
          create: (context) => CartProvider()..loadCart(),
        ),

        ChangeNotifierProvider(
          create: (context) => AddressController(),
        ),

        ChangeNotifierProvider(
          create: (context) => LoyaltyProvider(),
        ),

        ChangeNotifierProvider(
          create: (context) => OrderHistoryProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => CouponController(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;
  bool _showInitialAddress = false;

  Future<void> _finishSplash() async {
    final hasShownFirstAddress =
    await SharedPrefService.getHasShownFirstAddress();

    if (!mounted) return;

    setState(() {
      _showSplash = false;
      _showInitialAddress = !hasShownFirstAddress;
    });
  }

  Future<void> _initialAddressSaved() async {
    await SharedPrefService.saveHasShownFirstAddress(true);

    if (!mounted) return;

    setState(() {
      _showInitialAddress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget home;

    if (_showSplash) {
      home = SplashScreen(
        onFinished: _finishSplash,
      );
    } else if (_showInitialAddress) {
      home = LocationScreen(
        addressTypeId: 3,
        localOnly: true,
        onAddressSaved: _initialAddressSaved,
      );
    } else {
      home = const HomeScreen();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(data: mediaQuery.copyWith(
            textScaler: TextScaler.noScaling), child: child!);
      },
      home: home,
    );
  }
}