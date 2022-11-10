import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdl/NearbyService.dart';
import 'dart:developer' as developer;
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
//
// bool isSaved = false;
// late File fileOpen;
class SavedForms extends StatefulWidget {
  const SavedForms({Key? key}) : super(key: key);

  @override
  SavedFormsState createState() => SavedFormsState();
}
//
class SavedFormsState extends State<SavedForms> {
  get navigatorKey => null;


  @override
  void initState() {
    // void activate() {
    super.initState();
    super.activate();
    // developer.log("init");
    // startDis();
    _listofFiles();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Future<File> get _localFile async {
  //   final path = await _localPath;
  //   // String txt="${titleController.text}.json";
  //   return File('$path/');
  // }


  @override
  void dispose() {
    super.dispose();
  }

  late String directory;
  List file = [];

  // Make New Function
  void _listofFiles() async {
    directory = (await getApplicationDocumentsDirectory()).path;
    setState(() {
      file = io.Directory("$directory/").listSync();
      file.removeWhere((file) => file.path.split('/').last.split('.').first == 'flutter_assets');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Form Templates"),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: file.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(file[index].path.split('/').last.split('.').first.toString()),
              // subtitle: Text(key),
              onTap: () {
                context.read<NearbyService>().isSaved=true;
                context.read<NearbyService>().fileOpen=file[index].path.toString();
                Navigator.pushNamed(context, '/createForm');
              },
            );
          },
        ),
      ),
    );
  }


  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }

}