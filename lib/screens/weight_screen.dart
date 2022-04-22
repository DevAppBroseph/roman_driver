import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:ridbrain_project/screens/pick_nomenclature.dart';
import 'package:ridbrain_project/services/buttons.dart';
import 'package:ridbrain_project/services/constants.dart';
import 'package:ridbrain_project/services/objects.dart';
import 'package:ridbrain_project/services/snack_bar.dart';
import 'package:ridbrain_project/services/text_field.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({Key? key}) : super(key: key);

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  List<Nomenclature?> _addedNomenclatures = [null];

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
                'Отвес',
                style: TextStyle(color: Colors.black),
              ),
              centerTitle: true,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 25)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _nomenclatureWidget(index, context),
              childCount: _addedNomenclatures.length,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: StandartButton(
                label: 'Добавить номенклатуру',
                onTap: () {
                  if (_addedNomenclatures.last != null) {
                    setState(() {
                      _addedNomenclatures.add(null);
                    });
                  } else {
                    StandartSnackBar.show(
                      context,
                      'Чтобы добавить номенклатуру, необходимо заполнить предыдущую.',
                      SnackBarStatus.warning(),
                    );
                  }
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: StandartButton(
                label: 'Сохранить',
                onTap: () {
                  setState(() {
                    _addedNomenclatures.add(null);
                  });
                },
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 35)),
        ],
      ),
    );
  }

  Container _nomenclatureWidget(int index, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: radius,
      ),
      margin: EdgeInsets.only(right: 15, left: 15, bottom: 15),
      child: Column(
        children: [
          if (_addedNomenclatures[index]?.name == null)
            Padding(
              padding: EdgeInsets.only(top: 15, left: 15, right: 15),
              child: StandartButton(
                label: _addedNomenclatures[index]?.name ?? 'Номенклатура',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PickNomenclatureScreen(),
                    ),
                  ).then((value) {
                    if (value is Nomenclature) {
                      setState(() {
                        _addedNomenclatures[index] = value;
                      });
                    }
                  });
                },
              ),
            ),
          if (_addedNomenclatures[index]?.name != null)
            Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
                top: 15,
              ),
              child: Text(
                _addedNomenclatures[index]!.name,
                textAlign: TextAlign.start,
              ),
            ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 15, bottom: 5, left: 15),
                      child: Text('Бутирование'),
                    ),
                    Container(
                      height: 45,
                      margin: EdgeInsets.only(bottom: 15, right: 5, left: 15),
                      child: TextFieldWidget(
                        hint: '',
                        type: TextInputType.phone,
                        controller: TextEditingController(),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 15, bottom: 5, left: 15),
                      child: Text('Тарирование'),
                    ),
                    Container(
                      height: 45,
                      margin: EdgeInsets.only(bottom: 15, right: 15, left: 15),
                      child: TextFieldWidget(
                        hint: '',
                        type: TextInputType.phone,
                        controller: TextEditingController(),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text('Нетто'),
                      ),
                      Container(
                          margin: EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: radius,
                          ),
                          height: 45,
                          child: Center(child: Text('349кг'))),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
