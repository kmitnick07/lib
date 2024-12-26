import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:prestige_prenew_frontend/config/api_constant.dart';
import 'package:responsive_builder/responsive_builder.dart';


class Config {
  static String weburl = '${ApiConstant.baseUrl}/';
static int sessionTimeOutMinutes = 120;

  static bool isEncrypted = !kDebugMode && false;
  static bool isPreferenceEncrypted = !kDebugMode && false;

  static const adminutype = '622ed36cbe213c85a88da9a0';
  static const String kHutmentSupportId = '65decc3b043a708fe6b84085';

  // static const measureUnit = [
  //   {'value': 1, 'label': 'sq.ft'},
  //   {'value': 2, 'label': 'sq.m'},
  //   {'value': 3, 'label': 'Acre'},
  //   {'value': 4, 'label': 'Hectare'},
  // ];
  static const statusType = [
    {'value': 1, 'label': 'Active'},
    {'value': 0, 'label': 'Inactive'},
  ];
  static const agreeType = [
    {'value': 1, 'label': 'Yes'},
    {'value': 0, 'label': 'No'},
  ];
  static const durationType = [
    {'value': 1, 'label': 'Day'},
    {'value': 2, 'label': 'Week'},
    {'value': 3, 'label': 'Month'},
  ];
  static const errmsg = {
    'insert': 'Data inserted successfully.',
    'update': 'Data updated successfully.',
    'delete': 'Data deleted successfully.',
    'reqired': 'Please fill in all required fields.',
    'inuse': 'Data is already in use.',
    'isexist': 'Data already exist.',
    'dberror': 'Something went wrong, Error Code : ',
    'userright': "Sorry, You don't have enough permissions to perform this action",
    'size': "Sorry, You don't have enough permissions to perform this action",
    'type': "Sorry, You don't have enough permissions to perform this action.",
    'success': "Data found",
    'error': "Error",
    'nodatafound': "No data found",
    'uservalidate': "User Validate.",
    'deactivate': "Your account is suspended, please contact administrator to activate account.",
    'invalidrequest': "Invalid request.",
    'sessiontimeout': "Session timeout",
    'dataduplicate': "Data Duplicated Successfully",
    'tokenvalidate': "Token validated",
    'invalidtoken': "Invalid token.",
    'usernotfound': "User not found",
    'invalidusername': "Invalid Username or Password.",
    'invalidpassword': "Invalid Username or Password..",
    'verifyemail': "Please verify your email addess",
    'invalidfile': "Invalid File Type",
    'filetype': "Invalid file extension",
    'loginright': "Sorry, You don't have enough permissions to login. Please contact admin",
    'somethingwrong': 'Sorry, something went wrong.',
    'loginsuccess': "Login Successfully",
    'logoutsuccess': "Logout Successfully",
    'appupdate': "We have released new version of Poly Cafe App. Download the update and install to continue use this App.",
    'profile-update': "Profile updated successfully",
    'passchanged': "Password changed successfully",
    'correctpass': "Please enter correct old password",
    'csvdownload': "CSV downloaded successfully",
    'invalidbarcode': "Invalid barcode",
    'itemalreadyassign': "Item already assigned",
    'itemassign': "Item assigned successfully",
    'itemreassign': "Item reassigned successfully",
    'newnodeadd': "New Nodes added successfully",
    'nodedelnot': "Can't delete super admin node",
    'nodedel': "Node deleted successfully",
    'noitemfound': "No item found",
    'cancelorditem': "Order item cancelled successfully",
    'reqorderseries': "Order series data is required",
    'nonotifound': "No notification found",
    'noorderfound': "No order found",
    'itemready': "Item has been ready successfully",
    'itemserved': "Item has been served successfully",
    'paycollectsuccess': "Payment collected successfully",
    'orderaccept': "Order accepted successfully",
    'ordpreparetime': "Order preparation time updated successfully",
    'outofstock': "Out Of Stock",
    'itemoutofstock': "are Out Of Stock",
    'checkqty': "Please Enter at least one quantity",
    'selecttable': "Please Select table first",
    'tablesbooked': "All tables are booked",
    'imagevalid': "Please Selected valid required image."
  };
}

class HtmlControls {
  HtmlControls._privateConstructor();

  static final HtmlControls _instance = HtmlControls._privateConstructor();

  factory HtmlControls() => _instance;

  static const String kText = 'text';
  static const String kInputText = 'input-text';
  static const String kLookUp = 'lookup';
  static const String kNumberInput = 'number-input';
  static const String kDropDown = 'dropdown';
  static const String kMultiSelectDropDown = 'multipleselectdropdown';
  static const String kRadio = 'radio';
  static const String kSwitch = 'switch';
  static const String kDocumentAdd = 'document_add';
  static const String kStatus = 'status';
  static const String kTenantStatus = 'tenantstatus';
  static const String kDropStatus = 'drop_status';
  static const String kCheckBox = 'checkbox';
  static const String kPassword = 'password';
  static const String kInputTextArea = 'input-textarea';
  static const String kDateRangePicker = 'daterangepicker';
  static const String kTable = 'table';
  static const String kTimeRangePicker = 'timerangepicker';
  static const String kTimePicker = 'timepicker';
  static const String kDatePicker = 'datepicker';
  static const String kImagePicker = 'image';
  static const String kAvatarPicker = 'avatar';
  static const String kFilePicker = 'file';
  static const String kMultipleImagePicker = 'multipleimagepicker';
  static const String kModel = 'modal';
  static const String kMultipleContactSelection = 'multiplecontactselection';
  static const String kFieldGroupList = 'fieldgrouplist';
  static const String kPrimaryField = 'primary';
  static const String kEmptyBlock = 'empty-block';
  static const String kMultipleTextFieldWithTitle = 'multipletextfieldwithtitle';
  static const String kMultipleFilePickerFieldWithTitle = 'multipleFilePickerfieldwithtitle';
  static const String kTextArray = 'text-array';
  static const String kTableAddButton = 'table-add-button';
  static const String kDivider = 'divider';
  static const String kMasterForm = 'masterform';
}

class ModelClassSize {
  ModelClassSize._privateConstructor();

  static final ModelClassSize _instance = ModelClassSize._privateConstructor();

  factory ModelClassSize() => _instance;

  static const double xs = 400;
  static const double sm = 600;
  static const double md = 850;
  static const double lg = 1000;
  static const double xl = 1400;
  static const double full = 1800;
}

class FileTypes {
  FileTypes._privateConstructor();

  static final FileTypes _instance = FileTypes._privateConstructor();

  factory FileTypes() => _instance;

  static List<String> pdf = ['pdf'];
  static List<String> image = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'JPG',
    'JPEG',
    'PNG',
    'WEBP',
  ];
  static List<String> excel = [
    'xlsx',
  ];
  static List<String> pdfAndImage = [...pdf, ...image];
}

Widget constrainedBoxWithPadding({required Widget child, num? width}) {
  return ResponsiveBuilder(
    builder: (context, sizingInformation) => ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: double.parse((sizingInformation.isMobile ? MediaQuery.sizeOf(context).width : width ?? 400).toString()),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: child,
      ),
    ),
  );
}

class FieldSize {
  FieldSize._privateConstructor();

  static final FieldSize _instance = FieldSize._privateConstructor();

  factory FieldSize() => _instance;

  static int k25 = 25;
  static int k50 = k25 + 25;
  static int k75 = k50 + 25;
  static int k100 = k75 + 25;
  static int k125 = k100 + 25;
  static int k150 = k125 + 25;
  static int k175 = k150 + 25;
  static int k200 = k175 + 25;
  static int k225 = k200 + 25;
  static int k243 = k200 + 18;
  static int k250 = k225 + 25;
  static int k266 = k250 + 16;
  static int k275 = k250 + 25;
  static int k300 = k275 + 25;
  static int k325 = k300 + 25;
  static int k350 = k325 + 25;
  static int k375 = k350 + 25;
  static int k400 = k375 + 25;
  static int k425 = k400 + 25;
  static int k450 = k425 + 25;
  static int k475 = k450 + 25;
  static int k500 = k475 + 25;
  static int k525 = k500 + 25;
  static int k550 = k525 + 25;
  static int k575 = k550 + 25;
  static int k600 = k575 + 25;
  static int k625 = k600 + 25;
  static int k650 = k625 + 25;
  static int k675 = k650 + 25;
  static int k700 = k675 + 25;
  static int k725 = k700 + 25;
  static int k750 = k725 + 25;
  static int k775 = k750 + 25;
  static int k800 = k775 + 25;
  static int k825 = k800 + 25;
  static int k850 = k825 + 25;
  static int k875 = k850 + 25;
  static int k900 = k875 + 25;
  static int k925 = k900 + 25;
  static int k950 = k925 + 25;
  static int k975 = k950 + 25;
  static int k1000 = k975 + 25;
  static int k1025 = k1000 + 25;
  static int k1050 = k1025 + 25;
  static int k1075 = k1050 + 25;
  static int k1100 = k1075 + 25;
  static int k1125 = k1100 + 25;
  static int k1150 = k1125 + 25;
  static int k1175 = k1150 + 25;
  static int k1200 = k1175 + 25;
}
