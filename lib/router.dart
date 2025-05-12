import 'package:flutter/material.dart';
import 'package:kitchen_king/common/bottom_bar.dart';
import 'package:kitchen_king/features/Maps/map_screen.dart';
import 'package:kitchen_king/features/authentication/form_screen.dart';
import 'package:kitchen_king/features/authentication/login_screen.dart';
import 'package:kitchen_king/features/authentication/register_screen.dart';
import 'package:kitchen_king/features/consumption_graph/total_consumption.dart';
import 'package:kitchen_king/features/home/home.dart';
import 'package:kitchen_king/features/notificatinos/notification_screen.dart';
import 'package:kitchen_king/features/profile/profile.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const LoginScreen(),
      );
    case RegisterScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const RegisterScreen(),
      );
    case FormScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const FormScreen(),
      );
    case HomeScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const HomeScreen(),
      );
    case ProfileScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ProfileScreen(),
      );
    case BottomBar.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const BottomBar(),
      );
    case NotificationScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const NotificationScreen(),
      );
    case TotalConsumption.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const TotalConsumption(),
      );
    case MapsScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const MapsScreen(),
      );
    default:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Scaffold(
          body: Center(
            child: Text("Screen do not exist"),
          ),
        ),
      );
  }
}
