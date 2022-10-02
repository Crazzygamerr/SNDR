import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:sdl/NearbyService.dart';
import 'package:provider/provider.dart';

class CreateForm extends StatefulWidget {
  const CreateForm({Key? key}) : super(key: key);

  @override
  State<CreateForm> createState() => _CreateFormState();
}

class _CreateFormState extends State<CreateForm> {
  
  Map<String, dynamic> form = {
    "type": "form",
    // "type": "attendance",
    // "type": "camera",
    // "type": "file","
    "content": [
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
  
  // @override
  // void initState() {
  //   super.initState();
  //   form["device_id"] = context.read<NearbyService>().userName;
  // }
  
  @override
  void dispose() {
    NearbyService().stopAdvertising();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Form'),
      ),
      body: Column(
        children: [
          Text('Create Form'),
          Text(new JsonEncoder.withIndent("  ").convert(form)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  NearbyService().stopAdvertising();
                },
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  NearbyService().startAdvertising(form);
                },
                child: const Text('Open'),
              ),
            ],
          ),
          Text("Data"),
          ListView.builder(
            itemCount: context.watch<NearbyService>().payloads.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Text(context.watch<NearbyService>().payloads[index].toString());
            },
          ),

          ElevatedButton(
            onPressed: () {
              // developer.log(jsonEncode(form).runtimeType.toString());
              // developer.log(jsonDecode('{"type":"form","fields":[{"id":1,"title":"What is your name?"},{"id":2,"title":"What is your age?"}]}').runtimeType.toString());
              developer.log(context.read<NearbyService>().payloads.toString());
            },
            child: const Text('Test'),
          ),
        ],
      ),
    );
  }
}
