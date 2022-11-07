
// import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdl/NearbyService.dart';
import 'dart:developer' as developer;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SNDR'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  // Navigator.pushNamed(context, '/createForm');
                  Provider.of<PageController>(context, listen: false).jumpToPage(1);
                }, 
                child: const Text('Form'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigator.pushNamed(context, '/rooms');
                  Provider.of<PageController>(context, listen: false).jumpToPage(2);
                }, 
                child: const Text('Rooms'),
              ),
              // ...context.watch<NearbyService>().payloads.map((e) => Text(e.toString())),
              // ElevatedButton(
              //   onPressed: () async {
              //     // List<CameraDescription> cameras = await availableCameras();
              //     // controller = CameraController(cameras[0], ResolutionPreset.medium);
              //     // controller!.initialize().then((_) {
              //     //   if(!mounted) return;
              //     //   context.read<NearbyService>().cameraController = controller;
              //     //   setState(() {});
              //     // });
              //   }, 
              //   child: const Text('Test'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}