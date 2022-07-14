import 'package:flutter/material.dart';

import 'package:iris_tools/widgets/searchBar.dart';

import '/abstracts/stateBase.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/tools/countryTools.dart';

class CurrencySelectScreen extends StatefulWidget {
  static const screenName = 'CurrencySelectScreen';

  CurrencySelectScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CurrencySelectScreenState();
  }
}
///=====================================================================================
class CurrencySelectScreenState extends StateBase<CurrencySelectScreen> {
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
    //CountrySelectScreenState state = ss as CountrySelectScreenState;

    AppNavigator.pop(context, result: result);
    return Future<bool>.value(false);
  }

  void fetchCountries() {
    /*AssetsManager.loadAsString('assets/raw/countries.json').then((data) {
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
      title: Text(tC('currencySelection')!),
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
              hint: tC('selectCurrency'),
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
                        'iso': m.value['iso'],
                        'currency_name': m.value['currencyName'],
                        'currency_symbol': m.value['currencySymbol'],
                        'currency_code': m.value['currencyCode'],
                      };
                      AppNavigator.pop(context, result: result);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  m.value['currencyName'] + '  (${m.value['currencySymbol']})',
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  style: AppThemes.baseTextStyle().copyWith(fontWeight: FontWeight.bold),),
                              ),

                              Text('${m.value['currencyCode']}')
                            ],
                          ),

                          const SizedBox(height: 8,),

                          Text('${m.key}',
                            style: AppThemes.baseTextStyle().copyWith(
                                color: AppThemes.baseTextStyle().color!.withAlpha(150)
                            ),),
                        ],
                      ),
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
          || el.value['currencyName'].contains(rex)
          || el.value['currencyCode'].contains(rex)
          || el.value['currencySymbol'].toString().contains(rex);
    });
  }
}

