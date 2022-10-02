import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdl/CreateForm.dart';
import 'package:sdl/Home.dart';
import 'package:sdl/NearbyService.dart';
import 'package:sdl/ResponsePage.dart';
import 'package:sdl/Rooms.dart';

void main() => runApp(const MyApp());

// App
// class App extends StatefulWidget {
//   const App({Key? key}) : super(key: key);
//   @override
//   AppState createState() => AppState();
// }
// 
// class AppState extends State<App> {
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => NearbyService(),
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         initialRoute: "/",
//         routes: {
//           "/": (context) => const MyApp(),
//         },
//         // home: MyApp(),
//       ),
//     );
//   }
// }

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NearbyService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: generateRoute,
        initialRoute: '/',
        // routes: {
        //   '/': (context) => const Home(),
        //   '/rooms': (context) => const Rooms(),
        //   '/create': (context) => const CreateForm(),
        //   '/response': (context) => const ResponsePage(),
        // },
        // home: Scaffold(
        //   // resizeToAvoidBottomInset: false,
        //   appBar: AppBar(
        //     title: const Text('SNDR'),
        //   ),
        //   body: const Body(),
        // ),
        // home: ChangeNotifierProvider(
        //   create: (context) => NearbyService(),
        //   child: const PageViewWidget(),
        // ),
      ),
    );
  }
}

// PageViewWidget
// class PageViewWidget extends StatefulWidget {
//   const PageViewWidget({Key? key}) : super(key: key);
// 
//   @override
//   PageViewWidgetState createState() => PageViewWidgetState();
// }
// 
// class PageViewWidgetState extends State<PageViewWidget> {
  // 
//   PageController pageController = PageController();
  // 
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<NearbyService>().addListener(() {
//         if(
//           // context.read<NearbyService>().connectedDevice != null
//           context.read<NearbyService>().connectedDevices.isNotEmpty
//           // || context.read<NearbyService>().payload.containsKey('type')
//           || context.read<NearbyService>().payloads[0].containsKey('content')
//           ) {
//           if(context.read<NearbyService>().isDiscovering){
//             // Navigator.pushNamed(context, '/response');
//             pageController.jumpToPage(2);
//           }
//         } else {
//           if(context.read<NearbyService>().isDiscovering){
//             // Navigator.pushNamed(context, '/rooms');
//             pageController.jumpToPage(3);
//           }
//         }
    // 
//         context.read<NearbyService>().addListener(() {
//           if(context.read<NearbyService>().error != null) {
//             Provider.of<NearbyService>(context, listen: false).error = null;
//             Provider.of<NearbyService>(context, listen: false).payloads.insert(0, {});
//             Provider.of<NearbyService>(context, listen: false).foundDevices = {};
//             NearbyService().stopAllEndpoints();
//             NearbyService().startDiscovery();
//           }
//         });
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: PageView(
//             controller: pageController,
//             physics: const NeverScrollableScrollPhysics(),
//             children: const <Widget>[
//               Home(),
//               CreateForm(),
//               Rooms(),
//               ResponsePage(),
//             ],
//           ),
//         ),
//         Text("isAdvertising:${context.watch<NearbyService>().isAdvertising}"),
//         Text("isDiscovering:${context.watch<NearbyService>().isDiscovering}"),
//         Text(context.watch<NearbyService>().foundDevices.toString()),
//         Text(context.watch<NearbyService>().connectedDevices.toString()),
//         Row(
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 NearbyService().stopAdvertising();
//               },
//               child: const Text('Stop advertising'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 NearbyService().stopDiscovery();
//               },
//               child: const Text('Stop discovery'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 NearbyService().stopAllEndpoints();
//               },
//               child: const Text('Stop all'),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const Home()
      );
    case '/rooms':
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const Rooms()
      );
    case '/responsePage':
      return MaterialPageRoute(builder: (_) => const ResponsePage());
    case '/createForm':
      return MaterialPageRoute(builder: (_) => const CreateForm());
    // case 'formPage':
    //   return MaterialPageRoute(builder: (_) => const TempPage());
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}')),
        ));
  }
}