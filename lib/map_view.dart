import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventMap extends StatefulWidget {
  @override
  _EventMapState createState() => _EventMapState();
}

class _EventMapState extends State<EventMap> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};

  // Firebase setup
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  CollectionReference events = FirebaseFirestore.instance.collection('events');

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
              onLongPress: (LatLng latLng) {
                _addEventDialog(latLng);
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.42796133580664, -122.085749655962),
                zoom: 14.4746,
              ),
            ),
          );
        }

        return CircularProgressIndicator(); // Loading indicator until Firebase is initialized
      },
    );
  }

  void _addEventDialog(LatLng latLng) {
    final TextEditingController title = TextEditingController();
    final TextEditingController description = TextEditingController();
    const List<String> list = <String>['One', 'Two', 'Three', 'Four'];
    var dropdownValue = list[0];
    var newEvent = EventDetails();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return AlertDialog(
        //   title: Text('Add Event'),
        //   content: EventInputDialog(latLng: latLng),
        //   actions: <Widget>[
        //     TextButton(
        //       onPressed: () {
        //         final formState = context.findAncestorStateOfType<FormState>();
        //         if (formState != null && formState.validate()) {
        //           formState.save();
        //           _addEventToMap(latLng, EventDetails());
        //           Navigator.of(context).pop();
        //         }
        //       },
        //       child: Text('Add'),
        //     ),
        //   ],
        // );
        return AlertDialog(
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
              newEvent.title = title.text,
              newEvent.description = description.text,
              newEvent.eventType = dropdownValue,
              _addEventToMap(latLng, newEvent),
              Navigator.pop(context, 'OK')
            },
            child: const Text('OK'),
          ),
        ],
      );
      },
    );
  }

  void _addEventToMap(LatLng latLng, EventDetails eventDetails) async {
    // Add the event to the map
    markers.add(
      Marker(
        markerId: MarkerId(latLng.toString()),
        position: latLng,
        infoWindow: InfoWindow(
          title: eventDetails.title,
          snippet: eventDetails.description,
        ),
        // Additional properties like title, snippet, icon, etc. can be added here
      ),
    );

    // Add the event to Firebase
    await FirebaseFirestore.instance.collection('events').add({
      'title': eventDetails.title,
      'description': eventDetails.description,
      'eventType': eventDetails.eventType,
//      'dateTime': eventDetails.dateTime,
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
    });

    setState(() {});
  }

  void _retrieveEventsFromFirebase() async {
    // Logic to retrieve events from Firebase and update the map accordingly
    QuerySnapshot querySnapshot = await events.get();

    querySnapshot.docs.forEach((doc) {
      // Extract necessary data
      String title = doc['title'];
      String description = doc['description'];
      String eventType = doc['eventType'];
//      DateTime dateTime = doc['dateTime'].toDate(); // Convert Timestamp to DateTime
      double latitude = doc['latitude'];
      double longitude = doc['longitude'];

      // Update the map accordingly
      markers.add(
        Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: title,
            snippet: description,
          ),
          // Additional properties like title, snippet, icon, etc. can be added here
        ),
      );
    });

    setState(() {});
  }
}

class EventDetails {
  late String title;
  late String description;
  late String eventType;
//  late DateTime dateTime;
}

class EventInputDialog extends StatefulWidget {
  final LatLng latLng;

  EventInputDialog({required this.latLng});

  @override
  _EventInputDialogState createState() => _EventInputDialogState();
}

class _EventInputDialogState extends State<EventInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final EventDetails eventDetails = EventDetails();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(labelText: 'Title'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
            onSaved: (value) {
              eventDetails.title = value!;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Description'),
            onSaved: (value) {
              eventDetails.description = value!;
            },
          ),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Event Type'),
            value: eventDetails.eventType,
            items: <String>['Meeting', 'Party', 'Other']
                .map<DropdownMenuItem<String>>(
              (String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              },
            ).toList(),
            onChanged: (String? newValue) {
              setState(() {
                eventDetails.eventType = newValue!;
              });
            },
            onSaved: (value) {
              eventDetails.eventType = value!;
            },
          ),
          // TextFormField(
          //   decoration: InputDecoration(labelText: 'Date and Time'),
          //   onTap: () async {
          //     DateTime? picked = await showDatePicker(
          //       context: context,
          //       initialDate: DateTime.now(),
          //       firstDate: DateTime.now(),
          //       lastDate: DateTime(2101),
          //     );
          //     if (picked != null) {
          //       TimeOfDay? time = await showTimePicker(
          //         context: context,
          //         initialTime: TimeOfDay.now(),
          //       );
          //       if (time != null) {
          //         setState(() {
          //           eventDetails.dateTime = DateTime(
          //             picked.year,
          //             picked.month,
          //             picked.day,
          //             time.hour,
          //             time.minute,
          //           );
          //         });
          //       }
          //     }
          //   },
          // ),
        ],
      ),
    );
  }
}
