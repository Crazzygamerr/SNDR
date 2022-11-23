import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdl/NearbyService.dart';
import 'dart:developer' as developer;

class Rooms extends StatefulWidget {
  const Rooms({Key? key}) : super(key: key);

  @override
  RoomsState createState() => RoomsState();
}

class RoomsState extends State<Rooms> {
  
  @override
  void initState() {
  // void activate() {
    super.initState();
    super.activate();
    // developer.log("init");
    startDis();    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NearbyService>().payloads = [{}];
    });
  }
  
  void startDis() async {
    await NearbyService().stopAllEndpoints();
    String s = await NearbyService().startDiscovery();
    if(s != 'true') {
      showSnackbar(s);
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
  // void deactivate() {
    NearbyService().stopDiscovery();
    NearbyService().stopAllEndpoints();
    // developer.log("dispose");
    // context.read<NearbyService>().removeListener(changeRoute);
    super.dispose();
    // super.deactivate();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rooms"),
      ),
      body: SafeArea(
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
                  '{"type": "request"}'

                );
                Navigator.pushNamed(context, '/responsePage').then((value) => startDis());
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