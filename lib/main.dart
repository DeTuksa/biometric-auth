import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Biometric Auth'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  GlobalKey scaffoldKey = GlobalKey<ScaffoldState>();

  final errorSnackBar = const SnackBar(
    content: Text('Error Authenticating'),
  );

  final successSnackBar = const SnackBar(
    content: Text('User Authenticated'),
  );

  final LocalAuthentication localAuthentication = LocalAuthentication();
  bool hasBiometric = false;
  bool isAuthenticated = false;

  Future<bool> getBiometricSupport() async {
    bool hasSupport = false;
    try {
      hasSupport = await localAuthentication.canCheckBiometrics;
    } catch(e) {
      print(e);
    }
    return hasSupport;
  }

  Future<bool> authenticateUser() async {
    bool authenticated = false;
    bool biometric = await getBiometricSupport();
    setState(() {
      hasBiometric = biometric;
    });
    if (biometric) {
      try {
        authenticated = await localAuthentication.authenticate(
          localizedReason: 'Authenticate User',
          useErrorDialogs: true,
          stickyAuth: true,
          sensitiveTransaction: true,
          biometricOnly: true
        );
      } catch (e) {
        print(e);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
      setState(() {
        authenticated = false;
      });
    }
    return authenticated;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(

      ),
      floatingActionButton:  FloatingActionButton.extended(
        onPressed: () async {
          bool authStatus = await authenticateUser();
          if (authStatus) {
            ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
          }
        },
        label: const Text(
          'Press to authenticate'
        ),
      ), //
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
