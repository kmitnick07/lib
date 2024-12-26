import 'package:flutter/material.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

class HtmlEditor extends StatefulWidget {
  const HtmlEditor({super.key});

  @override
  State<HtmlEditor> createState() => _HtmlEditorState();
}

class _HtmlEditorState extends State<HtmlEditor> {
  late QuillEditorController controller;

  final customToolBarList = [
    ToolBarStyle.bold,
    ToolBarStyle.italic,
    ToolBarStyle.underline,
    ToolBarStyle.strike,
    ToolBarStyle.blockQuote,
    ToolBarStyle.codeBlock,
    ToolBarStyle.indentMinus,
    ToolBarStyle.indentAdd,
    ToolBarStyle.directionRtl,
    ToolBarStyle.directionLtr,
    ToolBarStyle.headerOne,
    ToolBarStyle.headerTwo,
    ToolBarStyle.color,
    ToolBarStyle.background,
    ToolBarStyle.align,
    ToolBarStyle.listOrdered,
    ToolBarStyle.listBullet,
    ToolBarStyle.size,
    ToolBarStyle.link,
    ToolBarStyle.image,
    ToolBarStyle.video,
    ToolBarStyle.clean,
    ToolBarStyle.undo,
    ToolBarStyle.redo,
    ToolBarStyle.clearHistory,
    ToolBarStyle.addTable,
    ToolBarStyle.editTable,
    ToolBarStyle.separator,
  ];

  @override
  void initState() {
    controller = QuillEditorController();

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            ToolBar(
              toolBarConfig: customToolBarList,
              padding: const EdgeInsets.all(8),
              iconSize: 22,
              activeIconColor: Colors.blueAccent,
              controller: controller,
              crossAxisAlignment: WrapCrossAlignment.start,
              direction: Axis.horizontal,
            ),
            FloatingActionButton(onPressed: () {
              controller.setText(
                  "<p><strong>[Offer Letter Date]</strong></p><p><br></p><p><em>[Name]</em></p><p><u>[Address Line 1]</u></p><p><s>[Address Line 2]</s></p><blockquote>[City], [State], [PIN Code]</blockquote><p><br></p><h1 class=\"ql-indent-2\">Dear [Mr./Miss./Mrs./Ms.] [Name],&nbsp;</h1><p>&nbsp;</p><h2>Congratulations! We are pleased to confirm that you have been selected to work for [Company Name]. We are delighted to make you the following job offer.&nbsp;</h2><p>&nbsp;</p><p>The position we are offering you is that of [Job Title] at a monthly salary of [Salary per month] with an annual cost to company [Annual CTC]. This position reports to [Supervisor Title], [Supervisor Name]. Your working hours will be from [9AM to 6PM], [Starting Week Day] to [Ending Week Day]. &nbsp;</p><p>&nbsp;</p><p>Benefits for the position include: (Use if relevant to the position)</p><p>Benefit A (Casual Leave of 12 days per annum) </p><p>Benefit B (Employer State Insurance Corporation ESIC Coverage)</p><p>Benefit C</p><p><br></p><p>We would like you to start work on [Desired starting date] at [Desired starting time]. Please report to [Name of person to report on start date], for documentation and orientation. If this date is not acceptable, please contact me immediately.&nbsp;</p><p>&nbsp;</p><p>Please sign the enclosed copy of this letter and return it to me by [Last date for offer acceptance] to indicate your acceptance of this offer.&nbsp;</p><p>&nbsp;</p><p>We are confident you will be able to make a significant contribution to the success of our [Company Name] and look forward to working with you.&nbsp;</p><p>&nbsp;</p><p>Sincerely,&nbsp;</p><p>&nbsp;</p><p><br></p><p><br></p><p>(Name of person authorized to make offer)&nbsp;</p><p>(Position)&nbsp;</p><p>(Company)<br></p>listening to <p><strong>[Offer Letter Date]</strong></p><p><br></p><p><em>[Name]</em></p><p><u>[Address Line 1]</u></p><p><s>[Address Line 2]</s></p><blockquote>[City], [State], [PIN Code]</blockquote><p><br></p><h1 class=\"ql-indent-2\">Dear [Mr./Miss./Mrs./Ms.] [Name],&nbsp;</h1><p>&nbsp;</p><h2>Congratulations! We are pleased to confirm that you have been selected to work for [Company Name]. We are delighted to make you the following job offer.&nbsp;</h2><p>&nbsp;</p><p>The position we are offering you is that of [Job Title] at a monthly salary of [Salary per month] with an annual cost to company [Annual CTC]. This position reports to [Supervisor Title], [Supervisor Name]. Your working hours will be from [9AM to 6PM], [Starting Week Day] to [Ending Week Day]. &nbsp;</p><p>&nbsp;</p><p>Benefits for the position include: (Use if relevant to the position)</p><p>Benefit A (Casual Leave of 12 days per annum) </p><p>Benefit B (Employer State Insurance Corporation ESIC Coverage)</p><p>Benefit C</p><p><br></p><p>We would like you to start work on [Desired starting date] at [Desired starting time]. Please report to [Name of person to report on start date], for documentation and orientation. If this date is not acceptable, please contact me immediately.&nbsp;</p><p>&nbsp;</p><p>Please sign the enclosed copy of this letter and return it to me by [Last date for offer acceptance] to indicate your acceptance of this offer.&nbsp;</p><p>&nbsp;</p><p>We are confident you will be able to make a significant contribution to the success of our [Company Name] and look forward to working with you.&nbsp;</p><p>&nbsp;</p><p>Sincerely,&nbsp;</p><p>&nbsp;</p><p><br></p><p><br></p><p>(Name of person authorized to make offer)&nbsp;</p><p>(Position)&nbsp;</p><p>(Company)<br></p>");
            }),
            FloatingActionButton(onPressed: () {
              IISMethods().convertHtmlToPdf(
                  htmlHeaderContent: "<p><strong>Headder</strong></p>",
                  htmlFooterContent: "<p><strong>Footer</strong></p>",
                  htmlBodyContent:
                      "<p><strong>[Offer Letter Date]</strong></p><p><br></p><p><em>[Name]</em></p><p><u>[Address Line 1]</u></p><p><s>[Address Line 2]</s></p><blockquote>[City], [State], [PIN Code]</blockquote><p><br></p><h1 class=\"ql-indent-2\">Dear [Mr./Miss./Mrs./Ms.] [Name],&nbsp;</h1><p>&nbsp;</p><h2>Congratulations! We are pleased to confirm that you have been selected to work for [Company Name]. We are delighted to make you the following job offer.&nbsp;</h2><p>&nbsp;</p><p>The position we are offering you is that of [Job Title] at a monthly salary of [Salary per month] with an annual cost to company [Annual CTC]. This position reports to [Supervisor Title], [Supervisor Name]. Your working hours will be from [9AM to 6PM], [Starting Week Day] to [Ending Week Day]. &nbsp;</p><p>&nbsp;</p><p>Benefits for the position include: (Use if relevant to the position)</p><p>Benefit A (Casual Leave of 12 days per annum) </p><p>Benefit B (Employer State Insurance Corporation ESIC Coverage)</p><p>Benefit C</p><p><br></p><p>We would like you to start work on [Desired starting date] at [Desired starting time]. Please report to [Name of person to report on start date], for documentation and orientation. If this date is not acceptable, please contact me immediately.&nbsp;</p><p>&nbsp;</p><p>Please sign the enclosed copy of this letter and return it to me by [Last date for offer acceptance] to indicate your acceptance of this offer.&nbsp;</p><p>&nbsp;</p><p>We are confident you will be able to make a significant contribution to the success of our [Company Name] and look forward to working with you.&nbsp;</p><p>&nbsp;</p><p>Sincerely,&nbsp;</p><p>&nbsp;</p><p><br></p><p><br></p><p>(Name of person authorized to make offer)&nbsp;</p><p>(Position)&nbsp;</p><p>(Company)<br></p>listening to <p><strong>[Offer Letter Date]</strong></p><p><br></p><p><em>[Name]</em></p><p><u>[Address Line 1]</u></p><p><s>[Address Line 2]</s></p><blockquote>[City], [State], [PIN Code]</blockquote><p><br></p><h1 class=\"ql-indent-2\">Dear [Mr./Miss./Mrs./Ms.] [Name],&nbsp;</h1><p>&nbsp;</p><h2>Congratulations! We are pleased to confirm that you have been selected to work for [Company Name]. We are delighted to make you the following job offer.&nbsp;</h2><p>&nbsp;</p><p>The position we are offering you is that of [Job Title] at a monthly salary of [Salary per month] with an annual cost to company [Annual CTC]. This position reports to [Supervisor Title], [Supervisor Name]. Your working hours will be from [9AM to 6PM], [Starting Week Day] to [Ending Week Day]. &nbsp;</p><p>&nbsp;</p><p>Benefits for the position include: (Use if relevant to the position)</p><p>Benefit A (Casual Leave of 12 days per annum) </p><p>Benefit B (Employer State Insurance Corporation ESIC Coverage)</p><p>Benefit C</p><p><br></p><p>We would like you to start work on [Desired starting date] at [Desired starting time]. Please report to [Name of person to report on start date], for documentation and orientation. If this date is not acceptable, please contact me immediately.&nbsp;</p><p>&nbsp;</p><p>Please sign the enclosed copy of this letter and return it to me by [Last date for offer acceptance] to indicate your acceptance of this offer.&nbsp;</p><p>&nbsp;</p><p>We are confident you will be able to make a significant contribution to the success of our [Company Name] and look forward to working with you.&nbsp;</p><p>&nbsp;</p><p>Sincerely,&nbsp;</p><p>&nbsp;</p><p><br></p><p><br></p><p>(Name of person authorized to make offer)&nbsp;</p><p>(Position)&nbsp;</p><p>(Company)<br></p>");
            }),
            Expanded(
              child: QuillHtmlEditor(
                controller: controller,
                isEnabled: true,
                ensureVisible: false,
                minHeight: 500,
                autoFocus: false,
                hintTextAlign: TextAlign.start,
                padding: const EdgeInsets.only(left: 10, top: 10),
                hintTextPadding: const EdgeInsets.only(left: 20),
                inputAction: InputAction.newline,
                onEditingComplete: (s) => debugPrint('Editing completed '),
                onFocusChanged: (focus) {},
                onTextChanged: (text) => debugPrint('widget text change '),
                onEditorCreated: () {
                  debugPrint('Editor has been loaded');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
