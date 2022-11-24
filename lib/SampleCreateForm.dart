import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import 'package:sdl/main.dart';

class SampleCreateForm extends StatefulWidget {
  const SampleCreateForm({Key? key}) : super(key: key);

  @override
  SampleCreateFormState createState() => SampleCreateFormState();
}

//enum formType { Attendance, Quiz, FormType1, Club }
final List<String> formType = ['Form', 'Share'];

String? _formTypeSelected;

class SampleCreateFormState extends State<SampleCreateForm> {
  @override
  void initState() {
    super.initState();
    super.activate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    backgroundColor: Color(0XFF50C2C9),
    minimumSize: Size(88, 36),
    padding: EdgeInsets.symmetric(horizontal: 20.0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          context
              .read<PageController>()
              .jumpToPage(Pages.cpSampleFormTypes.index);
          return Future.value(false);
        },
        child: Scaffold(
            backgroundColor: Color.fromARGB(255, 248, 246, 246),
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
                  child: Text('Create Room',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 21.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ))),
              Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Let’s create a room',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 17.0,
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  )),
              Padding(
                  padding:
                      EdgeInsets.only(left: 8, right: 8, top: 50, bottom: 15),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.88,
                    height: MediaQuery.of(context).size.width * 0.14,
                    child: TextField(
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                            hintText: 'Room Name',
                            hintStyle:
                                TextStyle(fontFamily: 'Poppins', fontSize: 13),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 3,
                                    color: Color.fromARGB(161, 80, 195, 201)),
                                borderRadius: BorderRadius.circular(50)),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(50)))),
                  )),
              // Padding(
              //     padding: EdgeInsets.only(top: 10, bottom: 15),
              //     child: SizedBox(
              //       width: MediaQuery.of(context).size.width * 0.88,
              //       height: MediaQuery.of(context).size.width * 0.15,
              //       child: TextField(
              //           decoration: InputDecoration(
              //               hintText: 'Creator Name',
              //               hintStyle:
              //                   TextStyle(fontFamily: 'Poppins', fontSize: 13),
              //               focusedBorder: OutlineInputBorder(
              //                   borderSide: BorderSide(
              //                       width: 3,
              //                       color: Color.fromARGB(161, 80, 195, 201)),
              //                   borderRadius: BorderRadius.circular(50)),
              //               filled: true,
              //               fillColor: Colors.white,
              //               border: OutlineInputBorder(
              //                   borderSide: BorderSide.none,
              //                   borderRadius: BorderRadius.circular(50)))),
              //     )),
              Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.55,
                      height: MediaQuery.of(context).size.width * 0.17,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: Text("Type",
                                style: TextStyle(
                                    fontFamily: 'Poppins', fontSize: 13)),
                            items: formType
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                            value: _formTypeSelected,
                            onChanged: (v) =>
                                setState(() => _formTypeSelected = v ?? ""),
                          ),
                        ),
                      ))),
              Container(
                  margin: EdgeInsets.all(25),
                  padding: EdgeInsets.only(top: 28),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.88,
                    height: 60.0,
                    child: ElevatedButton(
                      style: flatButtonStyle,
                      onPressed: () {
                        Provider.of<PageController>(context, listen: false)
                            .jumpToPage(Pages.sampleCreate.index);
                      },
                      child: Text(
                        "Create Room",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2),
                      ),
                    ),
                  )),
            ])))));
  }
}
