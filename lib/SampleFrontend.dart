import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

class SampleFrontend extends StatefulWidget {
  const SampleFrontend({Key? key}) : super(key: key);

  @override
  SampleFrontendState createState() => SampleFrontendState();
}

class SampleFrontendState extends State<SampleFrontend> {
  @override
  void initState() {
    // void activate() {
    super.initState();
    super.activate();
    // developer.log("init");
    // startDis();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<NearbyService>().payloads = [{}];
    // });
  }

  // void startDis() async {
  //   await NearbyService().stopAllEndpoints();
  //   String s = await NearbyService().startDiscovery();
  //   if(s != 'true') {
  //     showSnackbar(s);
  //   }
  // }

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
    // // void deactivate() {
    //   NearbyService().stopDiscovery();
    //   NearbyService().stopAllEndpoints();
    // developer.log("dispose");
    // context.read<NearbyService>().removeListener(changeRoute);
    super.dispose();
    // super.deactivate();
  }

  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    backgroundColor: Color(0XFF50C2C9),
    minimumSize: Size(88, 36),
    padding: EdgeInsets.symmetric(horizontal: 20.0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 248, 246, 246),
        body: SafeArea(
            child: Column(children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.30,
              child: Stack(children: [
                Positioned(
                    top: -10,
                    left: -110,
                    child: Container(
                      height: 250,
                      width: 250,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Color(0x738FE1D7)),
                    )),
                Positioned(
                    top: -110,
                    left: 0,
                    child: Container(
                      height: 250,
                      width: 250,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Color(0x738FE1D7)),
                    )),
              ])),
          Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text('Welcome',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ))),
          Image(image: AssetImage('assets/welcomeScreenImg.png')),
          Padding(
              padding: EdgeInsets.only(top: 30),
              child: Text(
                'Go Ahead',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17.0,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              )),
          Container(
              padding: EdgeInsets.only(top: 15),
              margin: EdgeInsets.only(top: 25, right: 25, left: 25),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.88,
                height: 60.0,
                child: ElevatedButton(
                  style: flatButtonStyle,
                  onPressed: () {
                    Navigator.pushNamed(context, '/sampleRooms');
                  },
                  child: Text(
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
              margin: EdgeInsets.all(25),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.88,
                height: 60.0,
                child: ElevatedButton(
                  style: flatButtonStyle,
                  onPressed: () {
                    Navigator.pushNamed(context, '/sampleCreateForm');
                  },
                  child: Text(
                    "CREATE ROOM",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )),
        ])
            // appBar: AppBar(
            //   title: const Text('Sample'),
            // ),

            // body: SafeArea(
            //   child: Center(
            //     child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            //       Align(
            //         widthFactor: 0.3,
            //         child: CircleAvatar(
            //           backgroundColor: Colors.blueAccent,
            //           radius: 70.0,
            //         ),
            //       ),
            //       Text(
            //         'Welcome',
            //         style: TextStyle(
            //           fontFamily: 'Poppins.SemiBold',
            //           fontSize: 30.0,
            //           color: Colors.teal,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ]),
            //   ),
            // ),
            ));
  }
}
