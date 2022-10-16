import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:sdl/NearbyService.dart';

class ResponsePage extends StatefulWidget {
  const ResponsePage({Key? key}) : super(key: key);

  @override
  ResponsePageState createState() => ResponsePageState();
}

class ResponsePageState extends State<ResponsePage> {
  
  Map<String, dynamic> response = {
    "type": "response",
    "content": [
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
  bool? isSharing;
  bool isCameraOpen = false;
  CameraController? controller;
  TextEditingController textController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<NearbyService>().removeListener(catchError);
      context.read<NearbyService>().addListener(catchError);
      // payloadType = context.read<NearbyService>().payloads[0].containsKey("type") ? context.read<NearbyService>().payloads[0]["type"] : "";
      isSharing = context.read<NearbyService>().payloads[0].containsKey("type") ? context.read<NearbyService>().payloads[0]["type"] == "share" : null;
      
      List<CameraDescription> cameras = await availableCameras();
      controller = CameraController(cameras[0], ResolutionPreset.medium);
      controller!.initialize().then((_) {
        if(!mounted) return;
        context.read<NearbyService>().cameraController = controller;
        setState(() {});
      });
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // payloadType = context.read<NearbyService>().payloads[0].containsKey("type") ? context.read<NearbyService>().payloads[0]["type"] : "";
    // developer.log(context.read<NearbyService>().payloads.toString());
    isSharing = context.read<NearbyService>().payloads[0].containsKey("type") ? context.read<NearbyService>().payloads[0]["type"] == "share" : null;
  }
  
  @override
  // void deactivate() {
  void dispose() {
    // context.read<NearbyService>().removeListener(catchError);
    // context.read<NearbyService>().payloads = [{}];
    // NearbyService().stopAllEndpoints();
    // super.deactivate();
    controller?.dispose();
    super.dispose();
  }
  
  void catchError() {
    if(!mounted) return;
    if(context.read<NearbyService>().error != null || (context.read<NearbyService>().connectedDevices.isEmpty && (isSharing ?? false))) {
      // developer.log(context.read<NearbyService>().error.toString());
      Provider.of<NearbyService>(context, listen: false).payloads = [{}];
      context.read<NearbyService>().error = null;
      ModalRoute.of(context)?.settings.name == "/responsePage" ? Navigator.pop(context) : null;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> payloads = context.watch<NearbyService>().payloads.reversed.toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Response Page'),
      ),
      body: SafeArea(
        child: Stack(
          children: [            
            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  ListView.builder(
                    itemCount: context.watch<NearbyService>().payloads.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Text(context.watch<NearbyService>().payloads[index].toString());
                    },
                  ),
                  
                  if (isSharing == null)
                  ...[
                    const CircularProgressIndicator(),
                  ]
                  else if (!isSharing!)
                  ...[
                    const Text("Form"),
                    Text(response.toString()),
                    Text("Response sent: ${context.watch<NearbyService>().payloads[0].containsKey('sent') ? context.watch<NearbyService>().payloads[0]['sent'].toString() : "false"}"),
                    ElevatedButton(
                      onPressed: (){
                        if(context.read<NearbyService>().payloads[0].containsKey("device_id")){
                          NearbyService().requestConnection(
                            context.read<NearbyService>().payloads[0]['device_id'].toString(),
                            jsonEncode(response)
                          );
                        }
                      },
                      child: const Text('Send'),
                    ),
                  ] 
                  else
                    ...[
                      Expanded(
                        child: ListView.builder(
                          itemCount: context.watch<NearbyService>().payloads.length,
                          itemBuilder: (context, index) {
                            
                            if(!payloads[index].containsKey("contentType")) return Container();
                            if(payloads[index]["contentType"] == "ack" 
                              || payloads[index]["contentType"] == "file"
                              || payloads[index]["contentType"] == "camera"
                              ) return Container();
                            
                            return GestureDetector(
                              onTap: () {
                                if(payloads[index]["contentType"] == "filename") {
                                  developer.log("Called");
                                  OpenFilex.open("/storage/emulated/0/Download/${payloads[index]['filename']}")
                                  .catchError((obj){
                                    
                                  });
                                }
                              },
                              child: Container(
                                alignment: payloads[index].containsKey("sent") ? Alignment.centerRight : Alignment.centerLeft,
                                padding: EdgeInsets.only(
                                  top: 5,
                                  left: (payloads[index].containsKey("sent")) ? MediaQuery.of(context).size.width * 0.1 : 0,
                                  right: (!payloads[index].containsKey("sent")) ? MediaQuery.of(context).size.width * 0.1 : 0,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.blue,
                                  ),
                                  child: Text(
                                    (payloads[index]["contentType"] == "text") 
                                      ? payloads[index]["content"].toString()
                                      : (payloads[index]["contentType"] == "filename") 
                                        ? payloads[index]["filename"].toString()
                                        : payloads[index].toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: textController,
                              decoration: const InputDecoration(
                                hintText: "Enter text",
                              ),
                              onFieldSubmitted: (value) {
                                if(value.isNotEmpty) {
                                  NearbyService().sendBytesPayload({
                                    "type": "share",
                                    "contentType": "text",
                                    "content": value,
                                  });
                                  textController.clear();
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.attach_file),
                            onPressed: () async {
                              FilePickerResult? result = await FilePicker.platform.pickFiles();
                              // developer.log(result?.files.single.path ?? "");
                              // showSnackbar(result);
                              if (result?.files.single.path == null) return;
                              
                              File file = File(result!.files.single.path!);
                              NearbyService().sendFilePayload(file);
                              // developer.log('{"type": "share", "contentType": "filename", "content": "${file.path.split('/').last}}"');
                            },
                          ),
                          (!isCameraOpen) ? IconButton(
                            icon: const Icon(Icons.camera_alt),
                            onPressed: () async {
                              setState(() {
                                isCameraOpen = true;
                              });
                              NearbyService().sendBytesPayload({
                                "type": "share",
                                "contentType": "camera",
                                "content": "open",
                              });
                            },
                          ) : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () async {
                              setState(() {
                                isCameraOpen = false;
                              });
                              NearbyService().sendBytesPayload({
                                "type": "share",
                                "contentType": "camera",
                                "content": "close",
                            });
                            },
                          ),
                        ],
                      ),                      
                      // ElevatedButton(
                      //   child: const Text("Clear"),
                      //   onPressed: () async {
                      //     // context.read<NearbyService>().payloads = [{"type": "share", "contentType": "ack"}];
                      //     developer.log(context.read<NearbyService>().payloads[0]["payload_id"].runtimeType.toString());
                      //   },
                      // ),
                    ]
                ],
              ),
            ),
            
            if(payloads[payloads.length - 1]["contentType"] == "camera" && payloads[payloads.length - 1]["content"] == "open")
              SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: Center(
                  child: ElevatedButton(
                    child: const Text("Take picture"),
                    onPressed: () async {
                      NearbyService().sendBytesPayload({
                        "type": "share",
                        "contentType": "camera",
                        "content": "clickImage",
                      });
                    },
                  ),
                ),
              ),
            if(isCameraOpen && controller != null) 
              SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: Center(
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () async {
                          setState(() {
                            isCameraOpen = false;
                          });
                          NearbyService().sendBytesPayload({
                            "type": "share",
                            "contentType": "camera",
                            "content": "close",
                          });
                        },
                      ),
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: AspectRatio(
                          aspectRatio: controller!.value.aspectRatio,
                          child: CameraPreview(controller!),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}