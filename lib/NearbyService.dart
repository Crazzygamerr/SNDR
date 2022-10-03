import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'package:image_picker/image_picker.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:path_provider/path_provider.dart';

enum NearbyState { isIdle, isAdvertising, isDiscovering }

class NearbyService with ChangeNotifier {
  static final NearbyService _instance = NearbyService._internal();
  factory NearbyService() => _instance;
  NearbyService._internal();
  
  // NearbyState nearbyState = NearbyState.isIdle;
  bool isAdvertising = false, isDiscovering = false;
  final Strategy strategy = Strategy.P2P_STAR;
  final String userName = Random().nextInt(10000).toString();
  
  Map<String, String> foundDevices = {};
  Map<String, ConnectionInfo> connectedDevices = {};
  // ConnectionInfo? connectedDevice;
  List<Map<String, dynamic>> payloads = [{}];
  
  Exception? error;
  bool errorHandled = false;
  
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
      await Nearby().stopDiscovery();
      bool a = await Nearby().startDiscovery(
        userName,
        strategy,
        onEndpointFound: (id, name, serviceId) {
          if (
            foundDevices.containsKey(id) 
            || connectedDevices.containsKey(id)
            // || connectedDevices?.endpointName == id
            ) return;
          foundDevices[id] = name;
          notifyListeners();
        },
        onEndpointLost: (id) {
          foundDevices.remove(id);
          notifyListeners();
        },
      );
      isDiscovering = a;
      foundDevices = {};
      notifyListeners();
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
        connectedDevices[id] = info;
        // connectedDevice = info;
        notifyListeners();
        bool b = await acceptConnection(id);
        if(!b) {
          throw Exception('Connection failed');
        }
      },
      onConnectionResult: (id, status) async {
        if(status == Status.CONNECTED) {
          // connectedDevice?.endpointName = id;
          connectedDevices[id]?.endpointName = id;
          await Nearby().sendBytesPayload(id, Uint8List.fromList(utf8.encode(jsonEncode(response))));
          if(response.contains('type')) {
            // payloads.removeAt(0);
            payloads[0]["sent"] = true;
          }
          notifyListeners();
        } else {
          // connectedDevice = null;
          // developer.log(status.toString());
          connectedDevices.remove(id);
        }
        notifyListeners();
      },
      onDisconnected: (id) {
        connectedDevices.remove(id);
        // connectedDevice = null;
        notifyListeners();
      },
    ).catchError((e){
      connectedDevices.remove(key);
      // connectedDevice = null;
      error = e;
      errorHandled = false;
      notifyListeners();
      return false;
    });
    return true;
  }
  
  Future<bool> startAdvertising(Map<String, dynamic> form) async {
    await Nearby().stopAdvertising();
    try {
      await Nearby().stopAdvertising();
      bool a = await Nearby().startAdvertising(
        userName,
        strategy,
        onConnectionInitiated: (id, info) async {
          connectedDevices[id] = info;
          // connectedDevice = info;
          notifyListeners();
          await acceptConnection(id, jsonEncode(form));
        },
        onConnectionResult: (id, status) async {
          if(status == Status.CONNECTED) {
            // connectedDevice?.endpointName = id;
            connectedDevices[id]?.endpointName = id;
          } else {
            // connectedDevice = null;
            connectedDevices.remove(id);
          }
          notifyListeners();
        },
        onDisconnected: (id) {
          connectedDevices.remove(id);
          // connectedDevice = null;
          notifyListeners();
        },
      );
      isAdvertising = a;
      notifyListeners();
      return a;
    } catch (e) {
      return false;
    }
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
            // developer.log(str);
            var payload = jsonDecode(jsonDecode(str));
            // developer.log();
            if(payload.containsKey('content')) {
              payload["device_id"] = endid;
              // if(payloads[0].containsKey('type')) {
              //   payloads.insert(0, payload);
              // } else {
              //   payloads[0] = payload;
              // }
              payloads[0] = payload;
              notifyListeners();
            } else if(isAdvertising){
              await Nearby().sendBytesPayload(id, Uint8List.fromList(utf8.encode(jsonEncode(form))));
            }
            if(isDiscovering){
              await Nearby().disconnectFromEndpoint(id);
              connectedDevices.remove(id);
              notifyListeners();
            }
            // if(nearbyState == NearbyState.isDiscovering) {
            //   await Nearby().disconnectFromEndpoint(id);
            // }
            // if(nearbyState == NearbyState.isAdvertising && !payload.containsKey('type')) {
            //   await Nearby().sendBytesPayload(id, Uint8List.fromList(utf8.encode(jsonEncode(form))));
            // }
          } else if (pload.type == PayloadType.FILE) {
            // tempFileUri = payload.uri;
          }
        },
        onPayloadTransferUpdate: (endid, payloadTransferUpdate) async {
          // developer.log(payloadTransferUpdate.status.toString());
        },
      ).catchError((e) {
        connectedDevices.remove(id);
        error = e;
        errorHandled = false;
        notifyListeners();
        return false;
      });
      return true;
  }
  
  Future<void> stopAdvertising() async {
    await Nearby().stopAdvertising();
    isAdvertising = false;
    notifyListeners();
  }
  
  Future<void> stopDiscovery() async {
    await Nearby().stopDiscovery();
    isDiscovering = false;
    foundDevices = {};
    notifyListeners();
  }
  
  Future<void> disconnectFromEndpoint(String id) async {
    await Nearby().disconnectFromEndpoint(id);
    connectedDevices.remove(id);
    notifyListeners();
  }
  
  Future<void> stopAllEndpoints() async {
    await Nearby().stopAllEndpoints();
    connectedDevices = {};
    notifyListeners();
  }
  
  // Future<bool> sendPayload(dynamic payload) async {
  //   if(connectedDevice != null) {
  //     String s;
  //     if (payload is String) {
  //       s = payload;
  //     } else if (payload is Map) {
  //       s = jsonEncode(payload);
  //     } else {
  //       return false;
  //     }
  //     await Nearby().sendBytesPayload(connectedDevice!.endpointName, Uint8List.fromList(utf8.encode(s)));
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }
  
}
