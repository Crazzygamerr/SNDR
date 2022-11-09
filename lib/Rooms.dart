import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdl/NearbyService.dart';
import 'package:sdl/main.dart';

class Rooms extends StatefulWidget {
  const Rooms({Key? key}) : super(key: key);

  @override
  RoomsState createState() => RoomsState();
}

class RoomsState extends State<Rooms> {
  
  @override
  void initState() {
    super.initState();
    startDis();
  }
  
  void startDis() async {
    await NearbyService().stopAllEndpoints();
    String s = await NearbyService().startDiscovery();
    if(s != 'true') {
      showSnackbar(s);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        context.read<PageController>().jumpToPage(Pages.home.index);
        return Future.value(false);
      },
      child: Scaffold(
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
                    // jsonEncode({
                    //   "type": "request",
                    //   "device_id": context.read<NearbyService>().userName,
                    // })
                  );
                  // Navigator.pushNamed(context, '/responsePage').then((value) => startDis());
                  Provider.of<PageController>(context, listen: false).jumpToPage(Pages.responsePage.index);
                },
              );
            },
          ),
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