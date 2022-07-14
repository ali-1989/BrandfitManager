import '/database/models/userAdvancedModelDb.dart';
import '/models/dataModels/chatModels/chatModel.dart';

class ChatAvatarHolder {
  int? userId;
  int? chatId;
  int? addresseeId;
  UserAdvancedModelDb? userModel;
  ChatModel? chatModel;
}
