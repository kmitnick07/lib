import '../../config/config.dart';

class MenuAssignJson {
  MenuAssignJson._privateConstructor();

  static final MenuAssignJson _instance = MenuAssignJson._privateConstructor();

  factory MenuAssignJson() => _instance;

  static designationFormFields(String formName) {
    switch (formName) {
      case 'menuassign':
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'Menu Assign',
          "formname": 'Menu Assign',
          "alias": 'menuassign',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "this is default case executed...",
              "formFields": [
                {
                  'field': 'moduletypeid',
                  'text': 'Module Type',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
                  'masterdata': 'moduletype',
                  'masterdatafield': 'moduletype',
                  'formdatafield': 'moduletype',
                  'cleanable': true,
                  'searchable': true,
                  'onchangefill': ['moduleid'],
                  'onchangedata': ['moduletypeid'],
                  'masterdatadependancy': false,
                },
                {
                  'field': 'moduleid',
                  'text': 'Module',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
                  'masterdata': 'module',
                  'masterdatafield': 'module',
                  'formdatafield': 'module',
                  'cleanable': true,
                  'searchable': true,
                  
                  'dependentfilter': {'moduletypeid': 'moduletypeid'},
                  'masterdatadependancy': true,
                },
              ]
            }
          ],
        };
      case "menudesign":
        return {
          "rightsidebarsize": ModelClassSize.md,
          "pagename": 'menudesign',
          "formname": 'Menu Design',
          "alias": 'menudesign',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "Menu",
              "formFields": [
                {
                  'field': 'moduletypeid',
                  'text': 'Module',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
                  'masterdata': 'moduletype',
                  'masterdatafield': 'moduletype',
                  'formdatafield': 'moduletype',
                  'cleanable': false,
                  'searchable': true,
                  'masterdatadependancy': false,
                },
              ]
            },
          ],
        };
      default:
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'this is default case',
          "formname": 'this is default case executed...',
          "alias": '',
          "dataview": "tab",
          'formfields': [
            {
              "tab": "this is default case executed...",
              "formFields": [
                {
                  'field': 'this is default case executed...',
                  'text': 'this is default case executed...',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
                  'masterdata': 'project',
                  'masterdatafield': 'project',
                  'formdatafield': 'status',
                  'cleanable': true,
                  'searchable': true,
                  
                  'onchangedata': ['statusid'],
                  'masterdatadependancy': false,
                },
                {
                  'field': 'buildingid',
                  'text': 'Building',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k125,
                  'masterdata': 'building',
                  'masterdatafield': 'building',
                  'formdatafield': 'building',
                  'cleanable': true,
                  'searchable': true,
                  
                  'onchangedata': ['statusid'],
                  'masterdatadependancy': false,
                },
                {
                  'field': 'floorid',
                  'text': 'Floor',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k125,
                  'masterdata': 'floor',
                  'masterdatafield': 'floor',
                  'formdatafield': 'floor',
                  'cleanable': true,
                  'searchable': true,
                  'dependentfilter': {'projectid': 'projectnameid'},
                  
                  'onchangedata': ['statusid'],
                  'masterdatadependancy': false,
                },
                {
                  'field': 'unitid',
                  'text': 'Unit',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k100,
                  'masterdata': 'unit',
                  'masterdatafield': 'unit',
                  'formdatafield': 'unit',
                  'cleanable': true,
                  'searchable': true,
                  
                  'onchangedata': ['statusid'],
                  'masterdatadependancy': false,
                },
                {
                  'field': 'sasas',
                  'text': 'Against Hutment Id',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
                  'masterdata': 'againsthutmentid',
                  'masterdatafield': 'againsthutmentid',
                  'formdatafield': 'againsthutmentid',
                  'cleanable': true,
                  'searchable': true,
                  
                  'onchangedata': ['statusid'],
                  'masterdatadependancy': false,
                },
                {
                  'field': 'name',
                  'text': 'Name',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
                },
                {
                  'field': 'sradwellerid',
                  'text': 'SRA Dweller ID',
                  'type': HtmlControls.kInputText,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
                },
                {
                  'field': 'sradwellerdocument',
                  'text': 'SRA Dweller Document',
                  'type': HtmlControls.kFilePicker,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'filetypes': ['pdf'],
                  'gridsize': FieldSize.k400,
                },
                {
                  'field': 'keyhandovwrdate',
                  'text': 'Key Handover Date',
                  'type': HtmlControls.kDatePicker,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
                },
                {
                  'field': 'allotmentletter',
                  'text': 'Allotment Letter',
                  'type': HtmlControls.kFilePicker,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'filetypes': ['pdf'],
                  'gridsize': FieldSize.k400,
                },
                {
                  'field': 'otherdocumnets',
                  'text': 'Other Documents',
                  'type': HtmlControls.kFilePicker,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'filetypes': ['pdf'],
                  'gridsize': FieldSize.k400,
                },
                {
                  'field': 'statusid',
                  'text': 'Status',
                  'type': HtmlControls.kDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k400,
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
    }
  }
}
