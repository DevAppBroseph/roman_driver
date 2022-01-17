import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:ridbrain_project/screens/policy_screen.dart';
import 'package:ridbrain_project/services/app_bar.dart';
import 'package:ridbrain_project/services/buttons.dart';
import 'package:ridbrain_project/services/constants.dart';
import 'package:ridbrain_project/services/network.dart';
import 'package:ridbrain_project/services/objects.dart';
import 'package:ridbrain_project/services/prefs_handler.dart';
import 'package:ridbrain_project/services/snack_bar.dart';
import 'package:ridbrain_project/services/text_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginController = TextEditingController();
  final _passController = TextEditingController();
  int _whichLogIn = 0;

  void _login(DataProvider provider) async {
    if (_loginController.text.isNotEmpty && _passController.text.isNotEmpty) {
      if (_whichLogIn == 0) {
        var result = await Network.getDriver(
          _loginController.text,
          _passController.text,
        );

        if (result?.error == 0) {
          provider.setDriver(result!.driver!);
        } else {
          StandartSnackBar.show(
            context,
            'Ошибка.',
            SnackBarStatus.warning(),
          );
        }
      } else {
        var result = await Network(context).userAuth(
          _loginController.text,
          _passController.text,
        );

        if (result?.error == 0) {
          provider.setAdmin(
            Admin(
              token: result!.token,
              userId: result.user.userId,
              userEmail: result.user.userEmail,
              userName: result.user.userName,
              userRole: result.user.userRole,
              userStatus: result.user.userStatus,
            ),
          );
        } else {
          StandartSnackBar.show(
            context,
            'Ошибка.',
            SnackBarStatus.warning(),
          );
        }
      }
    } else {
      StandartSnackBar.show(
        context,
        'Заполните E-Mail и Пароль',
        SnackBarStatus.warning(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          slivers: [
            StandartAppBar(
              title: Text('Авторизация'),
              color: Colors.grey[200]!,
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 30,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() {
                          _loginController.clear();
                          _passController.clear();
                          _whichLogIn = 0;
                        }),
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: _whichLogIn == 0
                                ? Colors.white
                                : Colors.grey[200],
                            borderRadius: radius,
                          ),
                          child: Icon(
                            LineIcons.car,
                            size: 40,
                            color: _whichLogIn == 0
                                ? Colors.black
                                : Colors.blueGrey,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() {
                          _loginController.clear();
                          _passController.clear();
                          _whichLogIn = 1;
                        }),
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: _whichLogIn == 1
                                ? Colors.white
                                : Colors.grey[200],
                            borderRadius: radius,
                          ),
                          child: Icon(
                            LineIcons.user,
                            size: 40,
                            color: _whichLogIn == 1
                                ? Colors.black
                                : Colors.blueGrey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 0, 15, 20),
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: radius,
                ),
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Roman.",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _whichLogIn == 0 ? 'Driver' : 'Admin',
                            style: TextStyle(
                              fontSize: 19,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextFieldWidget(
                      hint: 'E-Mail',
                      controller: _loginController,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFieldWidget(
                      hint: 'Пароль',
                      controller: _passController,
                      password: true,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    StandartButton(
                      label: 'Войти',
                      onTap: () => _login(provider),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => PolicyScreen(),
                          ),
                        );
                      },
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Политика конфиденциальности',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
