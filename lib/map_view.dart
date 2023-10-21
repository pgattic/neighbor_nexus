import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:neighbor_nexus/firebase/auth_provider.dart';

// Placeholder for AuthProvider



class EventMap extends StatefulWidget {
  @override
  _EventMapState createState() => _EventMapState();
}

class _EventMapState extends State<EventMap> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final CollectionReference events = FirebaseFirestore.instance.collection('events');

  late String selectedMonth;
  late String selectedDay;
  late String selectedYear;
  late String selectedTime;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.done) {
          _retrieveEventsFromFirebase();
          return Scaffold(
            body: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              markers: markers,
              onLongPress: _addEventDialog,
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.42796133580664, -122.085749655962),
                zoom: 14.4746,
              ),
            ),
          );
        }

        return CircularProgressIndicator();
      },
    );
  }

  void _retrieveEventsFromFirebase() {
    events.get().then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        final eventData = document.data() as Map<String, dynamic>;
        final event = Event(
          eventId: eventData['eventId'],
          title: eventData['title'],
          dateTime: (eventData['dateTime'] as Timestamp).toDate(),
          description: eventData['description'],
          latitude: eventData['latitude'],
          longitude: eventData['longitude'],
          eventType: eventData['eventType'],
          userId: eventData['userId'],
        );
        setState(() {
          markers.add(
            Marker(
              markerId: MarkerId(event.eventId),
              position: LatLng(event.latitude, event.longitude),
              infoWindow: InfoWindow(title: event.title, snippet: event.description),
            ),
          );
        });
      });
    });
  }

  void _addEventToMap(LatLng latLng, Event event) {
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId(event.eventId),
          position: latLng,
          infoWindow: InfoWindow(title: event.title, snippet: event.description),
        ),
      );
    });
    events.add(event.toMap());
  }

void _addEventDialog(LatLng latLng) {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  const List<String> eventTypes = <String>['One', 'Two', 'Three', 'Four'];
  var selectedEventType = eventTypes[0];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      final user = Provider.of<AuthProvider>(context).user;
      final userID = user!.uid;
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("New Event"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
                DropdownButton<String>(
                  value: selectedEventType,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedEventType = newValue!;
                    });
                  },
                  items: eventTypes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Text('Selected Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                Text('Selected Time: ${selectedTime.format(context)}'),
                ElevatedButton(
                  child: Text('Select Date and Time'),
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          selectedDate = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                          selectedTime = pickedTime;
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addEventToMap(
                  latLng,
                  Event(
                    eventId: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    dateTime: selectedDate,
                    description: descriptionController.text,
                    latitude: latLng.latitude,
                    longitude: latLng.longitude,
                    eventType: selectedEventType,
                    userId: userID,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    },
  );
}
}