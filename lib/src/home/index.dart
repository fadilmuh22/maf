import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:maf/src/map/index.dart';
import 'package:maf/src/mock_tracking.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static const routeName = '/';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _stopBackgroundText = 'Stop Tracking';

  @override
  void initState() {
    super.initState();

    MockTracking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ElevatedButton(
            child: Text(_stopBackgroundText),
            onPressed: () async {
              final service = FlutterBackgroundService();
              var isRunning = await service.isRunning();
              if (isRunning) {
                service.invoke("stopService");
              } else {
                service.startService();
              }

              if (!isRunning) {
                _stopBackgroundText = 'Stop Tracking';
              } else {
                _stopBackgroundText = 'Start Service';
              }
              setState(() {});
            },
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, MapPage.routeName);
            },
            child: const Text('Map'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    MockTracking.socket!.disconnect();
  }
}
