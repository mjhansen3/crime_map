import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Map extends StatefulWidget{
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map>{
  Completer<GoogleMapController> mapController = Completer();
  BitmapDescriptor _markerIcon;
  List<Marker> locationMarkers = [];

  var crimeMarkers = [];
  //bool crimeMarkersToggle;
  bool loadingMap = false;


  static final CameraPosition _initPosition = CameraPosition(
    target: LatLng(5.55602, -0.1969),
    zoom: 15,
  );

  void onMapCreated(GoogleMapController controller) {
    this.mapController.complete(controller);
    moveToCurrentUserLocation();
  }

  @override
  void initState() {
    super.initState();
    //moveToCurrentUserLocation();
    /*setState(() {
      loadingMap = true;
      crimeLocations();
    });*/
  }

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  /*crimeLocations() {
    crimeMarkers = [];
    Firestore.instance.collection('crime_location').getDocuments().then((snapshot) {
      if(snapshot.documents.isNotEmpty) {
        setState(() {
          loadingMap = false;
          crimeMarkersToggle = true;
        });

        for(int i = 0; i < snapshot.documents.length; i++) {
          crimeMarkers.add(snapshot.documents[i].data);
          initCrimeMarkers(snapshot.documents[i].data);
        }
      }
    });
  }

  initCrimeMarkers(crimeMarkers) {
    crimeMarkers.clearMarkers().then((val) {
      crimeMarkers.addMarkers(
        Marker(
          markerId: null,
          position: LatLng(
            crimeMarkers['location'].latitude,
            crimeMarkers['location'].longitude,
          ),
          draggable: false,
          icon: _markerIcon,
          infoWindow: InfoWindow(
              title: "${crimeMarkers['report_number']}",
          ),
        ),
      );
    });
  }*/

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(width: 750, height: 1334, allowFontScaling: true);
    _createMarkerImageFromAsset(context);

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: loadingMap ? Center(
        child: CircularProgressIndicator(),
      ) : GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initPosition,
        myLocationButtonEnabled: false,
        myLocationEnabled: true,
        onMapCreated: onMapCreated,
        zoomGesturesEnabled: true,
        //markers: _createMarker(locationMarkers),
      ),
    );
  }

  /*Widget loadCrimeLocations() {
    return StreamBuilder(
      stream: Firestore.instance.collection('crime_location').snapshots(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return Flushbar(
            title:  "Error",
            message:  "Error occurred, no crime data found.",
            margin: EdgeInsets.all(8),
            borderRadius: 8,
            flushbarStyle: FlushbarStyle.FLOATING,
            duration:  Duration(seconds: 3),
          )..show(context);
        }

        for(int i = 0; i < snapshot.data.documents.length; i++) {
          Set<Marker> location = locationMarkers
              .map((e) {
                  Marker(
                    markerId: MarkerId(snapshot.data.documents[i]['crime_location'].uid),
                    position: snapshot.data.documents[i]['crime_location'].location,
                    /*infoWindow: InfoWindow(
                    title: event["title"],
                    onTap: () {},
                  ),*/
                    icon: _markerIcon,
                  );
                }
          ).toSet();
        }

        return GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _initPosition,
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
          onMapCreated: onMapCreated,
          zoomGesturesEnabled: true,
          markers: _createMarker(locationMarkers),
        );
      },
    );
  }*/

  Set<Marker> _createMarker(locationMarkers) {
    Set<Marker> location = locationMarkers
        .map(
          Firestore.instance.collection('crime_location').getDocuments().then((snapshot) {
            if(snapshot.documents.isNotEmpty) {
              setState(() {
                loadingMap = false;
                //crimeMarkersToggle = true;
              });

              for(int i = 0; i < snapshot.documents.length; i++) {
                Marker(
                  markerId: MarkerId(snapshot.documents[i]['crime_location'].uid),
                  position: snapshot.documents[i]['crime_location'].location,
                  icon: _markerIcon,
                );
              }
            }
          })
    ).toSet();

    return location;
  }

  Future<void> _createMarkerImageFromAsset(BuildContext context) async {
    ScreenUtil.init(width: 750, height: 1334, allowFontScaling: true);
    if (_markerIcon == null) {
      final ImageConfiguration imageConfiguration =
      createLocalImageConfiguration(context);
      BitmapDescriptor.fromAssetImage(
        imageConfiguration,
        'assets/img/marker.png',
      ).then(_updateBitmap);
    }
  }

  void _updateBitmap(BitmapDescriptor bitmap) {
    setState(() {
      _markerIcon = bitmap;
    });
  }

  void moveToLocation(LatLng latLng, double zoom) {
    this.mapController.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: latLng,
            zoom: zoom,
          ),
        ),
      );
    });
  }

  void moveToCurrentUserLocation() {
    var location = Location();
    location.getLocation().then((locationData) {
      LatLng target = LatLng(locationData.latitude, locationData.longitude);
      moveToLocation(target, 15.0);
    }).catchError((error) {
      print(error);
    });
  }
}