
// import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sdl/main.dart';
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  
  @override
  void initState() {
    super.initState();
    checkPermissions();
  }
  
  List<bool> permissions = [false, false, false, false];
  void checkPermissions() async {
    // permissions[0] = await Permission.location.isGranted;
    // permissions[1] = await Permission.manageExternalStorage.isGranted;
    // permissions[2] = await Permission.bluetooth.isGranted;
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.camera,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.manageExternalStorage,
      Permission.nearbyWifiDevices,
      Permission.storage
      //add more permission to request here.
    ].request();
    //permissions[3] = await Nearby().checkLocationPermission() && await Nearby().checkLocationEnabled();
    setState(() {});
  }
  
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
                  Provider.of<PageController>(context, listen: false).jumpToPage(Pages.createForm.index);
                }, 
                child: const Text('Form'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigator.pushNamed(context, '/rooms');
                  Provider.of<PageController>(context, listen: false).jumpToPage(Pages.rooms.index);
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