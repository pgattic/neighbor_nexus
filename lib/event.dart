import 'dart:async';
import 'dart:collection';
import 'dart:js_util';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_view/map_view.dart';

class Event {
  String name;
  Location location;
  DateTime time;
  String explanation;

  Event (this.name, this.location, this.time, this.explanation);
}

class EventManager {
  List<Event> events = [];

  StreamController<Event>
  eventController = StreamController.broadcast();

  void addEvent (Event event)
  {
    events.add (event);

    eventController.add(event);
  }

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

class _MapViewWidgetState extends State<MapViewWidget>
{
  MapView mapView = new MapView();

  EventManager eventManager = new EventManager();

  @override
  void dispose() {
  eventManager.dispose();
  super.dispose();
  }
  @override
  void initState() {
    super.initState();

    mapView.show(new MapOptions(
      showUserLocation:true,

      initialCameraPosition: new CameraPosition(new Location (43.491651, -112.033964),//Rexburg, Idaho
      15.0,),
      title: "Map View",
    ),
    );

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
      
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
