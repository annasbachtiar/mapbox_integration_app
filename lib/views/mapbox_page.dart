// ignore_for_file: override_on_non_overriding_member, unnecessary_this

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_integration_app/utils.dart';
import 'package:mapbox_integration_app/services/direction_service.dart';
import 'package:mapbox_integration_app/services/searching_service.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapboxPage extends StatefulWidget {
  const MapboxPage({super.key});

  @override
  State<MapboxPage> createState() => _MapboxPageState();
}

class _MapboxPageState extends State<MapboxPage> {
  late MapboxMap mapboxMap;
  late num newLng, newLat;
  late DirectionService drcService;
  late SearchingService schService;
  PointAnnotation? pointAnnotation;
  PointAnnotationManager? pointAnnotationManager;
  PolylineAnnotationManager? polylineAnnotationManager;

  int styleIndex = 1;
  List<Point> markerPoints = [];
  List<PolylineAnnotationOptions> polylineAnnotations = [];

  @override
  Widget build(BuildContext context) {
    schService = Provider.of<SearchingService>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color(0xFF111D2D),
        foregroundColor: Colors.white,
        title: const Text('Mapbox Page',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Bagian map
          MapWidget(
            cameraOptions: CameraOptions(
              center: Point(coordinates: Position(106.8229, -6.1944)),
              zoom: 8,
              pitch: 0,
              bearing: 0
            ),
            onMapCreated: _onMapCreated,
            onTapListener: _onTap
          ),

          // Bagian searchbox
          Container(
            margin: const EdgeInsets.only(right: 50),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: schService.controller,
                  decoration: const InputDecoration(
                    hintText: 'Search places...',
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF111D2D))),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF111D2D), width: 2)),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: Icon(Icons.search_outlined, color: Color(0xFF111D2D)),
                    contentPadding: EdgeInsets.all(10)
                  ),
                  onChanged: (query) => setState(() => schService.query = query),
                ),
                schService.query.isNotEmpty
                ? ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(5),
                      child: FutureBuilder<List<Map<String,dynamic>>>(
                        future: schService.getSearchResult(), 
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(padding: EdgeInsets.only(top: 10), child: Center(child: CircularProgressIndicator(color: Color(0xFF111D2D))));
                          }
                          else if (snapshot.hasError) {
                            return const SizedBox.shrink();
                          }
                          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          else {
                            final List<Map<String,dynamic>> data = snapshot.data!;
                            return ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                final item = data[index];
                                return InkWell(
                                  onTap: () async {
                                    final List<dynamic> coordinates = item['coordinates'];
                                    if (coordinates.isNotEmpty) {
                                      newLng = coordinates[0];
                                      newLat = coordinates[1];
                                      print('Longitude:  $newLng; Latitude: $newLat');

                                      mapboxMap.setCamera(CameraOptions(
                                        center: Point(coordinates: Position(newLng, newLat)),
                                        zoom: 8, pitch: 0, bearing: 0
                                      ));

                                      if (markerPoints.length < 5) {

                                        final ByteData bytes = await rootBundle.load('assets/custom-icon.png');
                                        final Uint8List list = bytes.buffer.asUint8List();
                                        createAnnotation(list);
                                        setState(() {
                                          schService.query = '' ;
                                          markerPoints.add(Point(coordinates: Position(newLng, newLat)));
                                        });
                                      }
                                      else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Color(0xFF111D2D),
                                          content: Text('Only 5 markers are allowed.', 
                                            style: TextStyle(color: Colors.white, fontSize: 12)
                                          ),
                                        ));
                                        return;
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: 60,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: const BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Color(0xFF111D2D)))
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['name'] ?? 'Unknown places', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        FittedBox(fit: BoxFit.scaleDown, child: Text(item['full_address'] ?? 'Unknown address', style: const TextStyle(fontSize: 12))),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        }
                      ),
                    ),
                  )
                : const SizedBox.shrink()
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Button mengganti style map
          Padding(
            padding: const EdgeInsets.only(bottom: 140),
            child: FloatingActionButton(
              onPressed: () {
                mapboxMap.style.setStyleURI(Utils().annotationStyles[++styleIndex % Utils().annotationStyles.length]);
                print('Change Map Style Button Clicked');
              },
              backgroundColor: const Color(0xFF111D2D),
              tooltip: 'Change map style',
              child: const Icon(Icons.swap_horiz, color: Colors.white),
            ),
          ),
          // Button Membuat polyline
          Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: FloatingActionButton(
              onPressed: () {
                createPolyline();
                print('Create Polyline Button Clicked');
              },
              backgroundColor: const Color(0xFF111D2D),
              tooltip: 'Create polyline',
              child: const Icon(Icons.polyline, color: Colors.white),
            ),
          ),
          // Button menghapus seluruh marker
          FloatingActionButton(
            onPressed: () {
              deleteAllAnnotation();
              print('Delete All Annotation Button Clicked');
            },
            backgroundColor: const Color(0xFF111D2D),
            tooltip: 'Delete all annotation',
            child: const Icon(Icons.delete_sweep, color: Colors.white),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /* ======================================================================== */
  /*                            KUMPULAN FUNGSI                               */
  /* ======================================================================== */

  // Fungsi initState
  @override
  void initState() {
    super.initState();
    drcService = DirectionService();
  }

  // Fungsi ketika user melakukan interaksi 'tap' pada map
  @override
  _onTap(MapContentGestureContext mapContext) async {
    if (markerPoints.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF111D2D),
        content: Text('Only 5 markers are allowed.', 
          style: TextStyle(color: Colors.white, fontSize: 12)
        ),
      ));
      return;
    }

    newLng = mapContext.point.coordinates.lng;
    newLat = mapContext.point.coordinates.lat;
    print('Longitude:  $newLng; Latitude: $newLat');

    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF111D2D),
        content: Text('Longitude: ${mapContext.point.coordinates.lng}\nLatitude: ${mapContext.point.coordinates.lat}', 
          style: const TextStyle(color: Colors.white, fontSize: 12)
        ),
      )
    );

    final ByteData bytes = await rootBundle.load('assets/custom-icon.png');
    final Uint8List list = bytes.buffer.asUint8List();

    createAnnotation(list);
    setState(() => markerPoints.add(Point(coordinates: Position(mapContext.point.coordinates.lng, mapContext.point.coordinates.lat))));
  }

  // Fungsi ketika map pertama dibuat
  @override
  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    pointAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();
    polylineAnnotationManager = await mapboxMap.annotations.createPolylineAnnotationManager();

    final ByteData bytes = await rootBundle.load('assets/custom-icon.png');
    final Uint8List imageData = bytes.buffer.asUint8List();

    PointAnnotationOptions pointAnnotationOptions = PointAnnotationOptions(
      geometry: Point(coordinates: Position(106.8229, -6.1944)),
      image: imageData,
      iconSize: 3.0
    );

    pointAnnotationManager?.create(pointAnnotationOptions);
    setState(() => markerPoints.add(Point(coordinates: Position(106.8229, -6.1944))));
  }

  // Fungsi membuat marker
  void createAnnotation(Uint8List list) {
    pointAnnotationManager?.create(PointAnnotationOptions(
      geometry: Point(coordinates: Position(newLng, newLat)),
      image: list,
      iconSize: 3.0
    )).then((value) => pointAnnotation = value);
  }

  // Fungsi menghilangkan semua marker
  void deleteAllAnnotation() {
    pointAnnotationManager?.deleteAll();
    polylineAnnotationManager?.deleteAll();
    markerPoints.clear();
  }

  // Fungsi menggambar polyline
  void createPolyline() async {
    polylineAnnotationManager?.deleteAll();

    if (markerPoints.length > 1) {
      List<Point> polylinePoints = await drcService.getDirection(markerPoints);
      if (polylinePoints.isNotEmpty) {
        LineString lineString = LineString(coordinates: polylinePoints.map(
          (point) => Position(point.coordinates.lng, point.coordinates.lat)
        ).toList());
        polylineAnnotationManager?.create(PolylineAnnotationOptions(
          geometry: lineString,
          lineColor: const Color(0xFF111D2D).value,
          lineWidth: 5,
          lineOpacity: 0.5,
        ));
      }
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF111D2D),
        content: Text('There must be at least 2 markers to draw polylines.', 
          style: TextStyle(color: Colors.white, fontSize: 12)
        ),
      ));
    }
  }
}