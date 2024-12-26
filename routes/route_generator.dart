import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/config/settings.dart';
import 'package:prestige_prenew_frontend/controller/Approval/approval_master_controller.dart';
import 'package:prestige_prenew_frontend/controller/dashboard/dashboard_controller.dart';
import 'package:prestige_prenew_frontend/controller/layout_templete_controller.dart';
import 'package:prestige_prenew_frontend/controller/new_tenant_project/new_tenant_project_controller.dart';
import 'package:prestige_prenew_frontend/models/Menu/menu_model.dart';
import 'package:prestige_prenew_frontend/routes/route_name.dart';
import 'package:prestige_prenew_frontend/view/analytics/analytics_screen.dart';
import 'package:prestige_prenew_frontend/view/approval/approval_master_screen.dart';
import 'package:prestige_prenew_frontend/view/dashboard/dashboard_screen.dart';
import 'package:prestige_prenew_frontend/view/delete_account/delete_account_web_view.dart';
import 'package:prestige_prenew_frontend/view/developer/developer_screen.dart';
import 'package:prestige_prenew_frontend/view/field_setting/tenant_mandatory_field_view.dart';
import 'package:prestige_prenew_frontend/view/field_setting/tenant_project_mandatory_field_view.dart';
import 'package:prestige_prenew_frontend/view/login_screen.dart';
import 'package:prestige_prenew_frontend/view/master_view.dart';
import 'package:prestige_prenew_frontend/view/menu_design/menu_design.dart';
import 'package:prestige_prenew_frontend/view/new_tenant_project/new_tenant_project.dart';
import 'package:prestige_prenew_frontend/view/no_page_found_screen.dart';
import 'package:prestige_prenew_frontend/view/tenant_master/tenants_master_view.dart';
import 'package:prestige_prenew_frontend/view/user_rights/user_rights_view.dart';
import 'package:prestige_prenew_frontend/view/user_role_hierarchy/user_role_hierarchy_screen.dart';

import '../controller/developer/developer_controller.dart';
import '../global_screen_bindings.dart';
import '../view/Masters/master_list_screen.dart';
import '../view/SAPTenantHistory/sap_tenant_history.dart';
import '../view/analytics/chart_screen.dart';
import '../view/html_editor/html_editor.dart';
import '../view/menu_assign/menu_assign.dart';
import '../view/profile/profile_screen.dart';
import '../view/project/project_management_screen.dart';
import '../view/reports/tenant_report_view.dart';
import '../view/sap_logs_history/sap_log_history_screen.dart';
import '../view/splash_screen.dart';
import '../view/tenant/tenant_sra_screen.dart';
import '../view/tenant_master/offline_tenants_master_view.dart';

class RouteGenerator {
  static List<GetPage<dynamic>> generate() {
    return <GetPage<dynamic>>[
      GetPage(
        name: RouteNames.kSplashScreenRoute,
        page: () => const SplashScreen(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kLoginScreen,
        page: () => const LoginScreen(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kAdminScreen,
        page: () => const AdminScreen(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kCharts,
        page: () => const ChartsScreen(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: "/h",
        page: () => const HtmlEditor(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kDashboard,
        page: () => const Dashboard(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      for (int i = 0; i < RouteNames.kMastersRoute.length; i++) ...[
        GetPage(
          name: RouteNames.kMastersListScreen + RouteNames.kMastersRoute[i],
          page: () => const MasterView(),
          binding: GlobalScreenBindings(),
          middlewares: [NavigatorMiddleware()],
          transition: navigationTransaction,
        ),
      ],
      GetPage(
        name: RouteNames.kNoPageFound,
        page: () => NoPageFoundScreen(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kTenantProjectScreen,
        page: () => const NewTenantProjectScreen(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kApprovals,
        page: () => const Approvals(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kApprovalTemplate,
        page: () => const ApprovalTempl(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kTemplateAssignment,
        page: () => const TemplateAssign(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kProfile,
        page: () => const ProfileScreen(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kPostHandOverSRAUnit,
        page: () => const TenantSRAScreen(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kMastersListScreen,
        page: () => const MastersListScreen(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kTenants,
        page: () => const TenantsMasterView(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kOfflineTenants,
        page: () => const OfflineTenantsMasterView(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kProject,
        page: () => const ProjectManagementScreen(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kBuilding,
        page: () => const Building(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kFloor,
        page: () => const Floor(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kUnit,
        page: () => const Unit(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kDeveloper,
        page: () => const Dev(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kUsers,
        page: () => const Users(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kTeam,
        page: () => const Team(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kUserRole,
        page: () => const UserRole(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kIcon,
        page: () => const MasterView(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kModule,
        page: () => const MasterView(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kMenu,
        page: () => const MasterView(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kMenuAssign,
        page: () => const MenuAssign(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kMenuDesign,
        page: () => const MenuDesign(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kUserRights,
        page: () => const UserRightsMaster(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kUserRoleHierarchy,
        page: () => const UserRoleHierarchy(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kAnalytics,
        page: () => const AnalyticsScreen(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kTenantReport,
        page: () => const TenantReportView(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kSapTenantHistory,
        page: () => const SapTenantHistory(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kSapLogHistory,
        page: () => const SapLogHistoryScreen(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kNewTenantProjectScreen,
        page: () => const NewTenantProjectScreen(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),GetPage(
        name: RouteNames.kPaymentManagement,
        page: () => const TenantSRAScreen(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kMandatoryFieldMapping,
        page: () => const MandatoryFieldMappingView(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
      GetPage(
        name: RouteNames.kDeleteAccount,
        page: () => const DeleteAccountWebView(),
        binding: GlobalScreenBindings(),
        middlewares: [NavigatorMiddleware()],
        transition: navigationTransaction,
      ),
    ];
  }
}

void setPageTitle(String title, BuildContext context) {
  SystemChrome.setApplicationSwitcherDescription(ApplicationSwitcherDescription(
    label: title,
    primaryColor: Theme.of(context).primaryColor.value, // This line is required
  ));
}

Transition navigationTransaction = Transition.fadeIn;

class NavigatorMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    devPrint('--->$route');
    Get.find<LayoutTemplateController>().currentAlias.value = route?.split("/").last ?? Get.find<LayoutTemplateController>().currentAlias.value;
    if (Settings.isUserLogin) {
      if (RouteNames.kNoPageFound == route || RouteNames.kSplashScreenRoute == route) {
        return null;
      }
      if (RouteNames.kLoginScreen == route || RouteNames.kAdminScreen == route) {
        return const RouteSettings(name: RouteNames.kDashboard);
      }
      List<UserRight> rights = Settings.loginData.userrights ?? [];
      for (UserRight right in rights) {
        if (right.alias == route?.split("/").last) {
          return null;
        }
      }
      return const RouteSettings(name: RouteNames.kNoPageFound);
    } else if (!Settings.isUserLogin && !(route == RouteNames.kLoginScreen || route == RouteNames.kAdminScreen || route == RouteNames.kSplashScreenRoute)) {
      return const RouteSettings(name: RouteNames.kSplashScreenRoute);
    }
    return null;
  }
}

class Dev extends StatefulWidget {
  const Dev({super.key});

  @override
  State<Dev> createState() => _DevState();
}

class _DevState extends State<Dev> {
  DeveloperController controller = Get.put(DeveloperController());

  @override
  void initState() {
    controller.onInitl();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DeveloperScreen(
      controller: controller,
    );
  }
}

class ApprovalTempl extends StatefulWidget {
  const ApprovalTempl({super.key});

  @override
  State<ApprovalTempl> createState() => _ApprovalTemplState();
}

class _ApprovalTemplState extends State<ApprovalTempl> {
  ApprovalMasterController controller = Get.put(ApprovalMasterController());

  @override
  void initState() {
    controller.onInitl();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ApprovalMasterScreen(
      controller: controller,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DashBoardController controller = Get.put(DashBoardController());

  @override
  void initState() {
    controller.onInitl();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(Dashboard oldWidget) {
    controller.onInitl();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return DashBoardScreen(controller: controller);
  }

  @override
  void dispose() {
    controller.dispose();
    Get.delete<DashBoardController>();
    super.dispose();
  }
}


class Approvals extends StatefulWidget {
  const Approvals({super.key});

  @override
  State<Approvals> createState() => _ApprovalsState();
}

class _ApprovalsState extends State<Approvals> {
  ApprovalMasterController controller = Get.put(ApprovalMasterController());

  @override
  void initState() {
    controller.onInitl();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ApprovalMasterScreen(
      controller: controller,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class TemplateAssign extends StatefulWidget {
  const TemplateAssign({super.key});

  @override
  State<TemplateAssign> createState() => _TemplateAssignState();
}

class _TemplateAssignState extends State<TemplateAssign> {
  ApprovalMasterController controller = Get.put(ApprovalMasterController());

  @override
  void initState() {
    controller.onInitl();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ApprovalMasterScreen(
      controller: controller,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  DeveloperController controller = Get.put(DeveloperController());

  @override
  void initState() {
    controller.onInitl();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DeveloperScreen(
      controller: controller,
    );
  }
}

class Team extends StatefulWidget {
  const Team({super.key});

  @override
  State<Team> createState() => _TeamState();
}

class _TeamState extends State<Team> {
  DeveloperController controller = Get.put(DeveloperController());

  @override
  void initState() {
    controller.onInitl();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DeveloperScreen(
      controller: controller,
    );
  }
}

class UserRole extends StatefulWidget {
  const UserRole({super.key});

  @override
  State<UserRole> createState() => _UserRoleState();
}

class _UserRoleState extends State<UserRole> {
  DeveloperController controller = Get.put(DeveloperController());

  @override
  void initState() {
    controller.onInitl();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DeveloperScreen(
      controller: controller,
    );
  }
}

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}

class TenantProjectScreen extends StatelessWidget {
  const TenantProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TenantSRAScreen();
  }
}

class Building extends StatelessWidget {
  const Building({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProjectManagementScreen();
  }
}

class Floor extends StatelessWidget {
  const Floor({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProjectManagementScreen();
  }
}

class Unit extends StatelessWidget {
  const Unit({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProjectManagementScreen();
  }
}
