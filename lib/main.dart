import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:ridbrain_project/screens/check_screen.dart';
import 'package:ridbrain_project/services/prefs_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var provider = await DataProvider.getInstance();

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
