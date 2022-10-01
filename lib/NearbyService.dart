import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'package:image_picker/image_picker.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:path_provider/path_provider.dart';

enum NearbyState { isIdle, isAdvertising, isDiscovering, isConnected }

class NearbyService with ChangeNotifier {
  static final NearbyService _instance = NearbyService._internal();
  factory NearbyService() => _instance;
  NearbyService._internal();
  
  NearbyState nearbyState = NearbyState.isIdle;
  final Strategy strategy = Strategy.P2P_STAR;
  final String userName = Random().nextInt(10000).toString();
  
  Map<String, String> foundDevices = {};
  // Map<String, ConnectionInfo> connectedDevices = {};
  ConnectionInfo? connectedDevice;
  // PageController pageController = PageController();
  
  Map<String, dynamic> payload = {};
  
  // NearbyService.page(PageController pageController) {
  //   addListener(() {
  //     if(payload.containsKey('type')) {
  //       // pageController.jumpToPage();
  //     }
  //   });
  // }
  
  Future<bool> requestPermissions() async {
    if(!await Nearby().checkLocationPermission()) { await Nearby().askLocationPermission(); }
    if(!await Nearby().checkExternalStoragePermission()) { Nearby().askExternalStoragePermission(); }
    if(!await Nearby().checkBluetoothPermission()) { Nearby().askBluetoothPermission(); }
    if(!await Nearby().checkLocationPermission()) { await Nearby().askLocationPermission(); }
    if(!await Nearby().checkLocationEnabled()) { await Nearby().enableLocationServices(); }
    
    if(await Nearby().checkLocationPermission() && await Nearby().checkExternalStoragePermission() && await Nearby().checkBluetoothPermission() && await Nearby().checkLocationEnabled()) {
      return true;
    } else {
      return false;
    }
  }
  
  Future<String> startDiscovery() async {
    try {
      bool a = await Nearby().startDiscovery(
        userName,
        strategy,
        onEndpointFound: (id, name, serviceId) {
          if (
            foundDevices.containsKey(id) 
            // || connectedDevices.containsKey(id)
            || connectedDevice?.endpointName == id
            ) return;
          foundDevices[id] = name;
          developer.log('Found device: $name');
          notifyListeners();
        },
        onEndpointLost: (id) {
          foundDevices.remove(id);
          notifyListeners();
        },
      );
      return a.toString();
    } catch (e) {
      return e.toString();
    }
  }
  
  Future<bool> requestConnection(String key, String response) async {
    Nearby().requestConnection(
      userName,
      key,
      onConnectionInitiated: (id, info) async {
        // connectedDevices[id] = info;
        connectedDevice = info;
        notifyListeners();
        bool b = await acceptConnection(id);
        if(b) {
          Nearby().sendBytesPayload(id, Uint8List.fromList(utf8.encode(jsonEncode(response))));
        }
      },
      onConnectionResult: (id, status) {
        if(status == Status.CONNECTED) {
          connectedDevice?.endpointName = id;
        } else {
          connectedDevice = null;
        }
        notifyListeners();
      },
      onDisconnected: (id) {
        // connectedDevices.remove(id);
        connectedDevice = null;
        notifyListeners();
      },
    );
    return true;
  }
  
  Future<bool> acceptConnection(
      String id,
      [String form = ""]
    ) async {
    await Nearby().acceptConnection(
      id,
      onPayLoadRecieved: (endid, pload) async {
        if (pload.type == PayloadType.BYTES) {
          String str = String.fromCharCodes(pload.bytes!);
          payload = jsonDecode(str);
          notifyListeners();
          
          if(nearbyState == NearbyState.isAdvertising && !payload.containsKey('type')) {
            await Nearby().sendBytesPayload(id, Uint8List.fromList(utf8.encode(jsonEncode(form))));
          }
        } else if (pload.type == PayloadType.FILE) {
          // tempFileUri = payload.uri;
        }
      },
      onPayloadTransferUpdate: (endid, payloadTransferUpdate) async {
        
      },
    );
    return true;
  }
  
  Future<bool> sendPayload(dynamic payload) async {
    if(connectedDevice != null) {
      String s;
      if (payload is String) {
        s = payload;
      } else if (payload is Map) {
        s = jsonEncode(payload);
      } else {
        return false;
      }
      await Nearby().sendBytesPayload(connectedDevice!.endpointName, Uint8List.fromList(utf8.encode(s)));
      return true;
    } else {
      return false;
    }
  }
  
  // void pageCon() {
  //   if(payload.containsKey('type') && pageController.hasClients) {
  //     // pageController.jumpToPage();
  //   }
  // }
}