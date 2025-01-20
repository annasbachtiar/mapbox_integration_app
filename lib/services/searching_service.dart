import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SearchingService extends ChangeNotifier {
  String query = ' ';
  String accessToken = const String.fromEnvironment("ACCESS_TOKEN");
  TextEditingController controller = TextEditingController();

  List<Map<String,dynamic>> suggestions = [];

  // Fungsi mendapatkan hasil pencarian
  Future<List<Map<String,dynamic>>> getSearchResult() async {
    final response = await http.get(
      Uri.parse('https://api.mapbox.com/search/searchbox/v1/forward?q=$query&access_token=$accessToken')
    );

    // Respon berhasil
    if (response.statusCode == 200) {
      Iterable result = json.decode(response.body)['features'];
      final List<Map<String,dynamic>> data = result.map((item) => {
        'name': item['properties']['name'] ?? 'Unknown place',
        'full_address': item['properties']['full_address'] ?? 'Unknown address',
        'coordinates': item['geometry']['coordinates'] ?? [],
      }).toList();

      try {
        suggestions = data;
      } catch (e) {
        print('Error: $e');
      }

      return data;
    }
    // Respon gagal
    else {
      print('Failed response: ${response.statusCode}, body: ${response.body}');
      throw Exception('Error: ${json.decode(response.body)}');
    }
  }
}