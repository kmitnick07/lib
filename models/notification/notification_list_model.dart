class NotificationListModel {
  String? sId;
  String? title;
  String? body;
  String? type;
  String? typeid;
  String? pagename;
  String? receiverid;
  int? status;
  String? time;
  String? noticolor;
  String? iconimg;
  String? sid;
  int? read;
  int? iV;

  NotificationListModel(
      {this.sId,
      this.noticolor,
      this.iconimg,
      this.title,
      this.body,
      this.type,
      this.typeid,
      this.pagename,
      this.receiverid,
      this.status,
      this.time,
      this.sid,
      this.read,
      this.iV});

  NotificationListModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    body = json['body'];
    noticolor = json['noticolor'];
    iconimg = json['iconimg'];
    type = json['type'];
    typeid = json['typeid'];
    pagename = json['pagename'];
    receiverid = json['receiverid'];
    status = json['status'];
    time = json['time'];
    sid = json['sid'];
    read = json['read'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['body'] = this.body;
    data['type'] = this.type;
    data['typeid'] = this.typeid;
    data['pagename'] = this.pagename;
    data['receiverid'] = this.receiverid;
    data['status'] = this.status;
    data['time'] = this.time;
    data['sid'] = this.sid;
    data['read'] = this.read;
    data['noticolor'] = this.noticolor;
    data['iconimg'] = this.iconimg;
    data['__v'] = this.iV;
    return data;
  }
}
