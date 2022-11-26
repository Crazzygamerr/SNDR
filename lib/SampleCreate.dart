import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_excel/excel.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:sdl/NearbyService.dart';
import 'package:sdl/main.dart';

class SampleCreate extends StatefulWidget {
  const SampleCreate({Key? key}) : super(key: key);

  @override
  SampleCreateState createState() => SampleCreateState();
}

// final List<String> formType = ['Attendance', 'Quiz', 'FormType1', 'Club'];
bool isChecked = false;

const _lowColor = Colors.black38;
const _highColor = const Color.fromARGB(161, 80, 195, 201);

const _lowBgColor = Colors.white;

Color _fieldColor = _lowColor;

Color _textColor = Colors.black38;

const _lowDescColor = Colors.black38;
const _highDescColor = const Color.fromARGB(161, 80, 195, 201);

Color _fieldDescColor = _lowDescColor;

class SampleCreateState extends State<SampleCreate> {
  // @override
  // void initState() {
  //   // void activate() {
  //   super.initState();
  //   super.activate();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<NearbyService>().removeListener(catchError);
  //     context.read<NearbyService>().removeListener(goToConnectedPage);
  //     context.read<NearbyService>().addListener(catchError);
  //     context.read<NearbyService>().addListener(goToConnectedPage);
  //   });
  //   // developer.log("init");
  //   // startDis();
  //   // WidgetsBinding.instance.addPostFrameCallback((_) {
  //   //   context.read<NearbyService>().payloads = [{}];
  //   // });
  // }

  // void catchError() {
  //   if (!mounted) return;
  //   if (context.read<NearbyService>().error != null) {
  //     // if(context.read<NearbyService>().isAdvertising) {
  //     //   context.read<NearbyService>().startAdvertising(form);
  //     // }
  //     context.read<NearbyService>().error = null;
  //   }
  // }

  // void goToConnectedPage() {
  //   if (!mounted) return;
  //   if (context.read<NearbyService>().connectedDevices.isNotEmpty &&
  //       isSharing &&
  //       !context.read<NearbyService>().payloads[0].containsKey("contentType")) {
  //     Provider.of<NearbyService>(context, listen: false).payloads = [
  //       {"type": "share", "contentType": "ack"}
  //     ];
  //     Navigator.of(context).pushNamed('/sampleResponsePage').then((value) {
  //       context.read<NearbyService>().payloads = [{}];
  //       NearbyService().stopAllEndpoints();
  //       NearbyService().startAdvertising(shareMsg, isSharing: true);
  //     });
  //   }
  // }

  // @override
  // void dispose() {
  //   NearbyService().stopAdvertising();
  //   NearbyService().stopDiscovery();
  //   NearbyService().stopAllEndpoints();
  //   // context.read<NearbyService>().removeListener(catchError);
  //   // context.read<NearbyService>().removeListener(goToConnectedPage);
  //   super.dispose();
  // }

  Map<String, dynamic> shareMsg = {
    "type": "share",
    "contentType": "ack",
  };
  Map<String, dynamic> form = {
    "type": "form",
    "title": "Untitled Form",
    "description": "",
    "content": [
      {
        "type": QuestionTypes.singleLine.value,
        "title": "Untitled Question",
        "options": ["Option 1"],
      }
    ],
  };
  
  final bool _fileExists = false;
  late File _filePath;
  final Map<String, dynamic> _json = {};
  late String _jsonString;

  bool isSharing = false;
  TextEditingController titleController =
          TextEditingController(text: "Untitled Form"),
      descriptionController = TextEditingController();
  List<TextEditingController> questionControllers = [
    TextEditingController(text: "Untitled Question")
  ];
  List<List<TextEditingController>> optionControllers = [
    [TextEditingController(text: "Option 1")]
  ];

  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    backgroundColor: const Color(0XFF50C2C9),
    minimumSize: const Size(88, 36),
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
  );

  void exportResponse() async {
    // print("-----------------");
    // print(await getExternalStorageDirectory());
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    context.read<NearbyService>().payloads.forEach((element) {
      if (element.containsKey("content")) {
        List<String> row = [element["device_id"]];
        element["content"].forEach((element) {
          if (element["type"] == QuestionTypes.singleLine.value ||
              element["type"] == QuestionTypes.multiLine.value) {
            row.add(element["response"]);
          } else if (element["type"] == QuestionTypes.checkbox.value) {
            String checked = "";
            for (int i = 0; i < element["checked"].length; i++) {
              checked += element["options"][element["checked"][i]];
              if (i != element["checked"].length - 1) checked += ", ";
            }
            row.add(checked);
          } else if (element["type"] == QuestionTypes.multipleChoice.value ||
              element["type"] == QuestionTypes.dropdown.value) {
            row.add(element["options"][element["selected"]]);
          }
        });
        sheet.appendRow(row);
      }
    });

    var bytes = excel.save();
    File(path.join("/storage/emulated/0/Download/", "Responses.xlsx"))
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes ?? []);
  }
  
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if(Provider.of<NearbyService>(context, listen: false).savedForm.isNotEmpty) {
    //     setForm();
    //   }
    // });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(Provider.of<NearbyService>(context, listen: false).savedForm != null && Provider.of<NearbyService>(context, listen: false).savedForm!.isNotEmpty) {
      setForm();
    }
  }
  
  Future<void> setForm() async {
    // print(Provider.of<NearbyService>(context, listen: false).savedForm);
    form = jsonDecode(jsonEncode(Provider.of<NearbyService>(context, listen: false).savedForm));
    Provider.of<NearbyService>(context, listen: false).savedForm = null;
    
    titleController.text = form["title"];
    descriptionController.text = form["description"];
    optionControllers = [];
    questionControllers = [];
    
    for (int i = 0; i < form["content"].length; i++) {
      questionControllers.add(TextEditingController(text: form["content"][i]["title"]));
      List<TextEditingController> temp = [];
      for (int j = 0; j < form["content"][i]["options"].length; j++) {
        temp.add(TextEditingController(text: form["content"][i]["options"][j]));
      }
      optionControllers.add(temp);
    }
    
    setState(() {});
  }


  // Future<String> readFile(String path) async {
  //   return await File(path).readAsString();
  // }

  // Future<String> get _localPath async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   return directory.path;
  // }

  // Future<File> get _localFile async {
  //   final path = await _localPath;
  //   String txt=titleController.text.toString();
  //   return File('$path/$txt''.json');
  // }

  // void _writeJson() async {
  //   Map<String, dynamic> _newJson = {key: value};
  //   _json.addAll(_newJson);

  //   _jsonString = jsonEncode(_json);

  //   _filePath.writeAsString(_jsonString);
  // }

  // void _readJson() async {
  //   _filePath = await _localFile;

  //   _fileExists = await _filePath.exists();

  //   if (_fileExists) {
  //     try {
  //       _jsonString = await _filePath.readAsString();
  //       _json = jsonDecode(_jsonString);
  //     } catch (e) {
  //       print('Tried reading _file error: $e');
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> payloads =
        context.watch<NearbyService>().payloads;

    return WillPopScope(
        onWillPop: () {
          context
              .read<PageController>()
              .jumpToPage(Pages.home.index);
          return Future.value(false);
        },
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: const Color.fromARGB(255, 248, 246, 246),
            body: SafeArea(
                child: SingleChildScrollView(
                    child: Column(children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.28,
                  child: Stack(children: [
                    Positioned(
                        top: -10,
                        left: -110,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.28,
                          width: 230,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Color(0x738FE1D7)),
                        )),
                    Positioned(
                        top: -110,
                        left: 0,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.28,
                          width: 230,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Color(0x738FE1D7)),
                        )),
                  ])),
              const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('Create Form',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 21.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ))),
              const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Let’s create a form',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 17.0,
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  )),
              Container(
                  width: MediaQuery.of(context).size.width * 0.88,
                  padding: const EdgeInsets.only(top: 29, bottom: 5),
                  child: ListView(
                    primary: false,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Padding(
                      //   padding:
                      //       EdgeInsets.only(left: 8, right: 8, top: 50, bottom: 15),
                      //   child: SizedBox(
                      //     width: MediaQuery.of(context).size.width * 0.88,
                      //     height: MediaQuery.of(context).size.width * 0.14,
                      //     child: TextField(
                      //         textAlign: TextAlign.left,
                      //         decoration: InputDecoration(
                      //             hintText: 'Room Name',
                      //             hintStyle:
                      //                 TextStyle(fontFamily: 'Poppins', fontSize: 13),
                      //             focusedBorder: OutlineInputBorder(
                      //                 borderSide: BorderSide(
                      //                     width: 3,
                      //                     color: Color.fromARGB(161, 80, 195, 201)),
                      //                 borderRadius: BorderRadius.circular(50)),
                      //             filled: true,
                      //             fillColor: Colors.white,
                      //             border: OutlineInputBorder(
                      //                 borderSide: BorderSide.none,
                      //                 borderRadius: BorderRadius.circular(50)))),
                      //   )),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(75.0)),
                        ),
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        height: 55, //gives the height of the dropdown button
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            value: context.watch<NearbyService>().isSharing,
                            onChanged: (v) => setState(() {
                              context.read<NearbyService>().isSharing =
                                  v as bool;
                            }),
                            items: const [
                              DropdownMenuItem(
                                value: true,
                                child: Text("Share"),
                              ),
                              DropdownMenuItem(
                                value: false,
                                child: Text("Form"),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (!context.watch<NearbyService>().isSharing) ...[
                        Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 248, 246, 246),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(9)),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0, 1),
                                  blurRadius: 5,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ],
                            ),
                            child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0,
                                    right: 8.0,
                                    top: 8.0,
                                    bottom: 8.0),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'Username',
                                        labelStyle: TextStyle(
                                        backgroundColor: Colors.white,
                                        fontFamily: 'Poppins'),

                                    contentPadding:
                                        EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        borderSide: BorderSide(
                                            width: 2,
                                            color: Color.fromARGB(
                                                161, 80, 195, 201))),
                                    filled: true,
                                    fillColor: Colors.white,
                                      ),
                                      initialValue: Provider.of<NearbyService>(context, listen: false).userName.toString(),
                                      onChanged: (v) => Provider.of<NearbyService>(context, listen: false).userName=v,
                                    ),
                                    const SizedBox(height: 10),
                                    Focus(
                                        onFocusChange: (hasFocus) {
                                          setState(() => {
                                                _fieldColor = hasFocus
                                                    ? _highColor
                                                    : _lowColor,
                                              });
                                        },
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            labelText: 'Form Title',
                                            // labelStyle: TextStyle(
                                            //     color: Color.fromARGB(161, 80, 195, 201),
                                            //     backgroundColor: Color(0xFFE6E6E6)),
                                            labelStyle: TextStyle(
                                                color: _fieldColor,
                                                backgroundColor: Colors.white,
                                                fontFamily: 'Poppins'),

                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5),
                                            border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0)),
                                                borderSide: BorderSide(
                                                    width: 2,
                                                    color: Color.fromARGB(
                                                        161, 80, 195, 201))),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          controller: titleController,
                                          onChanged: (v) =>
                                              setState(() => form["title"] = v),
                                        )),
                                    const SizedBox(height: 10),
                                    Focus(
                                        onFocusChange: (hasFocus) {
                                          setState(() => {
                                                _fieldDescColor = hasFocus
                                                    ? _highDescColor
                                                    : _lowDescColor,
                                              });
                                        },
                                        child: TextFormField(
                                          keyboardType: TextInputType.multiline,
                                          maxLines: null,
                                          controller: descriptionController,
                                          onChanged: (v) => setState(
                                              () => form["description"] = v),
                                          decoration: InputDecoration(
                                            labelText: 'Form Description',
                                            labelStyle: TextStyle(
                                                color: _fieldDescColor,
                                                backgroundColor: Colors.white,
                                                fontFamily: 'Poppins'),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5),
                                            border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0)),
                                                borderSide: BorderSide(
                                                    width: 2,
                                                    color: Color.fromARGB(
                                                        161, 80, 195, 201))),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                        )),
                                  ],
                                ))),
                        const SizedBox(height: 20),
                        ListView.builder(
                          itemCount: form["content"].length,
                          primary: false,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Card(
                                child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 248, 246, 246),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                                boxShadow: [
                                  BoxShadow(
                                    offset: const Offset(0, 1),
                                    blurRadius: 5,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: questionControllers[index],
                                          decoration: const InputDecoration(
                                              labelText: 'Question Title',
                                              labelStyle: TextStyle(
                                                fontFamily: 'Poppins',
                                                color: Color.fromARGB(
                                                    255, 80, 185, 201),
                                                fontSize: 15,
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              filled: true,
                                              fillColor: Colors.white,
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              10.0)),
                                                  borderSide: BorderSide(
                                                      width: 2,
                                                      color: Color.fromARGB(
                                                          161, 80, 195, 201))),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(75.0)),
                                                borderSide: BorderSide.none,
                                              )),
                                              onChanged: (v) => setState(() => form["content"][index]["title"] = v),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => setState(() {
                                          form["content"].removeAt(index);
                                          optionControllers.removeAt(index);
                                          questionControllers.removeAt(index);
                                        }),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.only(
                                            top: 10,
                                          ),
                                          child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(75.0)),
                                              ),
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 10),
                                              height:
                                                  55, //gives the height of the dropdown button
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5,
                                              child:
                                                  DropdownButtonHideUnderline(
                                                      child: DropdownButton(
                                                items: QuestionTypes.values
                                                    .map((e) =>
                                                        DropdownMenuItem(
                                                          value: e.value,
                                                          child: Text(
                                                            e.name,
                                                            style: const TextStyle(
                                                                fontFamily:
                                                                    'Poppins',
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black54),
                                                          ),
                                                        ))
                                                    .toList(),
                                                onChanged: (v) => setState(() =>
                                                    form["content"][index]
                                                        ["type"] = v),
                                                value: form["content"][index]
                                                    ["type"],
                                              )))),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Padding(
                                          padding: EdgeInsets.only(
                                            left: 10,
                                          ),
                                          child: Text(
                                            "Is Required : ",
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.black54,
                                              fontSize: 13,
                                            ),
                                          )),
                                      Switch(
                                        activeColor:
                                            const Color.fromARGB(212, 80, 195, 201),
                                        activeTrackColor:
                                            const Color.fromARGB(69, 80, 195, 201),
                                        inactiveThumbColor: Colors.grey,
                                        inactiveTrackColor: Colors.grey[400],
                                        // value: isChecked,
                                        // onChanged: (bool value) {
                                        //   setState(() {
                                        //     isChecked = value;
                                        //   });
                                        //  },

                                        value: form["content"][index]
                                                ["isRequired"] ??
                                            false,
                                        onChanged: (v) => setState(() =>
                                            form["content"][index]
                                                ["isRequired"] = v),
                                      ),
                                    ],
                                  ),
                                  if (form["content"][index]["type"] ==
                                          QuestionTypes.multipleChoice.value ||
                                      form["content"][index]["type"] ==
                                          QuestionTypes.checkbox.value ||
                                      form["content"][index]["type"] ==
                                          QuestionTypes.dropdown.value) ...[
                                    const SizedBox(height: 10),
                                    ListView.builder(
                                      itemCount: form["content"][index]
                                              ["options"]
                                          .length,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      primary: false,
                                      itemBuilder: (context, index2) {
                                        return Row(
                                          children: [
                                            if (form["content"][index]
                                                    ["type"] ==
                                                QuestionTypes
                                                    .multipleChoice.value)
                                              Radio(
                                                value: null,
                                                groupValue: null,
                                                onChanged: null,
                                                fillColor: MaterialStateColor
                                                    .resolveWith((states) =>
                                                        const Color.fromARGB(
                                                            150, 80, 195, 201)),
                                                focusColor: MaterialStateColor
                                                    .resolveWith((states) =>
                                                        const Color.fromARGB(
                                                            212, 80, 195, 201)),
                                              ),
                                            if (form["content"][index]
                                                    ["type"] ==
                                                QuestionTypes.checkbox.value)
                                              Theme(
                                                  data: Theme.of(context)
                                                      .copyWith(
                                                    unselectedWidgetColor:
                                                        const Color.fromARGB(
                                                            255, 255, 255, 255),
                                                  ),
                                                  child: const Checkbox(
                                                    value: false,
                                                    onChanged: null,
                                                  )),
                                            Expanded(
                                              child: TextFormField(
                                                decoration:
                                                    const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 5),
                                                  border:
                                                      UnderlineInputBorder(),
                                                ),
                                                onChanged: (v) => setState(() =>
                                                    form["content"][index]
                                                            ["options"]
                                                        [index2] = v),
                                                controller:
                                                    optionControllers[index]
                                                        [index2],
                                              ),
                                            ),
                                            IconButton(
                                                icon: const Icon(Icons.close),
                                                onPressed: () {
                                                  setState(() => form["content"]
                                                          [index]["options"]
                                                      .removeAt(index2));
                                                  optionControllers[index]
                                                      .removeAt(index2);
                                                  questionControllers
                                                      .removeAt(index2);
                                                }),
                                          ],
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            style: flatButtonStyle,
                                            onPressed: () {
                                              setState(() => form["content"]
                                                      [index]["options"]
                                                  .add(""));
                                              optionControllers[index]
                                                  .add(TextEditingController());
                                              questionControllers
                                                  .add(TextEditingController());
                                            },
                                            child: const Text("Add Option",
                                                style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 13.0,
                                                    fontWeight: FontWeight.w100,
                                                    letterSpacing: 1.2)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ));
                          },
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: flatButtonStyle,
                          onPressed: () => setState(() {
                            form["content"].add({
                              "type": QuestionTypes.singleLine.value,
                              "title": "Untitled Question",
                              "options": [
                                "Option 1",
                              ],
                            });
                            optionControllers.add([
                              TextEditingController(text: "Option 1"),
                            ]);
                            questionControllers.add(TextEditingController());
                          }),
                          child: const Text(
                            'Add Question',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15.0,
                                fontWeight: FontWeight.w200,
                                letterSpacing: 1.2),
                          ),
                        ),
                      ],

                      Text(
                          "Is open: ${context.watch<NearbyService>().isAdvertising}",
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.0,
                              letterSpacing: 1.2)),
                      // Text(const JsonEncoder.withIndent("  ").convert(form)),

                      Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: flatButtonStyle,
                                onPressed: () {
                                  NearbyService().stopAdvertising();
                                  // developer.log(QuestionTypes.dropdown.value);
                                  // developer.log(const JsonEncoder.withIndent("  ").convert(form));
                                },
                                child: const Text('Close',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2)),
                              ),
                              ElevatedButton(
                                style: flatButtonStyle,
                                onPressed: () async {
                                  NearbyService().writeJson(titleController.text, form);
                                },
                                child: const Text('Save'),
                              ),
                              ElevatedButton(
                                style: flatButtonStyle,
                                onPressed: () {
                                  NearbyService().startAdvertising(
                                      context.read<NearbyService>().isSharing
                                          ? shareMsg
                                          : form);
                                },
                                child: const Text('Open',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2)),
                              ),
                            ],
                          )),

                      // ElevatedButton(
                      //   onPressed: () {
                      //     // developer.log(jsonEncode(form).runtimeType.toString());
                      //     // developer.log(jsonDecode('{"type":"form","fields":[{"id":1,"title":"What is your name?"},{"id":2,"title":"What is your age?"}]}').runtimeType.toString());
                      //     developer.log(context.read<NearbyService>().payloads.toString());
                      //   },
                      //   child: const Text('Test'),
                      // ),
                    ],
                  )),

              // Text(const JsonEncoder.withIndent(" ").convert(payloads)),
              if(payloads[0].isNotEmpty) const Text(
                "Responses",
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17.0,
                    letterSpacing: 1.2),
              ),
              ListView.builder(
                itemCount: payloads.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, responseIndex) {
                  if (payloads[responseIndex].isEmpty ||
                      !payloads[responseIndex].containsKey("content")) {
                    return Container();
                  }
                  return Container(
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 248, 246, 246)),
                      child: Column(children: [
                        ExpansionTile(
                            // title: Text(payloads[responseIndex]["name"]),
                            onExpansionChanged: (expanded) {
                              setState(() {
                                if (expanded) {
                                  _textColor =
                                      const Color.fromARGB(255, 80, 185, 201);
                                } else {
                                  _textColor = Colors.black45;
                                }
                              });
                            },
                            title: Text(
                              payloads[responseIndex]["device_id"],
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  letterSpacing: 1.2,
                                  color: _textColor),
                            ),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Text(
                                          "${payloads[responseIndex]["device_id"]}",
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            letterSpacing: 1.2,
                                          ),
                                        )),
                                    ListView.builder(
                                      itemCount: payloads[responseIndex]
                                              ["content"]
                                          .length,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, questionIndex) {
                                        return Padding(
                                            padding: questionIndex ==
                                                    payloads.length - 1
                                                ? const EdgeInsets.fromLTRB(
                                                    8, 0, 8, 0)
                                                : const EdgeInsets.all(8),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: const Color.fromARGB(
                                                      255, 248, 246, 246),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(5)),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      offset: const Offset(0, 1),
                                                      blurRadius: 3,
                                                      color: const Color.fromARGB(
                                                              47, 0, 0, 0)
                                                          .withOpacity(0.3),
                                                    ),
                                                  ],
                                                ),
                                                padding: const EdgeInsets.all(10.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        payloads[responseIndex]
                                                                    ['content']
                                                                [questionIndex]
                                                            ["title"],
                                                        style: const TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 14,
                                                            letterSpacing:
                                                                0.9)),
                                                    if (payloads[responseIndex]['content'][questionIndex]["type"] == QuestionTypes.singleLine.value ||
                                                        payloads[responseIndex]['content']
                                                                    [questionIndex]
                                                                ["type"] ==
                                                            QuestionTypes
                                                                .multiLine
                                                                .value) ...[
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                  top: 10.0),
                                                          child: Text(
                                                            payloads[responseIndex]
                                                                        [
                                                                        'content']
                                                                    [
                                                                    questionIndex]
                                                                ["response"],
                                                            style: const TextStyle(
                                                                fontFamily:
                                                                    'Poppins',
                                                                fontSize: 14,
                                                                letterSpacing:
                                                                    0.9,
                                                                color: Color
                                                                    .fromARGB(
                                                                        158,
                                                                        46,
                                                                        32,
                                                                        32)),
                                                          )),
                                                    ] else if (payloads[responseIndex]['content'][questionIndex]['type'] == QuestionTypes.multipleChoice.value ||
                                                        payloads[responseIndex]
                                                                        ['content']
                                                                    [questionIndex]
                                                                ['type'] ==
                                                            QuestionTypes
                                                                .checkbox
                                                                .value) ...[
                                                      ListView.builder(
                                                        shrinkWrap: true,
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        itemCount: payloads[responseIndex]
                                                                        [
                                                                        'content']
                                                                    [
                                                                    questionIndex]
                                                                ['options']
                                                            .length,
                                                        itemBuilder: (context,
                                                            optionIndex) {
                                                          return Row(
                                                            children: [
                                                              if (payloads[responseIndex]
                                                                              ['content']
                                                                          [questionIndex][
                                                                      'type'] ==
                                                                  QuestionTypes
                                                                      .multipleChoice
                                                                      .value)
                                                                Radio(
                                                                    value:
                                                                        optionIndex,
                                                                    groupValue: payloads[responseIndex]['content']
                                                                            [questionIndex][
                                                                        'selected'],
                                                                    onChanged:
                                                                        null,
                                                                    )
                                                              else
                                                                Theme(
                                                                    data: ThemeData(
                                                                        unselectedWidgetColor: const Color.fromARGB(
                                                                            255,
                                                                            80,
                                                                            195,
                                                                            201)),
                                                                    child:
                                                                        Checkbox(
                                                                      value: payloads[responseIndex]['content'][questionIndex]
                                                                              [
                                                                              'checked']
                                                                          .contains(
                                                                              optionIndex),
                                                                      onChanged:
                                                                          null,
                                                                      checkColor: const Color.fromARGB(
                                                                          255,
                                                                          255,
                                                                          255,
                                                                          255), // color of tick Mark
                                                                      activeColor:
                                                                          const Color(
                                                                              0xFF3BCBD2),
                                                                    )),
                                                              Text(
                                                                  payloads[responseIndex]['content']
                                                                              [
                                                                              questionIndex]
                                                                          [
                                                                          'options']
                                                                      [
                                                                      optionIndex],
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          'Poppins',
                                                                      fontSize:
                                                                          14,
                                                                      letterSpacing:
                                                                          0.9)),
                                                            ],
                                                          );
                                                        },
                                                      )
                                                    ] else if (payloads[responseIndex]
                                                                ['content']
                                                            [questionIndex]['type'] ==
                                                        QuestionTypes.dropdown.value) ...[
                                                      DropdownButton(
                                                        value: payloads[responseIndex]
                                                                    ['content']
                                                                [questionIndex]
                                                            ['selected'],
                                                        items: payloads[responseIndex]
                                                                        [
                                                                        'content']
                                                                    [
                                                                    questionIndex]
                                                                ['options']
                                                            .map<
                                                                DropdownMenuItem<
                                                                    int>>(
                                                              (e) =>
                                                                  DropdownMenuItem<
                                                                      int>(
                                                                value: payloads[responseIndex]['content']
                                                                            [
                                                                            questionIndex]
                                                                        [
                                                                        'options']
                                                                    .indexOf(e),
                                                                child: Text(e,
                                                                    style: const TextStyle(
                                                                        fontFamily:
                                                                            'Poppins',
                                                                        fontSize:
                                                                            14,
                                                                        letterSpacing:
                                                                            0.9)),
                                                              ),
                                                            )
                                                            .toList(),
                                                        onChanged: null,
                                                      )
                                                    ],
                                                  ],
                                                )));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                        
                      ]));
                },
              ),
              if(payloads[0].isNotEmpty) Container(
                margin: const EdgeInsets.all(25),
                padding: const EdgeInsets.only(top: 28, bottom: 28),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.88,
                  height: 60.0,
                  child: ElevatedButton(
                    style: flatButtonStyle,
                    onPressed: () {
                      exportResponse();
                    },
                    child: const Text(
                      "Export Responses",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2),
                    ),
                  ),
                )),
            ])))));
  }
}
