import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class AddCrimeLocation extends StatefulWidget {
  final LatLng currentLatLng;

  AddCrimeLocation({this.currentLatLng});

  @override
  _AddCrimeLocationState createState() => _AddCrimeLocationState();
}

class _AddCrimeLocationState extends State<AddCrimeLocation> {
  Completer<GoogleMapController> mapController = Completer();
  final Set<Marker> markers = Set();
  final db = Firestore.instance;

  LatLng newCrimeLocation;
  LatLng crimeLocFromDB;

  int reportNumberFromDB;
  int finalReportNumber;

  void onMapCreated(GoogleMapController controller) {
    this.mapController.complete(controller);
    moveToCurrentUserLocation();
  }

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    markers.add(Marker(
      position: widget.currentLatLng,
      markerId: MarkerId("selected-location"),
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(width: 750, height: 1334, allowFontScaling: true);



    return Scaffold(
      appBar: AppBar(
        title: Text('Add Crime Location'),
        centerTitle: true,
        backgroundColor: Color(0xFFE85D09),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: widget.currentLatLng,
                zoom: 15,
              ),
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              onMapCreated: onMapCreated,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onTap: (latLng) {
                moveToLocation(latLng);
                setState(() {
                  newCrimeLocation = latLng;
                });
              },
              markers: markers,
            ),
          ),
          Positioned(
            left: 35,
            right: 35,
            bottom: 35,
            child: FlatButton(
              onPressed: () async {
                await db.collection('crime_location').document(newCrimeLocation.toString()).setData({
                  'location': GeoPoint(newCrimeLocation.latitude, newCrimeLocation.longitude),
                  'report_number': FieldValue.increment(1),
                }, merge: true).whenComplete((){
                  Navigator.pop(context);
                }).catchError((onError){
                  print("onError");
                });
              },
              child: Text(
                'Add Location',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenUtil().setSp(30),
                  fontWeight: FontWeight.w400
                ),
              ),
              color: Color(0xFFE85D09),
            ),
          ),
        ],
      ),
    );
  }

  void setMarker(LatLng latLng) {
    setState(() {
      markers.clear();
      markers.add(Marker(markerId: MarkerId("selected-location"), position: latLng));
    });
  }

  void moveToLocation(LatLng latLng) {
    this.mapController.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: latLng, zoom: 15.0)),
      );
    });

    newCrimeLocation = latLng;
    setMarker(latLng);
  }

  void moveToCurrentUserLocation() {
    /*if (widget.currentLatLng != null) {
      moveToLocation(widget.currentLatLng);
      return;
    }*/

    Location().getLocation().then((locationData) {
      LatLng target = LatLng(locationData.latitude, locationData.longitude);
      moveToLocation(target);
    }).catchError((error) {
      print(error);
    });
  }
}