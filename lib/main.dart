import 'package:flutter/material.dart';
import 'package:sdl/Home.dart';


void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoute,
      initialRoute: '/',
      // home: Scaffold(
      //   // resizeToAvoidBottomInset: false,
      //   appBar: AppBar(
      //     title: const Text('SNDR'),
      //   ),
      //   body: const Body(),
      // ),
    );
  }
}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const Home());
    // case 'browser':
    //   return MaterialPageRoute(
    //       builder: (_) => DevicesListScreen(deviceType: DeviceType.browser));
    // case 'advertiser':
    //   return MaterialPageRoute(
    //       builder: (_) => DevicesListScreen(deviceType: DeviceType.advertiser));
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}