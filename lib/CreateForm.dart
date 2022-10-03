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
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NearbyService>().addListener(catchError);
    });
  }
  
  @override
  void deactivate() {
    context.read<NearbyService>().removeListener(catchError);
    super.deactivate();
  }
  
  void catchError() {
    if(context.read<NearbyService>().error != null) {
      // Provider.of<NearbyService>(context, listen: false).payloads = [{}];
      // Navigator.of(context).pop();
      context.read<NearbyService>().error = null;
    }
  }
  
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create Form'),
          Text("Is open: ${context.watch<NearbyService>().isAdvertising}"),
          Text(const JsonEncoder.withIndent("  ").convert(form)),
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
          const Text("Data"),
          ListView.builder(
            itemCount: context.watch<NearbyService>().payloads.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Text(context.watch<NearbyService>().payloads[index].toString());
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
    );
  }
}
