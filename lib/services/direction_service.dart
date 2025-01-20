import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class DirectionService extends ChangeNotifier {
  String accessToken = const String.fromEnvironment("ACCESS_TOKEN");

  // Fungsi mendapatkan arah
  Future<List<Point>> getDirection(List<Point> markerPoints) async {
    List<Point> polylinePoints = [];

    for (int i = 0; i < markerPoints.length - 1 && i < 4; i++) {
      final String url = 
        'https://api.mapbox.com/directions/v5/mapbox/driving/'
        '${markerPoints[i].coordinates.lng},${markerPoints[i].coordinates.lat};'
        '${markerPoints[i+1].coordinates.lng},${markerPoints[i+1].coordinates.lat}'
        '?geometries=geojson&access_token=$accessToken';
        
      try {
        final response = await http.get(Uri.parse(url));
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];

          polylinePoints.addAll(coordinates.map((value)
            => Point(coordinates: Position(value[0], value[1]))
          ).toList());
        }
        else {
          print('Failed response: ${response.statusCode}, body: ${response.body}');
          throw Exception('Error: ${json.decode(response.body)}');
        }
      } 
      catch (e) {
        print('Error: $e');
      }
    }
    return polylinePoints;
  }
}