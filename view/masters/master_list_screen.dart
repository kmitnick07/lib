import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_shimmer.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/hover_builder.dart';
import 'package:prestige_prenew_frontend/controller/Masters/master_screen_controller.dart';
import 'package:prestige_prenew_frontend/routes/route_name.dart';
import 'package:prestige_prenew_frontend/view/no_data_found_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../models/Menu/menu_model.dart';
import '../../style/theme_const.dart';
import '../CommonWidgets/common_header_footer.dart';

class MastersListScreen extends GetView<MasterListScreenController> {
  const MastersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: GetBuilder<MasterListScreenController>(
          global: false,
          init: Get.put(MasterListScreenController()),
          builder: (controller) {
            return ResponsiveBuilder(builder: (context, sizingInformation) {
              bool isMobile = sizingInformation.isMobile;
              double width = MediaQuery.of(context).size.width;
              int widthCard = 250;
              int countRow = width ~/ widthCard;
              return CommonHeaderFooter(
                title: "Masters",
                hasSearch: true,
                onSearch: (value) {
                  controller.searchText.value = value;
                  controller.getMasterList();
                },
                onSearchChange: (value) {
                  controller.searchText.value = value;
                  controller.getMasterList();
                },
                txtSearchController: controller.searchController,
                child: Obx(() {
                  return CustomShimmer(
                    isLoading: controller.isLoading.value,
                    child: controller.masterList.isEmpty && !controller.isLoading.value
                        ? const NoDataFoundScreen()
                        : Obx(() {
                            List<MenuData> dataList = controller.masterList.value.where((element) {
                              if (controller.searchText.isEmpty) {
                                return true;
                              }
                              try {
                                return element.formname!.toLowerCase().contains(controller.searchText.value.toLowerCase());
                              } catch (e) {
                                return false;
                              }
                            }).toList();
                            return GridView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isMobile ? 2 : countRow,
                                childAspectRatio: 1.5,
                                crossAxisSpacing: isMobile ? 8 : width * 0.012,
                                mainAxisSpacing: isMobile ? 8 : width * 0.012,
                              ),
                              itemBuilder: (context, i) {
                                if (controller.isLoading.value) {
                                  return Container(
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: ColorTheme.kBlack,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  );
                                }
                                return HoverBuilder(
                                  builder: (bool isHovered) {
                                    return InkWell(
                                      onTap: () {
                                        navigateTo('/masters/${dataList[i].alias!}');
                                      },
                                      child: AnimatedContainer(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: ColorTheme.kBorderColor),
                                          color: isHovered ? ColorTheme.kBlack.withOpacity(0.8) : null,
                                        ),
                                        duration: const Duration(milliseconds: 300),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: SvgPicture.network(
                                                dataList[i].iconimage?.url ?? "",
                                                height: 100,
                                                colorFilter: ColorFilter.mode(isHovered ? ColorTheme.kWhite : ColorTheme.kBlack.withOpacity(0.7), BlendMode.srcIn),
                                              ).paddingOnly(top: 24, left: 24, right: 24, bottom: 8),
                                            ),
                                            TextWidget(
                                              text: dataList[i].menuname ?? "",
                                              maxLines: 1,
                                              fontSize: 14,
                                              fontWeight: FontTheme.notoMedium,
                                              color: isHovered ? ColorTheme.kWhite : ColorTheme.kBlack,
                                              textOverflow: TextOverflow.ellipsis,
                                            ).paddingOnly(top: 16, left: 8, right: 8, bottom: 16)
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              itemCount: controller.isLoading.value ? 30 : dataList.length,
                            );
                          }),
                  );
                }).paddingAll(
                  sizingInformation.isMobile || sizingInformation.isTablet ? 12 : 24,
                ),
              );
            });
          }),
    );
  }
}
