import 'dart:async';
import 'dart:math';

import 'package:brandfit_manager/tools/app/appNotification.dart';
import 'package:getsocket/getsocket.dart';
import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/system.dart';

import '/database/models/userAdvancedModelDb.dart';
import '/managers/chatManager.dart';
import '/managers/settingsManager.dart';
import '/managers/ticketManager.dart';
import '/managers/userAdvancedManager.dart';
import '/models/dataModels/chatModels/chatMediaModel.dart';
import '/models/dataModels/chatModels/chatMessageModel.dart';
import '/models/dataModels/chatModels/chatModel.dart';
import '/models/dataModels/ticketModels/ticketMediaModel.dart';
import '/models/dataModels/ticketModels/ticketMessageModel.dart';
import '/models/dataModels/ticketModels/ticketModel.dart';
import '/system/httpCodes.dart';
import '/system/keys.dart';
import '/system/session.dart';
import '/tools/centers/broadcastCenter.dart';
import '/tools/deviceInfoTools.dart';
import '/tools/netListenerTools.dart';
import '/tools/playerTools.dart';
import '/tools/userLoginTools.dart';

class WsCenter {
	WsCenter._();

	static GetSocket? _ws;
	static String? _uri;
	static bool _isConnected = false;
	static bool canReconnectState = true;
	static Duration reconnectInterval = Duration(seconds: 6);
	static Timer? periodicHeartTimer;
	static Timer? reconnectTimer;
	static final List<void Function(dynamic data)> _receiverListeners = [];
	//static StreamController _streamCtr = StreamController.broadcast();

	static String? get address => _uri;
	//static Stream get stream => _streamCtr.stream;
	static bool get isConnected => _isConnected;

	static void addMessageListener(void Function(dynamic data) fun){
		//return stream.listen(fun);
		if(!_receiverListeners.contains(fun)) {
		  _receiverListeners.add(fun);
		}
	}

	static void removeMessageListener(void Function(dynamic data) fun){
		//return stream.listen(fun);
		_receiverListeners.remove(fun);
	}

	static Future<void> prepareWebSocket(String uri) async{
		_uri = uri;

		try {
				_isConnected = false;
				_ws?.close(1000); //status.normalClosure
		}
		catch(e){}

		connect();
	}

	static void connect() async {
		if(isConnected || System.isWeb() || SettingsManager.serverHackState) {
			return;
		}

		try {
			_ws = GetSocket(_uri!);

			_ws!.onOpen(() {
				_onConnected();
			});

			_ws!.onClose((c) {
				_onDisConnected();
			});

			_ws!.onError((e) {
				_onDisConnected();
			});

			/// onData
			_ws!.onMessage((data) {
				_handlerNewMessage(data);
			});

			_ws!.connect();
		}
		catch(e){
			_onDisConnected();
		}
	}

	static void _reconnect([Duration? delay]){
		if(canReconnectState) {
			reconnectTimer?.cancel();

			reconnectTimer = Timer(delay?? reconnectInterval, () {
				if(BroadcastCenter.isNetConnected) {
					connect();
				}
			});

			var temp = reconnectInterval.inSeconds;
			temp = min<int>((temp * 1.3).floor(), 600);
			reconnectInterval = Duration(seconds: temp);
		}
	}

	static void shutdown(){
		_isConnected = false;

		if(_ws != null) {
			_ws!.close();
		}

		periodicHeartTimer?.cancel();
	}

	static void sendData(dynamic data){
		_ws!.send(data);
	}
	///-------------- on dis Connect -----------------------------------------------------------
	static void _onDisConnected() async{
		_isConnected = false;
		periodicHeartTimer?.cancel();

		NetListenerTools.onWsDisConnectedListener();

		_reconnect();
	}
	///-------------- on new Connect -----------------------------------------------------------
	static void _onConnected() async {
		_isConnected = true;
		reconnectInterval = Duration(seconds: 6);
		sendData(JsonHelper.mapToJson(UserLoginTools.getHowIsMap()));

		NetListenerTools.onWsConnectedListener();

		periodicHeartTimer?.cancel();
		periodicHeartTimer = Timer.periodic(Duration(minutes: SettingsManager.webSocketPeriodicHeart), (timer) {
			sendHeartAndUsers();
		});
	}
	///------------ heart every 4 min ---------------------------------------------------
	static void sendHeartAndUsers() {
		final heart = UserLoginTools.getHeartMap();

		try {
			sendData(JsonHelper.mapToJson(heart));
		}
		catch(e){
			_isConnected = false;
			periodicHeartTimer?.cancel();
			_reconnect(Duration(seconds: 3));
		}
	}




	///-------------- onNew Ws Message -----------------------------------------------------------
	static void _handlerNewMessage(dynamic dataAsJs) async{
		try {
			final receiveData = dataAsJs.toString();

			if(!Checker.isJson(receiveData)) {
				return;
			}

			final js = JsonHelper.jsonToMap<String, dynamic>(receiveData)!;
			/// UserData , ChatData, TicketData, Command, none
			final String section = js[Keys.section]?? 'none';
			final String command = js[Keys.command]?? '';
			final userId = js[Keys.userId]?? 0;
			final data = js[Keys.data];
			//--------------------------------------------------
			if(section == HttpCodes.sec_command || section == 'none') {
				switch (command) {
					case HttpCodes.com_serverMessage: // from WsServerNs
						break;
					case HttpCodes.com_forceLogOff:
						// ignore: unawaited_futures
						UserLoginTools.forceLogoff(userId);
						break;
					case HttpCodes.com_forceLogOffAll:
						// ignore: unawaited_futures
						UserLoginTools.forceLogoffAll();
						break;
					case HttpCodes.com_talkMeWho:
						sendData(JsonHelper.mapToJson(UserLoginTools.getHowIsMap()));
						break;
					case HttpCodes.com_sendDeviceInfo:
						sendData(JsonHelper.mapToJson(DeviceInfoTools.getDeviceInfo()));
						break;
				}
			}
			//--------------------------------------------------
			if(section == HttpCodes.sec_ticketData){
				ticketDataSec(command, data, userId, js);
			}

			if(section == HttpCodes.sec_chatData){
				chatDataSec(command, data, userId, js);
			}

			if(section == HttpCodes.sec_userData){
				userDataSec(command, data, userId, js);
			}

			if(section == HttpCodes.sec_courseData){
				courseDataSec(command, data, userId, js);
			}

			// ignore: unawaited_futures
			Future((){
				for(var f in _receiverListeners){
					f.call(js);
				}
			});
		}
		catch(e){}
	}

	static void ticketDataSec(String command, Map<String, dynamic> data, int userId, Map js) async {
		/// user Seen =======================
		if(command == HttpCodes.com_userSeen) {
			/*final senderId = data[Keys.userId];
			final ticketId = data['ticket_id'];
			final seenTs = data['seen_ts'];*/

			BroadcastCenter.ticketMessageSeenNotifier.value = data;
		}

		/// new Message =======================
		else if(command == HttpCodes.com_newMessage) {
			final ticketData = js['ticket_data'];
			final mediaData = js['media_data'];
			final userData = js['user_data'];

			TicketMediaModel? media;

			if(userData != null) {
				final ticketUser = UserAdvancedModelDb.fromMap(userData);
				UserAdvancedManager.addItem(ticketUser);
				UserAdvancedManager.sinkItems([ticketUser]);
			}

			if(ticketData != null){
				final ticket = TicketModel.fromMap(ticketData);
				TicketManager.managerFor(userId).addItem(ticket);
				// ignore: unawaited_futures
				TicketManager.managerFor(userId).sinkItems([ticket]);
			}

			if(mediaData != null){
				media = TicketMediaModel.fromMap(mediaData);
				TicketManager.addMediaMessage(media);
				// ignore: unawaited_futures
				TicketManager.sinkTicketMedia([media]);
			}

			final tMsg = TicketMessageModel.fromMap(data);
			TicketManager.addTicketMessage(tMsg);

			final ticket = TicketManager.managerFor(userId).getById(tMsg.ticketId?? 0);

			if(ticket == null){
				return;
			}

			ticket.invalidate();
			// ignore: unawaited_futures
			TicketManager.sinkTicketMessages([tMsg]);

			BroadcastCenter.ticketMessageUpdateNotifier.value = tMsg;

			if(!BroadcastCenter.ticketUpdateNotifier.hasListeners){
				AppNotification.showTicketNotification(userId);
			}

			if(BroadcastCenter.openedTicketId == tMsg.ticketId){
				// ignore: unawaited_futures
				PlayerTools.playNotification();
			}
		}

		/// delete Message =======================
		else if(command == HttpCodes.com_delMessage) {
			//var ticketId = data['ticket_id'];
			final messageId = data['message_id'];

			final msg = TicketManager.getTicketMessageById(messageId);

			if(msg != null) {
				// ignore: unawaited_futures
				TicketManager.deleteMessage(msg, true);

				if (BroadcastCenter.openedTicketId != null) {
					BroadcastCenter.ticketMessageUpdateNotifier.value = TicketMessageModel();
				}
			}
		}
	}

	static void chatDataSec(String command, Map<String, dynamic> data, int userId, Map js) async {
		/// user Seen =======================
		if(command == HttpCodes.com_userSeen) {
			/*final senderId = data[Keys.userId];
			final conversationId = data['conversation_id'];
			final seenTs = data['seen_ts'];*/

			BroadcastCenter.chatMessageSeenNotifier.value = data;
		}

		/// new Message =======================
		else if(command == HttpCodes.com_newMessage) {
			final chatData = js['chat_data'];
			final mediaData = js['media_data'];
			final userData = js['user_data'];
			ChatMediaModel? media;

			if(userData != null){
				final chatUser = UserAdvancedModelDb.fromMap(userData);
				UserAdvancedManager.addItem(chatUser);
				UserAdvancedManager.sinkItems([chatUser]);
			}

			if(chatData != null){
				final chat = ChatModel.fromMap(chatData);
				ChatManager.managerFor(userId).addItem(chat);
				// ignore: unawaited_futures
				ChatManager.managerFor(userId).sinkItems([chat]);
			}

			if(mediaData != null){
				media = ChatMediaModel.fromMap(mediaData);
				ChatManager.addMediaMessage(media);
				// ignore: unawaited_futures
				ChatManager.sinkChatMedia([media]);
			}

			final chatMsg = ChatMessageModel.fromMap(data);
			ChatManager.addMessage(chatMsg);

			final chat = ChatManager.managerFor(userId).getById(chatMsg.chatId?? 0);

			if(chat == null){
				return;
			}

			chat.invalidate();
			// ignore: unawaited_futures
			ChatManager.sinkChatMessages([chatMsg]);

			BroadcastCenter.chatMessageUpdateNotifier.value = chatMsg;

			if(!BroadcastCenter.chatUpdateNotifier.hasListeners){
				AppNotification.showChatNotification(userId);
				//BroadcastCenter.prepareBadgesAndRefresh();
			}

			if(BroadcastCenter.openedChatId == chatMsg.chatId){
				// ignore: unawaited_futures
				PlayerTools.playNotification();
			}
		}

		/// delete Message =======================
		else if(command == HttpCodes.com_delMessage) {
			//final chatId = data['chat_id'];
			final messageId = data['message_id'];

			final msg = ChatManager.getMessageById(messageId);

			if(msg != null) {
				// ignore: unawaited_futures
				ChatManager.deleteMessage(msg, true);

				if (BroadcastCenter.openedChatId != null) {
					BroadcastCenter.chatMessageUpdateNotifier.value = ChatMessageModel();
				}
			}
		}
	}

	static void userDataSec(String command, Map<String, dynamic> data, int userId, Map js) async {
		/// new profile =======================
		if(command == HttpCodes.com_updateProfileSettings) {
			await Session.newProfileData(data);
		}
	}

	static void courseDataSec(String command, Map<String, dynamic> data, int userId, Map js) async {
		
	}
}
