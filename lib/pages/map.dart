import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergency/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GMap extends StatefulWidget {
  final double userLat;
  final double userLong;
  const GMap({Key? key, required this.userLat, required this.userLong})
      : super(key: key);

  @override
  State<GMap> createState() => _GMapState();
}

class _GMapState extends State<GMap> {
  final Location locationController = Location();
  late GoogleMapController mapController;
  LatLng? currentPosition;
  LatLng? station = const LatLng(35.548994, 45.445501);
  LatLng? userLocation;
  Map<PolylineId, Polyline> polylines = {};
  StreamSubscription<LocationData>? locationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initializeMap();
    });
    userLocation = LatLng(widget.userLat, widget.userLong);
  }

  Future<void> initializeMap() async {
    await fetchLocationUpdates();
    await fetchStationLocation();
    final coordinates = await fetchPolyLinePoints();
    generatePolyLineFromPoints(coordinates);
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    mapController.dispose();
    super.dispose();
  }

  Future<void> fetchStationLocation() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();

      if (docSnapshot.exists) {
        final userData = docSnapshot.data() as Map<String, dynamic>;
        final latitude = userData['latitude'] as double?;
        final longitude = userData['longitude'] as double?;

        if (latitude != null && longitude != null) {
          setState(() {
            station = LatLng(latitude, longitude);
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching station location: $e');
    }
  }

  Future<void> fetchLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    locationSubscription =
        locationController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          currentPosition =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });
      }
    });
  }

  Future<List<LatLng>> fetchPolyLinePoints() async {
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPI,
      PointLatLng(station!.latitude, station!.longitude),
      PointLatLng(userLocation!.latitude, userLocation!.longitude),
    );

    if (result.points.isNotEmpty) {
      return result.points
          .map(
            (point) => LatLng(point.latitude, point.longitude),
          )
          .toList();
    } else {
      debugPrint(result.errorMessage);
      return [];
    }
  }

  Future<void> generatePolyLineFromPoints(
      List<LatLng> polylineCoordinates) async {
    const id = PolylineId("polyline");
    final polyline = Polyline(
      polylineId: id,
      color: Colors.blueAccent,
      points: polylineCoordinates,
      width: 5,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  void centerOnUser() {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: userLocation!,
          zoom: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentPosition == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                  initialCameraPosition:
                      CameraPosition(target: currentPosition!, zoom: 13),
                  markers: {
                    Marker(
                      markerId: const MarkerId("User Location"),
                      icon: BitmapDescriptor.defaultMarker,
                      position: userLocation!,
                    ),
                    Marker(
                      markerId: const MarkerId("Police Location"),
                      icon: BitmapDescriptor.defaultMarker,
                      position: station!,
                    ),
                    Marker(
                      markerId: const MarkerId("Current Location"),
                      icon: BitmapDescriptor.defaultMarker,
                      position: currentPosition!,
                    ),
                  },
                  polylines: Set<Polyline>.of(polylines.values),
                ),
                Positioned(
                    bottom: 100,
                    right: 5,
                    child: FloatingActionButton(
                      child: const Icon(Icons.location_searching),
                      onPressed: () {
                        centerOnUser();
                      },
                    ))
              ],
            ),
    );
  }
}
