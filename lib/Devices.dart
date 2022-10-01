import 'package:flutter/material.dart';
import 'package:sdl/NearbyService.dart';
import 'package:provider/provider.dart';

class Devices extends StatefulWidget {
  const Devices({Key? key}) : super(key: key);

  @override
  DevicesState createState() => DevicesState();
}

class DevicesState extends State<Devices> {
  
  @override
  void initState() {
    super.initState();
    init();    
  }
  
  void init() async {
    bool b = await NearbyService().requestPermissions();
    if(b) {
      String s = await NearbyService().startDiscovery();
      if(s != 'true') {
        showSnackbar(s);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      // max height and width
      height: double.infinity,
      width: double.infinity,
      child: ListView.builder(
        itemCount: context.watch<NearbyService>().foundDevices.length,
        itemBuilder: (context, index) {
          String key = context.watch<NearbyService>().foundDevices.keys.elementAt(index);
          
          return ListTile(
            title: Text(context.watch<NearbyService>().foundDevices[key]!),
            subtitle: Text(key),
            onTap: () {
              // connect to device
              NearbyService().requestConnection(key, "{}");
            },
          );
        },
      ),
    );
  }
  
  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }
}