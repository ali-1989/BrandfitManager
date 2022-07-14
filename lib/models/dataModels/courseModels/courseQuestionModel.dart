import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import '/models/dataModels/photoDataModel.dart';
import '/models/dataModels/usersModels/fitnessDataModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/system/keys.dart';

class CourseQuestionModel {
  CourseQuestionModel();

  late double height;
  late double weight;
  late int sex;
  late DateTime birthdate;
  String? illDescription;
  String? illMedications;
  List<String> illList = [];
  String? jobType;
  String? noneWorkActivity;
  String? sportTypeDescription;
  String? goalOfBuy;
  late int sleepHoursAtNight;
  late int sleepHoursAtDay;
  late int exerciseHours;
  String? exerciseTimesDescription;
  String? gymToolsDescription;
  String? homeToolsDescription;
  String? dietDescription;
  String? harmDescription;
  String? sportsRecordsDescription;
  String? exercisePlaceType;
  String? gymToolsType;

  List<PhotoDataModel> experimentPhotos = [];
  List<PhotoDataModel> bodyPhotos = [];
  List<PhotoDataModel> bodyAnalysisPhotos = [];
  PhotoDataModel? cardPhoto;
  //-------------------- local
  late bool haveNoIlls;
  int? userId;

  CourseQuestionModel.fromMap(Map map, {String? domain}){
    final List? experimentPhoto = map[NodeNames.experiment_photo.name];
    final List? bodyPhoto = map[NodeNames.body_photo.name];
    final List? bodyAnalysisPhoto = map[NodeNames.body_analysis_photo.name];
    final Map? cardImage = map['card_photo'];

    if(cardImage != null){
      cardPhoto = PhotoDataModel.fromMap(cardImage, domain: domain);
    }

    if(experimentPhoto != null){
      for(var p in experimentPhoto){
        final ph = PhotoDataModel.fromMap(p, domain: domain);
        experimentPhotos.add(ph);
      }
    }

    if(bodyPhoto != null){
      for(var p in bodyPhoto){
        final ph = PhotoDataModel.fromMap(p, domain: domain);
        bodyPhotos.add(ph);
      }
    }

    if(bodyAnalysisPhoto != null){
      for(var p in bodyAnalysisPhoto){
        final ph = PhotoDataModel.fromMap(p, domain: domain);
        bodyAnalysisPhotos.add(ph);
      }
    }

    height = map['height'];
    weight = map['weight'];
    sex = map[Keys.sex];
    birthdate = DateHelper.tsToSystemDate(map[Keys.birthdate])?? DateHelper.getNow();
    illDescription = map['ill_description'];
    illMedications = map['ill_medications'];
    illList = JsonHelper.jsonToList<String>(map['ill_list'])?? [];
    jobType = map['job_type'];
    sportTypeDescription = map['sport_type_description'];
    noneWorkActivity = map['none_work_activity'];
    sleepHoursAtNight = map['sleep_hours_at_night'];
    sleepHoursAtDay = map['sleep_hours_at_day'];
    exerciseHours = map['exercise_hours'];
    goalOfBuy = map['goal_of_buy'];
    exerciseTimesDescription = map['exercise_times_description'];
    exercisePlaceType = map['exercise_place_type'];
    gymToolsType = map['gym_tools_type'];
    gymToolsDescription = map['gym_tools_description'];
    homeToolsDescription = map['home_tools_description'];
    harmDescription = map['harm_description'];
    sportsRecordsDescription = map['sports_records_description'];
    dietDescription = map['diet_description'];
  }

  Map toMap(){
    final map = {};

    map['height'] = height;
    map['weight'] = weight;
    map[Keys.sex] = sex;
    map[Keys.birthdate] = DateHelper.toTimestampNullable(birthdate);
    map['ill_list'] = illList;
    map['exercise_hours'] = exerciseHours;
    map['sleep_hours_at_night'] = sleepHoursAtNight;
    map['sleep_hours_at_day'] = sleepHoursAtDay;
    map['none_work_activity'] = noneWorkActivity;
    map['sport_type_description'] = sportTypeDescription;
    map['job_type'] = jobType;
    map['ill_medications'] = illMedications;
    map['ill_description'] = illDescription;
    map['goal_of_buy'] = goalOfBuy;
    map['exercise_times_description'] = exerciseTimesDescription;
    map['exercise_place_type'] = exercisePlaceType;
    map['gym_tools_type'] = gymToolsType;
    map['gym_tools_description'] = gymToolsDescription;
    map['home_tools_description'] = homeToolsDescription;
    map['harm_description'] = harmDescription;
    map['sports_records_description'] = sportsRecordsDescription;
    map['diet_description'] = dietDescription;
    map[NodeNames.experiment_photo.name] = experimentPhotos.map((e) => e.toMap()).toList();
    map[NodeNames.body_analysis_photo.name] = bodyAnalysisPhotos.map((e) => e.toMap()).toList();
    map[NodeNames.body_photo.name] = bodyPhotos.map((e) => e.toMap()).toList();
    map['card_photo'] = cardPhoto?.toMap();

    return map;
  }

  CourseQuestionModel.fromUser(UserModel user){
    userId = user.userId;
    height = user.fitnessDataModel.height?? 160;
    weight = user.fitnessDataModel.weight?? 70;
    sex = user.sex;
    birthdate = user.birthDate?? DateTime(DateTime.now().year-20);// (DateTime.now().subtract(Duration(days: 7*365)));
    illDescription = user.healthConditionModel.illDescription?? '';
    illMedications = user.healthConditionModel.illMedications?? '';
    illList = user.healthConditionModel.illList;
    jobType = user.jobActivityModel.jobType;
    sportTypeDescription = user.jobActivityModel.sportsTypeDescription;
    noneWorkActivity = user.jobActivityModel.noneWorkActivity;
    sleepHoursAtNight = user.jobActivityModel.sleepHoursAtNight?? 8;
    sleepHoursAtDay = user.jobActivityModel.sleepHoursAtDay?? 0;
    exerciseHours = user.jobActivityModel.exerciseHours?? 0;
    gymToolsDescription = user.sportEquipmentModel.gymTools;
    homeToolsDescription = user.sportEquipmentModel.homeTools;

    haveNoIlls = illList.isEmpty;
  }

  void addPhoto(String path, NodeNames nodeName){
    final ph = PhotoDataModel();

    ph.localPath = path;
    ph.utcDate = DateHelper.getNowToUtc();

    if(nodeName == NodeNames.experiment_photo) {
      experimentPhotos.add(ph);
      PhotoDataModel.sort(experimentPhotos, asc: false);
    }
    else if(nodeName == NodeNames.body_photo) {
      bodyPhotos.add(ph);
      PhotoDataModel.sort(bodyPhotos, asc: false);
    }
    else if(nodeName == NodeNames.body_analysis_photo) {
      bodyAnalysisPhotos.add(ph);
      PhotoDataModel.sort(bodyAnalysisPhotos, asc: false);
    }
  }

  void deletePhoto(PhotoDataModel ph, NodeNames nodeName){
    if(nodeName == NodeNames.experiment_photo) {
      experimentPhotos.removeWhere((element) => element == ph);
    }
    else if(nodeName == NodeNames.body_photo) {
      bodyPhotos.removeWhere((element) => element == ph);
    }
    else if(nodeName == NodeNames.body_analysis_photo) {
      bodyAnalysisPhotos.removeWhere((element) => element == ph);
    }
  }

  void deletePhotoByDate(DateTime dt, NodeNames nodeName){
    if(nodeName == NodeNames.experiment_photo) {
      experimentPhotos.removeWhere((element) => element.utcDate == dt);
    }
    else if(nodeName == NodeNames.body_photo) {
      bodyPhotos.removeWhere((element) => element.utcDate == dt);
    }
    else if(nodeName == NodeNames.body_analysis_photo) {
      bodyAnalysisPhotos.removeWhere((element) => element.utcDate == dt);
    }
  }
}
///=======================================================================================
enum ExercisePlaceType {
  workAtGyn,
  workAtHome,
}

enum GymToolsType {
  little,
  half,
  high,
}
