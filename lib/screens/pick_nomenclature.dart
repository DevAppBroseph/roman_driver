import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridbrain_project/services/network.dart';
import 'package:ridbrain_project/services/objects.dart';
import 'package:ridbrain_project/services/prefs_handler.dart';

class PickNomenclatureScreen extends StatefulWidget {
  PickNomenclatureScreen({Key? key}) : super(key: key);

  @override
  State<PickNomenclatureScreen> createState() => _PickNomenclatureScreenState();
}

class _PickNomenclatureScreenState extends State<PickNomenclatureScreen> {
  List<Nomenclature> _nomenclatures = [];

  void _getNomenclatures() async {
    var provider = Provider.of<DataProvider>(context);
    // if (provider.hasDriver) {
    var result =
        await Network(context).getNomenclatures(provider.driver.driverToken);
    if (result != null) {
      setState(() {
        _nomenclatures = result;
      });
      print(true);
    }
    // }
    print(false);
  }

  @override
  void didChangeDependencies() {
    _getNomenclatures();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Выберите номенклатуру',
                style: TextStyle(color: Colors.black),
              ),
              centerTitle: true,
            ),
          ),
          if (_nomenclatures.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => InkWell(
                  onTap: () {
                    Navigator.pop(context, _nomenclatures[index]);
                  },
                  child: Container(
                    height: 70,
                    child: Center(
                      child: ListTile(
                        title: Text(_nomenclatures[index].name),
                      ),
                    ),
                  ),
                ),
                childCount: _nomenclatures.length,
              ),
            ),
        ],
      ),
    );
  }
}
