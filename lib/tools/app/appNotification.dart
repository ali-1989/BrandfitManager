import 'dart:typed_data';

import 'package:brandfit_manager/managers/chatManager.dart';
import 'package:brandfit_manager/managers/ticketManager.dart';
import 'package:brandfit_manager/managers/userAdvancedManager.dart';
import 'package:brandfit_manager/system/enums.dart';
import 'package:brandfit_manager/system/session.dart';
import 'package:brandfit_manager/tools/centers/broadcastCenter.dart';
import 'package:brandfit_manager/tools/centers/dbCenter.dart';
import 'package:brandfit_manager/tools/centers/routeCenter.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/textHelper.dart';

import '/system/keys.dart';
import '/system/extensions.dart';
import '/constants.dart';
import '/models/dataModels/notificationModel.dart' as nm;
import 'package:awesome_notifications/awesome_notifications.dart';

// https://github.com/rafaelsetragni/awesome_notifications/blob/master/example/lib/utils/notification_util.dart

class AppNotification {
	AppNotification._();

	static Future<void> insertNotificationIds() async {
		await DbCenter.setKv(Keys.setting$notificationChanelKey, 'C${Generator.generateName(8)}');
		await DbCenter.setKv(Keys.setting$notificationChanelGroup, 'G${Generator.generateName(8)}');

		return;
	}

	static String getChannelKey(){
		return DbCenter.fetchKv(Keys.setting$notificationChanelKey);
	}

	static nm.NotificationModel getNotificationModel(){
		return nm.NotificationModel.fromMap(DbCenter.fetchKv(Keys.setting$notificationModel));
	}

	static Future saveNotificationModel(nm.NotificationModel model){
		return DbCenter.setKv(Keys.setting$notificationModel, model.toMap());
	}

	static Future<bool> initial() async {
		AwesomeNotifications().removeChannel(getChannelKey());
		final highModel = getNotificationModel();

		AwesomeNotifications().initialize(
			/// android\app\src\main\res\drawable\app_icon.png   or   ic_launcher.png
				null,// 'resource://drawable/res_app_icon',
				[
					NotificationChannel(
          channelGroupKey: DbCenter.fetchKv(Keys.setting$notificationChanelGroup),
          channelKey: getChannelKey(),
          channelName: highModel.name,
          channelDescription: Constants.appName,
          defaultColor: highModel.defaultColor,
          ledColor: highModel.ledColor,
          defaultPrivacy: highModel.isPublic? NotificationPrivacy.Public : NotificationPrivacy.Private,
          importance: highModel.importanceIsHigh? NotificationImportance.High : NotificationImportance.Default,
          enableLights: highModel.enableLights,
          enableVibration: highModel.enableVibration,
          playSound: highModel.playSound,
					//soundSource: ,
          vibrationPattern: getVibration(),
          ledOnMs: 500,
          ledOffMs: 500,
        )
      ],
				/*channelGroups: [
					NotificationChannelGroup(
							channelGroupkey: 'basic_channel_group',
							channelGroupName: 'Basic group')
				],*/
				debug: true,
		);

		requestPermission();
		return true;
	}

	static Int64List getVibration() {
		final vibrationPattern = Int64List(4);
		vibrationPattern[0] = 0;
		vibrationPattern[1] = 100;
		vibrationPattern[2] = 0;
		vibrationPattern[3] = 0;

		return vibrationPattern;
	}

	static void requestPermission() {
		AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
			if (!isAllowed) {
				AwesomeNotifications().requestPermissionToSendNotifications(
					channelKey: getChannelKey(),
					permissions: [
						NotificationPermission.Alert,
						NotificationPermission.Sound,
						NotificationPermission.Badge,
						NotificationPermission.Vibration,
						NotificationPermission.Light,
						NotificationPermission.PreciseAlarms, // allows the scheduled notifications to be displayed at the expected time
						NotificationPermission.FullScreenIntent, // pop up even if the user is using another app
					]
				);
			}
		});
	}

	static void startListenTap() {
		AwesomeNotifications().actionStream.listen((ReceivedNotification receivedNotification){
			//receivedNotification.id , payload
				}
		);
	}

	static void dismissAll() {
		AwesomeNotifications().dismissAllNotifications();
	}

	static void dismissById(int nId) {
		AwesomeNotifications().dismiss(nId);
	}

	static void dismissByChannel(String channel) {
		AwesomeNotifications().dismissNotificationsByChannelKey(channel);
	}

	static void showNotificationSettingPage() {
		AwesomeNotifications().showNotificationConfigPage();
	}

	static void sendNotification(String? title, String text, {int? id}) {
		AwesomeNotifications().createNotification(
				content: NotificationContent(
						id: id ?? Generator.generateIntId(5),
						channelKey: getChannelKey(),
						title: title,
						body: text,
					autoDismissible: true,
					category: NotificationCategory.Message,
					notificationLayout: NotificationLayout.Default,
				),
		);
	}

	static Future sendMessagesNotification(String? title, String user, String messages, {int? id}) {
		return AwesomeNotifications().createNotification(
			content: NotificationContent(
				id: id ?? Generator.generateIntId(5),
				channelKey: getChannelKey(),
				title: title,
				summary: user,
				autoDismissible: true,
				category: NotificationCategory.Email,
				notificationLayout: NotificationLayout.Inbox,
				body: messages,
				//largeIcon: largeIcon,
				//customSound: 'resource://raw/res_morph_power_rangers'
			),
		);
	}

	/*
	'<b> 10.000 visitor! Congratz!</b> You just won our prize'
						'\n'
						'<b>Want to loose weight?</b> Are you tired from false advertisements? '
						'\n'
						'<b>READ MY MESSAGE</b> Stop to ignore me!'
						'\n'
						'<b>READ MY MESSAGE</b> Stop to ignore me!'
						'\n'
						'<b>READ MY MESSAGE</b> Stop to ignore me!'
						'<b>READ MY MESSAGE</b> Stop to ignore me!'
		*/
	///-----------------------------------------------------------------------------------
	static Future<void> showChatNotification(int userId) async {
		if(Session.getLastLoginUser()?.userId != userId){
			return;
		}

		final manager = ChatManager.managerFor(userId);

		for(final chat in manager.allChatList){
			final unRead = chat.unReadCount();

			if(unRead < 1){
				continue;
			}

			String? title;
			String? messageText;
			final user = chat.addressee(userId);

			if(chat.type == 10) {
				title = user?.userName?? '';
			}
			else {
				title = chat.title!;
			}

			title += ' ($unRead)';

			final chatMsg = chat.lastMessage!;

			if(chatMsg.type == ChatType.TEXT.typeNum) {
				messageText = TextHelper.subByCharCountSafe(chatMsg.text, 100);
			}
			else {
				final type = chat.getChatMessageType(chat.lastMessage);
				messageText = RouteCenter.getContext().tInMap('chatData', type)!;
			}

			await sendMessagesNotification(title, user?.userName?? '', messageText);
		}
	}

	static Future<void> showTicketNotification(int userId) async {
		if(Session.getLastLoginUser()?.userId != userId){
			return;
		}

		final manager = TicketManager.managerFor(userId);

		for(final ticket in manager.allTicketList){
			final unRead = ticket.unReadCount();

			if(unRead < 1){
				continue;
			}

			String title = ticket.title?? '';
			String? messageText;

			title += ' ($unRead)';

			final chatMsg = ticket.lastMessage!;
			final user = UserAdvancedManager.getById(ticket.lastMessage?.senderUserId?? 0);

			if(chatMsg.type == ChatType.TEXT.typeNum) {
				messageText = TextHelper.subByCharCountSafe(chatMsg.text, 100);
			}
			else {
				final type = ticket.getTicketMessageType(ticket.lastMessage);
				messageText = RouteCenter.getContext().tInMap('chatData', type)!;
			}

			await sendMessagesNotification(title, user?.userName?? 'admin', messageText,
			id: BroadcastCenter.newTicketNotificationId);
		}
	}
}
