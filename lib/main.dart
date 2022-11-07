
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:provider/provider.dart';
import 'package:sdl/CreateForm.dart';
import 'package:sdl/Home.dart';
import 'package:sdl/NearbyService.dart';
import 'package:sdl/ResponsePage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sdl/Rooms.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  bool permission = false;
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(

      create: (context) => NearbyService(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        // onGenerateRoute: generateRoute,
        // initialRoute: '/',
        home: PageViewWidget(),
      ),
    );
  }
}

// PageViewWidget
class PageViewWidget extends StatefulWidget {
  const PageViewWidget({Key? key}) : super(key: key);

  @override
  PageViewWidgetState createState() => PageViewWidgetState();
}

class PageViewWidgetState extends State<PageViewWidget> {
  
  PageController pageController = PageController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      pageController.addListener(() {
        if(pageController.page == 0 || pageController.page == 1) {
          NearbyService().stopAdvertising();
          NearbyService().stopDiscovery();
          NearbyService().stopAllEndpoints();
          NearbyService().payloads = [{}]; 
        }
      });
    });
  }
  
  @override
  void didChangeDependencies() {
    if(!mounted) return;
    NearbyService nearbyService = context.watch<NearbyService>();
    
    // Go to connected page from create
    if(
      nearbyService.connectedDevices.isNotEmpty 
      && pageController.page == 1
      && nearbyService.isSharing
      && !nearbyService.payloads[0].containsKey("contentType")
    ) {
      nearbyService.payloads = [{"type": "share", "contentType": "ack"}];
      pageController.jumpToPage(3);
    }
    
    // Handle Error
    if(nearbyService.error != null) {
      nearbyService.foundDevices = {};
      NearbyService().stopAllEndpoints();
      
    } 
    
    // Exit chat if disconnected
    if(nearbyService.error != null
        || (
          pageController.page == 3
          && nearbyService.connectedDevices.isEmpty 
          && (nearbyService.payloads[0].containsKey("type") 
            ? nearbyService.payloads[0]["type"] == "share" 
            : false))) {
      
      nearbyService.payloads = [{}];
      pageController.jumpToPage(0);
    }
    nearbyService.error = null;
    
    super.didChangeDependencies();
  }
  
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: pageController,
      child: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const <Widget>[
          Home(),
          CreateForm(),
          Rooms(),
          ResponsePage(),
        ],
      ),
    );
  }
}