import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdl/NearbyService.dart';

class FormPage extends StatefulWidget {
  const FormPage({Key? key}) : super(key: key);

  @override
  FormPageState createState() => FormPageState();
}

class FormPageState extends State<FormPage> {
  
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
  
  // @override
  // void initState() {
  //   super.initState();
  //   response["device_id"] = context.read<NearbyService>().userName;
  // }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(context.watch<NearbyService>().payloads[0].toString()),
        Text(response.toString()),
        ElevatedButton(
          onPressed: () {
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
    );
  }
}