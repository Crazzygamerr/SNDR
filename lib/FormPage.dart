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
    "responses": [
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
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(context.watch<NearbyService>().payload.toString()),
        Text(response.toString()),
        ElevatedButton(
          onPressed: () {
            NearbyService().sendPayload(response);
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}