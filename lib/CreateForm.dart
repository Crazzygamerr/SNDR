import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdl/NearbyService.dart';

// enum FormType { form, attendace, camera, file }

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
  
  Map<String, dynamic> shareMsg = {
    "type": "share",
    "contentType": "string",
    "content": "Hello World",
  };
  Map<String, dynamic> form = {
    "type": "form",
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
  bool isSharing = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NearbyService>().removeListener(catchError);
      context.read<NearbyService>().removeListener(goToConnectedPage);
      context.read<NearbyService>().addListener(catchError);
      context.read<NearbyService>().addListener(goToConnectedPage);
    });
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
      && !context.read<NearbyService>().payloads[0].containsKey("type")
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
          DropdownButton(
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
                  if(isSharing) {
                    NearbyService().startAdvertising(shareMsg, isSharing: true);
                  } else {
                    NearbyService().startAdvertising(form, isSharing: false);
                  }
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
