
//import 'package:flutter_contact/contacts.dart';

/*class ContactPickerScreen extends StatefulWidget {
  static final screenName = 'ContactPickerScreen';

  ContactPickerScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ContactPickerScreenState();
  }
}
///=====================================================================================
class ContactPickerScreenState extends StateBase<ContactPickerScreen> {
  Contact? result;
  List<Contact> contacts = [];
  String searchText = '';
  late Iterable<Contact> filteredList;

  @override
  void initState() {
    super.initState();

    if (contacts.isEmpty) {
      fetchCountries();
    }
  }

  @override
  Widget build(BuildContext context) {
    rotateToPortrait();

    return getScaffold(this);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> onWillBack<s extends StateBase>(s ss) {
    AppNavigator.pop(context, result: result);
    return Future<bool>.value(false);
  }

  void fetchCountries() async {
    await Contacts.streamContacts(
      withThumbnails: false,
      withHiResPhoto: false,
      withUnifyInfo: true,
    ).forEach((contact) {
      contacts.add(contact);
    });

    update();
  }
}

///========================================================================================================
Widget getScaffold(ContactPickerScreenState state) {
  return WillPopScope(
    onWillPop: () => state.onWillBack(state),
    child: Scaffold(
      key: state.scaffoldKey,
      appBar: getAppbar(state),
      body: getBody(state),
    ),
  );
}

///========================================================================================================
getAppbar(ContactPickerScreenState state) {
  return AppBar(
    title: Text(state.tC('contactSelection')!),
  );
}

///========================================================================================================
getBody(ContactPickerScreenState state) {
  filter(state);

  return Container(
    width: AppSizes.getScreenWidth(state.context),
    height: AppSizes.getScreenHeight(state.context),
    child: Column(
      children: <Widget>[
        SizedBox(
          height: 4,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          child: SearchBar(
            iconColor: AppThemes.checkPrimaryByWB(AppThemes.currentTheme.primaryColor, AppThemes.currentTheme.textColor),
            //hint: state.tC(''),
            onChangeEvent: (t) {
              state.searchText = t;
              state.update();
            },
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Expanded(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ListView.separated(
              itemCount: state.filteredList.length,
              itemBuilder: (BuildContext context, int index) {
                Contact c = state.filteredList.elementAt(index);

                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    state.result = c;
                    AppNavigator.pop(context, result: state.result);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${c.displayName}',
                          style: AppThemes.baseTextStyle().copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          '${(c.phones.length > 0) ? c.phones.first.value ?? '' : ''}',
                          style: AppThemes.baseTextStyle().copyWith(color: AppThemes.baseTextStyle().color!.withAlpha(150)),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
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
void filter(ContactPickerScreenState state) {
  if (state.searchText.trim().isEmpty) {
    state.filteredList = state.contacts;
    return;
  }

  RegExp rex = RegExp('${RegExp.escape(state.searchText)}', caseSensitive: false, unicode: true);

  state.filteredList = state.contacts.where((el) {
    return (el.displayName?.contains(rex) ?? false) ||
        el.phones.any((number) {
          return number.value?.contains(rex) ?? false;
        });
  });
}*/
///========================================================================================================
