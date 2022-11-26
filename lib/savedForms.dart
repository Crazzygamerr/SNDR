
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sdl/NearbyService.dart';
import 'package:sdl/main.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // getJson();
      // json = await NearbyService().readJson();
      // setState(() {});
    });
  }
  
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    json = await NearbyService().readJson();
    setState(() {});
  }
  
  late String directory;
  List file = [];
  Map<String, dynamic> json = {};

  void getJson() async {
    directory = (await getApplicationDocumentsDirectory()).path;
    setState(() {
      file = io.Directory("$directory/").listSync();
      file.removeWhere((file) => file.path.split('/').last.split('.').first == 'flutter_assets');
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<PageController>().jumpToPage(Pages.cpSampleFormTypes.index);
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
              height: MediaQuery.of(context).size.height * 0.28,
              child: Stack(children: [
                Positioned(
                    top: -10,
                    left: -110,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.28,
                      width: 230,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Color(0x738FE1D7)),
                    )),
                Positioned(
                    top: -110,
                    left: 0,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.28,
                      width: 230,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Color(0x738FE1D7)),
                    )),
              ])),
              const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('Saved Forms',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 21.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ))),
              Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(116, 80, 195, 201),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: ListView.builder(
                  itemCount: json.keys.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(208, 255, 255, 255),
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              json.keys.elementAt(index)
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete), 
                              onPressed: () async {
                                await NearbyService().deleteJsonEntry(json.keys.elementAt(index));
                                json = await NearbyService().readJson();
                                setState(() {});
                            }),
                          ],
                        ),
                        onTap: () {
                          context.read<NearbyService>().savedForm = json[json.keys.elementAt(index)];
                          context.read<PageController>().jumpToPage(Pages.sampleCreate.index);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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