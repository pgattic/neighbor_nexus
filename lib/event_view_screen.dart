import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:neighbor_nexus/chat_screen.dart';
import 'package:neighbor_nexus/firebase/auth_provider.dart';
import 'package:provider/provider.dart';

class EventDetailPage extends StatelessWidget {
  final Event event; // Event object
  



  EventDetailPage({
    required this.event,
  });
  
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final isCurrentUserEventCreator = event.userId == user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(event.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Date and Time: ${event.dateTime.toString()}'),
                Text('User ID: ${event.userId}'),
              ],
            ),
          ),
          // Add any other event details you want to display here

          if (!isCurrentUserEventCreator)
            Expanded(
              child: ChatScreen(recipientUid: event.userId,), // Show the chat screen if the user is not the event creator
            )
          else
            ElevatedButton(
              onPressed: () {
                // Delete event logic here
                onDeleteEvent(event,context);
              },
              child: Text('Delete Event'),
            ),
        ],
      ),
    );
  }
}

void onDeleteEvent(event,context) {
  // Assuming you have a reference to your Firestore collection
  final CollectionReference eventsCollection = FirebaseFirestore.instance.collection('events');

  // Replace 'event.eventId' with the actual identifier you use for your events
  final eventDocRef = eventsCollection.doc(event.eventId);

  eventDocRef.delete().then((_) {
    // Event successfully deleted, you can navigate back to the previous screen or perform other actions
    Navigator.pop(context);
  }).catchError((error) {
    // Handle any errors that occur during the delete process
    print('Error deleting event: $error');
  });
}