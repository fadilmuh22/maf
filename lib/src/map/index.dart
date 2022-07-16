import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:socket_io_client/socket_io_client.dart' as io;

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  static const routeName = '/map';

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late io.Socket socket;
  late Map<MarkerId, Marker> _markers;

  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _cameraPosition = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(37.43296265331129, -122.08832357078792),
    tilt: 59.440717697143555,
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _markers = <MarkerId, Marker>{};
    _markers.clear();

    initSocket();
  }

  Future<void> initSocket() async {
    try {
      socket = io.io('http://192.168.1.11:3700', <String, dynamic>{
        'transport': ['websocket'],
        'autoconnect': true,
      });
      socket.connect();
      socket.on('position-change', (data) async {
        var latlng = jsonDecode(data);
        final GoogleMapController controller = await _controller.future;

        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(latlng['lat'], latlng['lng']),
              zoom: 19,
            ),
          ),
        );

        Marker marker = Marker(
          markerId: const MarkerId('ID'),
          position: LatLng(latlng['lat'], latlng['lng']),
        );

        setState(() {
          _markers[const MarkerId('ID')] = marker;
        });
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _cameraPosition,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: Set<Marker>.of(_markers.values),
      ),
    );
  }
}
