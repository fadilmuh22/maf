import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class MockTracking {
  static io.Socket? socket;

  static final MockTracking _mockTracking = MockTracking._internal();

  factory MockTracking() {
    initSocket();
    return _mockTracking;
  }

  MockTracking._internal();

  static Future<void> initSocket() async {
    try {
      socket = io.io('http://192.168.1.11:3700', <String, dynamic>{
        'transports': ['websocket'],
        'autoconnect': true,
      });

      socket!.connect();

      socket!.onConnect((data) => {print('Connect: ${socket!.id}')});
    } catch (e) {
      print(e.toString());
    }
  }

  static Future mockTracking() async {
    double startLng = 107.690513;

    Future.doWhile(() async {
      var coords = {'lat': -6.914593, 'lng': startLng};

      socket!.emit('position-change', jsonEncode(coords));
      print('lat: ${coords['lat']}, lng: ${coords['lng']}');

      startLng -= 0.000200;
      startLng = double.parse(startLng.toStringAsFixed(6));

      await Future.delayed(const Duration(seconds: 5));

      if (startLng < 107.64) {
        return false;
      }

      return true;
    });
  }

  static void onBackgroundStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    if (socket == null) {
      initSocket();
    }

    mockTracking();

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": 'fadil',
      },
    );
  }

  static bool onIosBackground(ServiceInstance service) {
    WidgetsFlutterBinding.ensureInitialized();
    print('FLUTTER BACKGROUND FETCH');

    return true;
  }

  static Future<void> initBackgroundService() async {
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onBackgroundStart,

        // auto start service
        autoStart: true,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: true,

        // this will be executed when app is in foreground in separated isolate
        onForeground: onBackgroundStart,

        // you have to enable background fetch capability on xcode project
        onBackground: onIosBackground,
      ),
    );
  }
}
