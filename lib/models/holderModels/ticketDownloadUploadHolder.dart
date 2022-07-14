import '/models/dataModels/ticketModels/ticketMediaModel.dart';
import '/models/dataModels/ticketModels/ticketMessageModel.dart';

class TicketDownloadUploadHolder {
  int? ownerId;
  int? ticketId;
  BigInt? messageId;
  BigInt? mediaId;
  //TicketModel? ticketModel;
  TicketMessageModel? messageModel;
  TicketMediaModel? mediaModel;
}