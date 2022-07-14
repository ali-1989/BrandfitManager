import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/models/dataModels/colorTheme.dart';

import '/managers/fontManager.dart';

/// hlp:
/// https://htmlcolorcodes.com/
/// https://colorhunt.co/

class AppThemes {
	AppThemes._();

	static bool _isInit = false;
	static Map<String, ColorTheme> themeList = {};
	static late ColorTheme currentTheme;
	static late ColorTheme defaultTheme;
	static late Font baseFont;
	static late Font subFont;
	static late Font boldFont;
	static late Font chatFont;
	static late ThemeData themeData;
	static ThemeMode currentThemeMode = ThemeMode.light;
	static Brightness currentBrightness = Brightness.light;
	static TextDirection textDirection = TextDirection.ltr;
	static StrutStyle strutStyle = StrutStyle(forceStrutHeight: true, height: 1.08, leading: 0.36);
	static final List<Function(ColorTheme)> _onThemeChangeListeners = [];

	static void addThemeChangeListener(Function(ColorTheme) lis) {
		if (!_onThemeChangeListeners.contains(lis)) {
		  _onThemeChangeListeners.add(lis);
		}
	}

	static void removeThemeChangeListener(Function(ColorTheme) lis) {
		_onThemeChangeListeners.remove(lis);
	}

	static ThemeData getThemeData(BuildContext context) {
		return Theme.of(context);
	}

	static void initial() {
		if(!_isInit) {
			baseFont = Font();
			subFont = Font();
			boldFont = Font();
			chatFont = Font();
		}

		themeList.clear();
		prepareThemes();

		if(!_isInit) {
			currentTheme = defaultTheme;
		}

		themeData = createThemeData(currentTheme);
		_isInit = true;
	}

	static void prepareThemes() {
		{
			final blueTheme = ColorTheme(Color(0xFF1976D2), Color(0xFF00AACC), Color(0xFFFF006E), Colors.black);
			//primary: ^1976D2, 1060A0 | dif: (FF006E|d81b60), ^F77F00

			blueTheme.themeName = 'Blue';

			themeList[blueTheme.themeName] = blueTheme;
		}
		//-------------------------------------------------------------
		 {
			final oliveTheme = ColorTheme(Color(0xFF407C50), Color(0xFF669955), Color(0xFFFF3010), Colors.black);
			//accent: 607E50   |  dif: FF3010, FF4560
			oliveTheme.themeName = 'olive';

			themeList[oliveTheme.themeName] = oliveTheme;
		}
		//-------------------------------------------------------------
		 {
			final mustardTheme = ColorTheme(Colors.orange, Color(0xFFBFAA20), Color(0xFF00DD77), Colors.black);

			mustardTheme.themeName = 'Mustard';//FF9000

			themeList[mustardTheme.themeName] = mustardTheme;
		}
		//-------------------------------------------------------------
		 {
			final seafoamTheme = ColorTheme(Color(0xFF00D070), Color(0xFF008877), Color(0xFFD2691E), Colors.black);

			seafoamTheme.themeName = 'Seafoam';//FF9000
			seafoamTheme.underLineDecorationColor = Colors.pink[600]!;

			themeList[seafoamTheme.themeName] = seafoamTheme;
		}
		//-----------------------------------------------------------------------------
		{
			final orangeTheme = ColorTheme(Color(0xFFFC4800), Color(0xFFB04F00), Color(0xFFEECC11), Colors.black);
			//primary: FB5607 | accent: B03F0F, | dif: 80b918 , 55BBFF

			orangeTheme.themeName = 'Orange';
			orangeTheme.badgeBackColor = Colors.blue;
			orangeTheme.underLineDecorationColor = Colors.lightBlue;

			themeList[orangeTheme.themeName] = orangeTheme;
		}
		//-----------------------------------------------------------------------------
		{
			final brownTheme = ColorTheme(Color(0xFFB03F0F), Color(0xFFBB7733), Color(0xFFDD2277), Colors.black);

			brownTheme.themeName = 'Brown';
			brownTheme.badgeBackColor = Colors.blue;

			themeList[brownTheme.themeName] = brownTheme;
		}
		//-----------------------------------------------------------------------------
		{
			final pinkTheme = ColorTheme(Color(0xFFDD2277), Color(0xFFD15070), Color(0xFF4455FF), Colors.black);

			pinkTheme.themeName = 'Pink';
			pinkTheme.badgeBackColor = Colors.blue;

			themeList[pinkTheme.themeName] = pinkTheme;
		}
		//-----------------------------------------------------------------------------
		{
			final pink2Theme = ColorTheme(Color(0xFFF11E65), Color(0xFFF05096), Color(0xFFFFD000), Colors.black);

			pink2Theme.themeName = 'Pink2';
			pink2Theme.badgeBackColor = Colors.blue;

			themeList[pink2Theme.themeName] = pink2Theme;
		}
		//-----------------------------------------------------------------------------
		{
			final greenTheme = ColorTheme(Color(0xFF608500), Color(0xFF80802F), Color(0xFFFC442C), Colors.black);
			//primary: 0xFFadc01a, 0xFFc5d500 | dif: 0xFF00b0d0

			greenTheme.themeName = 'Green';

			themeList[greenTheme.themeName] = greenTheme;

			defaultTheme = greenTheme;
		}
		//-----------------------------------------------------------------------------
		{
			final redTheme = ColorTheme(Color(0xFFFF0000), Color(0xFFFF1050), Color(0xFF3FE440), Colors.black);

			redTheme.themeName = 'Red';
			redTheme.badgeBackColor = Colors.lightBlue;

			themeList[redTheme.themeName] = redTheme;
		}
		//-----------------------------------------------------------------------------
		{
			final yellowTheme = ColorTheme(Color(0xFFEED010), Color(0xFFF0B020), Color(0xFF608500), Colors.black);

			yellowTheme.themeName = 'Yellow';

			themeList[yellowTheme.themeName] = yellowTheme;
		}
		//-----------------------------------------------------------------------------
		{
			final pSwitch = MaterialColor(Colors.grey.value, {
				50: Color(0xffbbbbbb),
				100: Color(0xffcccccc),
				200: Color(0xffcccccc),
				300: Color(0xffdddddd),
				400: Color(0xffdddddd),
				500: Colors.grey,
				600: Color(0xffdddddd),
				700: Color(0xffdddddd),
				800: Color(0xffcccccc),
				900: Color(0xffbbbbbb),
			});

			final greyTheme = ColorTheme(Colors.grey[600]!, Colors.grey[400]!, Color(0xFFD03F0F), Colors.black,
			primarySwatch: pSwitch);
			// accent: Color(0xFF5e5e5e)  | dif: Color(0xffb03030)

			greyTheme.themeName = 'Grey';
			greyTheme.backgroundColor = Color(0xFFFAFAFA);
			greyTheme.dialogBackColor = Colors.grey[400]!;
			greyTheme.cardColor = Colors.grey[400]!;
			greyTheme.appBarBackColor = Color(0xffbbbbbb);
			greyTheme.appBarItemColor = Colors.black;
			greyTheme.buttonTextColor = Color(0xFFffffff);
			greyTheme.buttonBackColor = Color(0xff454545);
			greyTheme.buttonTextColorOnPrimary = Colors.black;
			greyTheme.buttonBackColorOnPrimary = Colors.white;
			greyTheme.inactiveTextColor = Color(0xff998090);

			themeList[greyTheme.themeName] = greyTheme;
		}
		//-----------------------------------------------------------------------------
		{
			final pSwitch = MaterialColor(Colors.white.value, {
				50: Color(0xffcccccc),
				100: Color(0xffdddddd),
				200: Color(0xffdddddd),
				300: Color(0xffeeeeee),
				400: Color(0xffeeeeee),
				500: Colors.white,
				600: Color(0xffeeeeee),
				700: Color(0xffdddddd),
				800: Color(0xffdddddd),
				900: Color(0xffcccccc),
			});

			final ac = Colors.grey[300]!;
			final whiteTheme = ColorTheme(Colors.white, ac, Color(0xFFDD2277), Colors.black,
			primarySwatch: pSwitch);
			// dif: Colors.grey[600]و Colors.lightBlue

			whiteTheme.themeName = 'White';
			whiteTheme.dialogBackColor = Colors.grey[100]!;
			whiteTheme.backgroundColor = Color(0xffffffff);//old: Color(0xffeeeeee)
			whiteTheme.cardColor = Colors.white;
			whiteTheme.drawerBackColor = Colors.white;
			whiteTheme.drawerItemColor = Colors.black;
			whiteTheme.appBarBackColor = Colors.white;
			whiteTheme.appBarItemColor = Colors.black;
			whiteTheme.buttonTextColor = Colors.white;
			whiteTheme.buttonBackColor = Colors.black;
			whiteTheme.buttonTextColorOnPrimary = Colors.white;
			whiteTheme.buttonBackColorOnPrimary = Colors.black;
			whiteTheme.textDifferentColor = whiteTheme.differentColor;

			themeList.putIfAbsent(whiteTheme.themeName, () => whiteTheme);
		}
		//-------------------------------------------------------------
		{
			final pSwitch = MaterialColor(Colors.black.value, {
				50: Color(0xff404040),
				100: Color(0xff404040),
				200: Color(0xff303030),
				300: Color(0xff202020),
				400: Color(0xff101010),
				500: Colors.black,
				600: Color(0xff101010),
				700: Color(0xff202020),
				800: Color(0xff202020),
				900: Color(0xff303030),
			});

			final blackTheme = ColorTheme(Colors.black, Color(0xff404040), Color(0xffBB8100), Colors.white,
			primarySwatch: pSwitch);
			// dif: 0xffa02020 , 0xffC0406C, 0xff22DD33

			blackTheme.themeName = 'Black';
			blackTheme.backgroundColor = Color(0xff252525); //Colors.grey[900]
			blackTheme.dialogBackColor = Colors.grey[900]!;
			blackTheme.cardColor = Colors.black;
			blackTheme.drawerBackColor =  Color(0xff161616);
			blackTheme.drawerItemColor =  Colors.white;
			blackTheme.buttonBackColor = Color(0xfff0f0f0);
			blackTheme.buttonTextColor = Colors.black;
			blackTheme.buttonTextColorOnPrimary = Colors.black;
			blackTheme.buttonBackColorOnPrimary = Colors.white;
			blackTheme.appBarBackColor = Colors.black;
			blackTheme.shadowColor = Color(0xee808080);

			themeList.putIfAbsent(blackTheme.themeName, () => blackTheme);
		}
	}

	static void applyDefaultTheme() {
		applyTheme(defaultTheme);
	}

	static void applyTheme(ColorTheme theme) {
		currentTheme = theme;
		themeData = createThemeData(theme);

		_onThemeChange();
	}

	static void _onThemeChange() {
		for (var f in _onThemeChangeListeners) {
			try {
				f.call(currentTheme);
			}
			catch (e) {}
		}
	}
	///--------------------------------------------------------------------------------------------------
	static void _checkTheme(ColorTheme th) {
		th.buttonsColorScheme = ColorScheme.fromSwatch(
			primarySwatch: th.primarySwatch,
			primaryColorDark: ColorHelper.darkIfIsLight(th.primaryColor),
			// buttons are use this color for btnText (accentColor)
			accentColor: th.buttonTextColor,
			backgroundColor: th.buttonBackColor,
			errorColor: th.errorColor,
			cardColor: th.cardColor,
			brightness: currentBrightness,
		);

		th.fontSize = baseFont.size ??  FontManager.instance.getPlatformFont().size!;

		final raw = FontManager.instance.rawTextTheme;

		th.baseTextStyle = raw.bodyText2!.copyWith(
			fontSize: baseFont.size,
			fontFamily: baseFont.family,
			height: baseFont.height,
			color: th.textColor,
		);
		th.subTextStyle = raw.subtitle1!.copyWith(
			fontSize: subFont.size,
			fontFamily: subFont.family,
			height: subFont.height,
			color: th.textColor,
		);
		th.boldTextStyle = raw.headline1!.copyWith(
			fontSize: boldFont.size,
			fontFamily: boldFont.family,
			height: boldFont.height,
			color: th.textColor,
		);

		th.textUnderlineStyle = th.textUnderlineStyle.copyWith(
			fontSize: th.fontSize,
			height: baseFont.height,
			color: th.underLineDecorationColor,
			decorationColor: th.underLineDecorationColor,
		);
	}

	static ThemeData createThemeData(ColorTheme th) {
		if (th.executeOnStart != null) {
		  th.executeOnStart?.call(th);
		}

		_checkTheme(th);

		final baseFamily = th.baseTextStyle.fontFamily;
		final subFamily = th.subTextStyle.fontFamily;
		final boldFamily = th.boldTextStyle.fontFamily;
		final fontSize = th.fontSize;
		final height = th.baseTextStyle.height?? 1.0;
		final raw = FontManager.instance.rawThemeData;

		final primaryTextTheme = TextTheme(
				//fontSize: raw.textTheme.bodyText1.fontSize + fontSize
				bodyText1: raw.textTheme.bodyText1!.copyWith(
						fontFamily: baseFamily, color: th.textColor, fontSize: fontSize, height: height,
				),
				bodyText2: raw.textTheme.bodyText2!.copyWith(
						fontFamily: baseFamily, color: th.textColor, fontSize: fontSize, height: height,
				),
				subtitle1: raw.textTheme.subtitle1!.copyWith(
						fontFamily: baseFamily, color: th.textColor, fontSize: fontSize, height: height,
				),
				subtitle2: raw.textTheme.subtitle2!.copyWith(
						fontFamily: subFamily, color: th.textColor, fontSize: fontSize-1, height: height,
				),
				overline: raw.textTheme.overline!.copyWith(
						fontFamily: subFamily, color: th.textColor, fontSize: fontSize, height: height,
				),
				headline1: raw.textTheme.headline1!.copyWith(
						fontFamily: boldFamily, color: th.textColor, fontSize: fontSize + 6, height: height,
				),
				headline2: raw.textTheme.headline2!.copyWith(
						fontFamily: boldFamily, color: th.textColor, fontSize: fontSize + 5, height: height,
				),
				headline3: raw.textTheme.headline3!.copyWith(
						fontFamily: boldFamily, color: th.textColor, fontSize: fontSize + 4, height: height,
				),
				headline4: raw.textTheme.headline4!.copyWith(
						fontFamily: baseFamily, color: th.textColor, fontSize: fontSize + 3, height: height,
				),
				headline5: raw.textTheme.headline5!.copyWith(
						fontFamily: baseFamily, color: th.textColor, fontSize: fontSize + 2, height: height,
				),
				headline6: raw.textTheme.headline6!.copyWith(
						fontFamily: baseFamily, color: th.appBarItemColor, fontSize: fontSize + 1,
					fontWeight: FontWeight.bold, height: height,
				),
				button: raw.textTheme.button!.copyWith(
						fontFamily: boldFamily, color: th.buttonTextColor, fontSize: fontSize, height: height,
				),
				caption: raw.textTheme.caption!.copyWith(
						fontFamily: subFamily, color: th.textColor, fontSize: fontSize, height: height,
				),
		);

		final chipBack = checkPrimaryByWB(th.primaryColor, th.buttonBackColor);
		final chipTextColor = ColorHelper.getUnNearColor(Colors.white, chipBack, Colors.black);

		final chipThemeData = raw.chipTheme.copyWith(//ThemeData();
			brightness: currentBrightness,
			backgroundColor: chipBack,
			checkmarkColor: chipTextColor,
			deleteIconColor: chipTextColor,
			selectedColor: th.differentColor,
			disabledColor: th.inactiveTextColor,//changeLight(th.accentColor),
			shadowColor: th.shadowColor,
			labelStyle: th.subTextStyle.copyWith(color: chipTextColor),
			elevation: ColorHelper.isNearLightness(th.primaryColor, Colors.black)? 0.0: 1.0,
			padding: EdgeInsets.all(0.0),
		);

		final scrollbarTheme = ScrollbarThemeData().copyWith(
			thumbColor: MaterialStateProperty.all(
					AppThemes.checkPrimaryByWB(th.primaryColor.withAlpha(80), th.differentColor.withAlpha(80))
			),
		);

		/*IconThemeData iconTheme = IconThemeData(
      color: th.textColor,
    );*/

		final iconTheme = raw.iconTheme.copyWith(
			color: th.textColor,
		);

		final appAppBarTheme = AppBarTheme(
			toolbarTextStyle: primaryTextTheme.headline6,
			iconTheme: iconTheme.copyWith(color: th.appBarItemColor),
			actionsIconTheme: iconTheme.copyWith(color: th.appBarItemColor),
			systemOverlayStyle: currentBrightness == Brightness.light? SystemUiOverlayStyle.light: SystemUiOverlayStyle.dark,
			centerTitle: true,
			elevation: 1.0,
			color: th.appBarBackColor,
			shadowColor: th.shadowColor,
		);

		final dialogTheme = DialogTheme(
				elevation: ColorHelper.isNearLightness(th.primaryColor, Colors.black)? 1.0: 5.0,
				titleTextStyle: th.baseTextStyle.copyWith(fontSize: fontSize + 5, color: th.dialogTextColor, fontWeight: FontWeight.w700),
				contentTextStyle: th.baseTextStyle.copyWith(fontSize: fontSize + 2, color: th.dialogTextColor),
				backgroundColor: th.dialogBackColor,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
		);

		final pageTransition = PageTransitionsTheme(builders: {
			TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
			TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
		});

		final sliderTheme = SliderThemeData(
			trackHeight: 4.0,
			trackShape: RoundedRectSliderTrackShape(),
			thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
			overlayShape: RoundSliderOverlayShape(overlayRadius: 20.0),
			tickMarkShape: RoundSliderTickMarkShape(),
			valueIndicatorShape: PaddleSliderValueIndicatorShape(),
			thumbColor: th.buttonBackColor, //circle
			activeTrackColor: th.buttonBackColor,// selectedBar
			inactiveTrackColor: th.inactiveBackColor, // selectedBar before seek
			activeTickMarkColor: th.buttonBackColor,// selectedBar dot,
			disabledActiveTickMarkColor: th.buttonBackColor,// unSelectedBar dot,
			overlayColor: th.errorColor,
			valueIndicatorColor: th.infoColor,
		);

		final popupMenu = PopupMenuThemeData(
			elevation: ColorHelper.isNearLightness(th.primaryColor, Colors.black)? 0.0: 4.0,
			color: th.drawerBackColor,
			textStyle: th.baseTextStyle.copyWith(height: 1.1),
		);

		final colorScheme = ColorScheme.fromSwatch(
		primarySwatch: th.primarySwatch,
		primaryColorDark: ColorHelper.darkIfIsLight(th.primaryColor),
		accentColor: th.accentColor, // => is secondary
		backgroundColor: th.backgroundColor,
		errorColor: th.errorColor,
		cardColor: th.cardColor,
		brightness: currentBrightness,
		);

		final cardTheme = CardTheme(
			color: th.cardColor,
			elevation: ColorHelper.isNearLightness(th.primaryColor, Colors.black)? 3.0: 4.0,
			shadowColor: th.shadowColor,
			clipBehavior: Clip.antiAlias,
			margin: EdgeInsets.all(4.0), // def: 4.0
		);

		/// https://flutter.dev/docs/release/breaking-changes/buttons

		final elevatedButtonTheme = ElevatedButtonThemeData(
			style: ButtonStyle(
					tapTargetSize: MaterialTapTargetSize.padded,
				//backgroundColor: MaterialStateProperty.all(th.buttonBackColor),
				foregroundColor: MaterialStateProperty.all(th.buttonTextColor),
				backgroundColor: MaterialStateProperty.resolveWith<Color>(
							(Set<MaterialState> states) {
						if (states.contains(MaterialState.disabled)) {
						  return th.inactiveBackColor;
						}
						if (states.contains(MaterialState.hovered)) {
							return th.buttonBackColor.withAlpha(200);
						}
						if (states.contains(MaterialState.focused) ||
								states.contains(MaterialState.pressed)) {
						  return th.buttonBackColor;
						}

						return th.buttonBackColor;
					},
				),
			),
		);

		final textButtonTheme = TextButtonThemeData(
			style: ButtonStyle(
				//foregroundColor: MaterialStateProperty.all(AppThemes.checkPrimaryByWB(th.primaryColor, th.differentColor)),
				foregroundColor: MaterialStateProperty.all(Colors.lightBlue),
				overlayColor: MaterialStateProperty.all(
						AppThemes.checkPrimaryByWB(th.primaryColor, th.differentColor).withAlpha(100)
				),
					visualDensity: VisualDensity.compact,
					tapTargetSize: MaterialTapTargetSize.padded,
			),
		);

		final outlinedButtonTheme = OutlinedButtonThemeData(
			style: ButtonStyle(
				tapTargetSize: MaterialTapTargetSize.shrinkWrap,
				//backgroundColor: MaterialStateProperty.all(th.buttonBackColor),
				foregroundColor: MaterialStateProperty.all(th.textColor),
			),
		);

		final tableThemeData = DataTableThemeData(
			dataRowColor: MaterialStateProperty.all(th.primaryColor),
			headingRowColor: MaterialStateProperty.all(th.differentColor),
			dataTextStyle: primaryTextTheme.caption,
		);

		final radioThemeData = RadioThemeData(
			fillColor: MaterialStateProperty.all(AppThemes.checkPrimaryByWB(th.primaryColor, th.differentColor)),
			overlayColor: MaterialStateProperty.all(th.differentColor),
			materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
			visualDensity: VisualDensity.comfortable,
		);

		final checkboxThemeData = CheckboxThemeData(
			fillColor: MaterialStateProperty.all(AppThemes.checkPrimaryByWB(th.primaryColor, th.differentColor)),
			overlayColor: MaterialStateProperty.all(th.differentColor),
			materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
			visualDensity: VisualDensity.comfortable,
		);

		final dividerTheme = DividerThemeData(
			color: th.dividerColor,
			endIndent: 0,
			indent: 0,
			space: 1.0,
			thickness: 1.0
		);

		final inputDecoration = InputDecorationTheme(
			hintStyle: th.baseTextStyle.copyWith(color: th.hintColor),
			labelStyle: th.subTextStyle.copyWith(color: th.hintColor),
			focusColor: th.hintColor,
			hoverColor: th.infoTextColor,//webHoverColor
			floatingLabelBehavior: FloatingLabelBehavior.auto,
			border: UnderlineInputBorder(borderSide: BorderSide(color: th.hintColor)),
			focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: th.hintColor)),
			enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: th.hintColor)),
			disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: th.inactiveTextColor)),
			//errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: th.inactiveTextColor)),
			//focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: th.inactiveTextColor)),
		); ///OutlineInputBorder, UnderlineInputBorder

		final textSelectionTheme = TextSelectionThemeData(
			cursorColor: th.textColor,
			selectionColor: th.differentColor.withAlpha(180),
			selectionHandleColor: th.textColor,
		);

		//Switch & toggle color
		final sw = ColorHelper.isNearColors(th.primaryColor, [Colors.white, Colors.grey[600]!, Colors.grey[900]!])? th.differentColor: th.primaryColor;
		///-------------- themeData ----------------------------------
		final myThemeData = ThemeData(
			visualDensity: VisualDensity.adaptivePlatformDensity,
			applyElevationOverlayColor: true,
			platform: System.getTargetPlatform(),
			pageTransitionsTheme: pageTransition,
			brightness: currentBrightness,
			appBarTheme: appAppBarTheme,
			primaryTextTheme: primaryTextTheme,
			textTheme: primaryTextTheme,
			dialogTheme: dialogTheme,
			buttonBarTheme: ButtonBarThemeData(buttonTextTheme: ButtonTextTheme.accent),
			iconTheme: iconTheme,
			primaryIconTheme: iconTheme,
			sliderTheme: sliderTheme,
			popupMenuTheme: popupMenu,
			inputDecorationTheme: inputDecoration,
			textSelectionTheme: textSelectionTheme,
			cardTheme: cardTheme,
			textButtonTheme: textButtonTheme,
			elevatedButtonTheme: elevatedButtonTheme,
			outlinedButtonTheme: outlinedButtonTheme,
			//no longer used: buttonTheme: appButtonTheme,
			dataTableTheme: tableThemeData,
			radioTheme: radioThemeData,
			checkboxTheme: checkboxThemeData,
			dividerTheme: dividerTheme,
			primaryColorDark: ColorHelper.darkIfIsLight(th.primaryColor),
			primaryColorLight: ColorHelper.lightPlus(th.primaryColor),
			// canvasColor: drawer & dropDown backColor
			canvasColor: th.drawerBackColor,
			primarySwatch: th.primarySwatch,
			primaryColor: th.primaryColor,
			//accentColor: th.accentColor, use: colorScheme.secondary [this is used for btn if 'primaryColorScheme' not set]
			backgroundColor: th.backgroundColor,
			scaffoldBackgroundColor: th.backgroundColor,
			selectedRowColor: th.accentColor,
			dividerColor: th.dividerColor,
			cardColor: th.cardColor,
			errorColor: th.errorColor,
			hintColor: th.hintColor,
			dialogBackgroundColor: th.dialogBackColor,
			//buttonColor: th.buttonsColorScheme.background,
			disabledColor: th.inactiveTextColor,
			toggleableActiveColor: sw,
			splashColor: th.accentColor,
			indicatorColor: th.differentColor,
			secondaryHeaderColor: th.differentColor,
			highlightColor: ColorHelper.changeLight(th.primaryColor),
			bottomAppBarColor: th.appBarBackColor,
			colorScheme: colorScheme,
			chipTheme: chipThemeData,
			scrollbarTheme: scrollbarTheme,
			unselectedWidgetColor: th.hintColor, // color: radio btn
			shadowColor: th.shadowColor,
			hoverColor: th.webHoverColor,
		);

		if (th.executeOnEnd != null) {
		  th.executeOnEnd?.call(myThemeData, th);
		}

		return myThemeData;
	}
	///================================================================================================
	static TextTheme textTheme() {
		return themeData.textTheme;
	}

	static TextStyle appBarTextStyle() {
		final app = themeData.appBarTheme.toolbarTextStyle!;
		return app;//.copyWith(fontSize: app.fontSize! - 3);
	}

	static TextStyle baseTextStyle() {
		return currentTheme.baseTextStyle;
	}

	static TextStyle boldTextStyle() {
		return currentTheme.boldTextStyle;
	}

	static TextStyle subTextStyle() {
		return currentTheme.subTextStyle;
	}

	static TextStyle? body2TextStyle() {
		return themeData.textTheme.bodyText2;
	}

	static TextStyle infoHeadLineTextStyle() {
		return themeData.textTheme.headline5!.copyWith(
			color: themeData.textTheme.headline5!.color!.withAlpha(150),
		);
	}

	static TextStyle infoTextStyle() {
		return themeData.textTheme.headline5!.copyWith(
			color: themeData.textTheme.headline5!.color!.withAlpha(150),
			fontSize: themeData.textTheme.headline5!.fontSize! -2,
			height: 1.5,
		);
		//return currentTheme.baseTextStyle.copyWith(color: currentTheme.infoTextColor);
	}

	static ButtonThemeData buttonTheme() {
		return themeData.buttonTheme;
	}

	static TextStyle chatTextStyle() {
		return currentTheme.baseTextStyle.copyWith(
			fontSize: chatFont.size,
			fontFamily: chatFont.family,
			height: chatFont.height,
		);
	}

	static TextStyle? buttonTextStyle() {
		return themeData.textTheme.button;
		//return themeData.elevatedButtonTheme.style!.textStyle!.resolve({MaterialState.focused});
	}

	static Color? buttonTextColor() {
		return buttonTextStyle()?.color;
	}

	static Color buttonBackgroundColor() {
		return themeData.elevatedButtonTheme.style!.backgroundColor!.resolve({MaterialState.focused})!;
	}

	static ThemeData dropdownTheme(BuildContext context, {Color? color}) {
		return themeData.copyWith(
			canvasColor: color?? ColorHelper.changeHue(currentTheme.accentColor),
		);
	}

	static BoxDecoration dropdownDecoration({Color? color, double radius = 5}) {
		return BoxDecoration(
				color: color?? ColorHelper.changeHue(currentTheme.accentColor),
				borderRadius: BorderRadius.circular(radius),
		);
	}

	static Color cardColorOnCard() {
		return ColorHelper.changeHSLByRelativeDarkLight(currentTheme.cardColor, 2, 0.0, 0.04);
	}
	///--- Relative ---------------------------------------------------------------------------------------------------
	static bool isDarkPrimary(){
		return ColorHelper.isNearColor(currentTheme.primaryColor, Colors.grey[900]!);
	}

	static bool isLightPrimary(){
		return ColorHelper.isNearColor(currentTheme.primaryColor, Colors.grey[200]!);
	}

	static Color checkPrimaryByWB(Color ifNotNear, Color ifNear){
		return ColorHelper.ifNearColors(currentTheme.primaryColor, [Colors.grey[900]!, Colors.grey[600]!, Colors.white],
				()=> ifNear, ()=> ifNotNear);
	}

	static Color checkColorByWB(Color base, Color ifNotNear, Color ifNear){
		return ColorHelper.ifNearColors(base, [Colors.grey[900]!, Colors.grey[600]!, Colors.white],
				()=> ifNear, ()=> ifNotNear);
	}

	static TextStyle relativeSheetTextStyle() {
		final app = themeData.appBarTheme.toolbarTextStyle!;
		final color = ColorHelper.getUnNearColor(app.color!, currentTheme.primaryColor, Colors.black);

		return app.copyWith(color: color, fontSize: 14);//currentTheme.appBarItemColor
	}

	static Text sheetText(String text) {
		return Text(
			text,
			style: relativeSheetTextStyle(),
		);
	}

	static TextStyle relativeFabTextStyle() {
		final app = themeData.appBarTheme.toolbarTextStyle!;

		return app.copyWith(fontSize: app.fontSize! - 3, color: currentTheme.fabItemColor);
	}

	static Color relativeBorderColor$outButton({bool onColored = false}) {
		if(ColorHelper.isNearColors(AppThemes.currentTheme.primaryColor, [Colors.grey[900]!, Colors.grey[300]!])) {
		  return AppThemes.currentTheme.appBarItemColor;
		} else {
		  return onColored? Colors.white : AppThemes.currentTheme.primaryColor;
		}
	}

	static BorderSide relativeBorderSide$outButton({bool onColored = false}) {
		return BorderSide(width: 1.0, color: relativeBorderColor$outButton(onColored: onColored).withAlpha(140));
	}

	static InputDecoration textFieldInputDecoration({int alpha = 255}) {
		final border = OutlineInputBorder(
				borderSide: BorderSide(color: AppThemes.currentTheme.textColor.withAlpha(alpha))
		);

		return InputDecoration(
			border: border,
			disabledBorder: border,
			enabledBorder: border,
			focusedBorder: border,
			errorBorder: border,
		);
	}
	///------------------------------------------------------------------------------------------------------
	static TextDirection getOppositeDirection() {
		if (textDirection == TextDirection.rtl) {
		  return TextDirection.ltr;
		}

		return TextDirection.rtl;
	}

	static bool isLtrDirection() {
		if (textDirection == TextDirection.ltr) {
		  return true;
		}

		return false;
	}

	static bool isRtlDirection() {
		if (textDirection == TextDirection.rtl) {
		  return true;
		}

		return false;
	}
}
///=================================================================================================
