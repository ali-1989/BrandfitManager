import '/models/dataModels/chatModels/chatMediaModel.dart';
import '/models/dataModels/chatModels/chatMessageModel.dart';

class ChatDownloadUploadHolder {
  int? ownerId;
  int? chatId;
  BigInt? messageId;
  BigInt? mediaId;
  //TicketModel? ticketModel;
  ChatMessageModel? messageModel;
  ChatMediaModel? mediaModel;
}