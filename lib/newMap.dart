import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crime_map/addCrimeLocation.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:place_picker/place_picker.dart';

class NewMap extends StatefulWidget{
  @override
  _NewMapState createState() => _NewMapState();
}

class _NewMapState extends State<NewMap> {
  Completer<GoogleMapController> mapController = Completer();
  BitmapDescriptor _markerIcon;
  Set<Marker> crimeMarkers = HashSet<Marker>();
  LatLng target;
  //var crimeMarkers = [];

  int reportNumber;

  bool loadingMap = true;

  static final CameraPosition _initPosition = CameraPosition(
    target: LatLng(5.55602, -0.1969),
    zoom: 15,
  );

  void onMapCreated(GoogleMapController controller) {
    this.mapController.complete(controller);
    moveToCurrentUserLocation();
    //showCrimeLocations();
  }

  @override
  void initState() {
    super.initState();
  }

  showCrimeLocations() {
    Firestore.instance.collection('crime_location').getDocuments().then((snapshot) {
      if(snapshot.documents.isNotEmpty) {
        setState(() {
          loadingMap = false;
        });
        for(int i = 0; i < snapshot.documents.length; i++) {
          setState(() {
            reportNumber = snapshot.documents[i].data['report_number'];

            crimeMarkers.add(
              Marker(
                  markerId: MarkerId(snapshot.documents[i].documentID),
                  position: LatLng(
                    snapshot.documents[i].data['location'].latitude,
                    snapshot.documents[i].data['location'].longitude,
                  ),
                  icon: reportNumber < 5 ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
                      : reportNumber >= 5 && reportNumber < 20 ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)
                      : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  infoWindow: InfoWindow(
                    title: 'C.R: $reportNumber',
                  )
              ),
            );
          });
        }
      }
    });

    return crimeMarkers;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(width: 750, height: 1334, allowFontScaling: true);
    _createMarkerImageFromAsset(context);

    setState(() {});

    return Stack(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initPosition,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            onMapCreated: onMapCreated,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            markers: showCrimeLocations(),
          ),
        ),
        Positioned(
          bottom: 15,
          right: 15,
          child: FloatingActionButton(
            heroTag: 'addCrimeLocation',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    print("Target Coordinate to be sent: $target");

                    return AddCrimeLocation(
                      currentLatLng: target,
                    );
                  },
                )
              );
              //showPlacePicker(context);
            },
            backgroundColor: Color(0xFFE85D09),
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          )
        ),
        Positioned(
            bottom:85,
            right: 15,
            child: FloatingActionButton(
              heroTag: 'myLocation',
              onPressed: () {
                moveToCurrentUserLocation();
              },
              backgroundColor: Color(0xFFFFFFFF),
              child: Icon(
                Icons.my_location,
                color: Colors.black45,
              ),
            )
        ),
      ],
    );
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
      setState(() {
        loadingMap = false;
        target = LatLng(locationData.latitude, locationData.longitude);
        //showCrimeLocations();
      });

      print("Target coordinates: $target");

      moveToLocation(target, 15.0);
    }).catchError((error) {
      print(error);
    });
  }
}