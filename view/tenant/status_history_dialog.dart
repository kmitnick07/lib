import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/style/assets_string.dart';
import 'package:prestige_prenew_frontend/view/no_data_found_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../components/customs/custom_dialogs.dart';
import '../../components/customs/custom_tooltip.dart';
import '../../controller/tenant_master_controller.dart';
import '../../style/theme_const.dart';

class StatusHistoryDialog extends StatelessWidget {
  final Map data;
  final List statusList;

  const StatusHistoryDialog({
    super.key,
    required this.data,
    required this.statusList,
  });

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> tenantStatusHistory = List<Map<String, dynamic>>.from(data['tenantstatushistory'] ?? []);
    return SizedBox(
      width: 400,
      height: Get.height,
      child: ResponsiveBuilder(builder: (context, sizingInformation) {
        return SizedBox(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const TextWidget(
                    text: "Status History",
                    fontSize: 16,
                    textAlign: TextAlign.left,
                    color: ColorTheme.kBlack,
                    fontWeight: FontTheme.notoSemiBold,
                  ).paddingOnly(left: 4, bottom: 4),
                  Container(
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: ColorTheme.kBlack.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      splashColor: ColorTheme.kWhite,
                      hoverColor: ColorTheme.kWhite.withOpacity(0.1),
                      splashRadius: 20,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.clear_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              tenantStatusHistory.isNullOrEmpty
                  ? const NoDataFoundScreen()
                  : Expanded(
                      child: ListView.builder(
                        itemCount: tenantStatusHistory.length,
                        itemBuilder: (context, index) {
                          final status = tenantStatusHistory[index];

                          return TimelineTile(
                            isFirst: index == 0,
                            isLast: index == tenantStatusHistory.length - 1,
                            alignment: TimelineAlign.start,
                            beforeLineStyle: const LineStyle(
                              color: ColorTheme.kGrey,
                              thickness: 1,
                            ),
                            indicatorStyle: IndicatorStyle(
                              indicator: CircleAvatar(
                                backgroundColor: ColorTheme.kBackGroundGrey,
                                child: SvgPicture.network(
                                  statusList.firstWhere(
                                        (element) => element['_id'] == status['statusid'],
                                        orElse: () {
                                          return {};
                                        },
                                      )['image'] ??
                                      '',
                                  colorFilter: const ColorFilter.mode(
                                    ColorTheme.kPrimaryColor,
                                    BlendMode.srcIn,
                                  ),
                                ).paddingAll(7),
                              ),
                              padding: EdgeInsets.zero,
                              width: 35,
                              height: 35,
                            ),
                            endChild: SizedBox(
                              height: 75,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      TextWidget(
                                        text: status['status'] ?? "",
                                        fontSize: 16,
                                        color: ColorTheme.kBlack,
                                        height: 1,
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        width: 90,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            SvgPicture.asset(
                                              AssetsString.kCalender,
                                              colorFilter: const ColorFilter.mode(
                                                ColorTheme.kTextColor,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            TextWidget(
                                              text: status['statusupdateddate'].toString().toDateFormat(),
                                              fontSize: 10,
                                              color: ColorTheme.kTextColor,
                                              height: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Row(
                                    children: [
                                      const TextWidget(
                                        text: 'Updated By :',
                                        fontSize: 12,
                                        color: ColorTheme.kTextColor,
                                        height: 1,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      TextWidget(
                                        text: status['updateby'],
                                        fontSize: 12,
                                        color: ColorTheme.kTextColor,
                                        height: 1,
                                      ),
                                    ],
                                  ),
                                ],
                              ).paddingOnly(bottom: 12, top: 12, left: 16),
                            ),
                          ).paddingSymmetric(horizontal: 12);
                        },
                      ),
                    ),
              // if (!sizingInformation.isMobile) ...[
              //   const SizedBox(height: 16),
              //   Row(
              //     mainAxisAlignment: MainAxisAlignment.end,
              //     children: [
              //       CustomButton(
              //         title: 'Close',
              //         buttonColor: ColorTheme.kBlack,
              //         fontColor: ColorTheme.kWhite,
              //         showBoxBorder: true,
              //         height: 34,
              //         width: 80,
              //         borderRadius: 5,
              //         onTap: () {
              //           Get.back();
              //         },
              //       ),
              //     ],
              //   ),
              // ]
            ],
          ),
        ).paddingAll(20);
      }),
    );
  }

  Widget timelineTile({
    bool isFirst = false,
    bool isLast = false,
    bool aboveTrue = false,
    required msgString,
    required dateString,
    required svgString,
  }) {
    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      alignment: TimelineAlign.start,
      beforeLineStyle: LineStyle(color: aboveTrue ? ColorTheme.kWarnColor : ColorTheme.kGrey, thickness: 2),
      indicatorStyle: IndicatorStyle(
          indicator: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(shape: BoxShape.circle, color: aboveTrue ? ColorTheme.kBlack : ColorTheme.kWhite, border: Border.all(color: aboveTrue ? ColorTheme.kWarnColor : ColorTheme.kGrey, width: 1.5)),
            child: SvgPicture.network(
              svgString,
              colorFilter: ColorFilter.mode(aboveTrue ? ColorTheme.kWhite : ColorTheme.kGrey, BlendMode.srcIn),
            ).paddingAll(6),
          ),
          padding: EdgeInsets.zero,
          width: 35,
          height: 35),
      endChild: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dateString.toString().isNotNullOrEmpty)
            TextWidget(
              text: dateString ?? "",
            ),
          TextWidget(
            text: msgString ?? "",
            fontSize: 14,
            color: aboveTrue ? ColorTheme.kBlack : ColorTheme.kGrey,
          ),
        ],
      ).paddingOnly(bottom: 16, top: 16, left: 16),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
// import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
// import 'package:timeline_tile/timeline_tile.dart';
//
// import '../../components/customs/custom_button.dart';
// import '../../style/theme_const.dart';
//
// class StatusHistoryDialog extends StatelessWidget {
//   final Map data;
//   final List statusList;
//
//   const StatusHistoryDialog({
//     super.key,
//     required this.data,
//     required this.statusList,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     bool aboveNodes = true;
//     return Dialog(
//       surfaceTintColor: ColorTheme.kWhite,
//       backgroundColor: ColorTheme.kWhite,
//       alignment: Alignment.topRight,
//       insetPadding: EdgeInsets.zero,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: SizedBox(
//         width: 400,
//         height: Get.height,
//         child: SizedBox(
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const TextWidget(
//                     text: "Status History",
//                     fontSize: 16,
//                     textAlign: TextAlign.left,
//                     color: ColorTheme.kBlack,
//                     fontWeight: FontTheme.notoSemiBold,
//                   ).paddingOnly(left: 4, bottom: 4),
//                   Container(
//                     padding: EdgeInsets.zero,
//                     decoration: BoxDecoration(
//                       color: ColorTheme.kBlack.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                     child: IconButton(
//                       onPressed: () {
//                         Get.back();
//                       },
//                       splashColor: ColorTheme.kWhite,
//                       hoverColor: ColorTheme.kWhite.withOpacity(0.1),
//                       splashRadius: 20,
//                       constraints: const BoxConstraints(),
//                       padding: EdgeInsets.zero,
//                       icon: const Icon(Icons.clear_rounded),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: statusList.length,
//                   itemBuilder: (context, index) {
//                     final status = statusList[index];
//
//                     bool currentNode = aboveNodes;
//
//                     if (aboveNodes && data["tenantstatusid"] == status["_id"]) {
//                       aboveNodes = false;
//                     }
//
//                     return TimelineTile(
//                       isFirst: index == 0,
//                       isLast: index == statusList.length - 1,
//                       alignment: TimelineAlign.start,
//                       beforeLineStyle: LineStyle(
//                         color: aboveNodes
//                             ? ColorTheme.kBlack
//                             : currentNode
//                                 ? ColorTheme.kBlack
//                                 : ColorTheme.kGrey,
//                         thickness: 2,
//                       ),
//                       indicatorStyle: IndicatorStyle(
//                         indicator: Container(
//                           width: aboveNodes
//                               ? 35
//                               : currentNode
//                                   ? 45
//                                   : 35,
//                           height: aboveNodes
//                               ? 35
//                               : currentNode
//                                   ? 45
//                                   : 35,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: aboveNodes
//                                 ? ColorTheme.kBlack
//                                 : currentNode
//                                     ? ColorTheme.kWarnColor
//                                     : ColorTheme.kWhite,
//                             border: Border.all(
//                               color: aboveNodes
//                                   ? ColorTheme.kBlack
//                                   : currentNode
//                                       ? ColorTheme.kWarnColor
//                                       : ColorTheme.kGrey,
//                               width: 1.5,
//                             ),
//                           ),
//                           child: SvgPicture.network(
//                             status['image'] ?? '',
//                             colorFilter: ColorFilter.mode(
//                               currentNode ? ColorTheme.kWhite : ColorTheme.kGrey,
//                               BlendMode.srcIn,
//                             ),
//                           ).paddingAll(7),
//                         ),
//                         padding: EdgeInsets.zero,
//                         width: aboveNodes
//                             ? 35
//                             : currentNode
//                                 ? 45
//                                 : 35,
//                         height: aboveNodes
//                             ? 35
//                             : currentNode
//                                 ? 45
//                                 : 35,
//                       ),
//                       endChild: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           if ((data[status['_id'] + '_date']).toString().isNotNullOrEmpty)
//                             TextWidget(
//                               text: (data[status['_id'] + '_date']).toString().toDateFormat(),
//                               fontSize: aboveNodes
//                                   ? 10
//                                   : currentNode
//                                       ? 12
//                                       : 10,
//                               color: currentNode ? ColorTheme.kBlack : ColorTheme.kGrey,
//                             ),
//                           TextWidget(
//                             text: status['status'] ?? "",
//                             fontSize: aboveNodes
//                                 ? 12
//                                 : currentNode
//                                     ? 16
//                                     : 12,
//                             color: currentNode ? ColorTheme.kBlack : ColorTheme.kGrey,
//                           ),
//                         ],
//                       ).paddingOnly(bottom: 12, top: 12, left: 16),
//                     ).paddingOnly(
//                         left: aboveNodes
//                             ? 8
//                             : currentNode
//                                 ? 3
//                                 : 8);
//                   },
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   CustomButton(
//                     title: 'Close',
//                     buttonColor: ColorTheme.kBlack,
//                     fontColor: ColorTheme.kWhite,
//                     showBoxBorder: true,
//                     height: 34,
//                     width: 80,
//                     borderRadius: 5,
//                     onTap: () {
//                       Get.back();
//                     },
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ).paddingAll(20),
//       ),
//     );
//   }
//
//   Widget timelineTile({
//     bool isFirst = false,
//     bool isLast = false,
//     bool aboveTrue = false,
//     required msgString,
//     required dateString,
//     required svgString,
//   }) {
//     return TimelineTile(
//       isFirst: isFirst,
//       isLast: isLast,
//       alignment: TimelineAlign.start,
//       beforeLineStyle: LineStyle(color: aboveTrue ? ColorTheme.kWarnColor : ColorTheme.kGrey, thickness: 2),
//       indicatorStyle: IndicatorStyle(
//           indicator: Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//                 shape: BoxShape.circle, color: aboveTrue ? ColorTheme.kBlack : ColorTheme.kWhite, border: Border.all(color: aboveTrue ? ColorTheme.kWarnColor : ColorTheme.kGrey, width: 1.5)),
//             child: SvgPicture.network(
//               svgString,
//               colorFilter: ColorFilter.mode(aboveTrue ? ColorTheme.kWhite : ColorTheme.kGrey, BlendMode.srcIn),
//             ).paddingAll(6),
//           ),
//           padding: EdgeInsets.zero,
//           width: 35,
//           height: 35),
//       endChild: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (dateString.toString().isNotNullOrEmpty)
//             TextWidget(
//               text: dateString ?? "",
//             ),
//           TextWidget(
//             text: msgString ?? "",
//             fontSize: 14,
//             color: aboveTrue ? ColorTheme.kBlack : ColorTheme.kGrey,
//           ),
//         ],
//       ).paddingOnly(bottom: 16, top: 16, left: 16),
//     );
//   }
// }
