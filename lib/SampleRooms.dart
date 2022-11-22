import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdl/NearbyService.dart';
import 'dart:developer' as developer;
import 'package:sdl/main.dart';

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

    startDis();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<NearbyService>().payloads = [{}];
    // });
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

  // @override
  // void dispose() {
  //   NearbyService().stopDiscovery();
  //   NearbyService().stopAllEndpoints();

  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    int numberOfRooms = context.watch<NearbyService>().foundDevices.length;

    return WillPopScope(
        onWillPop: () {
          context.read<PageController>().jumpToPage(Pages.sampleFrontend.index);
          return Future.value(false);
        },
        child: Scaffold(
            body: SafeArea(
                child: SingleChildScrollView(
                    child: Column(children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.28,
              child: Stack(children: [
                Positioned(
                    top: -10,
                    left: -110,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.28,
                      width: 230,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Color(0x738FE1D7)),
                    )),
                Positioned(
                    top: -110,
                    left: 0,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.28,
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
                    itemCount:
                        context.watch<NearbyService>().foundDevices.length,
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
                                      Provider.of<PageController>(context,
                                              listen: false)
                                          .jumpToPage(
                                              Pages.sampleResponsePage.index);
                                    },
                                  )))));
                    },
                  ))),
        ])))));
  }

  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }
}
