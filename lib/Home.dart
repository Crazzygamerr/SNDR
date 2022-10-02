import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdl/NearbyService.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NearbyService>().addListener(() {
        developer.log("Called outside");
        if(
          // context.read<NearbyService>().connectedDevice != null
          context.read<NearbyService>().connectedDevices.isNotEmpty
          // || context.read<NearbyService>().payload.containsKey('type')
          || context.read<NearbyService>().payloads[0].containsKey('content')
          ) {
          if(context.read<NearbyService>().isDiscovering && ModalRoute.of(context)!.settings.name != '/response'){
            developer.log("Response called");
            Navigator.pushNamed(context, '/response');
          }
        } else {
          developer.log(ModalRoute.of(context)?.settings.toString() ?? "");
          if(context.read<NearbyService>().isDiscovering && ModalRoute.of(context)!.settings.name != '/rooms'){
            developer.log("Room called");
            // Navigator.pushNamed(context, '/rooms');
          }
        }
        
        context.read<NearbyService>().addListener(() {
          if(context.read<NearbyService>().error != null) {
            Provider.of<NearbyService>(context, listen: false).error = null;
            Provider.of<NearbyService>(context, listen: false).payloads.insert(0, {});
            Provider.of<NearbyService>(context, listen: false).foundDevices = {};
            NearbyService().stopAllEndpoints();
            NearbyService().startDiscovery();
          }
        });
      });
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    developer.log(ModalRoute.of(context)?.settings.toString() ?? "");
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SNDR'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/createForm');
            }, 
            child: const Text('Form'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/rooms');
            }, 
            child: const Text('Rooms'),
          ),
          ...context.watch<NearbyService>().payloads.map((e) => Text(e.toString())),
          ElevatedButton(
            onPressed: () {
              developer.log(context.read<NearbyService>().payloads[0].containsKey("content").toString());
            }, 
            child: const Text('Rooms'),
          ),
        //   ElevatedButton(
        //     onPressed: () {
        //       Navigator.pushNamed(context, 'attendance');
        //     }, 
        //     child: const Text('Attendance'),
        //   ),
        //   ElevatedButton(
        //     onPressed: () {
        //       Navigator.pushNamed(context, 'formPage');
        //     }, 
        //     child: const Text('Form'),
        //   ),
        //   ElevatedButton(
        //     onPressed: () {
        //       Navigator.pushNamed(context, 'camera');
        //     }, 
        //     child: const Text('Camera'),
        //   ),
        //   ElevatedButton(
        //     onPressed: () {
        //       Navigator.pushNamed(context, 'file');
        //     }, 
        //     child: const Text('File Sharing'),
        //   ),
        ],
      ),
    );
  }
}