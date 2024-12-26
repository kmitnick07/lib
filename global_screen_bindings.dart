import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/controller/Approval/approval_master_controller.dart';
import 'package:prestige_prenew_frontend/controller/analytics/analytics_screen_controller.dart';
import 'package:prestige_prenew_frontend/controller/dashboard/dashboard_controller.dart';

import 'controller/Masters/master_screen_controller.dart';
import 'controller/dynamic_field_setting/tenant_mandatory_field_controller.dart';
import 'controller/dynamic_field_setting/tenant_project_mandatory_field_controller.dart';
import 'controller/layout_templete_controller.dart';
import 'controller/login_screen_controller.dart';
import 'controller/master_controller.dart';
import 'controller/notification/notification_list_controller.dart';
import 'controller/profile/profile_controller.dart';
import 'controller/tenant/tenant_sra_controller.dart';
import 'controller/tenant_master_controller.dart';

class GlobalScreenBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginScreenController>(() => LoginScreenController());
    Get.lazyPut<MasterListScreenController>(() => MasterListScreenController());
    Get.lazyPut<MasterController>(() => MasterController());
    Get.lazyPut<TenantSRAController>(() => TenantSRAController());
    Get.lazyPut<TenantMasterController>(() => TenantMasterController());
    Get.lazyPut<DashBoardController>(() => DashBoardController());
    Get.put<LayoutTemplateController>(LayoutTemplateController());
    Get.lazyPut<AnalyticsScreenController>(() => AnalyticsScreenController());
    Get.lazyPut<NotificationListController>(() => NotificationListController());
    Get.lazyPut<ApprovalMasterController>(() => ApprovalMasterController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<MandatoryFieldMapping>(() => MandatoryFieldMapping());
    Get.lazyPut<TenantProjectMandatoryFieldController>(() => TenantProjectMandatoryFieldController());
    // Get.lazyPut<DeveloperController>(() => DeveloperController());
  }
}
