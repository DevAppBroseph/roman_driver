import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:ridbrain_project/screens/add_company.dart';
import 'package:ridbrain_project/screens/edit_company.dart';
import 'package:ridbrain_project/services/app_bar.dart';
import 'package:ridbrain_project/services/constants.dart';
import 'package:ridbrain_project/services/network.dart';
import 'package:ridbrain_project/services/objects.dart';
import 'package:ridbrain_project/services/prefs_handler.dart';

class AdminCompanies extends StatefulWidget {
  AdminCompanies({Key? key}) : super(key: key);

  @override
  _AdminCompaniesState createState() => _AdminCompaniesState();
}

class _AdminCompaniesState extends State<AdminCompanies> {
  List<Company> _companies = [];
  bool _loading = true;

  void _updateList(String token) async {
    setState(() {
      _loading = true;
    });
    var result = await Network(context).getCompanies(token);
    setState(() {
      _companies = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    if (_companies.isEmpty) {
      _updateList(provider.admin.token!);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        edgeOffset:
            MediaQuery.of(context).padding.top + AppBar().preferredSize.height,
        onRefresh: () async {
          _updateList(provider.admin.token!);
        },
        child: CustomScrollView(
          slivers: [
            StandartAppBar(
              title: Text("Компании"),
            ),
            _getCompaniesList()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[800],
        child: Icon(
          LineIcons.plus,
          color: Colors.white,
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddCompanyScreen(
              success: (company) {
                setState(() {
                  _companies.add(company);
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _getCompaniesList() {
    if (_loading) {
      return SliverToBoxAdapter(
        child: Container(
          height: 600,
          child: CupertinoActivityIndicator(),
        ),
      );
    }
    if (_companies.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 400,
          alignment: Alignment.center,
          child: Text(
            "Компании не добавлены.",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        var record = _companies[index];
        return CompanyCell(
          index: index,
          company: record,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditCompanyPage(
                company: record,
                save: (company) {
                  var index = 0;
                  for (Company item in _companies) {
                    if (item.companyId == company.companyId) {
                      setState(() {
                        _companies[index] = company;
                      });
                      break;
                    }
                    index++;
                  }
                },
              ),
            ),
          ),
        );
      }, childCount: _companies.length),
    );
  }
}

class CompanyCell extends StatelessWidget {
  const CompanyCell({
    Key? key,
    required this.index,
    required this.company,
    required this.onTap,
  }) : super(key: key);

  final int index;
  final Company company;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 10),
      decoration: const BoxDecoration(
        borderRadius: radius,
      ),
      child: Material(
        borderRadius: radius,
        color: index.isEven ? Colors.white : Colors.grey[50],
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  company.companyName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  company.companyLocation.address,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  company.companyPhone,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  company.companyWeb,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
