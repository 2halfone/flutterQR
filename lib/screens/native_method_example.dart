import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeMethodExample extends StatefulWidget {
  const NativeMethodExample({Key? key}) : super(key: key);

  @override
  State<NativeMethodExample> createState() => _NativeMethodExampleState();
}

class _NativeMethodExampleState extends State<NativeMethodExample> {
  static const platform = MethodChannel('com.example.qr_code_customizer/native');
  String _batteryLevel = 'Unknown battery level';
  Map<String, dynamic> _deviceInfo = {};

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level: $result%';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  Future<void> _getDeviceInfo() async {
    Map<String, dynamic> deviceInfo;
    try {
      final Map<dynamic, dynamic> result = await platform.invokeMethod('getDeviceInfo');
      deviceInfo = Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      deviceInfo = {"error": "Failed to get device info: ${e.message}"};
    }

    setState(() {
      _deviceInfo = deviceInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Native Method Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_batteryLevel),
            const SizedBox(height: 20),
            Text('Device Info: ${_deviceInfo.toString()}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getBatteryLevel,
              child: const Text('Get Battery Level'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _getDeviceInfo,
              child: const Text('Get Device Info'),
            ),
          ],
        ),
      ),
    );
  }
}