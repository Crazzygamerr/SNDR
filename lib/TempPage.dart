import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sdl/NearbyService.dart';

class TempPage extends StatefulWidget {
  const TempPage({Key? key}) : super(key: key);

  @override
  TempPageState createState() => TempPageState();
}

class TempPageState extends State<TempPage> {
  final String userName = Random().nextInt(10000).toString();
  final Strategy strategy = Strategy.P2P_STAR;
  
  Map<String, String> foundDevices = {};
  Map<String, ConnectionInfo> connectedDevices = {};
  Map<int, String> map = {};
  List<String> messages = [];
  
  List<bool> permissions = [false, false, false, false];
  NearbyState nearbyState = NearbyState.isDiscovering;

  String? tempFileUri;
  TextEditingController textEditingController = TextEditingController();

  Map<String, dynamic> questionForm = {
    "type": "form",
    // "type": "attendance",
    // "type": "camera",
    // "type": "file",
    "fields": [
      {
        "id": 1,
        "title": "What is your name?",
      },
      {
        "id": 2,
        "title": "What is your age?",
      }
    ]
  };
  
  Map<String, dynamic> responseForm = {
    "responses": [
      {
        "id": 1,
        "answer": "John",
      },
      {
        "id": 2,
        "answer": 20,
      }
    ]
  };

  @override
  void initState() {
    super.initState();
    init();
  }
  
  void init() async {
    permissions[0] = await Nearby().checkLocationPermission();
    permissions[1] = await Nearby().checkExternalStoragePermission();
    permissions[2] = await Nearby().checkBluetoothPermission();
    permissions[3] = await Nearby().checkLocationPermission() && await Nearby().checkLocationEnabled();
    setState(() {});
    
    if (!permissions[0] || !permissions[1] || !permissions[2] || !permissions[3]) {
      NearbyService().requestPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text("User Name: $userName\nState: $nearbyState"),
            const Divider(),
              ElevatedButton(
                child: const Text("Start Advertising"),
                onPressed: () async {
                  // NearbyService().startAdvertising();
                  bool b = await startAdvertising();
                  if(b) {
                    setState(() {
                      nearbyState = NearbyState.isAdvertising;
                      foundDevices = {};
                    });
                  }
                },
              ),
              ElevatedButton(
                child: const Text("Start Discovery"),
                onPressed: () async {
                  NearbyService().startDiscovery();
                  // bool b = await startDiscovering();
                  // if(b) {
                  //   setState(() {
                  //     nearbyState = NearbyState.isDiscovering;
                  //     foundDevices = {};
                  //   });
                  // }
                },
              ),
            if(nearbyState == NearbyState.isAdvertising)
              ElevatedButton(
                child: const Text("Stop Advertising"),
                onPressed: () async {
                  Nearby().stopAdvertising().then((value) => {
                    setState(() {
                      nearbyState = NearbyState.isDiscovering;
                      foundDevices = {};
                    }),
                  });
                },
              ),
            if(nearbyState == NearbyState.isDiscovering)
              ElevatedButton(
                child: const Text("Stop Discovery"),
                onPressed: () async {
                  Nearby().stopDiscovery().then((value) => {
                    setState(() {
                      nearbyState = NearbyState.isAdvertising;
                      foundDevices = {};
                    })
                  });
                },
              ),
              
            ElevatedButton(
              child: const Text("Disconnect All"),
              onPressed: () async {
                Nearby().stopAllEndpoints().then((value) => {
                  setState(() {
                    connectedDevices = {};
                  })
                });
              },
            ),

            const Divider(),
            const Text("Available Devices"),
            ...context.watch<NearbyService>().foundDevices.keys.map((key) {
              return ListTile(
                title: Text(foundDevices[key] ?? ""),
                subtitle: Text(key),
                trailing: ElevatedButton(
                  child: const Text("Connect"),
                  onPressed: () async {
                    Nearby().requestConnection(
                      userName,
                      key,
                      onConnectionInitiated: (id, info) async {
                        setState(() {
                          connectedDevices[id] = info;
                          foundDevices.remove(id);
                        });
                        await acceptConnection(id);
                        Nearby().sendBytesPayload(id, Uint8List.fromList(utf8.encode(jsonEncode(responseForm))));
                      },
                      onConnectionResult: (id, status) {
                        showSnackbar(status);
                      },
                      onDisconnected: (id) {
                        setState(() {
                          connectedDevices.remove(id);
                        });
                        showSnackbar("Disconnected from: ${connectedDevices[id]!.endpointName}, id $id");
                      },
                    );
                    // if(b) {
                    //   setState(() {
                    //     nearbyState = NearbyState.isConnected;
                    //   });
                    // }
                  },
                ),
              );
            }).toList(),

            const Divider(),
            const Text("Connected Devices"),
            ...context.watch<NearbyService>().connectedDevices.keys.map((key) {
              return ListTile(
                title: Text(connectedDevices[key]?.endpointName ?? ""),
                subtitle: Text(key),
                trailing: ElevatedButton(
                  child: const Text("Send JSON"),
                  onPressed: () async {
                    await Nearby().sendBytesPayload(
                      key,
                      Uint8List.fromList(utf8.encode(jsonEncode(questionForm))),
                    );
                  },
                ),
                // ElevatedButton(
                //       child: const Text("Disconnect"),
                //       onPressed: () async {
                //         // await Nearby().sendBytesPayload(key, Uint8List.fromList("Hello World".codeUnits));
                //         await Nearby().disconnectFromEndpoint(key);
                //         setState(() {
                //           connectedDevices.remove(key);
                //         });
                //       },
                //     ),
              );
            }).toList()

          ],
        ),
      ),
    );
  }

  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }

  Future<bool> moveFile(String uri, String fileName) async {
    String parentDir = (await getExternalStorageDirectory())!.absolute.path;
    final b =
    await Nearby().copyFileAndDeleteOriginal(uri, '$parentDir/$fileName');

    showSnackbar("Moved file:$b");
    return b;
  }

  Future<bool> startAdvertising() async {
    try {
      bool a = await Nearby().startAdvertising(
        userName,
        strategy,
        onConnectionInitiated: (id, info) async {
          setState(() {
            connectedDevices[id] = info;
            // foundDevices.remove(id);
          });
          await acceptConnection(id);
        },
        onConnectionResult: (id, status) {
          showSnackbar(status);
        },
        onDisconnected: (id) {
          showSnackbar(
                  "Disconnected: ${connectedDevices[id]!.endpointName}, id $id");
          setState(() {
            connectedDevices.remove(id);
          });
        },
      );
      showSnackbar("ADVERTISING: $a");
      return a;
    } catch (exception) {
      showSnackbar(exception);
      return false;
    }
  }
  
  // Future<bool> startDiscovering() async {
  //   try {
  //     bool a = await Nearby().startDiscovery(
  //       userName,
  //       strategy,
  //       onEndpointFound: (id, name, serviceId) {
  //         if (foundDevices.containsKey(id) || connectedDevices.containsKey(id)) return;
  //         setState(() {
  //           foundDevices[id] = name;
  //         });
  //       },
  //       onEndpointLost: (id) {
  //         setState(() {
  //           foundDevices.remove(id);           
  //         });
  //         showSnackbar(
  //                 "Lost discovered Endpoint: ${connectedDevices[id]!.endpointName}, id $id");
  //       },
  //     );
  //     showSnackbar("DISCOVERING: $a");
  //     return a;
  //   } catch (e) {
  //     showSnackbar(e);
  //     return false;
  //   }
  // }
  
  /// Called upon Connection request (on both devices)
  /// Both need to accept connection to start sending/receiving
  
  // void onConnectionInit(String id, ConnectionInfo info) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (builder) {
  //       return Container(
  //         padding: const EdgeInsets.all(10),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: <Widget>[
  //             const Text(
  //               "Connection Info:",
  //               style: TextStyle(
  //                 fontSize: 20,
  //               ),
  //             ),
  //             const SizedBox(
  //               height: 10,
  //             ),
  //             Text("id: $id"),
  //             Text("Token: ${info.authenticationToken}"),
  //             Text("Name: ${info.endpointName}"),
  //             Text("Incoming: ${info.isIncomingConnection}"),
  //             const SizedBox(
  //               height: 20,
  //             ),
  //             Row(
  //               mainAxisSize: MainAxisSize.max,
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: [
  //                 ElevatedButton(
  //                   child: const Text("Reject Connection"),
  //                   onPressed: () async {
  //                     Navigator.pop(context);
  //                     try {
  //                       await Nearby().rejectConnection(id);
  //                     } catch (e) {
  //                       showSnackbar(e);
  //                     }
  //                   },
  //                 ),
  //                 ElevatedButton(
  //                   child: const Text("Accept Connection"),
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                     setState(() {
  //                       connectedDevices[id] = info;
  //                       foundDevices.remove(id);
  //                     });
  //                     acceptConnection(id);
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
  
  Future<bool> acceptConnection(id) async {
    await Nearby().acceptConnection(
      id,
      onPayLoadRecieved: (endid, payload) async {
        if (payload.type == PayloadType.BYTES) {
          String str = String.fromCharCodes(payload.bytes!);
          // showSnackbar("$endid: $str");
          setState(() {
            messages.add("${connectedDevices[endid]!.endpointName}: $str");
          });
          // developer.log(jsonDecode(str).toString());
          if(nearbyState == NearbyState.isAdvertising && !jsonDecode(str).containsKey("responses")){
            await Nearby().sendBytesPayload(id, Uint8List.fromList(utf8.encode(jsonEncode(questionForm))));
          }
          await Nearby().disconnectFromEndpoint(id);
          setState(() {
            connectedDevices.remove(id);
          });

          // if (str.contains(':')) {
          //   // used for file payload as file payload is mapped as
          //   // payloadId:filename
          //   int payloadId = int.parse(str.split(':')[0]);
          //   String fileName = (str.split(':')[1]);

          //   if (map.containsKey(payloadId)) {
          //     if (tempFileUri != null) {
          //       moveFile(tempFileUri!, fileName);
          //     } else {
          //       showSnackbar("File doesn't exist");
          //     }
          //   } else {
          //     //add to map if not already
          //     map[payloadId] = fileName;
          //   }
          // }
        } else if (payload.type == PayloadType.FILE) {
          showSnackbar("$endid: File transfer started");
          tempFileUri = payload.uri;
        }
      },
      onPayloadTransferUpdate: (endid, payloadTransferUpdate) async {
        if (payloadTransferUpdate.status ==
                PayloadStatus.IN_PROGRESS) {
          print(payloadTransferUpdate.bytesTransferred);
        } else if (payloadTransferUpdate.status ==
                PayloadStatus.FAILURE) {
          print("failed");
          showSnackbar("$endid: FAILED to transfer file");
        } else if (payloadTransferUpdate.status ==
                PayloadStatus.SUCCESS) {
          showSnackbar(
                  "$endid success, total bytes = ${payloadTransferUpdate.totalBytes}");
                  
          if(nearbyState == NearbyState.isAdvertising) {
            // await Nearby().disconnectFromEndpoint(id);
            // setState(() {
            //   connectedDevices.remove(id);
            // });
          }
          if (map.containsKey(payloadTransferUpdate.id)) {
            //rename the file now
            String name = map[payloadTransferUpdate.id]!;
            moveFile(tempFileUri!, name);
          } else {
            //bytes not received till yet
            map[payloadTransferUpdate.id] = "";
          }
        }
      },
    );
    return true;
  }
}