<<<<<<< HEAD
// import 'dart:async';
// import 'dart:collection';
// import 'dart:js_util';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
=======
import 'dart:async';
import 'dart:collection';
import 'dart:js_util';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_view/map_view.dart';
>>>>>>> eab997061f306291832c11b8126d5cc007823996


// class Event {
//   String name;
//   String location;
//   DateTime time;
//   String explanation;

//   Event (this.name, this.location, this.time, this.explanation);
// }

<<<<<<< HEAD
// class EventManager {
//   List<Event> events = [];
=======
  StreamController<Event>
  eventController = StreamController.broadcast();
>>>>>>> eab997061f306291832c11b8126d5cc007823996

//   StreamController<Event>
//   eventController = new
//   StreamController.broadcast();

//   void addEvent (Event event)
//   {
//     events.add (event);

<<<<<<< HEAD
//     eventController.add(event);
//   }

//   Stream<Event> get
//   eventStream =>
//   eventController.stream;
// }
=======
  Stream<Event> get
  eventStream =>
  eventController.stream;

  void dispose() {
    eventController.close();
  }
}

class MapViewWidget extends
StatefulWidget{
  @override
  _MapViewWidgetState createState() =>_MapViewWidgetState();
}
>>>>>>> eab997061f306291832c11b8126d5cc007823996

// class MapViewWidget extends
// StatefulWidget{
//   const MapViewWidget({super.key});

//   @override
//   _MapViewWidgetStatecreateState() =>_MapViewWidgetState();
  
//   @override
//   State<StatefulWidget> createState() {
//     // TODO: implement createState
//     throw UnimplementedError();
//   }
// }

<<<<<<< HEAD
// class _MapViewWidgetState extends State<MapViewWidget>
// {
//   MapView mapView = new MapView();
=======
  @override
  void dispose() {
  eventManager.dispose();
  super.dispose();
  }
  @override
  void initState() {
    super.initState();
>>>>>>> eab997061f306291832c11b8126d5cc007823996

//   EventManager eventManager = new EventManager();

//   @override void initState() {
//     super.initState();

<<<<<<< HEAD
//     mapView.show(MapOptions(
//       showUserLocation:true,

//       initialCameraPosition: CameraPosition(new Location (43.491651, -112.033964),//Rexburg, Idaho
//       15.0, target: null,),
//       title: "Map View",
//     ),
//     );

//     eventManager.eventStream.listen((event) {
//       mapView.addMarker(
//         new Marker (
//           event.name,
//           event.explanation,
//           event.location.latitude,
//           event.location.longitude,
//           icon:Colors.red,
//         ),
//       );
//     });
//   }
//   @override
//   Widget build (BuildContext context) {
//     return Scaffold(
//       appBar: AppBar (title: Text ("Map View Widget"),),
//       body: Center(child: Text ("This is a placeholder for the map view"),),
//       floatingActionButton: FloatingActionButton (
//         onPressed: () {
//           //a sample event
//           Event sampleEvent = Event(
//             "Sample Event", new Location(43.491651, -112.033964) as String, DateTime.now(), "This is a sample event",
//           );
//           eventManager.addEvent(sampleEvent);
=======
    eventManager.eventStream.listen((event) {
      mapView.addMarker(
        new Marker (
          event.name,
          event.explanation,
          event.location.latitude,
          event.location.longitude,
          color:Colors.red,
        ),
      );
    });
  }
  @override
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar (title: Text ("Map View Widget"),),
      body: Center(child: Text ("This is a placeholder for the map view"),),
      floatingActionButton: FloatingActionButton (
        onPressed: () {
          //a sample event
          Event sampleEvent = new Event(
            "Sample Event", new Location(43.491651, -112.033964), DateTime.now(), "This is a sample event",
          );
          eventManager.addEvent(sampleEvent);
>>>>>>> eab997061f306291832c11b8126d5cc007823996
      
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }

// class Location {
//   Location(double d, double e);
// }

// class MapOptions {
// }
