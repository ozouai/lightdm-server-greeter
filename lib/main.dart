import 'dart:async';

import 'package:ffi/ffi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ffi' as ffi;

import 'package:servergreeter/generated_bindings.dart';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';


var lib = NativeLibrary(
    ffi.DynamicLibrary.open("/opt/servergreeter/liblightdm_interop.so"));
Future<Uri?> getVmUri() async {
  ServiceProtocolInfo serviceProtocolInfo = await Service.getInfo();
  return serviceProtocolInfo.serverUri;
}

void logDebugPort() async {
  print("Service Port: ${await getVmUri()}");
}

void main() {
  if (lib.initialize() != 1) {
    throw Exception("Error initializing lightdm interop");
  }
  logDebugPort();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final app = CupertinoApp(
      title: 'Flutter Demo',
      theme: CupertinoThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          primaryColor: Color(0xFF1B1D1E),

          // textTheme: TextTheme(
          //   displayLarge: TextStyle(),
          //   displayMedium: TextStyle(),
          //   displaySmall: TextStyle(),
          //   headlineLarge: TextStyle(),
          //   headlineMedium: TextStyle(),
          //   headlineSmall: TextStyle(),
          //   titleLarge: TextStyle(),
          //   titleMedium: TextStyle(),
          //   titleSmall: TextStyle(),
          //   bodyLarge: TextStyle(),
          //   bodyMedium: TextStyle(),
          //   bodySmall: TextStyle(),
          //   labelLarge: TextStyle(),
          //   labelMedium: TextStyle(),
          //   labelSmall: TextStyle()
          // ).apply(bodyColor: Colors.white, displayColor: Colors.white, fontFamily: "Inter"),
          textTheme: CupertinoTextThemeData(
            primaryColor: Colors.white,
            textStyle: TextStyle(
                color: Colors.white,
                fontFamily: "Inter",
                fontWeight: FontWeight.normal,
                fontSize: 14),
          ),
          scaffoldBackgroundColor: Color(0xFF1B1D1E),
          barBackgroundColor: Color(0xFF1B1D1E)
          // useMaterial3: false,
          ),
      home: const MyHomePage(title: ''),
    );
    return app;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future<int> performSignin(String username, String password) async {
  final completer = Completer<int>();
  final usernameFfi = username.toNativeUtf8().cast<ffi.UnsignedChar>();
  final passwordFfi = password.toNativeUtf8().cast<ffi.UnsignedChar>();
  late final ffi.NativeCallable<ffi.Void Function(ffi.Int)> callback;
  void cb(int status) {
    completer.complete(status);
    calloc.free(usernameFfi);
    calloc.free(passwordFfi);
    callback.close();
  }

  callback = ffi.NativeCallable<ffi.Void Function(ffi.Int)>.listener(cb);
  final launchCode =
      lib.attemptLogin(usernameFfi, passwordFfi, callback.nativeFunction);
  if (launchCode != 1) {
    completer.complete(launchCode);
    calloc.free(usernameFfi);
    calloc.free(passwordFfi);
    callback.close();
  }
  return completer.future;
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      final username = "foo";
      final password = "bar";

      performSignin(username, password);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return CupertinoPageScaffold(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          children: [
            SizedBox(
              height: 50,
              child: CupertinoNavigationBar(
                trailing: ClockWidget(),
              ),
            ),
            Row(
              children: [GridCard(), GridCard()],
            ),
            Expanded(
                child: Column(
              // Column is also a layout widget. It takes a list of children and
              // arranges them vertically. By default, it sizes itself to fit its
              // children horizontally, and tries to be as tall as its parent.
              //
              // Column has various properties to control how it sizes itself and
              // how it positions its children. Here we use mainAxisAlignment to
              // center the children vertically; the main axis here is the vertical
              // axis because Columns are vertical (the cross axis would be
              // horizontal).
              //
              // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
              // action in the IDE, or press "p" in the console), to see the
              // wireframe for each widget.
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 400, height: 200, child: 
                Padding(padding: EdgeInsets.all(20), child: 
                Column(children: [
                  Text("Login"),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  LoginForm()
                ],)
                ),
                )
              ],
            )),
          ]),
    );
  }
}

class ClockWidget extends StatelessWidget {
  const ClockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 5)),
      builder: (context, snapshot) {
        return Text(DateFormat('MM/dd/yyyy hh:mm:ss').format(DateTime.now()));
      },
    );
  }
}

class GridCard extends StatelessWidget {
  const GridCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: SizedBox(
        width: 200,
        height: 200,
        child: Card(
            color: Color(0xFF14532d),
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child:
                  Text("Network",
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .textStyle
                          .apply(fontSizeFactor: 2))),
                  Expanded(child: MarkdownBody(data: "- [x] Has IP Address\n- [x] DNS Resolves"))
                ],
              ),
            ))));
  }
}


class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final username = TextEditingController();
  final password = TextEditingController();
  bool submitting = false;
  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          CupertinoTextField(
            cursorColor: Colors.black,
            style: TextStyle(
              fontFamily: "Inter",
              color: Colors.black,
            ),
            prefix: Icon(Icons.person_outline),
            controller: username,
            decoration: BoxDecoration(color: Color(0xFFd1d5db), borderRadius: BorderRadius.all(Radius.elliptical(6, 4))),
          ),
          const Padding(padding: EdgeInsets.only(top: 10)),
          CupertinoTextField(
            cursorColor: Colors.black,
            style: const TextStyle(
              fontFamily: "Inter",
              color: Colors.black
            ),
            controller: password,
            prefix:  const Icon(Icons.lock_outline),
            suffix: submitting ? Icon(Icons.loop) : IconButton(
              onPressed: () async {
                if(_formKey.currentState!.validate()) {
                  setState(() {
                    submitting = true;
                  });
                  final result = await performSignin(username.text, password.text);
                  if(result != 1) {
                    setState(() {
                      submitting = false;
                      password.clear();
                    });
                  } else {
                    setState(() {
                      submitting = false;
                      username.clear();
                      password.clear();
                    });
                  }
                }
              },
              icon: const Icon(Icons.login)),
            decoration: const BoxDecoration(color: Color(0xFFd1d5db), borderRadius: BorderRadius.all(Radius.elliptical(6, 4))),
            
            obscureText: true,
          )
          // Add TextFormFields and ElevatedButton here.
        ],
      ),
    );
  }
}