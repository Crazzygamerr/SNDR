import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:path_provider/path_provider.dart';

// enum ExchangeType { none, form, share }

class NearbyService with ChangeNotifier {
  static final NearbyService _instance = NearbyService._internal();
  factory NearbyService() => _instance;
  NearbyService._internal();
  
  // ExchangeType exchangeType = ExchangeType.none;
  bool isAdvertising = false, isDiscovering = false;
  final Strategy strategy = Strategy.P2P_STAR;
  final String userName = Random().nextInt(10000).toString();
  
  Map<String, String> foundDevices = {};
  Map<String, ConnectionInfo> connectedDevices = {};
  // ConnectionInfo? connectedDevice;
  List<Map<String, dynamic>> payloads = [{}];
  
  Exception? error;
  bool errorHandledByHome = false;
  
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
        bool b = await acceptConnection_Form(id);
        if(!b) {
          throw Exception('Connection failed');
        }
      },
      onConnectionResult: (id, status) async {
        if(status == Status.CONNECTED) {
          // connectedDevice?.endpointName = id;
          connectedDevices[id]?.endpointName = id;
          await Nearby().sendBytesPayload(id, Uint8List.fromList(utf8.encode(response)));
          if(response.contains('content')) {
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
      errorHandledByHome = false;
      notifyListeners();
      return false;
    });
    return true;
  }
  
  Future<bool> startAdvertising(
    Map<String, dynamic> form, 
    {required bool isSharing}
    ) async {
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
          // if(isSharing) {
          //   // await acceptConnection_Share(id);
          // } else {
          // }
          await acceptConnection_Form(id, jsonEncode(form));
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
  
  Future<bool> acceptConnection_Form(
      String id,
      [String form = ""]
    ) async {
      await Nearby().acceptConnection(
        id,
        //TODO: Check if endid is the same as this id
        onPayLoadRecieved: (endid, pload) async {
          if (pload.type == PayloadType.BYTES) {
            String str = String.fromCharCodes(pload.bytes!);
            // developer.log(str);
            var payload = jsonDecode(str);
            // developer.log("${pload.id}: ${payload.toString()}");
            
            if(payload["type"] == "request"){
              await Nearby().sendBytesPayload(id, Uint8List.fromList(utf8.encode(form)));
            } else if(payload["type"] == "form" || payload["type"] == "response") {
              if(payload.containsKey('content')) {
                payload["device_id"] = endid;
                payloads.insert(0, payload);
                notifyListeners();
                if(isAdvertising) {
                  await Nearby().sendBytesPayload(id, Uint8List.fromList(utf8.encode('{"type": "form", "ack": true}')));
                }
              }
              // if(isAdvertising) {
              //   if(payload.containsKey('content')) {
              //     await Nearby().sendBytesPayload(id, Uint8List.fromList(utf8.encode(jsonEncode('{"type": "form", "ack": true}'))));
              //   } else {
              //     await Nearby().sendBytesPayload(id, Uint8List.fromList(utf8.encode(jsonEncode(form))));
              //   }
              // }
              if(isDiscovering){
                await Nearby().disconnectFromEndpoint(id);
                connectedDevices.remove(id);
                notifyListeners();
              }
            } else if(payload["type"] == "share") {
              if(payload["contentType"] == "filename") {
                payload["device_id"] = endid;
                developer.log("Filename");
                payloads.insert(0, payload);
                // moveFile(endid, payload["payload_id"], payload);
                checkAndMoveFile(payload["payload_id"].toString());
                
              } else {
                payloads.insert(0, payload);
              }
              notifyListeners();
            }
            
          } else if (pload.type == PayloadType.FILE) {
            developer.log("Insert ${pload.id} ${pload.uri ?? ""}");
            payloads.insert(0, {
              "type": "share",
              "contentType": "file",
              "device_id": endid,
              "payload_id": pload.id,
              "content": pload.uri,
              "moved": false,
            });
            // developer.log(payloads.toString());
          }
        },
        onPayloadTransferUpdate: (endid, payloadTransferUpdate) async {
          developer.log("Update ${payloadTransferUpdate.id}: ${payloadTransferUpdate.status}");
          if(payloadTransferUpdate.status == PayloadStatus.SUCCESS) {
            checkAndMoveFile(id);
          }
        },
      ).catchError((e) {
        connectedDevices.remove(id);
        error = e;
        errorHandledByHome = false;
        notifyListeners();
        return false;
      });
      return true;
  }
  
  Future<void> checkAndMoveFile(String id) async {
    var filePayload = payloads
      .firstWhere((element) => 
      element["payload_id"].toString() == id 
      && element["moved"] == false,
      orElse: () => {}
    );
    var payload = payloads
      .firstWhere((element) => 
      element["payload_id"].toString() == id 
      && element["filename"] != null,
      orElse: () => {}
    );
    developer.log("Check and move called");
    developer.log(payload.toString());
    developer.log(filePayload.toString());
    if(filePayload.isNotEmpty && payload.isNotEmpty) {
      developer.log("Moving file");
      final b = await moveFile(filePayload["content"], payload["filename"]);
      if(b) {
        payloads[payloads.indexOf(filePayload)]["moved"] = true;
      }
      notifyListeners();
    }
  }
  
  Future<bool> moveFile(String uri, String fileName) async {
    // String parentDir = (await getExternalStorageDirectory())!.absolute.path;
    String parentDir = "/storage/emulated/0/Download";
    final b = await Nearby().copyFileAndDeleteOriginal(uri, '$parentDir/$fileName');
    // developer.log('$parentDir/$fileName');
    return b;
  }
  
  // Future<bool> moveFile(String endid, int payloadId, Map<String, dynamic> p) async {
  //   bool b;
  //   var filePl = payloads.firstWhere((element) => 
  //     element["payload_id"] == payloadId 
  //     && element["device_id"] == endid
  //     && element["contentType"] != p["contentType"],
  //     orElse: () => p,
  //     );
    
  //   if(filePl == p) {
  //     payloads.insert(0, p);
  //     return false;
  //   } else { 
  //     String uri, fileName;
      
  //     if(filePl["contentType"] == "file") {
  //       uri = filePl["content"];
  //       fileName = p["content"];
  //     } else {
  //       uri = filePl["content"];
  //       fileName = filePl["content"];
  //     }
      
  //     String parentDir = (await getExternalStorageDirectory())!.absolute.path;
  //     b = await Nearby().copyFileAndDeleteOriginal(uri, '$parentDir/$fileName');
  //   }
    
  //   notifyListeners();
  //   return b;
  // }
  
  // Future<bool> moveFile(String uri, String fileName) async {
  //   String parentDir = (await getExternalStorageDirectory())!.absolute.path;
  //   // developer.log(uri);
  //   ///storage/emulated/0/Android/data/com.example.sdl/files
  //   File file = File.fromUri(Uri.dataFromString(uri));
  //   developer.log(file.path);
  //   final b = await Nearby().copyFileAndDeleteOriginal(uri, '/storage/emulated/0/Download/$fileName');

  //   showSnackbar("Moved file:$b");
  //   return b;
  // }
  
  Future<void> sendBytesPayload(String id, Uint8List list) async {
    await Nearby().sendBytesPayload(id, list);
  }
  
  Future<void> sendFilePayload(File file) async {
    String id = connectedDevices.keys.first;      /// The file is sent to the first connected
    var payloadId = await Nearby().sendFilePayload(id, file.path);
    Nearby().sendBytesPayload(
      id,
      Uint8List.fromList(utf8.encode(
        jsonEncode({
          "type": "share",
          "contentType": "filename",
          "payload_id": payloadId,
          "filename": file.path.split('/').last
        })
      )));
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
