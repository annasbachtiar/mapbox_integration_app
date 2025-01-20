import 'package:flutter/material.dart';
import 'package:mapbox_integration_app/route.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF111D2D),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Mapbox Integration App', style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111D2D)
            )),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, Routes.mapboxPage),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: const Color(0xFF111D2D),
                foregroundColor: Colors.white
              ),
              child: const Text('Go to Map Page')
            )
          ],
        ),
      ),
    );
  }
}