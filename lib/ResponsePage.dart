import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sdl/NearbyService.dart';
import 'dart:developer' as developer;

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
    developer.log(context.read<NearbyService>().payloads.toString());
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Response Page'),
      ),
      body: Column(
        children: [
          ListView.builder(
            itemCount: context.watch<NearbyService>().payloads.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Text(context.watch<NearbyService>().payloads[index].toString());
            },
          ),
          
          if (isSharing == null)
            const CircularProgressIndicator(),
          
          if (isSharing != null && !isSharing!)
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
          ],
          
          if (isSharing != null && isSharing!)
            ...[
              ElevatedButton(
                child: const Text("Send File Payload"),
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
              (!isCameraOpen) ? ElevatedButton(
                child: const Text("Open camera"),
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
              ) : ElevatedButton(
                child: const Text("Close camera"),
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
              if(context.read<NearbyService>().payloads[0]["contentType"] == "camera" && context.read<NearbyService>().payloads[0]["content"] == "open")
                ElevatedButton(
                  child: const Text("Take picture"),
                  onPressed: () async {
                    NearbyService().sendBytesPayload({
                      "type": "share",
                      "contentType": "camera",
                      "content": "clickImage",
                    });
                  },
                ),
              if(isCameraOpen && controller != null) SizedBox(
                width: 200,
                height: 200,
                child: AspectRatio(
                  aspectRatio: controller!.value.aspectRatio,
                  child: CameraPreview(controller!),
                ),
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
    );
  }
}