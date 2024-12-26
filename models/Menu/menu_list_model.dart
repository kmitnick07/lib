class MenuListModel {
  String? menuname;
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
  int? displayinsidebar;
  String? title;
  bool? expanded;
  int? canhavechild;
  String? sId;
  List<Children>? children;

  MenuListModel(
      {this.menuname,
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
      this.displayinsidebar,
      this.title,
      this.expanded,
      this.canhavechild,
      this.sId,
      this.children});

  MenuListModel.fromJson(Map<String, dynamic> json) {
    menuname = json['menuname'];
    formname = json['formname'];
    iconid = json['iconid'];
    iconunicode = json['iconunicode'];
    alias = json['alias'];
    isparent = json['isparent'];
    parentid = json['parentid'];
    moduleid = json['moduleid'];
    menuid = json['menuid'];
    containright = json['containright'];
    defaultopen = json['defaultopen'];
    displayinsidebar = json['displayinsidebar'];
    title = json['title'];
    expanded = json['expanded'];
    canhavechild = json['canhavechild'];
    sId = json['_id'];
    if (json['children'] != null) {
      children = <Children>[];
      json['children'].forEach((v) {
        children!.add(new Children.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['menuname'] = this.menuname;
    data['formname'] = this.formname;
    data['iconid'] = this.iconid;
    data['iconunicode'] = this.iconunicode;
    data['alias'] = this.alias;
    data['isparent'] = this.isparent;
    data['parentid'] = this.parentid;
    data['moduleid'] = this.moduleid;
    data['menuid'] = this.menuid;
    data['containright'] = this.containright;
    data['defaultopen'] = this.defaultopen;
    data['displayinsidebar'] = this.displayinsidebar;
    data['title'] = this.title;
    data['expanded'] = this.expanded;
    data['canhavechild'] = this.canhavechild;
    data['_id'] = this.sId;
    if (this.children != null) {
      data['children'] = this.children!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Children {
  String? menuname;
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
  int? displayinsidebar;
  String? title;
  bool? expanded;
  int? canhavechild;
  String? sId;
  String? moduletypeid;
  int? ipallowed;
  Recordinfo? recordinfo;
  int? iV;
  List<Children>? children;

  Children(
      {this.menuname,
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
      this.displayinsidebar,
      this.title,
      this.expanded,
      this.canhavechild,
      this.sId,
      this.moduletypeid,
      this.ipallowed,
      this.recordinfo,
      this.iV,
      this.children});

  Children.fromJson(Map<String, dynamic> json) {
    menuname = json['menuname'];
    formname = json['formname'];
    iconid = json['iconid'];
    iconunicode = json['iconunicode'];
    alias = json['alias'];
    isparent = json['isparent'];
    parentid = json['parentid'];
    moduleid = json['moduleid'];
    menuid = json['menuid'];
    containright = json['containright'];
    defaultopen = json['defaultopen'];
    displayinsidebar = json['displayinsidebar'];
    title = json['title'];
    expanded = json['expanded'];
    canhavechild = json['canhavechild'];
    sId = json['_id'];
    moduletypeid = json['moduletypeid'];
    ipallowed = json['ipallowed'];
    recordinfo = json['recordinfo'] != null ? new Recordinfo.fromJson(json['recordinfo']) : null;
    iV = json['__v'];
    if (json['children'] != null) {
      children = <Children>[];
      json['children'].forEach((v) {
        children!.add(new Children.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['menuname'] = this.menuname;
    data['formname'] = this.formname;
    data['iconid'] = this.iconid;
    data['iconunicode'] = this.iconunicode;
    data['alias'] = this.alias;
    data['isparent'] = this.isparent;
    data['parentid'] = this.parentid;
    data['moduleid'] = this.moduleid;
    data['menuid'] = this.menuid;
    data['containright'] = this.containright;
    data['defaultopen'] = this.defaultopen;
    data['displayinsidebar'] = this.displayinsidebar;
    data['title'] = this.title;
    data['expanded'] = this.expanded;
    data['canhavechild'] = this.canhavechild;
    data['_id'] = this.sId;
    data['moduletypeid'] = this.moduletypeid;
    data['ipallowed'] = this.ipallowed;
    if (this.recordinfo != null) {
      data['recordinfo'] = this.recordinfo!.toJson();
    }
    data['__v'] = this.iV;
    if (this.children != null) {
      data['children'] = this.children!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Recordinfo {
  String? updateuid;
  String? updateby;
  String? updatedate;

  Recordinfo({this.updateuid, this.updateby, this.updatedate});

  Recordinfo.fromJson(Map<String, dynamic> json) {
    updateuid = json['updateuid'];
    updateby = json['updateby'];
    updatedate = json['updatedate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['updateuid'] = this.updateuid;
    data['updateby'] = this.updateby;
    data['updatedate'] = this.updatedate;
    return data;
  }
}
