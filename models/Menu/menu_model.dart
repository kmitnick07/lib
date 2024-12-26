import 'dart:convert';

import 'package:prestige_prenew_frontend/utils/aws_service/file_data_model.dart';

LoginDataModel loginUserModelFromJson(String str) => LoginDataModel.fromJson(json.decode(str));

String loginUserModelToJson(LoginDataModel data) => json.encode(data.toJson());

class LoginDataModel {
  List<UserRight>? userrights;
  List<MenuData>? menudata;
  int? status;
  String? message;
  String? pagename;

  LoginDataModel({
    this.userrights,
    this.menudata,
    this.status,
    this.message,
    this.pagename,
  });

  factory LoginDataModel.fromJson(Map<String, dynamic> json) => LoginDataModel(
        userrights: json["userrights"] == null ? [] : List<UserRight>.from(json["userrights"]!.map((x) => UserRight.fromJson(x))),
        menudata: json["menudata"] == null ? [] : List<MenuData>.from(json["menudata"]!.map((x) => MenuData.fromJson(x))),
        status: json["status"],
        message: json["message"],
        pagename: json["pagename"],
      );

  Map<String, dynamic> toJson() => {
        "userrights": userrights == null ? [] : List<dynamic>.from(userrights!.map((x) => x.toJson())),
        "menudata": menudata == null ? [] : List<dynamic>.from(menudata!.map((x) => x.toJson())),
        "status": status,
        "message": message,
        "pagename": pagename,
      };
}

class MenuData {
  String? id;
  int? displayinsidebar;
  String? moduletypeid;
  String? menuname;
  FilesDataModel? iconimage;
  String? formname;
  String? iconid;
  String? iconunicode;
  String? alias;
  int? isparent;
  String? parentid;
  String? moduleid;
  String? menuid;
  int? containright;
  int? defaultopen;
  int? ipallowed;
  MenuDataRecordInfo? recordinfo;
  int? v;
  List<MenuData>? children;
  String? title;
  bool? expanded;

  MenuData({
    this.id,
    this.displayinsidebar,
    this.moduletypeid,
    this.menuname,
    this.iconimage,
    this.formname,
    this.iconid,
    this.iconunicode,
    this.alias,
    this.isparent,
    this.parentid,
    this.moduleid,
    this.menuid,
    this.containright,
    this.defaultopen,
    this.ipallowed,
    this.recordinfo,
    this.v,
    this.children,
    this.title,
    this.expanded,
  });

  factory MenuData.fromJson(Map<String, dynamic> json) => MenuData(
        id: json["_id"],
        displayinsidebar: json["displayinsidebar"],
        moduletypeid: json["moduletypeid"],
        menuname: json["menuname"],
        iconimage: FilesDataModel.fromJson(json["iconimage"] ?? FilesDataModel().toJson()),
        formname: json["formname"],
        iconid: json["iconid"],
        iconunicode: json["iconunicode"],
        alias: json["alias"],
        isparent: json["isparent"],
        parentid: json["parentid"],
        moduleid: json["moduleid"],
        menuid: json["menuid"],
        containright: json["containright"],
        defaultopen: json["defaultopen"],
        ipallowed: json["ipallowed"],
        recordinfo: json["recordinfo"] == null ? null : MenuDataRecordInfo.fromJson(json["recordinfo"]),
        v: json["__v"],
        children: json["children"] == null ? [] : List<MenuData>.from(json["children"]!.map((x) => MenuData.fromJson(x))),
        title: json["title"],
        expanded: json["expanded"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "displayinsidebar": displayinsidebar,
        "moduletypeid": moduletypeid,
        "menuname": menuname,
        "iconimage": (iconimage ?? FilesDataModel()).toJson(),
        "formname": formname,
        "iconid": iconid,
        "iconunicode": iconunicode,
        "alias": alias,
        "isparent": isparent,
        "parentid": parentid,
        "moduleid": moduleid,
        "menuid": menuid,
        "containright": containright,
        "defaultopen": defaultopen,
        "ipallowed": ipallowed,
        "recordinfo": recordinfo?.toJson(),
        "__v": v,
        "children": children == null ? [] : List<dynamic>.from(children!.map((x) => x.toJson())),
        "title": title,
        "expanded": expanded,
      };
}

class MenuDataRecordInfo {
  String? updateuid;
  String? updateby;
  DateTime? updatedate;

  MenuDataRecordInfo({
    this.updateuid,
    this.updateby,
    this.updatedate,
  });

  factory MenuDataRecordInfo.fromJson(Map<String, dynamic> json) => MenuDataRecordInfo(
        updateuid: json["updateuid"],
        updateby: json["updateby"],
        updatedate: json["updatedate"] == null ? null : DateTime.parse(json["updatedate"]),
      );

  Map<String, dynamic> toJson() => {
        "updateuid": updateuid,
        "updateby": updateby,
        "updatedate": updatedate?.toIso8601String(),
      };
}

class UserRight {
  String? id;
  String? formname;
  String? alias;
  String? moduletypeid;
  String? moduletype;
  int? allviewright;
  int? selfviewright;
  int? alladdright;
  int? selfaddright;
  int? alleditright;
  int? selfeditright;
  int? alldelright;
  int? selfdelright;
  int? allprintright;
  int? selfprintright;
  int? allexportdata;
  int? allimportdata;
  int? requestright;
  String? userroleid;
  String? personid;
  UserrightRecordinfo? recordinfo;
  int? v;
  String? menuname;

  UserRight({
    this.id,
    this.formname,
    this.alias,
    this.moduletypeid,
    this.moduletype,
    this.allviewright,
    this.selfviewright,
    this.alladdright,
    this.selfaddright,
    this.alleditright,
    this.selfeditright,
    this.alldelright,
    this.selfdelright,
    this.allprintright,
    this.selfprintright,
    this.allimportdata,
    this.allexportdata,
    this.requestright,
    this.userroleid,
    this.personid,
    this.recordinfo,
    this.v,
    this.menuname,
  });

  factory UserRight.fromJson(Map<String, dynamic> json) => UserRight(
        id: json["_id"],
        formname: json["formname"],
        allexportdata: json['allexportdata'],
        allimportdata: json['allimportdata'],
        alias: json["alias"],
        moduletypeid: json["moduletypeid"],
        moduletype: json["moduletype"],
        allviewright: json["allviewright"],
        selfviewright: json["selfviewright"],
        alladdright: json["alladdright"],
        selfaddright: json["selfaddright"],
        alleditright: json["alleditright"],
        selfeditright: json["selfeditright"],
        alldelright: json["alldelright"],
        selfdelright: json["selfdelright"],
        allprintright: json["allprintright"],
        selfprintright: json["selfprintright"],
        requestright: json["requestright"],
        userroleid: json["userroleid"],
        personid: json["personid"],
        recordinfo: json["recordinfo"] == null ? null : UserrightRecordinfo.fromJson(json["recordinfo"]),
        v: json["__v"],
        menuname: json["menuname"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "formname": formname,
        "alias": alias,
        "moduletypeid": moduletypeid,
        "moduletype": moduletype,
        "allviewright": allviewright,
        "selfviewright": selfviewright,
        "allexportdata": allexportdata,
        "allimportdata": allimportdata,
        "alladdright": alladdright,
        "selfaddright": selfaddright,
        "alleditright": alleditright,
        "selfeditright": selfeditright,
        "alldelright": alldelright,
        "selfdelright": selfdelright,
        "allprintright": allprintright,
        "selfprintright": selfprintright,
        "requestright": requestright,
        "userroleid": userroleid,
        "personid": personid,
        "recordinfo": recordinfo?.toJson(),
        "__v": v,
        "menuname": menuname,
      };
}

class UserrightRecordinfo {
  String? entryuid;
  String? entryby;
  DateTime? entrydate;
  int? timestamp;
  int? isactive;

  UserrightRecordinfo({
    this.entryuid,
    this.entryby,
    this.entrydate,
    this.timestamp,
    this.isactive,
  });

  factory UserrightRecordinfo.fromJson(Map<String, dynamic> json) => UserrightRecordinfo(
        entryuid: json["entryuid"],
        entryby: json["entryby"],
        entrydate: json["entrydate"] == null ? null : DateTime.parse(json["entrydate"]),
        timestamp: json["timestamp"],
        isactive: json["isactive"],
      );

  Map<String, dynamic> toJson() => {
        "entryuid": entryuid,
        "entryby": entryby,
        "entrydate": entrydate?.toIso8601String(),
        "timestamp": timestamp,
        "isactive": isactive,
      };
}
