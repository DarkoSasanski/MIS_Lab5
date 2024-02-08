import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:lab3/custom_app_bar.dart';

import '../services/firestore_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  final FirestoreService _firestoreService = FirestoreService();
  late List<Map<String, dynamic>> _exams;
  List<LatLng> routeCoordinates = [];

  @override
  void initState() {
    super.initState();
    _exams = [];
    _loadExams();
  }

  String formatDate(Timestamp date) {
    DateTime dateTime = date.toDate();
    return '${dateTime.day}.${dateTime.month}.${dateTime.year} at ${dateTime.hour}:${dateTime.minute}';
  }

  Future<void> _loadExams() async {
    try {
      List<Map<String, dynamic>> exams = await _firestoreService.getExams();
      setState(() {
        _exams = exams;
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error loading exams: $error');
      }
    }
  }

  Future<void> _refreshExams() async {
    await _loadExams();
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      if (kDebugMode) {
        print("ERROR$error");
      }
    });
    return await Geolocator.getCurrentPosition();
  }

  Future<List<LatLng>?> getDirections(LatLng origin, LatLng destination) async {
    const String apiKey = '';
    const String apiUrl =
        'https://maps.googleapis.com/maps/api/directions/json';

    final String originString = '${origin.latitude},${origin.longitude}';
    final String destinationString =
        '${destination.latitude},${destination.longitude}';

    final response = await http.get(
      Uri.parse(
          '$apiUrl?origin=$originString&destination=$destinationString&key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print('Directions API Response: $data');
      final List<LatLng> points = PolylinePoints()
          .decodePolyline(data['routes'][0]['overview_polyline']['points'])
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      return points;
    } else {
      // Handle error
      if (kDebugMode) {
        print('Error accessing Directions API: ${response.statusCode}');
      }
    }
    return null;
  }

  void findShortestPathToExam(LatLng examLocation) async {
    final Position currentPosition = await getUserCurrentLocation();
    final LatLng currentLocation =
        LatLng(currentPosition.latitude, currentPosition.longitude);
    final List<LatLng>? points =
        await getDirections(currentLocation, examLocation);
    if (points != null) {
      setState(() {
        routeCoordinates = points;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onRefresh: _refreshExams,
      ),
      body: SafeArea(
        child: GoogleMap(
          onMapCreated: (controller) {
            setState(() {
              mapController = controller;
            });
          },
          zoomControlsEnabled: false,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          layoutDirection: TextDirection.ltr,
          initialCameraPosition: const CameraPosition(
            target: LatLng(42.00478491557928, 21.40917442067392),
            zoom: 12.0,
          ),
          markers: _exams
              .map((exam) => Marker(
                  markerId: MarkerId(exam['id']),
                  position: LatLng(exam['location']['latitude'],
                      exam['location']['longitude']),
                  infoWindow: InfoWindow(
                      title: exam['title'],
                      snippet: 'Exam date: ${formatDate(exam['date'])}'),
                  onTap: () {
                    findShortestPathToExam(LatLng(exam['location']['latitude'],
                        exam['location']['longitude']));
                  }))
              .toSet(),
          polylines: <Polyline>{
            Polyline(
              polylineId: const PolylineId('route'),
              points: routeCoordinates,
              color: Colors.blue,
              width: 5,
            ),
          },
        ),
      ),
    );
  }
}
