import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdl/NearbyService.dart';

class Rooms extends StatefulWidget {
  const Rooms({Key? key}) : super(key: key);

  @override
  RoomsState createState() => RoomsState();
}

class RoomsState extends State<Rooms> {
  
  @override
  void initState() {
    super.initState();
    init();    
  }
  
  void init() {
    initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NearbyService>().payloads = [{}];
    });
  }
  
  void initialize() async {
    bool b = await NearbyService().requestPermissions();
    if(b) {
      await NearbyService().stopAllEndpoints();
      String s = await NearbyService().startDiscovery();
      if(s != 'true') {
        showSnackbar(s);
      }
    }
  }
  
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // context.read<NearbyService>().addListener(changeRoute);
    
  // }
  
  // void changeRoute() {
  //   if(context.read<NearbyService>().payloads[0].containsKey('content')
  //     && context.read<NearbyService>().isDiscovering
  //     && ModalRoute.of(context)!.settings.name != '/responsePage'
  //     ){
  //       Navigator.pushNamed(context, '/responsePage');
  //     }
  // }
  
  @override
  void dispose() {
    NearbyService().stopDiscovery();
    // context.read<NearbyService>().removeListener(changeRoute);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text("Rooms"),
        title: Text(ModalRoute.of(context)!.settings.name.toString()),
      ),
      body: SizedBox(
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
                NearbyService().requestConnection(
                  key, 
                  "{}"
                  // jsonEncode({
                  //   "type": "request",
                  //   "device_id": context.read<NearbyService>().userName,
                  // })
                );
                Navigator.pushNamed(context, '/responsePage');
              },
            );
          },
        ),
      ),
    );
  }
  
  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }
}