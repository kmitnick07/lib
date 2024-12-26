import '../../config/config.dart';
import '../../style/string_const.dart';

class DeveloperJson {
  DeveloperJson._privateConstructor();

  static final DeveloperJson _instance = DeveloperJson._privateConstructor();

  factory DeveloperJson() => _instance;

  static designationFormFields(String formName) {
    switch (formName) {
      case 'team':
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'team',
          "formname": 'Team',
          "alias": 'team',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Team",
              "formFields": [
                {
                  'field': 'name',
                  'text': 'Team Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'teamleadid',
                  'text': 'Team Leader',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'required': true,
                  'defaultvisibility': true,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'tenantteamlead',
                  'masterdatafield': 'name',
                  'formdatafield': 'teamleadname',
                  'cleanable': true,
                  'searchable': true,
                  "masterdatadependancy": false,
                  'staticfilter': {'status': 1},
                },
                {
                  'field': 'teammember',
                  'text': 'Team Member',
                  'type': HtmlControls.kMultiSelectDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'gridsize': FieldSize.k375,
                  'required': true,
                  'masterdata': 'tenantexecutive',
                  'masterdatafield': 'name',
                  'concatinationmasterdatafield': 'employeeid',
                  'formdatafield': 'name',
                  'cleanable': true,
                  'searchable': false,
                  "masterdatadependancy": false,
                  'staticfilter': {'status': 1, 'needconcate': 1},
                },
                {
                  'field': 'status',
                  'text': 'Status',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'status',
                  'masterdataarray': Config.statusType,
                  'defaultvalue': 1,
                  'formdatafield': 'status',
                  'cleanable': true,
                  'searchable': true,
                  'onchangedata': ['statusid'],
                  'masterdatadependancy': false,
                },
              ]
            }
          ]
        };

      case "user":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'user',
          "formname": 'User',
          "alias": 'user',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Edit",
              "formFields": [
                {
                  'field': 'photo',
                  'text': 'Photo',
                  'type': HtmlControls.kAvatarPicker,
                  'filetypes': ['png', 'jpg', 'jpeg'],
                  'uploadtext': "Upload",
                  'uploadedtext': "Upload New",
                  'resettext': StringConst.kResetBtnTxt,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': false,
                  'gridsize': FieldSize.k400,
                  'note': "Allowed JPG or PNG. Max size of 800K",
                },
                {
                  'field': 'name',
                  'text': 'Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
                  'primaryField': true
                },
                {
                  'field': 'employeeid',
                  'text': 'UID',
                  'type': HtmlControls.kNumberInput,
                  'maxlength': 6,
                  'minlength': 6,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
                  'primaryField': true
                },
                {
                  'field': 'userrole',
                  'text': 'Role',
                  'type': HtmlControls.kMultiSelectDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
                  'masterdata': 'userrole',
                  'masterdatafield': 'userrole',
                  'formdatafield': 'userrole',
                  'cleanable': true,
                  'searchable': true,
                  'masterdatadependancy': false,
                  'staticfilter': {'status': 1},
                },
                {
                  'field': 'team',
                  'text': 'Select Team',
                  'type': HtmlControls.kMultiSelectDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'gridsize': FieldSize.k400,
                  'required': false,
                  'masterdata': 'team',
                  'masterdatafield': 'name',
                  'formdatafield': 'name',
                  'cleanable': true,
                  'searchable': false,
                  "masterdatadependancy": false,
                  'staticfilter': {'status': 1},
                },
                {
                  'field': 'contact',
                  'text': 'Official Contact',
                  'type': HtmlControls.kNumberInput,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'maxlength': 10,
                  'minlength': 10,
                  'gridsize': FieldSize.k400,
                },
                {
                  'field': 'email',
                  'text': 'Official Email',
                  'type': HtmlControls.kInputText,
                  'regex':
                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
                },
                {
                  'field': 'status',
                  'text': 'Status',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
                  'masterdata': 'status',
                  'masterdataarray': Config.statusType,
                  'defaultvalue': 1,
                  'formdatafield': 'status',
                  'cleanable': true,
                  'searchable': true,
                  'masterdatadependancy': false,
                },
              ]
            }
          ],
        };

      case "userrole":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'userrole',
          "formname": 'Userrole',
          "alias": 'userrole',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Userrole",
              "formFields": [
                {
                  'field': 'userrole',
                  'text': 'Userrole',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
                },
                {
                  'field': 'status',
                  'text': 'Status',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
                  'masterdata': 'status',
                  'masterdataarray': Config.statusType,
                  'defaultvalue': 1,
                  'formdatafield': 'status',
                  'cleanable': true,
                  'searchable': true,
                  'masterdatadependancy': false,
                },
                {
                  'field': 'canapplogin',
                  'text': 'App Login Access',
                  'type': HtmlControls.kCheckBox,
                  'disabled': false,
                  'required': false,
                  'defaultvisibility': true,
                  'gridsize': FieldSize.k400,
                },
                {
                  'field': 'canweblogin',
                  'text': 'Web Login Access',
                  'type': HtmlControls.kCheckBox,
                  'disabled': false,
                  'required': false,
                  'defaultvisibility': true,
                  'gridsize': FieldSize.k400,
                },
              ]
            }
          ],
        };

      case "developer":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'developer',
          "formname": 'Developer',
          "alias": 'developer',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Edit",
              "formFields": [
                {
                  'field': 'logoimage',
                  'text': 'Logo',
                  'type': HtmlControls.kAvatarPicker,
                  'filetypes': ['png', 'jpg', 'jpeg'],
                  'uploadtext': "Upload",
                  'uploadedtext': "Upload New",
                  'resettext': StringConst.kResetBtnTxt,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': false,
                  'gridsize': FieldSize.k400,
                  'note': "Allowed JPG or PNG. Max size of 800K",
                },
                {
                  'field': 'name',
                  'text': 'Developer Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
                },
                {
                  'field': 'shortcode',
                  'text': 'Short Code',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
                },
                {
                  'field': 'address',
                  'text': 'Address',
                  'type': HtmlControls.kInputTextArea,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
                },
                {
                  'field': 'gstin',
                  'text': 'GSTIN',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'autocapital': true,
                  'gridsize': FieldSize.k400,
                  'regex': r'\d{2}[A-Z]{5}\d{4}[A-Z]{1}[A-Z\d]{1}[Z]{1}[A-Z\d]{1}',
                },
                {
                  'field': 'pan',
                  'text': 'PAN',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'autocapital': true,

                  'gridsize': FieldSize.k400,
                  'regex': r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$',
                },
                {
                  'field': 'phone',
                  'text': 'Phone',
                  'type': HtmlControls.kNumberInput,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
                  'maxlength': 10,
                  'minlength': 10,
                },
                {
                  'field': 'email',
                  'text': 'Email',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
                  'regex':
                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
                },
                {
                  'field': 'status',
                  'text': 'Status',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
                  'masterdata': 'status',
                  'masterdataarray': Config.statusType,
                  'defaultvalue': 1,
                  'formdatafield': 'status',
                  'cleanable': true,
                  'searchable': true,
                  'onchangedata': ['statusid'],
                  'masterdatadependancy': false,
                },
              ]
            }
          ],
        };
    }
  }
}
