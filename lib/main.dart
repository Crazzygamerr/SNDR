import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('SNDR'),
        ),
        body: const Body(),
      ),
    );
  }
}

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  _MyBodyState createState() => _MyBodyState();
}

enum NearbyState { isIdle, isAdvertising, isDiscovering, isConnected }
class _MyBodyState extends State<Body> {
  final String userName = Random().nextInt(10000).toString();
  final Strategy strategy = Strategy.P2P_STAR;
  
  Map<String, String> foundDevices = {};
  Map<String, ConnectionInfo> connectedDevices = {};
  Map<int, String> map = {};
  List<String> messages = [];
  
  List<bool> permissions = [false, false, false, false];
  NearbyState nearbyState = NearbyState.isIdle;

  String? tempFileUri;
  TextEditingController textEditingController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    checkPermissions();
  }
  
  void checkPermissions() async {
    permissions[0] = await Nearby().checkLocationPermission();
    permissions[1] = await Nearby().checkExternalStoragePermission();
    permissions[2] = await Nearby().checkBluetoothPermission();
    permissions[3] = await Nearby().checkLocationPermission() && await Nearby().checkLocationEnabled();
    setState(() {});
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
            (!permissions[0] && !permissions[1] && !permissions[2])
              ? const Text(
                "Permissions not granted",
              ) : const Text(
                "Permissions granted"
                ),
            if (!permissions[0] && !permissions[1] && !permissions[2])
              ElevatedButton(
                onPressed: () {
                  if(!permissions[0]) Nearby().askLocationPermission();
                  if(!permissions[1]) Nearby().askExternalStoragePermission();
                  if(!permissions[2]) Nearby().askBluetoothPermission();
                  checkPermissions();
                },
                child: const Text("Grant Permissions"),
              ),
            const Divider(),
            (!permissions[3])
              ? const Text(
                "Location not enabled",
              ) : const Text(
                "Location enabled"
                ),
            if (!permissions[3])
              ElevatedButton(
                onPressed: () async{
                  if (!await Nearby().checkLocationPermission()){
                    await Nearby().askLocationPermission();
                  }
                  await Nearby().enableLocationServices();
                  checkPermissions();
                },
                child: const Text("Enable Location"),
              ),
            const Divider(),
            Text("User Name: $userName\nState: $nearbyState"),
            const Divider(),
            if(nearbyState == NearbyState.isIdle)
              ...[
                ElevatedButton(
                  child: const Text("Start Advertising"),
                  onPressed: () async {
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
                    bool b = await startDiscovering();
                    if(b) {
                      setState(() {
                        nearbyState = NearbyState.isDiscovering;
                        foundDevices = {};
                      });
                    }
                  },
                ),
              ],
            if(nearbyState == NearbyState.isAdvertising)
              ElevatedButton(
                child: const Text("Stop Advertising"),
                onPressed: () async {
                  Nearby().stopAdvertising().then((value) => {
                    setState(() {
                      nearbyState = NearbyState.isIdle;
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
                      nearbyState = NearbyState.isIdle;
                      foundDevices = {};
                    })
                  });
                },
              ),

            const Divider(),
            const Text("Available Devices"),
            ...foundDevices.keys.map((key) {
              return ListTile(
                title: Text(foundDevices[key]!),
                subtitle: Text(key),
                trailing: ElevatedButton(
                  child: const Text("Connect"),
                  onPressed: () async {
                    Nearby().requestConnection(
                      userName,
                      key,
                      onConnectionInitiated: (id, info) {
                        onConnectionInit(id, info);
                      },
                      onConnectionResult: (id, status) {
                        showSnackbar(status);
                      },
                      onDisconnected: (id) {
                        setState(() {
                          connectedDevices.remove(id);
                        });
                        showSnackbar(
                                "Disconnected from: ${connectedDevices[id]!.endpointName}, id $id");
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
            ...connectedDevices.keys.map((key) {
              return ListTile(
                title: Text(connectedDevices[key]!.endpointName),
                subtitle: Text(key),
                trailing: ElevatedButton(
                  child: const Text("Disconnect"),
                  onPressed: () async {
                    // await Nearby().sendBytesPayload(key, Uint8List.fromList("Hello World".codeUnits));
                    await Nearby().disconnectFromEndpoint(key);
                    setState(() {
                      connectedDevices.remove(key);
                    });
                  },
                ),
              );
            }).toList(),
            const Divider(),

            if(nearbyState == NearbyState.isConnected)
            ...[
              const Text(
                "Sending Data",
              ),
              ElevatedButton(
                child: const Text("Send Random Bytes Payload"),
                onPressed: () async {
                  connectedDevices.forEach((key, value) {
                    String a = Random().nextInt(100).toString();

                    showSnackbar("Sending $a to ${value.endpointName}, id: $key");
                    Nearby()
                            .sendBytesPayload(key, Uint8List.fromList(a.codeUnits));
                  });
                },
              ),
              ElevatedButton(
                child: const Text("Send File Payload"),
                onPressed: () async {
                  PickedFile? file =
                  await ImagePicker().getImage(source: ImageSource.gallery);

                  if (file == null) return;

                  for (MapEntry<String, ConnectionInfo> m
                  in connectedDevices.entries) {
                    int payloadId =
                    await Nearby().sendFilePayload(m.key, file.path);
                    showSnackbar("Sending file to ${m.key}");
                    Nearby().sendBytesPayload(
                            m.key,
                            Uint8List.fromList(
                                    "$payloadId:${file.path.split('/').last}".codeUnits));
                  }
                },
              ),
              ElevatedButton(
                child: const Text("Print file names."),
                onPressed: () async {
                  final dir = (await getExternalStorageDirectory())!;
                  final files = (await dir.list(recursive: true).toList())
                          .map((f) => f.path)
                          .toList()
                          .join('\n');
                  showSnackbar(files);
                },
              ),
            ],
            const Divider(),
            const Text("Data Received",),
            ...messages.map((e) => Text(e)).toList(),

            if(connectedDevices.isNotEmpty)
              ...[
                const Divider(),
                const Text("Send Data to All Devices"),
                TextFormField(
                  controller: textEditingController,
                  onFieldSubmitted: (text) {
                    connectedDevices.forEach((key, value) {
                      showSnackbar("Sending $text to ${value.endpointName}, id: $key");
                      Nearby().sendBytesPayload(key, Uint8List.fromList(utf8.encode(text)));
                    });
                    textEditingController.clear();
                  },
                ),
              ]
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
        onConnectionInitiated: onConnectionInit,
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
  
  Future<bool> startDiscovering() async {
    try {
      bool a = await Nearby().startDiscovery(
        userName,
        strategy,
        onEndpointFound: (id, name, serviceId) {
          if (foundDevices.containsKey(id) || connectedDevices.containsKey(id)) return;
          setState(() {
            foundDevices[id] = name;
          });
          // showModalBottomSheet(
          //   context: context,
          //   builder: (builder) {
          //     return Center(
          //       child: Column(
          //         children: <Widget>[
          //           Text("id: $id"),
          //           Text("Name: $name"),
          //           Text("ServiceId: $serviceId"),
          //           ElevatedButton(
          //             child: const Text("Request Connection"),
          //             onPressed: () {
          //               Navigator.pop(context);
          //               Nearby().requestConnection(
          //                 userName,
          //                 id,
          //                 onConnectionInitiated: (id, info) {
          //                   onConnectionInit(id, info);
          //                 },
          //                 onConnectionResult: (id, status) {
          //                   showSnackbar(status);
          //                 },
          //                 onDisconnected: (id) {
          //                   setState(() {
          //                     endpointMap.remove(id);
          //                   });
          //                   showSnackbar(
          //                           "Disconnected from: ${endpointMap[id]!.endpointName}, id $id");
          //                 },
          //               );
          //             },
          //           ),
          //         ],
          //       ),
          //     );
          //   },
          // );
        },
        onEndpointLost: (id) {
          setState(() {
            foundDevices.remove(id);           
          });
          showSnackbar(
                  "Lost discovered Endpoint: ${connectedDevices[id]!.endpointName}, id $id");
        },
      );
      showSnackbar("DISCOVERING: $a");
      return a;
    } catch (e) {
      showSnackbar(e);
      return false;
    }
  }
  
  /// Called upon Connection request (on both devices)
  /// Both need to accept connection to start sending/receiving
  void onConnectionInit(String id, ConnectionInfo info) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Connection Info:",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text("id: $id"),
              Text("Token: ${info.authenticationToken}"),
              Text("Name: ${info.endpointName}"),
              Text("Incoming: ${info.isIncomingConnection}"),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    child: const Text("Reject Connection"),
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        await Nearby().rejectConnection(id);
                      } catch (e) {
                        showSnackbar(e);
                      }
                    },
                  ),
                  ElevatedButton(
                    child: const Text("Accept Connection"),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        connectedDevices[id] = info;
                        foundDevices.remove(id);
                      });
                      acceptConnection(id);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  void acceptConnection(id) {
    Nearby().acceptConnection(
      id,
      onPayLoadRecieved: (endid, payload) async {
        if (payload.type == PayloadType.BYTES) {
          String str = String.fromCharCodes(payload.bytes!);
          showSnackbar("$endid: $str");
          setState(() {
            messages.add("${connectedDevices[endid]!.endpointName}: $str");
          });

          if (str.contains(':')) {
            // used for file payload as file payload is mapped as
            // payloadId:filename
            int payloadId = int.parse(str.split(':')[0]);
            String fileName = (str.split(':')[1]);

            if (map.containsKey(payloadId)) {
              if (tempFileUri != null) {
                moveFile(tempFileUri!, fileName);
              } else {
                showSnackbar("File doesn't exist");
              }
            } else {
              //add to map if not already
              map[payloadId] = fileName;
            }
          }
        } else if (payload.type == PayloadType.FILE) {
          showSnackbar("$endid: File transfer started");
          tempFileUri = payload.uri;
        }
      },
      onPayloadTransferUpdate: (endid, payloadTransferUpdate) {
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
  }
}