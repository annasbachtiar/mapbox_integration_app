
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mapbox_integration_app/route.dart';
import 'package:mapbox_integration_app/services/direction_service.dart';
import 'package:mapbox_integration_app/services/searching_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  String accessToken = "pk.eyJ1Ijoia2FybG9kZXYiLCJhIjoiY2xocTN1ZnVjMjB1NDNtcHNoMmI2N2dhcCJ9.5Y8fh8aPfM6f5zDKA_bDiw";
  MapboxOptions.setAccessToken(accessToken);
  
  runApp(const MapboxIntegrationApp());
}

class MapboxIntegrationApp extends StatelessWidget {
  const MapboxIntegrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DirectionService()),
        ChangeNotifierProvider(create: (_) => SearchingService())
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.home,
        onGenerateRoute: Routes.getRoute,
      ),
    );
  }
}