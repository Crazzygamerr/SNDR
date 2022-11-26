// import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sdl/NearbyService.dart';
import 'package:sdl/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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
    getUUID();
  }
  
  void getUUID() async {
    // check if uuid exists
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(Uuid().v4());
    String? uuid = prefs.getString('uuid');
    if (uuid == null) {
      // generate uuid
      uuid = const Uuid().v4();
      // save uuid
      prefs.setString('uuid', uuid);
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NearbyService>(context, listen: false).uuid;
    });
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

  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    backgroundColor: const Color(0XFF50C2C9),
    minimumSize: const Size(88, 36),
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
  );
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: const Color.fromARGB(255, 248, 246, 246),
          body: SafeArea(
              child: Column(children: [
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.30,
                child: Stack(children: [
                  Positioned(
                      top: -10,
                      left: -110,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.30,
                        width: 250,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Color(0x738FE1D7)),
                      )),
                  Positioned(
                      top: -110,
                      left: 0,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.30,
                        width: 250,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Color(0x738FE1D7)),
                      )),
                ])),
            const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text('Welcome',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ))),
            const Image(image: AssetImage('assets/welcomeScreenImg.png')),
            // const Padding(
            //     padding: const EdgeInsets.only(top: 30),
            //     child: const Text(
            //       'Go Ahead',
            //       style: const TextStyle(
            //         fontFamily: 'Poppins',
            //         fontSize: 17.0,
            //         color: Colors.black,
            //         fontWeight: FontWeight.normal,
            //       ),
            //     )),
            Container(
                padding: const EdgeInsets.only(top: 15),
                margin: const EdgeInsets.only(top: 25, right: 25, left: 25),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.88,
                  height: 60.0,
                  child: ElevatedButton(
                    style: flatButtonStyle,
                    onPressed: () {
                      Provider.of<PageController>(context, listen: false)
                          .jumpToPage(Pages.sampleRooms.index);
                    },
                    child: const Text(
                      "JOIN ROOM",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )),
            Container(
                margin: const EdgeInsets.all(25),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.88,
                  height: 60.0,
                  child: ElevatedButton(
                    style: flatButtonStyle,
                    onPressed: () {
                      Provider.of<PageController>(context, listen: false).jumpToPage(
                        // Pages.sampleCreate.index
                        Pages.cpSampleFormTypes.index
                      );
                    },
                    child: const Text(
                      "CREATE ROOM",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )),
          ]
          )
          )
          );
  }
}
