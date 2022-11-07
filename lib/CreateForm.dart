
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sdl/NearbyService.dart';
import 'dart:io';
// import 'package:intl/intl.dart';


class CreateForm extends StatefulWidget {
  // final FormType formType;
  
  const CreateForm({
    Key? key,
    // required this.formType
  }) : super(key: key);
  
  @override
  State<CreateForm> createState() => CreateFormState();
}

class CreateFormState extends State<CreateForm> {
  // String txt2="";
  bool _fileExists = false;
  late File _filePath;
  Map<String, dynamic> _json = {};
  late String _jsonString;
  // int counter=0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NearbyService>().removeListener(catchError);
      context.read<NearbyService>().removeListener(goToConnectedPage);
      context.read<NearbyService>().addListener(catchError);
      context.read<NearbyService>().addListener(goToConnectedPage);
    });

    _readJson();
  }

  // saveJson(source) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   // int counterValue = prefs.getInt("counter") ?? 0;
  //
  //   prefs.setString('counterValue',jsonDecode(source));
  //   // SharedPreferences prefs = await SharedPreferences.getInstance();
  //   // prefs.setString('stringValue', "abc");
  //   // setState(() {
  //   //   counter = counter+1
  //   // });
  // }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    String txt=form["title"].toString();
    return File('$path/$txt''.json');
  }

  void _writeJson(String key, dynamic value) async {

    Map<String, dynamic> _newJson = {key: value};

    _json.addAll(_newJson);

    _jsonString = jsonEncode(_json);

    _filePath.writeAsString(_jsonString);
  }
  //
  // void _writeJson(dynamic form) async {
  //
  //   _jsonString = jsonEncode(_json);
  //
  //     _filePath.writeAsString(_jsonString);
  // }



  void _readJson() async {
    _filePath = await _localFile;

    _fileExists = await _filePath.exists();

    if (_fileExists) {
      try {
        _jsonString = await _filePath.readAsString();
        _json = jsonDecode(_jsonString);
      } catch (e) {
        print('Tried reading _file error: $e');
      }
    }
  }
  
  void catchError() {
    if(!mounted) return;
    if(context.read<NearbyService>().error != null) {
      // if(context.read<NearbyService>().isAdvertising) {
      //   context.read<NearbyService>().startAdvertising(form);
      // }
      context.read<NearbyService>().error = null;
    }
  }
  
  void goToConnectedPage() {
    if(!mounted) return;
    if(
      context.read<NearbyService>().connectedDevices.isNotEmpty 
      && isSharing 
      && !context.read<NearbyService>().payloads[0].containsKey("contentType")
    ) {
      Provider.of<NearbyService>(context, listen: false).payloads = [{"type": "share", "contentType": "ack"}];
      Navigator.of(context).pushNamed('/responsePage').then((value) {
        context.read<NearbyService>().payloads = [{}];
        NearbyService().stopAllEndpoints();
        NearbyService().startAdvertising(shareMsg, isSharing: true);
      });
    }
  }
  
  @override
  void dispose() {
    NearbyService().stopAdvertising();
    NearbyService().stopDiscovery();
    NearbyService().stopAllEndpoints();
    // context.read<NearbyService>().removeListener(catchError);
    // context.read<NearbyService>().removeListener(goToConnectedPage);
    // _controllerKey.dispose();
    // _controllerValue.dispose();
    super.dispose();
  }
  
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
        "options": [
          "Option 1"
        ],
      }
    ],
  };
  
  bool isSharing = false;
  TextEditingController titleController = TextEditingController(text: "Untitled Form"), descriptionController = TextEditingController();
  List<List<TextEditingController>> optionControllers = [[TextEditingController(text: "Option 1")]];
  
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    List<Map<String, dynamic>> payloads = context.watch<NearbyService>().payloads;
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Create Form'),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: [
              InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    value: isSharing,
                    onChanged: (v) => setState(() => isSharing = v as bool),
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
              if(!isSharing)
              ...[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Form Title',
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    border: OutlineInputBorder(),
                  ),
                  controller: titleController,
                  onChanged: (v) => setState(() => form["title"] = v),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: descriptionController,
                  onChanged: (v) => setState(() => form["description"] = v),
                  decoration: const InputDecoration(
                    labelText: 'Form Description',
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  itemCount: form["content"].length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index){
                    return Card(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Question Title',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      border: UnderlineInputBorder(),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => setState(() {
                                    form["content"].removeAt(index); 
                                    optionControllers.removeAt(index);
                                  }),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("Question Type: "),
                                DropdownButton(
                                  items: QuestionTypes.values.map((e) => DropdownMenuItem(
                                    value: e.value,
                                    child: Text(e.name),
                                  )).toList(),
                                  onChanged: (v) => setState(() => form["content"][index]["type"] = v),
                                  value: form["content"][index]["type"],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("Is Required: "),
                                Switch(
                                  value: form["content"][index]["isRequired"] ?? false,
                                  onChanged: (v) => setState(() => form["content"][index]["isRequired"] = v),
                                ),
                              ],
                            ),
                            if(
                              form["content"][index]["type"] == QuestionTypes.multipleChoice.value
                              || form["content"][index]["type"] == QuestionTypes.checkbox.value
                              || form["content"][index]["type"] == QuestionTypes.dropdown.value
                              )
                            ...[
                              const SizedBox(height: 10),
                              ListView.builder(
                                itemCount: form["content"][index]["options"].length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index2) {
                                  return Row(
                                    children: [
                                      if(form["content"][index]["type"] == QuestionTypes.multipleChoice.value)
                                        const Radio(
                                          value: null,
                                          groupValue: null,
                                          onChanged: null,
                                        ),
                                      if(form["content"][index]["type"] == QuestionTypes.checkbox.value)
                                        const Checkbox(
                                          value: false,
                                          onChanged: null,
                                        ),
                                      Expanded(
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            border: UnderlineInputBorder(),
                                          ),
                                          onChanged: (v) => setState(() => form["content"][index]["options"][index2] = v),
                                          controller: optionControllers[index][index2],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () { 
                                          setState(() => form["content"][index]["options"].removeAt(index2));
                                          optionControllers[index].removeAt(index2);
                                        }
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() => form["content"][index]["options"].add(""));
                                        optionControllers[index].add(TextEditingController());
                                      },
                                      child: const Text("Add Option"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      )
                    );
                  },
                ),
                const SizedBox(height: 10),
                Card(
                  child: TextButton(
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
                    }),
                    child: const Text('Add Question'),
                  ),
                ),              
              ],  
              
              Text("Is open: ${context.watch<NearbyService>().isAdvertising}"),
              // Text(const JsonEncoder.withIndent("  ").convert(form)),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // NearbyService().stopAdvertising();
                      // developer.log(QuestionTypes.dropdown.value);
                      developer.log(const JsonEncoder.withIndent("  ").convert(form));
                    },
                    child: const Text('Close'),
                  ),
                  ElevatedButton(
                    onPressed: () async {

                      developer.log(const JsonEncoder.withIndent("  ").convert(form));
                      //
                      // // print(
                      // //     '0. Input key: ${_controllerKey.text}; Input value: ${_controllerValue.text}\n-\n');
                      // // counter=counter+1
                      // _writeJson(form);
                      _writeJson("${now.hour}:${now.minute}:${now.second}", form);
                      final file = await _localFile;
                      _fileExists = await file.exists();

                    },
                    child: const Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      NearbyService().startAdvertising(isSharing ? shareMsg : form, isSharing: isSharing);
                    },
                    child: const Text('Open'),
                  ),
                ],
              ),
              const Text("Responses"),
              // Text(const JsonEncoder.withIndent(" ").convert(payloads)),
              ListView.builder(
                itemCount: payloads.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, responseIndex) {
                  
                  if (payloads[responseIndex].isEmpty) return Container();
                  return ExpansionTile(
                    // title: Text(payloads[responseIndex]["name"]),
                    title: Text(payloads[responseIndex]["device_id"]),
                    children: [
                      Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text("${payloads[responseIndex]["device_id"]}")
                          ),
                          ListView.builder(
                            itemCount: payloads[responseIndex]["content"].length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, questionIndex) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(payloads[responseIndex]['content'][questionIndex]["title"]),
                                  if(payloads[responseIndex]['content'][questionIndex]["type"] == QuestionTypes.singleLine.value
                                    || payloads[responseIndex]['content'][questionIndex]["type"] == QuestionTypes.multiLine.value)
                                    ...[
                                      Text(payloads[responseIndex]['content'][questionIndex]["response"]),
                                    ]
                                  else if(payloads[responseIndex]['content'][questionIndex]['type'] == QuestionTypes.multipleChoice.value
                                    || payloads[responseIndex]['content'][questionIndex]['type'] == QuestionTypes.checkbox.value)
                                    ...[
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: payloads[responseIndex]['content'][questionIndex]['options'].length,
                                        itemBuilder: (context, optionIndex) {
                                          return Row(
                                            children: [
                                              if(payloads[responseIndex]['content'][questionIndex]['type'] == QuestionTypes.multipleChoice.value)
                                                Radio(
                                                  value: optionIndex,
                                                  groupValue: payloads[responseIndex]['content'][questionIndex]['selected'],
                                                  onChanged: null,
                                                )
                                              else
                                                Checkbox(
                                                  value: payloads[responseIndex]['content'][questionIndex]['checked'].contains(optionIndex),
                                                  onChanged: null,
                                                ),
                                              Text(payloads[responseIndex]['content'][questionIndex]['options'][optionIndex]),
                                            ],
                                          );
                                        },
                                      )
                                    ]
                                  else if(payloads[responseIndex]['content'][questionIndex]['type'] == QuestionTypes.dropdown.value)
                                    ...[
                                      DropdownButton(
                                        value: payloads[responseIndex]['content'][questionIndex]['selected'],
                                        items: payloads[responseIndex]['content'][questionIndex]['options'].map<DropdownMenuItem<int>>(
                                          (e) => DropdownMenuItem<int>(
                                            value: payloads[responseIndex]['content'][questionIndex]['options'].indexOf(e),
                                            child: Text(e),
                                          ),
                                        ).toList() ,
                                        onChanged: null,
                                      )
                                    ],
                                  
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    ]
                  );
                },
              ),

              // ElevatedButton(
              //   onPressed: () {
              //     // developer.log(jsonEncode(form).runtimeType.toString());
              //     // developer.log(jsonDecode('{"type":"form","fields":[{"id":1,"title":"What is your name?"},{"id":2,"title":"What is your age?"}]}').runtimeType.toString());
              //     developer.log(context.read<NearbyService>().payloads.toString());
              //   },
              //   child: const Text('Test'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
