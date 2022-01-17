import 'package:flutter/material.dart';
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

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _loginController = TextEditingController();
  final _passController = TextEditingController();

  void _loginDriver(DataProvider provider) async {
    var result = await Network.getDriver(
      _loginController.text,
      _passController.text,
    );

    if (result?.error == 0) {
      provider.setDriver(result!.driver!);
      Navigator.pop(context);
    } else {
      StandartSnackBar.show(
        context,
        'Ошибка.',
        SnackBarStatus.warning(),
      );
    }
  }

  void _loginAdmin(DataProvider provider) async {
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

      Navigator.pop(context);
    } else {
      StandartSnackBar.show(
        context,
        'Ошибка.',
        SnackBarStatus.warning(),
      );
    }
  }

  void _login(DataProvider provider) {
    if (_loginController.text.isNotEmpty && _passController.text.isNotEmpty) {
      switch (widget.user) {
        case User.driver:
          _loginDriver(provider);
          break;
        case User.admin:
          _loginAdmin(provider);
          break;
        default:
          print("Warning");
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
                            widget.user == User.driver ? 'Driver' : 'Admin',
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
