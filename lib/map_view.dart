import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighbor_nexus/map_icon.dart';
import 'package:provider/provider.dart';
import 'package:neighbor_nexus/firebase/auth_provider.dart';

bool isEventMoreThan12HoursAgo(DateTime eventDateTime) {
  DateTime now = DateTime.now();
  Duration difference = now.difference(eventDateTime);
  return difference.inHours > 12;
}

class EventMap extends StatefulWidget {
  const EventMap({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EventMapState createState() => _EventMapState();
}

class _EventMapState extends State<EventMap> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final CollectionReference events =
      FirebaseFirestore.instance.collection('events');

  @override
  void initState() {
    super.initState();
    _initialization.then((value) {
      _retrieveEventsFromFirebase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            body: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              markers: markers,
              onLongPress: _addEventDialog,
              initialCameraPosition: const CameraPosition(
                target: LatLng(43.814189, -111.785021),
                zoom: 14.4746,
              ),
            ),
          );
        }

        return const CircularProgressIndicator();
      },
    );
  }

  void _retrieveEventsFromFirebase() {
    events.get().then((querySnapshot) {
      for (var document in querySnapshot.docs) {
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

        _addEventToMap(LatLng(event.latitude, event.longitude), event);
      }
    });
  }

  void _addEventToMap(LatLng latLng, Event event) {
    if (!isEventMoreThan12HoursAgo(event.dateTime)) {
      BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(), MapIcon.getGraphic(event.eventType))
          .then((BitmapDescriptor icon) {
        if (markers.any((marker) => marker.position == latLng)) {
          return; // Event with the same LatLng already exists, do not add it again
        }
        setState(() {
          markers.add(
            Marker(
              markerId: MarkerId(event.eventId),
              position: latLng,
              infoWindow:
                  InfoWindow(title: event.title, snippet: event.description),
              icon: icon,
              onTap: () {
                _showEventPopup(event, context);
              },
            ),
          );
        });
      });
    }
    ;
  }

  void _addEventDialog(LatLng latLng) {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    const List<String> eventTypes = <String>[
      "Party",
      "Sale",
      "Help",
      "Ride-Share",
      "Other"
    ];
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
                    items: eventTypes
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  Text(
                      'Selected Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                  Text('Selected Time: ${selectedTime.format(context)}'),
                  ElevatedButton(
                    child: const Text('Select Date and Time'),
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        // ignore: use_build_context_synchronously
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
                  var event = Event(
                    eventId: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    dateTime: selectedDate,
                    description: descriptionController.text,
                    latitude: latLng.latitude,
                    longitude: latLng.longitude,
                    eventType: selectedEventType,
                    userId: userID,
                  );
                  _addEventToMap(
                    latLng,
                    event,
                  );
                  events.add(event.toMap());
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

void _showEventPopup(Event event, context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return EventPopup(event: event);
    },
  );
}
