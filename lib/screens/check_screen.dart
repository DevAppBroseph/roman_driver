import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridbrain_project/screens/admin_screen.dart';
import 'package:ridbrain_project/screens/auth_screen.dart';
import 'package:ridbrain_project/screens/main_screen.dart';
import 'package:ridbrain_project/services/network.dart';
import 'package:ridbrain_project/services/prefs_handler.dart';

class CheckToken extends StatelessWidget {
  const CheckToken({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    return Scaffold(body: futureBulder(provider, context));
  }

  Widget? futureBulder(
    DataProvider provider,
    BuildContext context,
  ) {
    switch (provider.user) {
      case User.driver:
        return FutureBuilder(
          future: Network.checkDriverToken(provider.driver.driverToken),
          builder: (context, AsyncSnapshot<bool> snap) {
            if (snap.hasData) {
              if (snap.data ?? false) {
                return MainScreen();
              } else {
                provider.signOutAdmin();
                provider.signOutDriver();
                return const AuthScreen();
              }
            }
            return const Center(child: CupertinoActivityIndicator());
          },
        );
      case User.admin:
        return FutureBuilder(
          future: Network(context).checkAdminToken(provider.admin.token!),
          builder: (context, AsyncSnapshot<bool> snap) {
            if (snap.hasData) {
              if (snap.data ?? false) {
                return AdminScreen();
              } else {
                provider.signOutAdmin();
                provider.signOutDriver();
                return const AuthScreen();
              }
            }
            return const Center(child: CupertinoActivityIndicator());
          },
        );
      case User.none:
        return const AuthScreen();
    }
  }
}
