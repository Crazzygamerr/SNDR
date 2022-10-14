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
      context.read<NearbyService>().removeListener(catchError);
      context.read<NearbyService>().addListener(catchError);
    });
  }
  
  @override
  void dispose() {
    super.dispose();
    // context.read<NearbyService>().removeListener(catchError);
  }
  
  void catchError() {
    if(!mounted) return;
    if(context.read<NearbyService>().error != null && context.read<NearbyService>().errorHandledByHome == false) {
      // Provider.of<NearbyService>(context, listen: false).error = null;
      // Provider.of<NearbyService>(context, listen: false).payloads = [{}];
      Provider.of<NearbyService>(context, listen: false).foundDevices = {};
      NearbyService().stopAllEndpoints();
      // NearbyService().startDiscovery();
      Provider.of<NearbyService>(context, listen: false).errorHandledByHome = true;
    }
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
              // developer.log(context.read<NearbyService>().payloads[0].containsKey("content").toString());
              developer.log(context.read<NearbyService>().foundDevices.toString());
              developer.log(context.read<NearbyService>().connectedDevices.toString());
            }, 
            child: const Text('Test'),
          ),
        ],
      ),
    );
  }
}