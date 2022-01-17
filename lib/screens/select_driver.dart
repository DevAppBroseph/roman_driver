import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:ridbrain_project/services/app_bar.dart';
import 'package:ridbrain_project/services/buttons.dart';
import 'package:ridbrain_project/services/network.dart';
import 'package:ridbrain_project/services/objects.dart';
import 'package:ridbrain_project/services/prefs_handler.dart';
import 'package:ridbrain_project/services/text_field.dart';

class SelectDriver extends StatefulWidget {
  const SelectDriver({
    Key? key,
    required this.onSelcet,
  }) : super(key: key);

  final Function(AdminDriver driver) onSelcet;

  @override
  _SelectDriverState createState() => _SelectDriverState();
}

class _SelectDriverState extends State<SelectDriver> {
  final _driverController = TextEditingController();

  List<AdminDriver> _drivers = [];
  AdminDriver? _selectedDriver;

  void _search(String token, String text) async {
    var result = await Network(context).searchDrivers(token, text);

    if (result.isNotEmpty && mounted) {
      setState(() {
        _drivers = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    if (_selectedDriver != null) {
      _driverController.text = _selectedDriver!.driverName;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          slivers: [
            StandartAppBar(
              title: Text("Выбор водителя"),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: TextFieldWidget(
                  icon: LineIcons.addressCard,
                  hint: "Водитель",
                  controller: _driverController,
                  onChanged: (value) {
                    _selectedDriver = null;
                    if (value.isNotEmpty) {
                      _search(provider.admin.token!, value);
                    } else {
                      if (_drivers.isNotEmpty && mounted) {
                        setState(() {
                          _drivers = [];
                        });
                      }
                    }
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 15,
              ),
            ),
            SliverToBoxAdapter(
              child: AnimatedSizeAndFade(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  height: _drivers.isEmpty ? 0 : 200,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: _drivers.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_drivers[index].driverName),
                        subtitle: Text(_drivers[index].driverPhone),
                        onTap: () {
                          setState(() {
                            _selectedDriver = _drivers[index];
                            _drivers = [];
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            if (_selectedDriver != null)
              SliverToBoxAdapter(
                child: StandartButton(
                  label: "Сохранить",
                  onTap: () {
                    widget.onSelcet(_selectedDriver!);
                    Navigator.pop(context);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
