import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridbrain_project/services/network.dart';
import 'package:ridbrain_project/services/objects.dart';
import 'package:ridbrain_project/services/prefs_handler.dart';
import 'package:ridbrain_project/services/text_field.dart';

class PickNomenclatureScreen extends StatefulWidget {
  PickNomenclatureScreen({Key? key}) : super(key: key);

  @override
  State<PickNomenclatureScreen> createState() => _PickNomenclatureScreenState();
}

class _PickNomenclatureScreenState extends State<PickNomenclatureScreen> {
  List<Nomenclature> _nomenclatures = [];
  List<Nomenclature> _searchedNomenclatures = [];
  var _searchController = TextEditingController();

  void _getNomenclatures() async {
    var provider = Provider.of<DataProvider>(context);
    // if (provider.hasDriver) {
    var result =
        await Network(context).getNomenclatures(provider.driver.driverToken);
    if (result != null) {
      setState(() {
        _searchedNomenclatures = result;
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
    _searchController.addListener(() => _search(_searchController.text));
    super.didChangeDependencies();
  }

  void _search(String text) {
    if (text != '') {
      _searchedNomenclatures = _nomenclatures
          .where((element) =>
              element.name.toLowerCase().contains(text.toLowerCase()) ||
              element.code.toString().contains(text))
          .toList();
    } else {
      _searchedNomenclatures = _nomenclatures;
    }
    setState(() {});
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
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              child: TextFieldWidget(
                controller: _searchController,
                hint: 'Введите название номенклатуры',
              ),
            ),
          ),
          if (_searchedNomenclatures.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => InkWell(
                  onTap: () {
                    Navigator.pop(context, _searchedNomenclatures[index]);
                  },
                  child: Container(
                    height: 80,
                    child: Center(
                      child: ListTile(
                        title: Text(_searchedNomenclatures[index].name),
                        subtitle: Text('${_searchedNomenclatures[index].code}'),
                      ),
                    ),
                  ),
                ),
                childCount: _searchedNomenclatures.length,
              ),
            ),
        ],
      ),
    );
  }
}
