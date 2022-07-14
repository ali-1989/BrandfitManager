import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/managers/assetManager.dart';

import '/models/dataModels/countryModel.dart';
import '/system/extensions.dart';
import '/tools/centers/cacheCenter.dart';

class CountryTools {
  CountryTools._();

  static Map<String, dynamic>? countriesMap;

  static Future<Map?> fetchCountries() async {
    return AssetsManager.loadAsString('assets/raw/countries.json').then((data) {
      if (data == null) {
        if(CacheCenter.appCache.addKey('prepareCountries')) {
          return Future.delayed(Duration(seconds: 1), () {
            return fetchCountries();
          });
        }

        return null;
      }

      countriesMap = JsonHelper.jsonToMap(data)!;
      return countriesMap;
    });
  }

  static String countryShowNameByCountryIso(String countryIso) {
    final Map countryMap = countriesMap!;
    final itr = countryMap.entries;
    final first = itr.first;
    String res = first.key + (first.value['nativeName'] != null? ' (${first.value['nativeName']})': '');

    itr.firstWhereSafe((country) {
      if(country.value['iso'] == countryIso) {
        res = country.key + (country.value['nativeName'] != null? ' (${country.value['nativeName']})': '');
        return true;
      }

      return false;
    });

    return res;
  }

  static CountryModel countryModelByCountryIso(String countryIso) {
    final Map countryMap = countriesMap!;
    final itr = countryMap.entries;
    final first = itr.first;

    final res = CountryModel();
    res.countryIso = countryIso;
    res.countryName = first.value['nativeName']?? '';
    res.countryPhoneCode = first.value['phoneCode']?? '';

    itr.firstWhereSafe((country) {
      if(country.value['iso'] == countryIso) {
        res.countryName = country.value['nativeName']?? '';
        res.countryPhoneCode = country.value['phoneCode']?? '';
        return true;
      }

      return false;
    });

    return res;
  }
}
