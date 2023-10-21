// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class EventInfoWindow extends StatefulWidget {
//   final String eventId;
//   final String ownerId;
//   final String visitorId;

//   EventInfoWindow(this.eventId, this.ownerId, this.visitorId);

//   @override
//   State<EventInfoWindow> createState() => _EventInfoWindowState();
// }

// class _EventInfoWindowState extends State<EventInfoWindow> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Event Information'),
//       ),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance.collection('events').doc(widget.eventId).snapshots(),
//         builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }

//           var eventData = snapshot.data.data();
//           String title = eventData['title'];
//           String description = eventData['description'];
//           DateTime dateTime = eventData['dateTime'].toDate(); // Convert Firebase timestamp to DateTime
//           String eventType = eventData['eventType'];
//           double latitude = eventData['latitude'];
//           double longitude = eventData['longitude'];

//           return SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Title: $title'),
//                 Text('Description: $description'),
//                 Text('Date & Time: $dateTime'),
//                 Text('Event Type: $eventType'),
//                 Text('Latitude: $latitude'),
//                 Text('Longitude: $longitude'),
//                 if (widget.ownerId == widget.visitorId)
//                   Column(
//                     children: [
//                       // Add widgets for editing description, date, and time here
//                     ],
//                   )
//                 else
//                   ElevatedButton(
//                     onPressed: () {
//                       // Update the user's subscribedEvents list in Firebase
//                       FirebaseFirestore.instance.collection('users').doc(widget.visitorId).update({
//                         'subscribedEvents': FieldValue.arrayUnion([widget.eventId])
//                       });
//                     },
//                     child: Text('Subscribe to Event'),
//                   )
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventInfoWindow extends StatefulWidget {
  final String eventId;
  final String userId;
  final String user;

  EventInfoWindow(this.eventId, this.userId, this.user);

  @override
  _EventInfoWindowState createState() => _EventInfoWindowState();
}

class _EventInfoWindowState extends State<EventInfoWindow> {
  CollectionReference events = FirebaseFirestore.instance.collection('events');
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  DocumentSnapshot? eventData;

  TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDate;


  @override
  void initState() {
    super.initState();
    fetchEvent();
  }

  fetchEvent() async {
    eventData = await events.doc(widget.eventId).get();
    descriptionController.text = eventData!["description"];
    selectedDate = (eventData!["dateTime"] as Timestamp).toDate();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (eventData == null) {
      return Center(child: CircularProgressIndicator());
    }

    if (widget.userId == widget.user) {
      return Scaffold(
        appBar: AppBar(title: Text(eventData!["title"])),
        body: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text('Title: ${eventData!["title"]}'),
            Text('Description: ${eventData!["description"]}'),
            Text('Date & Time: ${selectedDate.toString()}'),
            Text('Event Type: ${eventData!["eventType"]}'),
            Text('Latitude: ${eventData!["latitude"]}'),
            Text('Longitude: ${eventData!["longitude"]}'),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            ElevatedButton(
              child: Text("Update Event"),
              onPressed: () async {
                await events.doc(widget.eventId).update({
                  "description": descriptionController.text,
                  //... add other fields to be updated here
                });
                // Add user feedback, for example:
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Event updated successfully")));
              },
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text(eventData!["title"])),
        body: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text('Title: ${eventData!["title"]}'),
            Text('Description: ${eventData!["description"]}'),
            Text('Date & Time: ${selectedDate.toString()}'),
            Text('Event Type: ${eventData!["eventType"]}'),
            Text('Latitude: ${eventData!["latitude"]}'),
            Text('Longitude: ${eventData!["longitude"]}'),
            ElevatedButton(
              child: Text("Subscribe"),
              onPressed: () async {
                await users.doc(widget.user).update({
                  "subscribedEvents": FieldValue.arrayUnion([widget.eventId])
                });
                // Add user feedback, for example:
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Subscribed to event")));
              },
            )
          ],
        ),
      );
    }
  }
}