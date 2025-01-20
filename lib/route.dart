import 'package:flutter/material.dart';
import 'package:mapbox_integration_app/views/home.dart';
import 'package:mapbox_integration_app/views/mapbox_page.dart';

class Routes {
  static const String home = '/home';
  static const String mapboxPage = '/mapbox_page';

  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const Homepage());
      case mapboxPage:
        return MaterialPageRoute(builder: (_) => const MapboxPage());
      default:
        return MaterialPageRoute(builder: (_) => Scaffold(
          body: Center(child: Text('No route defined for ${settings.name}')),
        ));
    }
  }
}