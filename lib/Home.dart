
// import 'package:camera/camera.dart';
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
      context.read<NearbyService>().foundDevices = {};
      NearbyService().stopAllEndpoints();
      // NearbyService().startDiscovery();
      Provider.of<NearbyService>(context, listen: false).errorHandledByHome = true;
    }
  }


  List<bool> permissions = [false, false, false, false];
  void checkPermissions() async {
    // permissions[0] = await Permission.location.isGranted;
    // permissions[1] = await Permission.manageExternalStorage.isGranted;
    // permissions[2] = await Permission.bluetooth.isGranted;
    //Map<Permission, PermissionStatus> statuses = await [
      //Permission.location,
      //Permission.camera,
      //Permission.bluetooth,
      //Permission.bluetoothScan,
      //Permission.bluetoothConnect,
      //.bluetoothAdvertise,
      //Permission.manageExternalStorage,
      //Permission.nearbyWifiDevices,
      //Permission.storage
      //add more permission to request here.
    //].request();
    //print(statuses[Permission.location]);
    //permissions[3] = await Nearby().checkLocationPermission() && await Nearby().checkLocationEnabled();
    setState(() {});
  }

  
  // CameraController? controller;
  
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