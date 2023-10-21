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

  static final CameraPosition _start = CameraPosition(
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
        initialCameraPosition: _start,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        markers: _markers,
        onLongPress: _addMarkerDialog,
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: ()=>{},
      //   label: const Text('To the lake!'),
      //   icon: const Icon(Icons.directions_boat),
      // ),
    );
  }


  _addMarkerDialog(LatLng latLng) async {
    final TextEditingController title = TextEditingController();
    final TextEditingController description = TextEditingController();
    const List<String> list = <String>['One', 'Two', 'Three', 'Four'];
    var dropdownValue = list[0];
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("New Event"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: title,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            TextFormField(
              controller: description,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            DropdownMenu<String>(
              initialSelection: list.first,
              onSelected: (String? value) {
                // This is called when the user selects an item.
                setState(() {
                  dropdownValue = value!;
                });
              },
              dropdownMenuEntries:
                  list.map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(value: value, label: value);
              }).toList(),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => {
              _addMarker(latLng, title.text, description.text, dropdownValue),
              Navigator.pop(context, 'OK')
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _addMarker(LatLng latLng, String title, String description, String dropdownValue) async {
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    Marker marker = Marker(
      markerId: MarkerId(id),
      position: latLng,
      infoWindow: InfoWindow(
        title: title,
        snippet: description,
      ),
    );
    _markers.add(marker);
    mapController.animateCamera(CameraUpdate.newLatLng(latLng));

    // Save the marker to Firestore
    await firestore.collection('markers').doc(id).set({
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
      'title': title,
      'description': description,
      'dropdownvalue': dropdownValue,
    });

    setState(() {});
  }

}
