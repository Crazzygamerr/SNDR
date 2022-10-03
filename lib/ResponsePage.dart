import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdl/NearbyService.dart';

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
      Provider.of<NearbyService>(context, listen: false).payloads = [{}];
      context.read<NearbyService>().error = null;
      Navigator.of(context).pop();
    }
  }
  
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   context.read<NearbyService>().addListener(changeRoute);
  // }
  
  // @override
  // void deactivate() {
  //   // context.read<NearbyService>().removeListener(changeRoute);
  //   if(context.read<NearbyService>().payloads[0].containsKey("content")) {
  //     context.read<NearbyService>().payloads.removeAt(0);
  //     /// Remomve sent responses?
  //   }
  //   super.deactivate();
  // }
  
  // @override
  // void dispose() {
  //   super.dispose();
  // }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Response Page'),
      ),
      body: Column(
        children: [
          Text(context.watch<NearbyService>().payloads[0].toString()),
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
      ),
    );
  }
}