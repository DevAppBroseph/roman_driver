import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:ridbrain_project/screens/add_user.dart';
import 'package:ridbrain_project/screens/policy_screen.dart';
import 'package:ridbrain_project/services/app_bar.dart';
import 'package:ridbrain_project/services/constants.dart';
import 'package:ridbrain_project/services/prefs_handler.dart';

class AdminAccount extends StatefulWidget {
  const AdminAccount({Key? key}) : super(key: key);

  @override
  _AdminAccountState createState() => _AdminAccountState();
}

class _AdminAccountState extends State<AdminAccount> {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          StandartAppBar(
            title: Text("Настройки"),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      LineIcons.user,
                      size: 60,
                      color: Colors.blueGrey,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.admin.userName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          provider.admin.userEmail,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ],
                ),
                Container(
                  height: 1,
                  margin: const EdgeInsets.all(15),
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              margin: const EdgeInsets.fromLTRB(15, 5, 15, 10),
              decoration: const BoxDecoration(
                borderRadius: radius,
              ),
              child: Material(
                borderRadius: radius,
                color: Colors.grey[200],
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PolicyScreen(),
                      ),
                    );
                  },
                  borderRadius: radius,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(LineIcons.userShield),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Политика конфиденциальности',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (!provider.hasDriver)
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                margin: const EdgeInsets.fromLTRB(15, 5, 15, 10),
                decoration: const BoxDecoration(
                  borderRadius: radius,
                ),
                child: Material(
                  borderRadius: radius,
                  color: Colors.grey[200],
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddUserScreen(
                          user: User.driver,
                        ),
                      ),
                    ),
                    borderRadius: radius,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Icon(LineIcons.car),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Добавить профиль водителя',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (provider.hasDriver)
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                margin: const EdgeInsets.fromLTRB(15, 5, 15, 10),
                decoration: const BoxDecoration(
                  borderRadius: radius,
                ),
                child: Material(
                  borderRadius: radius,
                  color: Colors.grey[200],
                  child: InkWell(
                    onTap: () {
                      provider.changeUser(User.driver);
                    },
                    borderRadius: radius,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Icon(LineIcons.car),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Перключить профиль на водителя',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              margin: const EdgeInsets.fromLTRB(15, 5, 15, 10),
              decoration: const BoxDecoration(
                borderRadius: radius,
              ),
              child: Material(
                borderRadius: radius,
                color: Colors.grey[200],
                child: InkWell(
                  onTap: () => provider.signOutAdmin(),
                  borderRadius: radius,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(LineIcons.alternateSignOut),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Выйти',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
