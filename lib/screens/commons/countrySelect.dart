import 'package:flutter/material.dart';

import 'package:iris_tools/widgets/searchBar.dart';

import '/abstracts/stateBase.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/tools/countryTools.dart';

class CountrySelectScreen extends StatefulWidget {
  static const screenName = 'CountrySelectScreen';

  CountrySelectScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CountrySelectScreenState();
  }
}
///========================================================================================================
class CountrySelectScreenState extends StateBase<CountrySelectScreen> {
  Map<String, dynamic> result = {};
  Map<String, dynamic> countries = {};
  String searchText = '';
  late Iterable filteredList;

  @override
  void initState() {
    super.initState();

    if(countries.isEmpty) {
      fetchCountries();
    }
  }

  @override
  Widget build(BuildContext context) {
    rotateToPortrait();

    return getScaffold();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Future<bool> onWillBack<S extends StateBase>(S state) {
    //CountrySelectScreenState state = state as CountrySelectScreenState;

    AppNavigator.pop(context, result: result);
    return Future<bool>.value(false);
  }

  void fetchCountries() {
    /*AssetsManager.loadAsString('assets/raw /countries.json').then((data) {
      if (data == null)
        return;

      countries = JsonHelper.jsonToMap(data)!;
      update();
    });*/

    countries = CountryTools.countriesMap!;
  }

  Widget getScaffold() {
    return WillPopScope(
      onWillPop: () => onWillBack(this),
      child: Scaffold(
        key: scaffoldKey,
        appBar: getAppbar(),
        body: getBody(),
      ),
    );
  }

  PreferredSizeWidget getAppbar() {
    return AppBar(
      title: Text(tC('countrySelection')!),
    );
  }

  Widget getBody() {
    filter();

    return SizedBox(
      width: AppSizes.getScreenWidth(context),
      height: AppSizes.getScreenHeight(context),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 4,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            child: SearchBar(
              iconColor: AppThemes.checkPrimaryByWB(AppThemes.currentTheme.primaryColor, AppThemes.currentTheme.textColor),
              hint: tC('selectCountry'),
              onChangeEvent: (t){
                searchText = t;
                update();
              },
            ),
          ),
          const SizedBox(height: 5,),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: ListView.separated(
                itemCount: filteredList.length,
                itemBuilder: (BuildContext context, int index){
                  final MapEntry m = filteredList.elementAt(index);

                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: (){
                      result = {
                        'name': m.key,
                        'native_name': m.value['nativeName'],
                        'iso': m.value['iso'],
                        'phone_code': m.value['phoneCode'],
                      };
                      AppNavigator.pop(context, result: result);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 22),
                      child: Text('${m.key}' + (m.value['nativeName'] != null? ' (${m.value['nativeName']})': ''),
                        style: AppThemes.baseTextStyle().copyWith(fontWeight: FontWeight.bold),),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index){
                  return const Divider(
                    indent: 20,
                    endIndent: 20,
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
  ///========================================================================================================
  void filter(){
    if(searchText.trim().isEmpty) {
      filteredList = countries.entries;
      return;
    }

    final rex = RegExp(RegExp.escape(searchText), caseSensitive: false, unicode: true);

    filteredList = countries.entries.where((el){
      return el.key.contains(rex)
          || el.value['nativeName'].contains(rex)
          || el.value['phoneCode'].toString().contains(rex);
    });
  }
}


