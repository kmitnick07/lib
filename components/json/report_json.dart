import '../../config/config.dart';

class ReportJson {
  ReportJson._privateConstructor();

  static final ReportJson _instance = ReportJson._privateConstructor();

  factory ReportJson() => _instance;

  static designationFormFields(String formName) {
    switch (formName) {
      case 'tenantreport':
        return {
          "rightsidebarsize": ModelClassSize.xs,
          "pagename": 'tenantreport',
          "formname": 'Tenant Report',
          "dataview": "tab",
          "alias": 'tenantreport',
          "formfields": [
            {
              "tab": "Icon",
              "formFields": [
                {
                  'field': 'tenantproject',
                  'text': 'Tenant Project Name',
                  'type': HtmlControls.kMultiSelectDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'tenantproject',
                  'masterdatafield': 'name',
                  'formdatafield': 'tenantproject',
                  'cleanable': true,
                  'searchable': true,
                  'onchangedata': [
                    'tenantproject',
                  ],
                  'onchangefill': [
                    'society',
                  ],
                  'staticfilter': {'status': 1},
                  'masterdatadependancy': false,
                },
                {
                  'field': 'hutmentusetype',
                  'text': 'Hutment Use',
                  'type': HtmlControls.kMultiSelectDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'unittype',
                  'masterdatafield': 'name',
                  'formdatafield': 'hutmentusetype',
                  'cleanable': true,
                  'searchable': true,
                  'onchangedata': ['hutmentusetype'],
                  'staticfilter': {'status': 1},
                  'masterdatadependancy': false,
                  'projection': {
                    '_id': 1,
                    'name': 1,
                  }
                },
                {
                  'field': 'eligibility',
                  'text': 'Eligibility',
                  'type': HtmlControls.kMultiSelectDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': false,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'eligibility',
                  'masterdatafield': 'name',
                  'formdatafield': 'eligibility',
                  'staticfilter': {'status': 1},
                  'projection': {
                    '_id': 1,
                    'name': 1,
                  },
                  'cleanable': true,
                  'searchable': true,
                  'masterdatadependancy': false,
                },
                {
                  'field': 'society',
                  'text': 'Society',
                  'type': HtmlControls.kMultiSelectDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': false,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'society',
                  'masterdatafield': 'tenantname',
                  'formdatafield': 'society',
                  'dependentfilter': {
                    'tenantproject': 'tenantproject',
                  },
                  'cleanable': true,
                  'searchable': true,
                  'staticfilter': {'status': 1},
                  // 'masterdatadependancy': true,
                  'projection': {
                    '_id': 1,
                    'tenantname': 1,
                  }
                },
                {
                  'field': 'hutmentsupport',
                  'text': 'Hutment Support',
                  'type': HtmlControls.kMultiSelectDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'hutmentsupport',
                  'masterdatafield': 'name',
                  'formdatafield': 'hutmentsupport',
                  'cleanable': true,
                  'searchable': true,
                  'staticfilter': {'status': 1},
                  'onchangedata': ['hutmentsupport'],
                  'masterdatadependancy': false,
                },
                {
                  'field': 'commonconsent',
                  'text': 'Common Consent',
                  'type': HtmlControls.kMultiSelectDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'consent',
                  'masterdatafield': 'name',
                  'formdatafield': 'commonconsent',
                  'staticfilter': {'forcommonconsent': 1, 'status': 1},
                  'cleanable': true,
                  'searchable': true,
                  'storemasterdatabyfield': true,
                  'masterdatadependancy': false,
                },
                {
                  'field': 'individualconsent',
                  'text': 'Individual Consent',
                  'type': HtmlControls.kMultiSelectDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'consent',
                  'masterdatafield': 'name',
                  'formdatafield': 'individualconsent',
                  'staticfilter': {'forindividualconsent': 1, 'status': 1},
                  'cleanable': true,
                  'searchable': true,
                  'storemasterdatabyfield': true,
                  'masterdatadependancy': false,
                },
                {
                  'field': 'individualagreement',
                  'text': 'Individual Agreement',
                  'type': HtmlControls.kMultiSelectDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': true,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'consent',
                  'masterdatafield': 'name',
                  'formdatafield': 'individualagreement',
                  'staticfilter': {'forindividualagreement': 1, 'status': 1},
                  'cleanable': true,
                  'searchable': true,
                  'storemasterdatabyfield': true,
                  'masterdatadependancy': false,
                },
                {
                  'field': 'tenantstatus',
                  'text': 'Hutment Status',
                  'type': HtmlControls.kMultiSelectDropDown,
                  'disabled': false,
                  'defaultvisibility': true,
                  'required': false,
                  'gridsize': FieldSize.k375,
                  'masterdata': 'tenantstatus',
                  'masterdatafield': 'status',
                  'formdatafield': 'tenantstatus',
                  'cleanable': true,
                  'staticfilter': {'status': 1},
                  'searchable': true,
                  'masterdatadependancy': false,
                  'projection': {
                    '_id': 1,
                    'status': 1,
                  },
                }
              ]
            },
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
