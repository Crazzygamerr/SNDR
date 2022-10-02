import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdl/CreateForm.dart';
import 'package:sdl/Devices.dart';
import 'package:sdl/FormPage.dart';
import 'package:sdl/Home.dart';
import 'package:sdl/NearbyService.dart';
import 'package:sdl/TempPage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // onGenerateRoute: generateRoute,
      // initialRoute: '/',
      // home: Scaffold(
      //   // resizeToAvoidBottomInset: false,
      //   appBar: AppBar(
      //     title: const Text('SNDR'),
      //   ),
      //   body: const Body(),
      // ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SNDR'),
        ),
        body: ChangeNotifierProvider(
          create: (context) => NearbyService(),
          child: PageViewWidget(),
        ),
      ),
    );
  }
}

// new stateful widget
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
    // add a listener that changes the page when nearbyState changes
    // context.watch<NearbyService>().addListener(() {
    //   if(context.watch<NearbyService>().payload.containsKey('type')) {
    //     // pageController.jumpToPage();
    //   }
    // });
    // Wait for widgets to be built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // context.watch<NearbyService>().pageController = pageController;
      // Provider.of<NearbyService>(context, listen: false).pageController = pageController;
      // add a listener that changes the page when nearbyState changes
      context.read<NearbyService>().addListener(() {
        if(
          // context.read<NearbyService>().connectedDevice != null
          context.read<NearbyService>().connectedDevices.isNotEmpty
          // || context.read<NearbyService>().payload.containsKey('type')
          // || context.read<NearbyService>().payloads.isNotEmpty
          ) {
          // pageController.jumpToPage(2);
        } else {
          // pageController.jumpToPage(1);
        }
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: pageController,
            // physics: NeverScrollableScrollPhysics(),
            children: const <Widget>[
              // Home(),
              CreateForm(),
              Devices(),
              FormPage(),
              TempPage(),
            ],
          ),
        ),
        Text("isAdvertising:" + context.watch<NearbyService>().isAdvertising.toString()),
        Text("isDiscovering:" + context.watch<NearbyService>().isDiscovering.toString()),
        Text(context.watch<NearbyService>().foundDevices.toString()),
        Text(context.watch<NearbyService>().connectedDevices.toString()),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                NearbyService().stopAdvertising();
              },
              child: const Text('Stop advertising'),
            ),
            ElevatedButton(
              onPressed: () {
                NearbyService().stopDiscovery();
              },
              child: const Text('Stop discovery'),
            ),
            ElevatedButton(
              onPressed: () {
                NearbyService().stopAllEndpoints();
              },
              child: const Text('Stop all'),
            ),
          ],
        ),
      ],
    );
  }
}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const Home());
    case 'formPage':
      return MaterialPageRoute(builder: (_) => const TempPage());
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}')),
        ));
  }
}