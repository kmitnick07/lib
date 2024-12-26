import 'dart:convert';

import 'package:prestige_prenew_frontend/utils/aws_service/file_data_model.dart';

class GetAccessTokenModel {
  int? status;
  String? message;
  Data? data;

  GetAccessTokenModel({this.status, this.message, this.data});

  GetAccessTokenModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? unqkey;
  String? uid;

  Data({this.unqkey, this.uid});

  Data.fromJson(Map<String, dynamic> json) {
    unqkey = json['unqkey'];
    uid = json['uid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['unqkey'] = unqkey;
    data['uid'] = uid;
    return data;
  }
}

LoginUserModel loginUserModelFromJson(String str) => LoginUserModel.fromJson(json.decode(str));

String loginUserModelToJson(LoginUserModel data) => json.encode(data.toJson());

class LoginUserModel {
  String? id;
  String? password;
  String? contact;
  List<LoginUserrole>? userrole;
  int? v;
  int? isadmin;
  List<String>? oldpasswords;
  String? email;
  String? name;
  FilesDataModel? photo;

  LoginUserModel({
    this.id,
    this.password,
    this.contact,
    this.userrole,
    this.v,
    this.isadmin,
    this.oldpasswords,
    this.email,
    this.name,
    this.photo,
  });

  factory LoginUserModel.fromJson(Map<String, dynamic> json) => LoginUserModel(
        id: json["_id"],
        password: json["password"],
        contact: json["contact"],
        photo: FilesDataModel.fromJson(json["photo"] ?? {}),
        userrole: json["userrole"] == null ? [] : List<LoginUserrole>.from(json["userrole"]!.map((x) => LoginUserrole.fromJson(x))),
        v: json["__v"],
        isadmin: json["isadmin"],
        oldpasswords: json["oldpasswords"] == null ? [] : List<String>.from(json["oldpasswords"]!.map((x) => x)),
        email: json["email"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "password": password,
        "contact": contact,
        "userrole": userrole == null ? [] : List<dynamic>.from(userrole!.map((x) => x.toJson())),
        "__v": v,
        "photo": photo?.toJson(),
        "isadmin": isadmin,
        "oldpasswords": oldpasswords == null ? [] : List<dynamic>.from(oldpasswords!.map((x) => x)),
        "email": email,
        "name": name,
      };
}

class LoginUserrole {
  String? userroleid;
  String? userrole;
  String? id;

  LoginUserrole({
    this.userroleid,
    this.userrole,
    this.id,
  });

  factory LoginUserrole.fromJson(Map<String, dynamic> json) => LoginUserrole(
        userroleid: json["userroleid"],
        userrole: json["userrole"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "userroleid": userroleid,
        "userrole": userrole,
        "_id": id,
      };
}
