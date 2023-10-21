import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:neighbor_nexus/chat_screen.dart';
import 'package:neighbor_nexus/firebase/auth_provider.dart';
import 'package:provider/provider.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;

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
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.event, color: Colors.blue, size: 40.0),
              title: Text(
                event.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 10),
                  Text('Date and Time: ${event.dateTime.toString()}'),
                  SizedBox(height: 10),
                  Text('User ID: ${event.userId}'),
                ],
              ),
            ),
            SizedBox(height: 20),
            if (!isCurrentUserEventCreator)
              Expanded(
                child: ChatScreen(recipientUid: event.userId,),
              )
            else
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () => _confirmDelete(context, event),
                  child: Text('Delete Event'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Event"),
        content: Text("Are you sure you want to delete this event?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text("Delete"),
            onPressed: () {
              onDeleteEvent(event, context);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void onDeleteEvent(Event event, BuildContext context) {
    final CollectionReference eventsCollection = FirebaseFirestore.instance.collection('events');
    final eventDocRef = eventsCollection.doc(event.eventId);

    eventDocRef.delete().then((_) {
      Navigator.pop(context);
    }).catchError((error) {
      print('Error deleting event: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting event. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }
}