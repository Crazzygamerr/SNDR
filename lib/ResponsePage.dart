import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:sdl/NearbyService.dart';
import 'package:permission_handler/permission_handler.dart';

class ResponsePage extends StatefulWidget {
  const ResponsePage({Key? key}) : super(key: key);

  @override
  ResponsePageState createState() => ResponsePageState();
}

class ResponsePageState extends State<ResponsePage> {
  
  Map<String, dynamic> response = {
    "type": "response",
    "content": [],
  };
  Map<String, dynamic> form = {};
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
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // payloadType = context.read<NearbyService>().payloads[0].containsKey("type") ? context.read<NearbyService>().payloads[0]["type"] : "";
    // developer.log(context.read<NearbyService>().payloads.toString());
    isSharing = context.read<NearbyService>().payloads[0].containsKey("type") ? context.read<NearbyService>().payloads[0]["type"] == "share" : null;
    form = context.read<NearbyService>().payloads[0];
    // if form has content then add the respective fields to the response
    if(form.isNotEmpty 
      && form["type"] == "form" 
      && response["content"].isEmpty) {
      initFunc();
    }
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
  
  List<TextEditingController> controllers = [];
  
  void initFunc() {
    response = {
      "type": "response",
      "content": [],
    };
    
    for (var i = 0; i < form["content"].length; i++) {
      
      controllers.add(TextEditingController());
      var resItem = form["content"][i];
      
      if(resItem["type"] == QuestionTypes.singleLine.value
        || resItem["type"] == QuestionTypes.multiLine.value) {
        resItem["response"] = "";
      } else if(resItem["type"] == QuestionTypes.multipleChoice.value
        || resItem["type"] == QuestionTypes.dropdown.value) {
        resItem["selected"] = 0;
      } else if(resItem["type"] == QuestionTypes.checkbox.value) {
        resItem["checked"] = [];
      }
      
      response["content"].add(resItem);
    }
  }
  
  void catchError() {
    if(!mounted) return;
    if(context.read<NearbyService>().error != null || (context.read<NearbyService>().connectedDevices.isEmpty && (isSharing ?? false))) {
      // developer.log(context.read<NearbyService>().error.toString());
      Provider.of<NearbyService>(context, listen: false).payloads = [{}];
      context.read<NearbyService>().error = null;
      // ModalRoute.of(context)?.settings.name == "/responsePage" ? Navigator.pop(context) : null;
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
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
                  if (isSharing == null)
                  ...[
                    const CircularProgressIndicator(),
                  ]
                  else if (!isSharing!)
                  ...[
                    Expanded(
                      child: ListView(
                        children: [
                          Text(form['title']),
                          Text(form['description']),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: form['content'].length,
                            itemBuilder: (context, index) {
                              return Card(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: [
                                      Text(form['content'][index]['title']),
                                      
                                      if(form['content'][index]['type'] == QuestionTypes.singleLine.value
                                        || form['content'][index]['type'] == QuestionTypes.multiLine.value)
                                        ...[
                                          TextFormField(
                                            controller: controllers[index],
                                            keyboardType: (form['content'][index]['type'] == QuestionTypes.singleLine.value)
                                              ? TextInputType.text 
                                              : TextInputType.multiline,
                                            maxLines: (form['content'][index]['type'] == QuestionTypes.singleLine.value)
                                              ? 1 
                                              : null,
                                            onChanged: (value) {
                                              response['content'][index]['response'] = value;
                                            },
                                            decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                              border: UnderlineInputBorder(),
                                            ),
                                          )
                                        ]
                                      else if(form['content'][index]['type'] == QuestionTypes.multipleChoice.value
                                        || form['content'][index]['type'] == QuestionTypes.checkbox.value)
                                        ...[
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: form['content'][index]['options'].length,
                                            itemBuilder: (context, index2) {
                                              return Row(
                                                children: [
                                                  if(form['content'][index]['type'] == QuestionTypes.multipleChoice.value)
                                                    Radio(
                                                      value: index2,
                                                      groupValue: response['content'][index]['selected'],
                                                      onChanged: (value) {
                                                        setState(() {
                                                          response['content'][index]['selected'] = value as int;
                                                        });
                                                      },
                                                    )
                                                  else
                                                    Checkbox(
                                                      value: response['content'][index]['checked'].contains(index2),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          if(value == true) {
                                                            response['content'][index]['checked'].add(index2);
                                                          } else {
                                                            response['content'][index]['checked'].remove(index2);
                                                          }
                                                        });
                                                      },
                                                    ),
                                                  Text(form['content'][index]['options'][index2]),
                                                ],
                                              );
                                            },
                                          )
                                        ]
                                      else if(form['content'][index]['type'] == QuestionTypes.dropdown.value)
                                        ...[
                                          DropdownButton(
                                            value: response['content'][index]['selected'],
                                            items: form['content'][index]['options'].map<DropdownMenuItem<int>>(
                                              (e) => DropdownMenuItem<int>(
                                                value: form['content'][index]['options'].indexOf(e),
                                                child: Text(e),
                                              ),
                                            ).toList() ,
                                            onChanged: (value) {
                                              setState(() {
                                                response['content'][index]['selected'] = value as int;
                                              });
                                            },
                                          )
                                        ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          
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
                      ),
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
                              var status = await Permission.camera.status;
                              if(status.isDenied){
                                openAppSettings();
                              } else {
                                List<
                                    CameraDescription> cameras = await availableCameras();
                                controller = CameraController(
                                    cameras[0], ResolutionPreset.medium);
                                controller!.initialize().then((_) {
                                  if (!mounted) return;
                                  context
                                      .read<NearbyService>()
                                      .cameraController = controller;
                                  setState(() {
                                    isCameraOpen = true;
                                  });
                                  NearbyService().sendBytesPayload(
                                      {
                                        "type": "share",
                                        "contentType": "camera",
                                        "content": "open",
                                      },
                                      addToPayloads: false
                                  );
                                });
                              }
                            },
                          ) : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () async {
                              setState(() {
                                isCameraOpen = false;
                              });
                              NearbyService().sendBytesPayload(
                                {
                                  "type": "share",
                                  "contentType": "camera",
                                  "content": "close",
                                }, 
                                addToPayloads: false
                              );
                            },
                          ),
                        ],
                      ),  
                      // if(payloads[payloads.length - 1]["contentType"] == "camera" && payloads[payloads.length - 1]["content"] == "open")
                      //   ElevatedButton(
                      //     child: const Text("Take picture"),
                      //     onPressed: () async {
                      //       NearbyService().sendBytesPayload(
                      //         {
                      //           "type": "share",
                      //           "contentType": "camera",
                      //           "content": "clickImage",
                      //         }, 
                      //         addToPayloads: false
                      //       );
                      //     },
                      //   ),       
                      //   if(isCameraOpen && controller != null) SizedBox(
                      //     width: 200,
                      //     height: 200,
                      //     child: AspectRatio(
                      //       aspectRatio: controller!.value.aspectRatio,
                      //       child: CameraPreview(controller!),
                      //     ),
                      //   ),             
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
            
            if(payloads[payloads.length - 1]["contentType"] == "camera" 
              && payloads[payloads.length - 1]["content"] == "open")
              Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.black,
                child: Center(
                  child: ElevatedButton(
                    child: const Text("Take picture"),
                    onPressed: () async {
                      NearbyService().sendBytesPayload(
                        {
                          "type": "share",
                          "contentType": "camera",
                          "content": "clickImage",
                        }, 
                        addToPayloads: false
                      );
                    },
                  ),
                ),
              ),
            if(isCameraOpen && controller != null) 
              Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.black,
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          setState(() {
                            isCameraOpen = false;
                          });
                          NearbyService().sendBytesPayload(
                            {
                              "type": "share",
                              "contentType": "camera",
                              "content": "close",
                            }, 
                            addToPayloads: false
                          );
                        },
                      ),
                      Expanded(
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