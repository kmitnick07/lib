import 'package:get/get.dart';

class FormDataModel {
  late RxList<Map<String, dynamic>> fieldOrder;
  late RxList<Map<String, dynamic>> masterFieldOrder;
  late int nextPage;
  late RxInt pageNo;
  late int contentLength;
  late int pageLimit;
  late RxInt noOfPages;
  late String pageName;
  late RxMap<String, dynamic> sortData;
  late RxMap<String, dynamic> formData;
  late RxMap<String, dynamic> masterFormData;
  late RxMap<String, dynamic> filterData;
  late RxMap<String, dynamic> oldFilterData;
  late RxMap<String, dynamic> oldFormData;
  late RxMap<String, dynamic> modal;
  late RxMap<String, dynamic> masterData;
  late RxMap<String, dynamic> filterMasterData;
  late RxMap<String, dynamic> masterDataList;
  late RxList<Map<String, dynamic>> data;

  FormDataModel({
    RxList<Map<String, dynamic>>? fieldOrder,
    RxList<Map<String, dynamic>>? newFieldOrder,
    int? nextPage,
    RxInt? pageNo,
    int? loadmore,
    RxInt? noOfPages,
    int? pageLength,
    int? pageLimit,
    String? pageName,
    RxMap<String, dynamic>? sortData,
    RxMap<String, dynamic>? formData,
    RxMap<String, dynamic>? masterFormData,
    RxMap<String, dynamic>? filterData,
    RxMap<String, dynamic>? oldFilterData,
    RxMap<String, dynamic>? oldFormData,
    RxMap<String, dynamic>? modal,
    RxMap<String, dynamic>? masterData,
    RxMap<String, dynamic>? masterDataList,
    RxMap<String, dynamic>? filterMasterData,
    RxList<Map<String, dynamic>>? data,
  })  : fieldOrder = fieldOrder ?? RxList<Map<String, dynamic>>(),
        masterFieldOrder = newFieldOrder ?? RxList<Map<String, dynamic>>(),
        nextPage = nextPage ?? 0,
        pageNo = pageNo ?? 1.obs,
        noOfPages = noOfPages ?? 0.obs,
        contentLength = pageLength ?? 1,
        pageLimit = pageLimit ?? 20,
        pageName = pageName ?? '',
        sortData = sortData ?? RxMap<String, dynamic>(),
        formData = formData ?? RxMap<String, dynamic>(),
        masterFormData = masterFormData ?? RxMap<String, dynamic>(),
        filterData = filterData ?? RxMap<String, dynamic>(),
        oldFilterData = oldFilterData ?? RxMap<String, dynamic>(),
        oldFormData = oldFormData ?? RxMap<String, dynamic>(),
        modal = modal ?? RxMap<String, dynamic>(),
        masterData = masterData ?? RxMap<String, dynamic>(),
        masterDataList = masterDataList ?? RxMap<String, dynamic>(),
        filterMasterData = filterMasterData ?? RxMap<String, dynamic>(),
        data = data ?? RxList<Map<String, dynamic>>();

  Map<String, dynamic> toJson() {
    return {
      'fieldOrder': fieldOrder.map((e) => Map<String, dynamic>.from(e)).toList(),
      'masterFieldOrder': masterFieldOrder.map((e) => Map<String, dynamic>.from(e)).toList(),
      'nextPage': nextPage,
      'pageNo': pageNo.value,
      'noOfPages': noOfPages.value,
      'contentLength': contentLength,
      'pageLimit': pageLimit,
      'pageName': pageName,
      'sortData': sortData,
      'formData': formData,
      'masterFormData': masterFormData,
      'filterData': filterData,
      'oldFilterData': oldFilterData,
      'oldFormData': oldFormData,
      'modal': modal,
      'masterData': masterData,
      'filterMasterData': filterMasterData,
      'masterDataList': masterDataList,
      'data': data.map((e) => Map<String, dynamic>.from(e)).toList(),
    };
  }

  FormDataModel.fromJson(Map<String, dynamic> json)
      : fieldOrder = (json['fieldOrder'] as List).map((e) => Map<String, dynamic>.from(e)).toList().obs,
        masterFieldOrder = (json['masterFieldOrder'] as List).map((e) => Map<String, dynamic>.from(e)).toList().obs,
        nextPage = json['nextPage'],
        pageNo = RxInt(json['pageNo']),
        noOfPages = RxInt(json['noOfPages']),
        contentLength = json['contentLength'],
        pageLimit = json['pageLimit'],
        pageName = json['pageName'],
        sortData = (Map<String, dynamic>.from(json['sortData'] ?? {})).obs,
        formData = (Map<String, dynamic>.from(json['formData'] ?? {})).obs,
        masterFormData = (Map<String, dynamic>.from(json['masterFormData'] ?? {})).obs,
        filterData = (Map<String, dynamic>.from(json['filterData'] ?? {})).obs,
        oldFilterData = (Map<String, dynamic>.from(json['oldFilterData'] ?? {})).obs,
        oldFormData = (Map<String, dynamic>.from(json['oldFormData'] ?? {})).obs,
        modal = (Map<String, dynamic>.from(json['modal'] ?? {})).obs,
        masterData = (Map<String, dynamic>.from(json['masterData'] ?? {})).obs,
        filterMasterData = (Map<String, dynamic>.from(json['filterMasterData'] ?? {})).obs,
        masterDataList = (Map<String, dynamic>.from(json['masterDataList'] ?? {})).obs,
        data = (json['data'] as List).map((e) => Map<String, dynamic>.from(e)).toList().obs;
}
