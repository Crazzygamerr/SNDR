import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, 'formPage');
          }, 
          child: const Text('Form'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, 'devices');
          }, 
          child: const Text('Rooms'),
        ),
      //   ElevatedButton(
      //     onPressed: () {
      //       Navigator.pushNamed(context, 'attendance');
      //     }, 
      //     child: const Text('Attendance'),
      //   ),
      //   ElevatedButton(
      //     onPressed: () {
      //       Navigator.pushNamed(context, 'formPage');
      //     }, 
      //     child: const Text('Form'),
      //   ),
      //   ElevatedButton(
      //     onPressed: () {
      //       Navigator.pushNamed(context, 'camera');
      //     }, 
      //     child: const Text('Camera'),
      //   ),
      //   ElevatedButton(
      //     onPressed: () {
      //       Navigator.pushNamed(context, 'file');
      //     }, 
      //     child: const Text('File Sharing'),
      //   ),
      ],
    );
  }
}