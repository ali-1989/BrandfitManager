import 'package:brandfit_manager/tools/app/appNotification.dart';
import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/api/helpers/databaseHelper.dart';

import '/system/keys.dart';

class DbCenter {
  DbCenter._();

  static late final DatabaseHelper db;
  ///---------------------------------------------------------------------------------------------
  static String tbKv = 'KvTable';
  static String tbUserModel = 'UserModel';
  static String tbUserAdvanced = 'UserAdvanced';

  // iso, iso_and_country, english_name, local_name, is_usable
  static String tbLanguages = 'Languages';

  // id, title, tag^, type, order_num, can_show, ...
  static String tbAdvertising = 'Advertising';

  // id, title, starter_user_id, start_date, type, is_close
  static String tbTickets = 'Tickets';
  static String tbTicketsDraft = 'TicketsDraft';
  // id, ticket_id, text, type, sender_user, send_date, server_receive_ts, user_receive_ts, is_saw
  static String tbTicketMessage = 'TicketMessage';
  static String tbTicketMessageDraft = 'TicketMessageDraft';
  static String tbMediaMessage = 'MediaMessage';
  static String tbMediaMessageDraft = 'MediaMessageDraft';
  static String tbChats = 'Chats';
  //static String tbChatDraft = 'ChatDraft';
  static String tbChatMessage = 'ChatMessage';
  static String tbChatMessageDraft = 'ChatMessageDraft';
  static String tbNotifiers = 'notifiers';
  static String tbMaterials = 'materials';
  static String tbPrograms = 'programs';
  static String tbCaloriesCounter = 'CaloriesCounter';
  static String tbCourseRequest = 'CourseRequest';


  static Future<bool> firstDatabasePrepare() async {
    await AppNotification.insertNotificationIds();
    await insertLanguages();

    return true;
  }

  static Future insertLanguages() async {
    final lan = <Map<String, dynamic>>[];
    lan.add({'iso':'en', 'iso_and_country': 'en_US', 'english_name': 'English'});
    lan.add({'iso':'fa', 'iso_and_country': 'fa_IR', 'english_name': 'Farsi'});
    lan.add({'iso':'ar', 'iso_and_country': null, 'english_name': 'Arabic'});
    lan.add({'iso':'en', 'iso_and_country': null, 'english_name': 'English'});

    for(var m in lan){
      await db.insertOrIgnore(tbLanguages, m,
          Conditions()
              .add(Condition(ConditionType.EQUAL)..key = 'iso'..value = m['iso'])
              .add(Condition(ConditionType.EQUAL)..key = 'iso_and_country'..value = m['iso_and_country']));
    }
  }

  static Future<int> setKv(String key, dynamic data){
    final con = Conditions();
    con.add(Condition()..key = Keys.name..value = key);

    final cell = <String, dynamic>{};
    cell[Keys.name] = key;
    cell[Keys.value] = data;

    return DbCenter.db.insertOrReplace(DbCenter.tbKv, cell, con);
  }

  static Future<int> deleteKv(String key){
    final con = Conditions();
    con.add(Condition()..key = Keys.name..value = key);

    return DbCenter.db.delete(DbCenter.tbKv, con);
  }

  static Future<int> addToList<T>(String key, T data){
    final con = Conditions();
    con.add(Condition()..key = Keys.name..value = key);

    final exist = DbCenter.db.queryFirst(DbCenter.tbKv, con);

    if(exist != null){
      final newList = (exist[Keys.value] as List).map((e) => e as T).toList();

      if(!newList.contains(data)) {
        newList.add(data);
      }

      final cell = <String, dynamic>{};
      cell[Keys.name] = key;
      cell[Keys.value] = newList;

      return DbCenter.db.update(DbCenter.tbKv, cell, con);
    }
    else {
      final cell = <String, dynamic>{};
      cell[Keys.name] = key;
      cell[Keys.value] = <T>[data];

      return DbCenter.db.insert(DbCenter.tbKv, cell);
    }
  }

  static Future<bool> removeFromList<T>(String key, T data) async {
    final con = Conditions();
    con.add(Condition()..key = Keys.name..value = key);

    final exist = DbCenter.db.queryFirst(DbCenter.tbKv, con);

    if(exist != null){
      final newList = (exist[Keys.value] as List).map((e) => e as T).toList();
      newList.remove(data);

      if(newList.isNotEmpty) {
        final cell = <String, dynamic>{};
        cell[Keys.name] = key;
        cell[Keys.value] = newList;

        return (await DbCenter.db.update(DbCenter.tbKv, cell, con)) > -1;
      }
      else {
        return (await DbCenter.db.delete(DbCenter.tbKv, con)) > -1;
      }
    }

    return true;
  }

  static List fetchKvs(String key){
    final con = Conditions();
    con.add(Condition()..key = Keys.name..value = key);

    final res = DbCenter.db.query(DbCenter.tbKv, con);

    if(res.isEmpty){
      return res;
    }

    return res.map((e) => e[Keys.value]).toList();
  }

  static dynamic fetchKv(String key){
    final con = Conditions();
    con.add(Condition()..key = Keys.name..value = key);

    final res = DbCenter.db.query(DbCenter.tbKv, con);

    if(res.isEmpty){
      return null;
    }

    return res[0][Keys.value];
  }

  static List<T> fetchAsList<T>(String key){
    final con = Conditions();
    con.add(Condition()..key = Keys.name..value = key);

    final res = DbCenter.db.query(DbCenter.tbKv, con);

    if(res.isEmpty){
      return [];
    }

    return res[0][Keys.value] as List<T>;
  }
}
