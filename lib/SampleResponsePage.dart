import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:sdl/NearbyService.dart';
import 'package:sdl/SampleCreate.dart';
import 'package:sdl/main.dart';

class SampleResponsePage extends StatefulWidget {
  const SampleResponsePage({Key? key}) : super(key: key);

  @override
  SampleResponsePageState createState() => SampleResponsePageState();
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(-1, 0.4),
      child: Container(
        alignment: Alignment.center,

        // we can set width here with conditions
        width: MediaQuery.of(context).size.width * 0.60,

        height: kToolbarHeight + 15,
        decoration: BoxDecoration(
          // border: Border(
          //     top: BorderSide(width: 2),
          //     right: BorderSide(width: 2),
          //     bottom: BorderSide(width: 2)),
          color: Color.fromARGB(255, 248, 246, 246),
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(156, 61, 61, 61),
              blurRadius: 10.0,
            ),
          ],
        ),
        child: Text(
          "Response Page",
          style: TextStyle(
              color: Colors.black,
              fontFamily: 'Poppins',
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
              fontSize: 17),
        ),
      ),
    );
  }

  ///width doesnt matter
  @override
  Size get preferredSize => Size(200, kToolbarHeight);
}

class SampleResponsePageState extends State<SampleResponsePage> {
  Map<String, dynamic> response = {
    "type": "response",
    "content": [],
  };
  Map<String, dynamic> form = {};
  bool? isSharing;
  bool isCameraOpen = false;
  CameraController? controller;
  TextEditingController textController = TextEditingController();

  Color chatSentColor = Color(0XCC50C2C9);
  Color chatReceiveColor = Color.fromARGB(180, 143, 225, 215);

  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    backgroundColor: Color(0XFF50C2C9),
    minimumSize: Size(88, 36),
    padding: EdgeInsets.symmetric(horizontal: 20.0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<NearbyService>().removeListener(catchError);
      context.read<NearbyService>().addListener(catchError);
      // payloadType = context.read<NearbyService>().payloads[0].containsKey("type") ? context.read<NearbyService>().payloads[0]["type"] : "";
      isSharing = context.read<NearbyService>().payloads[0].containsKey("type")
          ? context.read<NearbyService>().payloads[0]["type"] == "share"
          : null;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // payloadType = context.read<NearbyService>().payloads[0].containsKey("type") ? context.read<NearbyService>().payloads[0]["type"] : "";
    // developer.log(context.read<NearbyService>().payloads.toString());
    isSharing = context.read<NearbyService>().payloads[0].containsKey("type")
        ? context.read<NearbyService>().payloads[0]["type"] == "share"
        : null;
    form = context.read<NearbyService>().payloads[0];
    // if form has content then add the respective fields to the response
    if (form.isNotEmpty &&
        form["type"] == "form" &&
        response["content"].isEmpty) {
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

      if (resItem["type"] == QuestionTypes.singleLine.value ||
          resItem["type"] == QuestionTypes.multiLine.value) {
        resItem["response"] = "";
      } else if (resItem["type"] == QuestionTypes.multipleChoice.value ||
          resItem["type"] == QuestionTypes.dropdown.value) {
        resItem["selected"] = 0;
      } else if (resItem["type"] == QuestionTypes.checkbox.value) {
        resItem["checked"] = [];
      }

      response["content"].add(resItem);
    }
  }

  void catchError() {
    if (!mounted) return;
    if (context.read<NearbyService>().error != null ||
        (context.read<NearbyService>().connectedDevices.isEmpty &&
            (isSharing ?? false))) {
      // developer.log(context.read<NearbyService>().error.toString());
      Provider.of<NearbyService>(context, listen: false).payloads = [{}];
      context.read<NearbyService>().error = null;
      // ModalRoute.of(context)?.settings.name == "/responsePage" ? Navigator.pop(context) : null;
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> payloads =
        context.watch<NearbyService>().payloads.reversed.toList();

    return WillPopScope(
        onWillPop: () {
          context.read<PageController>().jumpToPage(Pages.sampleFrontend.index);
          return Future.value(false);
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Color.fromARGB(255, 248, 246, 246),
          appBar: PreferredSize(
            preferredSize:
                Size.fromHeight(MediaQuery.of(context).size.height * 0.18),
            child: Stack(
              children: [
                Container(
                    height: MediaQuery.of(context).size.height * 0.37,
                    decoration: BoxDecoration(color: Color(0XFF50C2C9)),
                    child: Stack(children: [
                      Positioned(
                          top: -10,
                          right: -110,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.24,
                            width: 200,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0x738FE1D7)),
                          )),
                      Positioned(
                          bottom: -110,
                          right: 0,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.28,
                            width: 200,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0x738FE1D7)),
                          )),
                    ])),
                MyAppBar()
              ],
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                // if (isSharing!) ...[

                // ],
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      if (isSharing == null) ...[
                        const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0XFF50C2C9))),
                      ] else if (!isSharing!) ...[
                        Expanded(
                            child: Column(children: [
                          Expanded(
                            child: ListView(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(top: 10, left: 10),
                                    child: Text(
                                      form['title'],
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 21,
                                          letterSpacing: 0.9,
                                          fontWeight: FontWeight.w600),
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        top: 10, bottom: 10, left: 10),
                                    child: Text(
                                      form['description'],
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 15,
                                          letterSpacing: 0.9),
                                    )),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: form['content'].length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 248, 246, 246),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          boxShadow: [
                                            BoxShadow(
                                              offset: Offset(0, 1),
                                              blurRadius: 3,
                                              color: Color.fromARGB(47, 0, 0, 0)
                                                  .withOpacity(0.3),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        child: ListView(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          children: [
                                            Text(
                                                form['content'][index]['title'],
                                                style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 16,
                                                    letterSpacing: 0.9)),
                                            if (form['content'][index]
                                                        ['type'] ==
                                                    QuestionTypes
                                                        .singleLine.value ||
                                                form['content'][index]
                                                        ['type'] ==
                                                    QuestionTypes
                                                        .multiLine.value) ...[
                                              TextFormField(
                                                controller: controllers[index],
                                                keyboardType: (form['content']
                                                            [index]['type'] ==
                                                        QuestionTypes
                                                            .singleLine.value)
                                                    ? TextInputType.text
                                                    : TextInputType.multiline,
                                                maxLines: (form['content']
                                                            [index]['type'] ==
                                                        QuestionTypes
                                                            .singleLine.value)
                                                    ? 1
                                                    : null,
                                                onChanged: (value) {
                                                  response['content'][index]
                                                      ['response'] = value;
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 5),
                                                  border:
                                                      UnderlineInputBorder(),
                                                ),
                                              )
                                            ] else if (form['content'][index]
                                                        ['type'] ==
                                                    QuestionTypes
                                                        .multipleChoice.value ||
                                                form['content'][index]
                                                        ['type'] ==
                                                    QuestionTypes
                                                        .checkbox.value) ...[
                                              ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: form['content']
                                                        [index]['options']
                                                    .length,
                                                itemBuilder: (context, index2) {
                                                  return Row(
                                                    children: [
                                                      if (form['content'][index]
                                                              ['type'] ==
                                                          QuestionTypes
                                                              .multipleChoice
                                                              .value)
                                                        Radio(
                                                            value: index2,
                                                            groupValue: response['content']
                                                                    [index]
                                                                ['selected'],
                                                            onChanged: (value) {
                                                              setState(() {
                                                                response['content']
                                                                            [
                                                                            index]
                                                                        [
                                                                        'selected'] =
                                                                    value
                                                                        as int;
                                                              });
                                                            },
                                                            fillColor:
                                                                MaterialStateColor.resolveWith(
                                                                    (states) =>
                                                                        Color.fromARGB(
                                                                            255,
                                                                            80,
                                                                            195,
                                                                            201)),
                                                            focusColor:
                                                                MaterialStateColor.resolveWith(
                                                                    (states) =>
                                                                        Color.fromARGB(255, 112, 238, 245)))
                                                      else
                                                        Theme(
                                                            data: ThemeData(
                                                                unselectedWidgetColor:
                                                                    Color.fromARGB(
                                                                        255,
                                                                        80,
                                                                        195,
                                                                        201)),
                                                            child: Checkbox(
                                                              checkColor: Colors
                                                                  .white, // color of tick Mark
                                                              activeColor: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      80,
                                                                      195,
                                                                      201),
                                                              value: response['content']
                                                                          [
                                                                          index]
                                                                      [
                                                                      'checked']
                                                                  .contains(
                                                                      index2),
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  if (value ==
                                                                      true) {
                                                                    response['content'][index]
                                                                            [
                                                                            'checked']
                                                                        .add(
                                                                            index2);
                                                                  } else {
                                                                    response['content'][index]
                                                                            [
                                                                            'checked']
                                                                        .remove(
                                                                            index2);
                                                                  }
                                                                });
                                                              },
                                                            )),
                                                      Text(
                                                        form['content'][index]
                                                            ['options'][index2],
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 14,
                                                            letterSpacing: 0.9),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              )
                                            ] else if (form['content'][index]
                                                    ['type'] ==
                                                QuestionTypes
                                                    .dropdown.value) ...[
                                              DropdownButton(
                                                value: response['content']
                                                    [index]['selected'],
                                                items: form['content'][index]
                                                        ['options']
                                                    .map<DropdownMenuItem<int>>(
                                                      (e) =>
                                                          DropdownMenuItem<int>(
                                                        value: form['content']
                                                                    [index]
                                                                ['options']
                                                            .indexOf(e),
                                                        child: Text(
                                                          e,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Poppins',
                                                              fontSize: 14,
                                                              letterSpacing:
                                                                  0.9),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    response['content'][index]
                                                            ['selected'] =
                                                        value as int;
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
                                Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      "Response sent: ${context.watch<NearbyService>().payloads[0].containsKey('sent') ? context.watch<NearbyService>().payloads[0]['sent'].toString() : "false"}",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.black54,
                                        fontSize: 15,
                                      ),
                                    )),
                                Padding(
                                    padding:
                                        EdgeInsets.only(top: 10, bottom: 20),
                                    child: ElevatedButton(
                                        style: flatButtonStyle,
                                        onPressed: () {
                                          if (context
                                              .read<NearbyService>()
                                              .payloads[0]
                                              .containsKey("device_id")) {
                                            NearbyService().requestConnection(
                                                context
                                                    .read<NearbyService>()
                                                    .payloads[0]['device_id']
                                                    .toString(),
                                                jsonEncode(response));
                                          }
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: const Text(
                                            'Send',
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 18.0,
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                fontWeight: FontWeight.w300,
                                                letterSpacing: 1),
                                          ),
                                        ))),
                              ],
                            ),
                          )
                        ])),
                      ] else ...[
                        Expanded(
                          child: ListView.builder(
                            itemCount:
                                context.watch<NearbyService>().payloads.length,
                            itemBuilder: (context, index) {
                              if (!payloads[index].containsKey("contentType"))
                                return Container();
                              if (payloads[index]["contentType"] == "ack" ||
                                  payloads[index]["contentType"] == "file" ||
                                  payloads[index]["contentType"] == "camera")
                                return Container();

                              return GestureDetector(
                                onTap: () {
                                  if (payloads[index]["contentType"] ==
                                      "filename") {
                                    developer.log("Called");
                                    OpenFilex.open(
                                            "/storage/emulated/0/Download/${payloads[index]['filename']}")
                                        .catchError((obj) {});
                                  }
                                },
                                child: Container(
                                  alignment: payloads[index].containsKey("sent")
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  padding: EdgeInsets.only(
                                    top: 5,
                                    left: (payloads[index].containsKey("sent"))
                                        ? MediaQuery.of(context).size.width *
                                            0.1
                                        : 0,
                                    right: (!payloads[index]
                                            .containsKey("sent"))
                                        ? MediaQuery.of(context).size.width *
                                            0.1
                                        : 0,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: payloads[index].containsKey("sent")
                                          ? chatSentColor
                                          : chatReceiveColor,
                                    ),
                                    child: Text(
                                      (payloads[index]["contentType"] == "text")
                                          ? payloads[index]["content"]
                                              .toString()
                                          : (payloads[index]["contentType"] ==
                                                  "filename")
                                              ? payloads[index]["filename"]
                                                  .toString()
                                              : payloads[index].toString(),
                                      style: TextStyle(
                                          color: payloads[index]
                                                  .containsKey("sent")
                                              ? Colors.white
                                              : Color.fromARGB(167, 0, 0, 0),
                                          fontFamily: 'Poppins',
                                          letterSpacing: 0.5,
                                          fontSize: 15.0),
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
                                  if (value.isNotEmpty) {
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
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles();
                                // developer.log(result?.files.single.path ?? "");
                                // showSnackbar(result);
                                if (result?.files.single.path == null) return;

                                File file = File(result!.files.single.path!);
                                NearbyService().sendFilePayload(file);
                                // developer.log('{"type": "share", "contentType": "filename", "content": "${file.path.split('/').last}}"');
                              },
                            ),
                            (!isCameraOpen)
                                ? IconButton(
                                    icon: const Icon(Icons.camera_alt),
                                    onPressed: () async {
                                      List<CameraDescription> cameras =
                                          await availableCameras();
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
                                        NearbyService().sendBytesPayload({
                                          "type": "share",
                                          "contentType": "camera",
                                          "content": "open",
                                        }, addToPayloads: false);
                                      });
                                    },
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () async {
                                      setState(() {
                                        isCameraOpen = false;
                                      });
                                      NearbyService().sendBytesPayload({
                                        "type": "share",
                                        "contentType": "camera",
                                        "content": "close",
                                      }, addToPayloads: false);
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
                if (payloads[payloads.length - 1]["contentType"] == "camera" &&
                    payloads[payloads.length - 1]["content"] == "open")
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Color.fromARGB(255, 248, 246, 246),
                    alignment: Alignment.center,
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Column(
                          children: [
                            Padding(
                                padding: EdgeInsets.only(bottom: 20),
                                child: Text(
                                  "CLICK PICTURE",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                      color: Color(0XFF50C2C9)),
                                )),
                            ElevatedButton(
                              child: IconButton(
                                iconSize: 40.0,
                                icon: const Icon(Icons.camera_alt),
                                onPressed: null,
                              ),
                              onPressed: () async {
                                NearbyService().sendBytesPayload({
                                  "type": "share",
                                  "contentType": "camera",
                                  "content": "clickImage",
                                }, addToPayloads: false);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(15),
                                backgroundColor:
                                    Color.fromARGB(164, 80, 195, 201),
                                minimumSize: Size(88, 36),
                              ),
                            )
                          ],
                        )),
                  ),
                if (isCameraOpen && controller != null)
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
                              NearbyService().sendBytesPayload({
                                "type": "share",
                                "contentType": "camera",
                                "content": "close",
                              }, addToPayloads: false);
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
        ));
  }
}
