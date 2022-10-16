
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
    "title": "Untitled Form",
    "content": [
      {
        "type": "singleLine",
        "title": "Untitled Question",
        "content": "",
      }
    ],
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
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Form'),
      ),
      body: Container(
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
              ),
              const SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
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
                itemBuilder: (context, index){
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      title: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Question Title',
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => setState(() => form["content"].removeAt(index)),
                      ),
                      
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextButton(
                  onPressed: () => setState(() => form["content"].add({
                    "type": "singleLine",
                    "title": "Untitled Question",
                    "content": "",
                  })),
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
                    NearbyService().stopAdvertising();
                  },
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () {
                    NearbyService().startAdvertising(isSharing ? shareMsg : form, isSharing: isSharing);
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
      ),
    );
  }
}
