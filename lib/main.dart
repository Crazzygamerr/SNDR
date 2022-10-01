import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.watch<NearbyService>().pageController = pageController;
    // });
  }
  
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
          child: PageView(
            // physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            children: const <Widget>[
              // Home(),
              Devices(),
              FormPage(),
              TempPage(),
            ],
          ),
        ),
      ),
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