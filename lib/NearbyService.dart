import 'dart:math';

import 'package:image_picker/image_picker.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:path_provider/path_provider.dart';

enum NearbyState { isIdle, isAdvertising, isDiscovering, isConnected }

class NearbyService {
  static final NearbyService _instance = NearbyService._internal();
  factory NearbyService() => _instance;
  NearbyService._internal();
  
  NearbyState nearbyState = NearbyState.isIdle;
  final Strategy strategy = Strategy.P2P_STAR;
  final String userName = Random().nextInt(10000).toString();
  
  Map<String, String> foundDevices = {};
  Map<String, ConnectionInfo> connectedDevices = {};
  Map<int, String> map = {};
  List<String> messages = [];
  
  List<bool> permissions = [false, false, false, false];
  
  void checkPermissions() async {
    permissions[0] = await Nearby().checkLocationPermission();
    permissions[1] = await Nearby().checkExternalStoragePermission();
    permissions[2] = await Nearby().checkBluetoothPermission();
    permissions[3] = await Nearby().checkLocationPermission() && await Nearby().checkLocationEnabled();
  }
  
  void requestPermissions() async {
    await Nearby().askLocationPermission();
    Nearby().askExternalStoragePermission();
    Nearby().askBluetoothPermission();
    await Nearby().askLocationPermission();
  }
  
  void enableLocation() async {
    permissions[3] = await Nearby().checkLocationEnabled();
    if (!permissions[3]) {
      await Nearby().enableLocationServices();
    }
  }
}