import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};

  late FirebaseFirestore firestore;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  void _initializeFirebase() async {
    await Firebase.initializeApp();
    firestore = FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        markers: _markers,
        onLongPress: _addMarker,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('To the lake!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = mapController;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  void _addMarker(LatLng latLng) async {
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    Marker marker = Marker(
      markerId: MarkerId(id),
      position: latLng,
      infoWindow: InfoWindow(
        title: "The Title",
        snippet: "iajhfoaefjeaf etoerjioj poggers",
      ),
    );
    _markers.add(marker);
    mapController.animateCamera(CameraUpdate.newLatLng(latLng));

    // Save the marker to Firestore
    await firestore.collection('markers').doc(id).set({
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
    });

    setState(() {});
  }

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
}
