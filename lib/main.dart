import 'package:flutter/material.dart';

import 'package:page_forms/page_forms.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Page Forms',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: PageForms(
        startIndex: 0,
        pages: <PageField>[
          PageField(
            color: Colors.green,
            child: Center(
              child: TextField(
                keyboardType: TextInputType.text,
                cursorWidth: 4.0,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  helperText: 'Please enter your full name here',
                ),
              ),
            ),
          ),
          PageField(
            color: Colors.orange,
            child: Center(
              child: Text('Page 2'),
            ),
          ),
          PageField(
            color: Colors.red,
            child: Center(
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  helperText: 'Enter your email address'
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
