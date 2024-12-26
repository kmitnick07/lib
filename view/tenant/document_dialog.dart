import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/row_column_widget.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/helper/device_service.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../style/theme_const.dart';
import '../../utils/aws_service/file_data_model.dart';

class DocumentDialog extends StatelessWidget {
  final Map data;
  final String formName;

  const DocumentDialog({super.key, required this.data, required this.formName});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> extraDocuments = List<Map<String, dynamic>>.from(data['tenantotherdocuments'] ?? []);
    return ResponsiveBuilder(
      builder: (context, sizingInformation) => Container(
        color: ColorTheme.kWhite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntrinsicHeight(
                child: RowColumnWidget(
                  grouptype: sizingInformation.isDesktop ? GroupType.row : GroupType.column,
                  children: [
                    expandedRowColumn(
                      sizingInformation.isDesktop ? 2 : 1,
                      !sizingInformation.isMobile,
                      RowColumnWidget(
                        grouptype: sizingInformation.isMobile ? GroupType.column : GroupType.row,
                        children: [
                          expandedRowColumn(
                            1,
                            !sizingInformation.isMobile,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TextWidget(
                                  text: "Consents | Agreements",
                                  fontSize: 18,
                                  fontWeight: FontTheme.notoSemiBold,
                                ).paddingOnly(bottom: 16),
                                documentRow(
                                  title: "Attended Common Consent",
                                  imgName: data['attendedcommonconsent'] == 1 ? 'YES' : 'NO',
                                ),
                                ...List.generate(((data['commonconsent'] ?? []) as List).where((element) => element['referralcode'].toString().isNotNullOrEmpty).length, (index) {
                                  Map obj = ((data['commonconsent'] ?? []) as List).where((element) => element['referralcode'].toString().isNotNullOrEmpty).toList()[index];
                                  return documentRow(
                                    title: obj['title'] ?? '',
                                    onTapHistory: null,
                                    imgName: obj['referralcode'] ?? '',
                                    // onTapHistory: (data['commonconsentfile'] ?? {})['url']
                                    //     .toString()
                                    //     .isNotNullOrEmpty
                                    //     ? () {
                                    // }
                                    //     : null,
                                    // status: data['commonconsentname'],
                                  );
                                }),
                                const SizedBox(
                                  height: 16,
                                ),
                                documentRow(
                                  title: "Individual Consent",
                                  imgName: data['individualconsentfile']?['name'],
                                  onTapHistory: (data['individualconsentfile'] ?? {})['url'].toString().isNotNullOrEmpty
                                      ? () {
                                          IISMethods().getDocumentHistory(tenantId: data["_id"], documentType: "Individual Consent", pagename: formName);
                                        }
                                      : null,
                                  status: data['individualconsentname'],
                                ),
                                documentRow(
                                  title: "Individual Agreement",
                                  imgName: data['individualagreementfile']?['name'],
                                  onTapHistory: (data['individualagreementfile'] ?? {})['url'].toString().isNotNullOrEmpty
                                      ? () {
                                          IISMethods().getDocumentHistory(tenantId: data["_id"], documentType: "Individual Agreement", pagename: formName);
                                        }
                                      : null,
                                  status: data['individualagreementname'],
                                ),
                              ],
                            ),
                          ),
                          const VerticalDivider(),
                          expandedRowColumn(
                            1,
                            !sizingInformation.isMobile,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (((data['generalbodyresolution'] ?? []) as List).where((element) => element['referralcode'].toString().isNotNullOrEmpty).isNotEmpty)
                                  const TextWidget(
                                    text: 'General Body Resolution',
                                    fontSize: 18,
                                    fontWeight: FontTheme.notoSemiBold,
                                  ).paddingOnly(bottom: 16),
                                documentRow(
                                  title: "Attended General Body Resolution",
                                  imgName: data['attendedgeneralbodyresolution'] == 1 ? 'YES' : 'NO',
                                ),
                                ...List.generate(((data['generalbodyresolution'] ?? []) as List).where((element) => element['referralcode'].toString().isNotNullOrEmpty).length, (index) {
                                  Map obj = ((data['generalbodyresolution'] ?? []) as List).where((element) => element['referralcode'].toString().isNotNullOrEmpty).toList()[index];
                                  return documentRow(
                                    title: obj['title'] ?? '',
                                    onTapHistory: null,
                                    imgName: obj['referralcode'] ?? '',
                                  );
                                }),
                                documentRow(
                                  title: "Survey Slip 2000",
                                  imgName: data['surveyslip']?['name'],
                                  onTapHistory: (data['surveyslip'] ?? {})['url'].toString().isNotNullOrEmpty
                                      ? () {
                                          IISMethods().getDocumentHistory(tenantId: data["_id"], documentType: "Survey Slip", pagename: formName);
                                        }
                                      : null,
                                ),
                                documentRow(
                                  title: "Hut Photo Pass",
                                  imgName: data['hutphotopass']?['name'],
                                  onTapHistory: (data['hutphotopass'] ?? {})['url'].toString().isNotNullOrEmpty
                                      ? () {
                                          IISMethods().getDocumentHistory(tenantId: data["_id"], documentType: "Hut Photo Pass", pagename: formName);
                                        }
                                      : null,
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                if (extraDocuments.isNotNullOrEmpty)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const TextWidget(
                                              text: "Extra Documents",
                                              fontSize: 18,
                                              fontWeight: FontTheme.notoSemiBold,
                                            ),
                                            InkResponse(
                                              onTap: () {
                                                IISMethods().getDocumentHistory(tenantId: data["_id"], documentType: "Tenant Other Documents", pagename: formName);
                                              },
                                              child: const Icon(
                                                Icons.history_rounded,
                                                size: 20,
                                              ),
                                            )
                                          ],
                                        ).paddingOnly(bottom: 16),
                                        ...List.generate(extraDocuments.length, (index) {
                                          return documentRow(
                                            title: extraDocuments[index]['name'] ?? '',
                                            imgName: extraDocuments[index]['doc']?['name'] ?? '',
                                            onTapHistory: (extraDocuments[index]['doc'] ?? {})['url'].toString().isNotNullOrEmpty
                                                ? () {
                                                    documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(extraDocuments[index]['doc'] ?? {})));
                                                  }
                                                : null,
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TextWidget(
                            text: "Other Documents",
                            fontSize: 18,
                            fontWeight: FontTheme.notoSemiBold,
                          ).paddingOnly(bottom: 16),
                          documentRow(
                            title: "Annexure Survey",
                            imgName: data['annexuresurveydoc']?['name'],
                            onTapHistory: (data['annexuresurveydoc'] ?? {})['url'].toString().isNotNullOrEmpty
                                ? () {
                                    IISMethods().getDocumentHistory(tenantId: data["_id"], documentType: "Survey", pagename: formName);
                                  }
                                : null,
                          ),
                          documentRow(
                            title: "Rent Agreement",
                            imgName: data['rentagreementdoc']?['name'],
                            onTapHistory: (data['rentagreementdoc'] ?? {})['url'].toString().isNotNullOrEmpty
                                ? () {
                                    IISMethods().getDocumentHistory(tenantId: data["_id"], documentType: "Rent Agreement", pagename: formName);
                                  }
                                : null,
                          ),
                          documentRow(
                            title: "Dislocation Allowance",
                            imgName: data['dislocationallowancedoc']?['name'],
                            onTapHistory: (data['dislocationallowancedoc'] ?? {})['url'].toString().isNotNullOrEmpty
                                ? () {
                                    IISMethods().getDocumentHistory(tenantId: data["_id"], documentType: "Dislocation Allowance", pagename: formName);
                                  }
                                : null,
                          ),
                          if (data['handoverletter'].toString().isNotNullOrEmpty)
                            documentRow(
                              title: "Handover Letter",
                              imgName: data['handoverletter']?['name'],
                              onTapHistory: (data['handoverletter'] ?? {})['url'].toString().isNotNullOrEmpty
                                  ? () {
                                      IISMethods().getDocumentHistory(tenantId: data["_id"], documentType: "Handover Letter", pagename: formName);
                                    }
                                  : null,
                            ),
                          documentRow(
                            title: "House Tax",
                            imgName: data['housetaxdocument']?['name'],
                            onTapHistory: (data['housetaxdocument'] ?? {})['url'].toString().isNotNullOrEmpty
                                ? () {
                                    IISMethods().getDocumentHistory(tenantId: data["_id"], documentType: 'House Tax', pagename: formName);
                                  }
                                : null,
                          ),
                          documentRow(
                            title: "Water Connection Bill",
                            imgName: data['watertaxbilldocument']?['name'],
                            onTapHistory: (data['watertaxbilldocument'] ?? {})['url'].toString().isNotNullOrEmpty
                                ? () {
                                    IISMethods().getDocumentHistory(tenantId: data["_id"], documentType: 'Water Connection Bill', pagename: formName);
                                  }
                                : null,
                          ),
                          documentRow(
                            title: "Electric Bill",
                            imgName: data['elecricitybilldocument']?['name'],
                            onTapHistory: (data['elecricitybilldocument'] ?? {})['url'].toString().isNotNullOrEmpty
                                ? () {
                                    IISMethods().getDocumentHistory(tenantId: data["_id"], documentType: 'Electric Bill', pagename: formName);
                                  }
                                : null,
                          ),
                          documentRow(
                            title: "Gumasta License",
                            imgName: data['gumastalicenseimage']?['name'],
                            onTapHistory: (data['gumastalicenseimage'] ?? {})['url'].toString().isNotNullOrEmpty
                                ? () {
                                    IISMethods().getDocumentHistory(tenantId: data["_id"], documentType: 'Gumasta License', pagename: formName);
                                  }
                                : null,
                          ),
                          documentRow(
                            title: "Family NOC",
                            imgName: data['familynocimage']?['name'],
                            onTapHistory: (data['familynocimage'] ?? {})['url'].toString().isNotNullOrEmpty
                                ? () {
                                    IISMethods().getDocumentHistory(tenantId: data["_id"], documentType: 'Family NOC', pagename: formName);
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget documentRow({
    required String? title,
    required String? imgName,
    String? status,
    void Function()? onTapHistory,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (title != null) Flexible(child: TextWidget(text: title)),
            if (status != null)
              TextWidget(
                text: status,
                fontWeight: FontTheme.notoSemiBold,
              ),
          ],
        ).paddingAll(2),
        InkWell(
          onTap: onTapHistory,
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), border: Border.all(color: ColorTheme.kBorderColor)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: TextWidget(
                  text: imgName.isNullOrEmpty ? "NA" : imgName,
                  textOverflow: TextOverflow.ellipsis,
                )),
                onTapHistory.toString().isNullOrEmpty
                    ? const SizedBox.shrink()
                    : const Icon(
                        Icons.visibility,
                        size: 16,
                      )
              ],
            ).paddingSymmetric(vertical: 8, horizontal: 8),
          ),
        )
      ],
    ).paddingOnly(bottom: 4);
  }

  Widget expandedRowColumn(int flex, bool isRow, Widget child) {
    if (isRow) {
      return Expanded(flex: flex, child: child);
    } else {
      return child;
    }
  }
}
