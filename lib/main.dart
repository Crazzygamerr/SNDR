import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdl/CreateForm.dart';
import 'package:sdl/Home.dart';
import 'package:sdl/NearbyService.dart';
import 'package:sdl/ResponsePage.dart';
import 'package:sdl/Rooms.dart';

// TODO: Mark attendance & UUID
// Rate limiting
// Room names

// TODO: Fix response question names 
// TODO: Remove multi device connect in share
// Navigation bugs
// Service restart bugs
  // remove all listeners & use didChangeDependencies

// Camera and other permissions - Ila
// form modification & error handling - Nivi
// export responses - Chanchala

// Duplicate form questions
// Camera preview & options like flash
// msg send time & long press options

// Refactoring & code cleanup
// Optimizations

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> { 
  
  bool permission = false; 
  
  @override
  void initState() {
    super.initState();
    initialize();
  }
  
  void initialize() async {
    permission = await NearbyService().requestPermissions();
    if(permission) {
      
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NearbyService(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: generateRoute,
        initialRoute: '/',
      ),
    );
  }
}

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
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const ResponsePage()
      );
    case '/createForm':
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const CreateForm()
      );
    // case 'formPage':
    //   return MaterialPageRoute(builder: (_) => const TempPage());
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: SafeArea(
            child: Center(
              child: Text('No route defined for ${settings.name}')),
          ),
        ));
  }
}