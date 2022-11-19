import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdl/NearbyService.dart';
import 'dart:developer' as developer;

class SampleRooms extends StatefulWidget {
  const SampleRooms({Key? key}) : super(key: key);

  @override
  SampleRoomsState createState() => SampleRoomsState();
}

class SampleRoomsState extends State<SampleRooms> {
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
    if (s != 'true') {
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
  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    backgroundColor: Color(0XFF50C2C9),
    minimumSize: Size(88, 36),
    padding: EdgeInsets.symmetric(horizontal: 20.0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
  );

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
    int numberOfRooms = context.watch<NearbyService>().foundDevices.length;
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
                child: Column(children: [
      Container(
          height: MediaQuery.of(context).size.height * 0.28,
          child: Stack(children: [
            // Positioned(
            //   top: 640,
            //   child: Container(
            //       margin: EdgeInsets.all(25),
            //       child: SizedBox(
            //         width: MediaQuery.of(context).size.width * 0.88,
            //         height: 60.0,
            //         child: ElevatedButton(
            //           style: flatButtonStyle,
            //           onPressed: () {
            //             Navigator.pushNamed(context, '/createForm');
            //           },
            //           child: Text(
            //             "CREATE ROOM",
            //             style: TextStyle(
            //               fontFamily: 'Poppins',
            //               fontSize: 15.0,
            //               fontWeight: FontWeight.w600,
            //             ),
            //           ),
            //         ),
            //       )),
            // ),
            // Positioned(
            //   top: 560,
            //   child: Container(
            //       margin: EdgeInsets.all(25),
            //       child: SizedBox(
            //         width: MediaQuery.of(context).size.width * 0.88,
            //         height: 60.0,
            //         child: ElevatedButton(
            //           style: flatButtonStyle,
            //           onPressed: () {
            //             Navigator.pushNamed(context, '/rooms');
            //           },
            //           child: Text(
            //             "JOIN ROOM",
            //             style: TextStyle(
            //               fontFamily: 'Poppins',
            //               fontSize: 15.0,
            //               fontWeight: FontWeight.w600,
            //             ),
            //           ),
            //         ),
            //       )),
            // ),
            // Positioned(
            //     top: 510,
            //     left: 145,
            //     child: Container(
            //       child: Text(
            //         'Go Ahead',
            //         style: TextStyle(
            //           fontFamily: 'Poppins',
            //           fontSize: 17.0,
            //           color: Colors.black,
            //           fontWeight: FontWeight.normal,
            //         ),
            //       ),
            //     )),
            // Positioned(
            //     top: 350,
            //     left: 124,
            //     child: Image(image: AssetImage('assets/welcomeScreenImg.png'))),
            // Positioned(
            //     top: 250,
            //     left: 117,
            //     child: Container(
            //       child: Text(
            //         'Welcome',
            //         style: TextStyle(
            //           fontFamily: 'Poppins',
            //           fontSize: 28.0,
            //           color: Colors.black,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     )),

            Positioned(
                top: -10,
                left: -110,
                child: Container(
                  height: 230,
                  width: 230,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Color(0x738FE1D7)),
                )),
            Positioned(
                top: -110,
                left: 0,
                child: Container(
                  height: 230,
                  width: 230,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Color(0x738FE1D7)),
                )),
          ])),
      Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text('My Rooms',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 21.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ))),
      Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            "Number of Rooms ~ ${numberOfRooms}",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17.0,
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          )),
      Padding(
          padding: EdgeInsets.only(top: 25),
          child: Container(
              padding: EdgeInsets.all(4),
              height: numberOfRooms * 83,
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4),
              width: MediaQuery.of(context).size.width * 0.88,
              decoration: BoxDecoration(
                  color: Color.fromARGB(116, 80, 195, 201),
                  borderRadius: BorderRadius.circular(10)),
              //height: MediaQuery.of(context).size.height * 0.88,
              // width: MediaQuery.of(context).size.width * 0.88,
              child: ListView.builder(
                itemCount: context.watch<NearbyService>().foundDevices.length,
                itemBuilder: (context, index) {
                  String key = context
                      .watch<NearbyService>()
                      .foundDevices
                      .keys
                      .elementAt(index);

                  return Padding(
                      padding: EdgeInsets.all(5),
                      child: Container(
                          decoration: BoxDecoration(
                              color: Color.fromARGB(208, 255, 255, 255),
                              borderRadius: BorderRadius.circular(12)),
                          child: SizedBox(
                              height: 69,
                              child: Center(
                                  child: ListTile(
                                visualDensity: VisualDensity(vertical: 0),
                                title: Text(context
                                    .watch<NearbyService>()
                                    .foundDevices[key]!),
                                subtitle: Text(key),
                                onTap: () {
                                  // connect to device
                                  NearbyService().requestConnection(
                                      key, '{"type": "request"}'
                                      // jsonEncode({
                                      //   "type": "request",
                                      //   "device_id": context.read<NearbyService>().userName,
                                      // })
                                      );
                                  Navigator.pushNamed(context, '/responsePage')
                                      .then((value) => startDis());
                                },
                              )))));
                },
              )))

      // child: DropdownButtonHideUnderline(
      //   child: DropdownButton(
      //     value: formType,
      //     onChanged: (v) {
      //       setState(() {
      //         formType = v as bool;
      //       });
      //     },
      //     items: [
      //       DropdownMenuItem(
      //         value: true,
      //         child: Text(
      //           "Attendance",
      //           style: TextStyle(
      //             fontFamily: 'Poppins',
      //             fontSize: 12.0,
      //             color: Colors.black,
      //             fontWeight: FontWeight.normal,
      //           ),
      //         ),
      //       ),
      //       DropdownMenuItem(
      //         value: false,
      //         child: Text(
      //           "Quiz",
      //           style: TextStyle(
      //             fontFamily: 'Poppins',
      //             fontSize: 12.0,
      //             color: Colors.black,
      //             fontWeight: FontWeight.normal,
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),

      ,
      // Container(
      //     margin: EdgeInsets.all(25),
      //     padding: EdgeInsets.only(top: 28),
      //     child: SizedBox(
      //       width: MediaQuery.of(context).size.width * 0.88,
      //       height: 60.0,
      //       child: ElevatedButton(
      //         style: flatButtonStyle,
      //         onPressed: () {
      //           Navigator.pushNamed(context, '/sampleCreate');
      //         },
      //         child: Text(
      //           "Create Room",
      //           style: TextStyle(
      //               fontFamily: 'Poppins',
      //               fontSize: 15.0,
      //               fontWeight: FontWeight.w600,
      //               letterSpacing: 1.2),
      //         ),
      //       ),
      //     )),
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
                ))
        // body: SafeArea(
        //   child: ListView.builder(
        //     itemCount: context.watch<NearbyService>().foundDevices.length,
        //     itemBuilder: (context, index) {
        //       String key = context
        //           .watch<NearbyService>()
        //           .foundDevices
        //           .keys
        //           .elementAt(index);

        //       return ListTile(
        //         title: Text(context.watch<NearbyService>().foundDevices[key]!),
        //         subtitle: Text(key),
        //         onTap: () {
        //           // connect to device
        //           NearbyService().requestConnection(key, '{"type": "request"}'
        //               // jsonEncode({
        //               //   "type": "request",
        //               //   "device_id": context.read<NearbyService>().userName,
        //               // })
        //               );
        //           Navigator.pushNamed(context, '/responsePage')
        //               .then((value) => startDis());
        //         },
        //       );
        //     },
        //   ),
        // ),
        );
  }

  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }
}
