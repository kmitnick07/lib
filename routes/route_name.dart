import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RouteNames {
  static const String kSplashScreenRoute = "/splash";
  static const String kLoginScreen = "/login";
  static const String kAdminScreen = "/admin";
  static const String kNoPageFound = "/nopagefound";
  static const String kDashboard = "/dashboard";

  static const String kCharts = "/charts";
  static const String kReports = "/reports";
  static const String kAnalytics = "/analytics";

  static const String kMenuAssign = "/menuassign";
  static const String kMenuDesign = "/menudesign";

  static const String kTenantProjectScreen = "/tenantproject";
  static const String kNewTenantProjectScreen = "/newtenantproject";
  static const String kPostHandOverSRAUnit = "/posthandoversra";
  static const String kTenants = "/tenant";
  static const String kOfflineTenants = "/offlinetenant";
  static const String kPaymentManagement = "/paymentmanagement";
  static const String kMandatoryFieldMapping = "/masters/mandatoryfieldmapping";

  static const String kApprovals = "/approvals";
  static const String kApprovalTemplate = "/approvaltemplate";
  static const String kProfile = "/profile";
  static const String kMastersListScreen = "/masters";
  static const List kMastersRoute = [
    "/state",
    "/city",
    "/pincode",
    "/projectlocation",
    "/projecttype",
    "/clustername",
    "/constructionstage",
    "/approvalcategory",
    "/subapprovalcategory",
    "/governmentauthority",
    "/committeedesignations",
    "/eligibility",
    "/locality",
    "/xpart",
    "/requestslot",
    '/consent',
    "/commonconsent",
    "/individualconsent",
    "/individualagreement",
    "/hutmentsupport",
    "/userrolemanagement",
    "/demolitionstatus",
    "/unittype",
    "/unitconfiguration",
    "/salutation",
    "/emailsmtp",
    "/form3-4",
    "/relation",
    "/documenttype",
    '/loft'
  ];

  static const String kProject = "/project";
  static const String kBuilding = "/building";
  static const String kFloor = "/floor";
  static const String kUnit = "/unit";

  static const String kDeveloper = "/developer";

  static const String kUsers = "/user";
  static const String kTeam = "/team";
  static const String kUserRole = "/userrole";
  static const String kUserRights = "/userrights";
  static const String kUserRoleHierarchy = "/userrolehierarchy";

  static const String kIcon = "/icon";
  static const String kModule = "/module";
  static const String kMenu = "/menu";

  static const String kTenantReport = "/tenantreport";
  static const String kSapTenantHistory = "/saptenanterrors";

  static const String kSapLogHistory = "/sapapihistory";
  static const String kTemplateAssignment = "/templateassignment";

  static const String kDeleteAccount = "/deleteaccount";
}

navigateTo(name) {
  clearFocus();
  Get.rootDelegate.offAndToNamed(name);
  // Get.find<LayoutTemplateController>().textSelectionFocus.requestFocus();
}

getCurrentPageName() {
  try {
    return Get.rootDelegate.history.last.locationString.split("/").last;
  } catch (e) {
    return 'login';
  }
}

clearFocus() {
  FocusManager.instance.primaryFocus?.unfocus();
}
