import '../../config/config.dart';
import '../../style/string_const.dart';

class MasterJson {
  MasterJson._privateConstructor();

  static final MasterJson _instance = MasterJson._privateConstructor();

  factory MasterJson() => _instance;

  static designationFormFields(String formName) {
    switch (formName) {
      case 'icon':
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'icon',
          "formname": 'Icon',
          "dataview": "tab",
          "alias": 'icon',
          "formfields": [
            {
              "tab": "Icon",
              "formFields": [
                {
                  'field': 'iconname',
                  'text': 'Icon Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'iconimage',
                  'text': 'Icon',
                  'type': HtmlControls.kFilePicker,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'filetypes': ['svg'],
                  'gridsize': FieldSize.k375,
                },
              ]
            },
          ]
        };

      case 'module':
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'module',
          "formname": 'Module',
          "alias": 'module',
          "dataview": "tab",
          "formfields": [
            {
              "tab": "Module",
              "formFields": [
                {
                  'field': 'moduletype',
                  'text': 'Module Type',
                  'type': HtmlControls.kMultiSelectDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'gridsize': FieldSize.k375,
                  'required': true,
                  'masterdata': 'moduletype',
                  'masterdatafield': 'moduletype',
                  'formdatafield': 'moduletype',
                  'cleanable': true,
                  'searchable': false,
                  "masterdatadependancy": false,
                },
                {
                  'field': 'module',
                  'text': 'Module Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'iconid',
                  'text': 'Icon',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'required': true,
                  'defaultvisibility': true,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'icon',
                  'masterdatafield': 'iconname',
                  'formdatafield': 'icon',
                  'cleanable': true,
                  'searchable': true,
                  "masterdatadependancy": false,
                },
              ]
            }
          ]
        };

      case 'menu':
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'menu',
          "formname": 'Menu',
          "alias": 'menu',
          "dataview": "tab",
          "formfields": [
            {
              "tab": "Menu",
              "formFields": [
                {
                  'field': 'menuname',
                  'text': 'Menu Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'formname',
                  'text': 'Form Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'alias',
                  'text': 'Alias Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'disableonedit': true,
                  'required': true,
                  'defaultvisibility': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'iconid',
                  'text': 'Icon',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'required': false,
                  'defaultvisibility': true,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'icon',
                  'masterdatafield': 'iconname',
                  'formdatafield': 'icon',
                  'cleanable': true,
                  'searchable': true,
                  'projection': {
                    'icon': 1,
                    'iconclass': 1,
                    'iconname': 1,
                    'iconstyle': 1,
                    'iconunicode': 1,
                    '_id': 1,
                  }
                },
                {
                  'field': 'moduletype',
                  'text': 'Module Type',
                  'type': HtmlControls.kMultiSelectDropDown,
                  'disabled': false,
                  'required': true,
                  'defaultvisibility': true,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'moduletype',
                  'masterdatafield': 'moduletype',
                  'formdatafield': 'moduletype',
                  'cleanable': true,
                  'searchable': false,
                },
                {
                  'field': 'defaultopen',
                  'text': 'Default Open',
                  'type': HtmlControls.kCheckBox,
                  'disabled': false,
                  'required': false,
                  'defaultvisibility': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'displayinsidebar',
                  'text': 'Display In Sidebar',
                  'type': HtmlControls.kCheckBox,
                  'disabled': false,
                  'required': false,
                  'defaultvisibility': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'canhavechild',
                  'text': 'Can Have Child',
                  'type': HtmlControls.kCheckBox,
                  'disabled': false,
                  'required': false,
                  'defaultvisibility': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'containright',
                  'text': 'Contain Right',
                  'type': HtmlControls.kCheckBox,
                  'disabled': false,
                  'required': false,
                  'defaultvisibility': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'ismaster',
                  'text': 'Show in Master Menu',
                  'type': HtmlControls.kCheckBox,
                  'disabled': false,
                  'required': false,
                  'defaultvisibility': true,
                  'gridsize': FieldSize.k375,
                },
              ]
            }
          ]
        };

      case 'state':
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'state',
          "formname": 'State',
          "alias": 'state',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "State",
              "formFields": [
                {
                  'field': 'state',
                  'text': 'State Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'shortcode',
                  'text': 'Short Code',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
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

      case "city":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'city',
          "formname": 'City',
          "alias": 'city',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "City",
              "formFields": [
                {
                  'field': 'city',
                  'text': 'City Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'stateid',
                  'text': 'State Name',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'state',
                  'masterdatafield': 'state',
                  'formdatafield': 'state',
                  'cleanable': true,
                  'searchable': true,
                  'onchangedata': ['stateid'],
                  'masterdatadependancy': false,
                  'staticfilter': {'status': 1},
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
          ],
        };

      case "pincode":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'pincode',
          "formname": 'Pincode',
          "alias": 'pincode',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Pincode",
              "formFields": [
                {
                  'field': 'pincode',
                  'text': 'Pincode',
                  'type': HtmlControls.kNumberInput,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                  'maxlength': 6,
                  'minlength': 6,
                },
                {
                  'field': 'stateid',
                  'text': 'State',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'state',
                  'masterdatafield': 'state',
                  'formdatafield': 'state',
                  'cleanable': true,
                  'searchable': true,
                  'onchangefill': ['cityid'],
                  'onchangedata': ['stateid'],
                  'staticfilter': {'status': 1},
                },
                {
                  'field': 'cityid',
                  'text': 'City',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'city',
                  'masterdatafield': 'city',
                  'formdatafield': 'city',
                  'cleanable': true,
                  'searchable': true,
                  'dependentfilter': {
                    'stateid': 'stateid',
                  },
                  'masterdatadependancy': true,
                  'staticfilter': {'status': 1},
                },
                {
                  'field': 'area',
                  'text': 'Area',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
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
          ],
        };

      case "projectlocation":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'projectlocation',
          "formname": 'Project Location',
          "alias": 'projectlocation',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Project Location",
              "formFields": [
                {
                  'field': 'name',
                  'text': 'Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'pincodeid',
                  'text': 'Pincode',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'pincode',
                  'masterdatafield': 'pincode',
                  'formdatafield': 'pincode',
                  'cleanable': true,
                  'searchable': true,
                  'onchangedata': ['pincodeid'],
                  'masterdatadependancy': false,
                  'staticfilter': {'status': 1},
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
          ],
        };

      case "constructionstage":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'constructionstage',
          "formname": 'Construction Stage',
          "alias": 'constructionstage',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Construction Stage",
              "formFields": [
                {
                  'field': 'name',
                  'text': 'Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
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
          ],
        };

      case "clustername":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'clustername',
          "formname": 'Cluster Name',
          "alias": 'clustername',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Cluster Name",
              "formFields": [
                {
                  'field': 'name',
                  'text': 'Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'clustermanagerid',
                  'text': 'Cluster Manager',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'clustermanager',
                  'masterdatafield': 'name',
                  'formdatafield': 'clustermanagername',
                  'cleanable': true,
                  'searchable': true,
                  'onchangedata': ['constructionstageid'],
                  'masterdatadependancy': false,
                  'staticfilter': {'status': 1},
                },
                {
                  'field': 'tenantproject',
                  'text': 'Tenant Projects',
                  'type': HtmlControls.kMultiSelectDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'gridsize': FieldSize.k375,
                  'required': true,
                  'masterdata': 'tenantproject',
                  'masterdatafield': 'name',
                  'formdatafield': 'tenantproject',
                  'cleanable': true,
                  'searchable': false,
                  "masterdatadependancy": false,
                  'staticfilter': {'status': 1},
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
          ],
        };

      case "projecttype":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'projecttype',
          "formname": 'Project Type',
          "alias": 'projecttype',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Project Type",
              "formFields": [
                {
                  'field': 'projecttype',
                  'text': 'Project Type',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
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
          ],
        };

      case "approvalcategory":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'approvalcategory',
          "formname": 'Approval Category',
          "alias": 'approvalcategory',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Approval Category",
              "formFields": [
                {
                  'field': 'name',
                  'text': 'Approval Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
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
          ],
        };

      case "subapprovalcategory":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'subapprovalcategory',
          "formname": 'Sub - Approval Category',
          "alias": 'subapprovalcategory',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Sub - Approval Category",
              "formFields": [
                {
                  'field': 'constructionstageid',
                  'text': 'Construction Stage',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'constructionstage',
                  'masterdatafield': 'name',
                  'formdatafield': 'constructionstage',
                  'cleanable': true,
                  'searchable': true,
                  'onchangedata': ['constructionstageid'],
                  'masterdatadependancy': false,
                  'showaddbutton': true,
                  'staticfilter': {'status': 1},
                },
                // {
                //   'field': 'approvalcategoryid',
                //   'text': 'Approval Category',
                //   'type': HtmlControls.kDropDown,
                //   'disabled': false,
                //   'defaultvisibility': true,
                //   'required': true,
                //   'gridsize': FieldSize.k375,
                //   'masterdata': 'approvalcategory',
                //   'masterdatafield': 'name',
                //   'formdatafield': 'approvalcategory',
                //   'cleanable': true,
                //   'searchable': true,
                //   'onchangedata': ['approvalcategoryid'],
                //   'masterdatadependancy': false,
                //   'showaddbutton': true,
                //   'staticfilter': {'status': 1},
                // },
                {
                  'field': 'userrole',
                  'text': 'User Role',
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
                  'field': 'name',
                  'text': 'Approval',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'frequency',
                  'text': 'Renewal Frequency',
                  'type': HtmlControls.kNumberInput,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k243,
                },
                {
                  'field': 'frequencyunitid',
                  'text': "",
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': false,
                  'gridsize': FieldSize.k150,
                  'masterdata': 'frequencyunit',
                  'masterdatafield': 'name',
                  'formdatafield': 'frequencyunit',
                  'cleanable': true,
                  'searchable': true,
                  // 'onchangedata': ['approvalcategoryid'],
                  'masterdatadependancy': false,
                  'staticfilter': {'status': 1},
                },
                {
                  'field': 'needapproval',
                  'text': 'Approval Upload?',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'needapproval',
                  'masterdataarray': Config.agreeType,
                  'defaultvalue': 1,
                  'formdatafield': 'approvalupload',
                  'cleanable': true,
                  'searchable': true,
                  // 'onchangedata': ['statusid'],
                  // 'masterdatadependancy': false,
                },
                {
                  'field': 'governmentauthorityid',
                  'text': 'Government Authority',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': false,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'governmentauthority',
                  'masterdatafield': 'name',
                  'formdatafield': 'governmentauthority',
                  'cleanable': true,
                  'searchable': true,
                  'istablefield': true,
                  'masterdatadependancy': false,
                  'staticfilter': {'status': 1},
                },
                {
                  'field': 'notificationfrequency',
                  'text': 'Notification Frequency',
                  'type': HtmlControls.kNumberInput,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k243,
                },
                {
                  'field': 'notificationfrequencyunitid',
                  'text': '',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': false,
                  'gridsize': FieldSize.k150,
                  'masterdata': 'notificationfrequencyunit',
                  'masterdataarray': Config.durationType,
                  'defaultvalue': 1,
                  'formdatafield': 'notificationfrequencyunit',
                  'cleanable': true,
                  'searchable': true,
                  'onchangedata': ['statusid'],
                  'masterdatadependancy': false,
                },
                {
                  'field': 'note',
                  'text': 'Note',
                  'type': HtmlControls.kInputTextArea,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': false,
                  'gridsize': FieldSize.k375,
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
          ],
        };

      case "governmentauthority":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'governmentauthority',
          "formname": 'Government Authority',
          "alias": 'governmentauthority',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Government Authority",
              "formFields": [
                {
                  'field': 'name',
                  'text': 'Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
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
          ],
        };

      case "committeedesignations":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'committeedesignations',
          "formname": 'Committee Designations',
          "alias": 'committeedesignations',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Committee Designations",
              "formFields": [
                {
                  'field': 'name',
                  'text': 'Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
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
          ],
        };

      case "eligibility":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'eligibility',
          "formname": 'Eligibility',
          "alias": 'eligibility',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Eligibility",
              "formFields": [
                {
                  'field': 'name',
                  'text': 'Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'shortcode',
                  'text': 'Short Code',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'description',
                  'text': 'Description',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'maxline': 3,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
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
          ],
        };

      case "locality":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'locality',
          "formname": 'Locality',
          "alias": 'locality',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Locality",
              "formFields": [
                {
                  'field': 'name',
                  'text': 'Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
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
          ],
        };

      case "xpart":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'xpart',
          "formname": 'Non-Survey Structure',
          "alias": 'xpart',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "X-PART",
              "formFields": [
                {
                  'field': 'name',
                  'text': 'Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
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
          ],
        };
      case "loft":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'loft',
          "formname": 'Loft',
          "alias": 'loft',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Loft",
              "formFields": [
                {
                  'field': 'name',
                  'text': 'Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
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
          ],
        };

      case "requestslot":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'requestslot',
          "formname": 'Request Slot',
          "alias": 'requestslot',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Request Slot",
              "formFields": [
                {
                  'field': 'name',
                  'text': 'Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
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
          ],
        };

      case "consent":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'consent',
          "formname": 'Consent',
          "alias": 'consent',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Consent",
              "formFields": [
                {
                  'field': 'name',
                  'text': 'Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'forcommonconsent',
                  'text': 'For Common Consent',
                  'type': HtmlControls.kCheckBox,
                  'disabled': false,
                  'required': false,
                  'defaultvisibility': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'forindividualconsent',
                  'text': 'For Individual Consent',
                  'type': HtmlControls.kCheckBox,
                  'disabled': false,
                  'required': false,
                  'defaultvisibility': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'forindividualagreement',
                  'text': 'For Individual Agreement',
                  'type': HtmlControls.kCheckBox,
                  'disabled': false,
                  'required': false,
                  'defaultvisibility': true,
                  'gridsize': FieldSize.k375,
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
          ],
        };

      case "hutmentsupport":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'hutmentsupport',
          "formname": 'Hutment Support',
          "alias": 'hutmentsupport',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Hutment Support",
              "formFields": [
                {
                  'field': 'name',
                  'text': 'Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
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
          ],
        };

      case "userrolemanagement":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'userrolemanagement',
          "formname": 'User Roles (* Role Management)',
          "alias": 'userrolemanagement',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "User Roles (* Role Management)",
              "formFields": [
                {
                  'field': 'name',
                  'text': 'Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
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
          ],
        };

      case "demolitionstatus":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'demolitionstatus',
          "formname": 'Demolition Status',
          "alias": 'demolitionstatus',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Demolition Status",
              "formFields": [
                {
                  'field': 'name',
                  'text': 'Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
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
          ],
        };

      case "unittype":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'unittype',
          "formname": 'Unit Type',
          "alias": 'unittype',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Unit Type",
              "formFields": [
                {
                  'field': 'name',
                  'text': 'Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
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
          ],
        };

      case "unitconfiguration":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'unitconfiguration',
          "formname": 'Unit Configuration',
          "alias": 'unitconfiguration',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Unit Configuration",
              "formFields": [
                {
                  'field': 'name',
                  'text': 'Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'unittypeid',
                  'text': 'Unit Type',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'unittype',
                  'masterdatafield': 'name',
                  'formdatafield': 'unittype',
                  'cleanable': true,
                  'searchable': true,
                  'masterdatadependancy': false,
                  'staticfilter': {'status': 1},
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
          ],
        };

      case "tenantprojectfilter":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'tenantprojectfilter',
          "formname": 'Filter',
          "alias": 'tenantprojectfilter',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Filter",
              "formFields": [
                {
                  'field': 'developername',
                  'text': 'Developer Name',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': false,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'developername',
                  'masterdatafield': 'developername',
                  'formdatafield': 'developername',
                  'cleanable': true,
                  'searchable': true,
                  'dependentfilter': {},
                  'onchangedata': [],
                  'masterdatadependancy': false,
                  'staticfilter': {'status': 1},
                },
                {
                  'field': 'projectname',
                  'text': 'Project Name',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': false,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'projectname',
                  'masterdatafield': 'projectname',
                  'formdatafield': 'projectname',
                  'cleanable': true,
                  'searchable': true,
                  'dependentfilter': {},
                  'onchangedata': [],
                  'masterdatadependancy': false,
                  'staticfilter': {'status': 1},
                },
                {
                  'field': 'projecttype',
                  'text': 'Project Type',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': false,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'projecttype',
                  'masterdatafield': 'projecttype',
                  'formdatafield': 'projecttype',
                  'cleanable': true,
                  'searchable': true,
                  'dependentfilter': {},
                  'onchangedata': [],
                  'masterdatadependancy': false,
                  'staticfilter': {'status': 1},
                },
                {
                  'field': 'pincodeid',
                  'text': 'Pincode',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': false,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'pincode',
                  'masterdatafield': 'pincode',
                  'formdatafield': 'pincode',
                  'cleanable': true,
                  'searchable': true,
                  'onchangedata': ['pincodeid'],
                  'masterdatadependancy': false,
                  'staticfilter': {'status': 1},
                },
                {
                  'field': 'areaid',
                  'text': 'Area',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': false,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'area',
                  'masterdatafield': 'area',
                  'formdatafield': 'area',
                  'cleanable': true,
                  'searchable': true,
                  'onchangedata': ['areaid'],
                  'masterdatadependancy': false,
                  'staticfilter': {'status': 1},
                },
                {
                  'field': 'cityid',
                  'text': 'City',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': false,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'city',
                  'masterdatafield': 'city',
                  'formdatafield': 'city',
                  'cleanable': true,
                  'searchable': true,
                  'onchangedata': ['cityid'],
                  'masterdatadependancy': false,
                  'staticfilter': {'status': 1},
                },
                {
                  'field': 'status',
                  'text': 'Status',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': false,
                  'gridsize': FieldSize.k800,
                  'masterdata': 'status',
                  'masterdatafield': 'status',
                  'formdatafield': 'status',
                  'cleanable': true,
                  'searchable': true,
                  'onchangedata': ['statusid'],
                  'masterdatadependancy': false,
                  'staticfilter': {'status': 1},
                },
              ]
            }
          ],
        };

      case "users":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'tenantprojectedit',
          "formname": 'Edit',
          "alias": 'tenantprojectedit',
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
                  'required': true,
                  'gridsize': FieldSize.k375,
                  'note': "Allowed JPG or PNG. Max size of 800K",
                },
                {
                  'field': 'name',
                  'text': 'Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'eid',
                  'text': 'EID',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'rolesid',
                  'text': 'Role',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'role',
                  'masterdatafield': 'role',
                  'formdatafield': 'role',
                  'cleanable': true,
                  'searchable': true,
                  'onchangedata': ['statusid'],
                  'masterdatadependancy': false,
                  'staticfilter': {'status': 1},
                },
                {
                  'field': 'contact',
                  'text': 'Official Contact',
                  'type': HtmlControls.kInputTextArea,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'email',
                  'text': 'Official Email',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
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
          ],
        };

      case "developer":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'tenantprojectedit',
          "formname": 'Edit',
          "alias": 'tenantprojectedit',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Edit",
              "formFields": [
                {
                  'field': 'logo',
                  'text': 'Logo',
                  'type': HtmlControls.kAvatarPicker,
                  'filetypes': ['png', 'jpg', 'jpeg'],
                  'uploadtext': "Upload",
                  'uploadedtext': "Upload New",
                  'resettext': StringConst.kResetBtnTxt,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                  'note': "Allowed JPG or PNG. Max size of 800K",
                },
                {
                  'field': 'developername',
                  'text': 'Developer Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'shortcode',
                  'text': 'Short Code',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'address',
                  'text': 'Address',
                  'type': HtmlControls.kInputTextArea,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'gstin',
                  'text': 'GSTIN',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'pan',
                  'text': 'PAN',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'phone',
                  'text': 'Phone',
                  'type': HtmlControls.kNumberInput,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'email',
                  'text': 'Email',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'status',
                  'text': 'Status',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k800,
                  'masterdata': 'status',
                  'masterdatafield': 'status',
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

      case "userrights":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'userrights',
          "formname": 'User Rights',
          "alias": 'userrights',
          "dataview": "tab",
          "formfields": [
            {
              "tab": "User Rights",
              "formFields": [
                {
                  'field': 'moduletypeid',
                  'text': 'Module',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k275,
                  'masterdata': 'moduletype',
                  'masterdatafield': 'moduletype',
                  'formdatafield': 'moduletype',
                  'cleanable': false,
                  'searchable': true,
                },
                {
                  'field': 'userroleid',
                  'text': 'User Type',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'required': false,
                  'defaultvisibility': true,
                  'gridsize': FieldSize.k175,
                  'masterdata': 'userrole',
                  'masterdatafield': 'userrole',
                  'formdatafield': 'userrole',
                  'cleanable': false,
                  'searchable': true,
                  'onchangefill': ['personid'],
                  'onchangedata': ['userroleid'],
                  'staticfilter': {'status': 1},
                },
                {
                  'field': 'or',
                  'text': '-Or-',
                  'type': HtmlControls.kText,
                  'defaultvisibility': true,
                },
                {
                  'field': 'personid',
                  'text': 'User',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'required': false,
                  'defaultvisibility': true,
                  'gridsize': FieldSize.k275,
                  'masterdata': 'user',
                  'masterdatafield': 'name',
                  'formdatafield': 'person',
                  'cleanable': true,
                  'searchable': true,
                  'masterdatadependancy': true,
                  'dependentfilter': {
                    'userroleid': 'userroleid',
                  },
                  'staticfilter': {'status': 1, 'needconcate': 1},
                },
              ],
            }
          ]
        };

      case "salutation":
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'salutation',
          "formname": 'Salutation',
          "alias": 'salutation',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Salutation",
              "formFields": [
                {
                  'field': 'name',
                  'text': 'Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
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
                  'masterdatadependancy': false,
                },
              ]
            }
          ],
        };

      case 'emailsmtp':
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'emailsmtp',
          "formname": 'Email SMTP',
          "alias": 'emailsmtp',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Email SMTP",
              "formFields": [
                {
                  'field': 'host',
                  'text': 'Host Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'port',
                  'text': 'Port Number',
                  'type': HtmlControls.kNumberInput,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                  'maxlength': 5,
                },
                {
                  'field': 'sendername',
                  'text': 'Sender Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'email',
                  'text': 'Email ID',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'username',
                  'text': 'User Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'password',
                  'text': 'Password',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'obscure': true,
                  'gridsize': FieldSize.k375,
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

      case 'form3-4':
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'form',
          "formname": 'Form 3/4',
          "alias": 'form3-4',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Form 3/4",
              "formFields": [
                {
                  'field': 'name',
                  'text': 'Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
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

      case 'relation':
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'relation',
          "formname": 'Relation',
          "alias": 'relation',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Relation",
              "formFields": [
                {
                  'field': 'relation',
                  'text': 'Relation',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
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

      case 'documenttype':
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'documenttype',
          "formname": 'Document Type',
          "alias": 'documenttype',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Document Type",
              "formFields": [
                {
                  'field': 'documenttype',
                  'text': 'Document Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'shortcode',
                  'text': 'Short Code',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'displayorder',
                  'text': 'Display Order',
                  'type': HtmlControls.kNumberInput,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                },
                {
                  'field': 'level',
                  'text': 'Level',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'documentlevel',
                  'masterdatafield': 'name',
                  'formdatafield': 'levelname',
                  'cleanable': true,
                  'searchable': true,
                  'masterdatadependancy': false,
                  'storemasterdatabyfield': false,
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

      case 'userrolehierarchy':
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'userrolehierarchy',
          "formname": 'User Role Hierarchy',
          "alias": 'userrolehierarchy',
          "dataview": "tree",
          'formfields': [
            {"tab": "Userrole Hierarchy", "formFields": []}
          ]
        };

      default:
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'this is default case',
          "formname": 'this is default case executed...',
          "alias": 'this is default case executed...',
          "dataview": "tab",
          'formfields': [
            {"tab": "this is default case executed...", "formFields": []}
          ],
        };
    }
  }
}
