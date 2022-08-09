import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:ridbrain_project/screens/check_screen.dart';
import 'package:ridbrain_project/services/prefs_handler.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  var provider = await DataProvider.getInstance();
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  cameras = await availableCameras();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => provider,
        ),
      ],
      child: OverlaySupport.global(
        child: MaterialApp(
          theme: ThemeData(primarySwatch: Colors.grey),
          debugShowCheckedModeBanner: false,
          home: const CheckToken(),
        ),
      ),
    ),
  );
}
