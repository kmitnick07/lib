import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_shimmer.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/controller/tenant_master_controller.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:prestige_prenew_frontend/view/tenant_master/tenants_kanban_card_view.dart';
import 'package:responsive_builder/responsive_builder.dart';

class TenantsKanbanView extends GetView<TenantMasterController> {
  TenantsKanbanView({super.key});

  ScrollController horizontalScroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      return Container(
        padding: const EdgeInsets.only(
          top: 24,
        ),
        color: ColorTheme.kScaffoldColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(() {
            return Scrollbar(
              controller: horizontalScroll,
              interactive: true,
              thumbVisibility: true,
              child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  controller: horizontalScroll,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> groupData = (index < controller.kanbanData.keys.length ? controller.kanbanData[controller.kanbanData.keys.toList()[index]] : {});
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: min(MediaQuery.sizeOf(context).width - 16, 350),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              width: 350,
                              height: 40,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: ColorTheme.kBackgroundColor,
                                border: Border.all(width: 1, color: ColorTheme.kBorderColor),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: CustomShimmer(
                                isLoading: controller.kanbanDataLoading.value,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextWidget(
                                        text: (groupData['name'] ?? '').toUpperCase(),
                                        fontSize: 16,
                                        fontWeight: FontTheme.notoSemiBold,
                                        color: ColorTheme.kPrimaryColor,
                                        height: 1,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: ColorTheme.kCherryRed,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: TextWidget(
                                        text: (groupData['count'] ?? 0),
                                        fontSize: 14,
                                        fontWeight: FontTheme.notoMedium,
                                        color: ColorTheme.kWhite,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Expanded(
                              child: Builder(builder: (context) {
                                if (!controller.kanbanCardScrollController.containsKey(groupData['id'] ?? '')) {
                                  controller.kanbanCardScrollController[groupData['id'] ?? ''] = ScrollController();
                                  controller.kanbanCardScrollController[groupData['id'] ?? '']?.addListener(() {
                                    double? maxScroll = controller.kanbanCardScrollController[groupData['id'] ?? '']?.position.maxScrollExtent;
                                    double? currentScroll = controller.kanbanCardScrollController[groupData['id'] ?? '']?.position.pixels;
                                    double delta = 200.0;
                                    if (maxScroll! - currentScroll! <= delta) {
                                      controller.getKanbanGroupPaginationData(groupData['id'] ?? '');
                                    }
                                  });
                                }
                                return Obx(() {
                                  return ListView.separated(
                                    shrinkWrap: true,
                                    controller: controller.kanbanCardScrollController[groupData['id'] ?? ''],
                                    cacheExtent: 1000,
                                    itemCount: (groupData['data'] ?? []).length +
                                        ((controller.kanbanData[groupData['id'] ?? ''] ?? {})['isLoading'] == true || controller.kanbanDataLoading.value ? 2 : 0),
                                    itemBuilder: (context, groupIndex) {
                                      Map<String, dynamic> data =
                                          Map<String, dynamic>.from(((groupData['data'] ?? []).length > groupIndex ? (groupData['data'] ?? [])[groupIndex] : {}));
                                      var ownerImage = data['tenantpanimage'] ?? {};
                                      return Obx(() {
                                        return TenantKanBanCardView(
                                          data: data,
                                          isLoading: (controller.kanbanDataLoading.value || (controller.kanbanData.value[(groupData['id'] ?? '')] ?? {})['isLoading'] == true) &&
                                              (groupData['data'] ?? []).length <= groupIndex, pageName: controller.pageName.value, index: index,
                                        );
                                      });
                                    },
                                    separatorBuilder: (context, index) => const SizedBox(
                                      height: 16,
                                    ),
                                  );
                                });
                              }),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(
                        width: 16,
                      ),
                  itemCount: controller.kanbanData.keys.length + (controller.kanbanDataLoading.value ? 6 : 0)),
            );
          }),
        ),
      );
    });
  }
}
