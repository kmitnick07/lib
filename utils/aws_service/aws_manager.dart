import 'dart:io';

import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/src/media_type.dart';
import 'package:prestige_prenew_frontend/config/api_constant.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';

import 'aws_policy.dart';
import 'file_data_model.dart';

class AwsManager {
  AwsManager._privateConstructor();

  static final AwsManager _instance = AwsManager._privateConstructor();

  factory AwsManager() => _instance;

  // Pool Credential
  static String awsUserPoolId = buildFor.isProd && !kDebugMode ? 'ap-south-1_axgCWrTBi' : "ap-south-1_6kxwJ6P7h";
  static String identityPoolId = buildFor.isProd && !kDebugMode ? 'ap-south-1:0fe6aa03-3a28-48ad-8074-0cca661b2a65' : 'ap-south-1:c04ccf76-fcf1-445b-a138-8986ccd25183';

  // Credentials
  static String awsUserName = buildFor.isProd && !kDebugMode ? 'file_upload' : "s3_file_upload";
  static String awsUserPassword = "Asd@123!@#";

  // Client Secret
  static String awsClientId = buildFor.isProd && !kDebugMode ? '37eruvo1cd9qc53fed87ui8ni6' : '3smtrb52qk7phdbburcpbs6kj7';
  static String awsClientSecret = buildFor.isProd && !kDebugMode ? '11s16ueb4ehbh7dh3sif6i95rmvamt21ot1j7edr51686k5ase6e' : '7gse5rrabeu6pcichlcfgfca0cqd2fsbbp4v7ltis7sgemuet0i';

  // Region and End-Point
  static String region = 'ap-south-1';
  static String bucket = buildFor.isDev || kDebugMode
      ? 'dev-prenew'
      : buildFor.isUat
          ? 'uat-prenew'
          : 'prenew';
  static String s3Endpoint = 'https://$bucket.s3-ap-south-1.amazonaws.com';

  // User Pool & Auth Details
  final CognitoUserPool userPool = CognitoUserPool(awsUserPoolId, awsClientId, clientSecret: awsClientSecret);
  final AuthenticationDetails authDetails = AuthenticationDetails(username: awsUserName, password: awsUserPassword);

  CognitoUser? cognitoUser;
  CognitoUserSession? session;
  CognitoCredentials? cognitoCredentials;

  void init() {
    if (kDebugMode) {
      return;
    }
    if (kIsWeb) {
      compute(initialiseService, null);
      // initialiseService(null);
    } else {
      // compute(initialiseService, null);
      initialiseService(null);
    }
  }

  Future<bool> initialiseService(void _) async {
    devPrint('INIT');

    cognitoUser = CognitoUser(awsUserName, userPool, clientSecret: awsClientSecret);
    try {
      session = await cognitoUser?.authenticateUser(authDetails);
      cognitoCredentials = CognitoCredentials(identityPoolId, userPool);
      await cognitoCredentials?.getAwsCredentials(session?.getIdToken().getJwtToken());
      if (kDebugMode) {
        devPrint("Aws initialised !!!!");
      }
    } catch (e) {
      devPrint(e);
      if (kDebugMode) {
        devPrint("Aws Error -------------------->   $e");
      }
      init();
    }
    return true;
  }

  Future<Map<String, dynamic>> uploadChatMedia(FilesDataModel filesDataModel) async {
    Map<String, dynamic> returnReponse = {};
    String fileName = "${DateTime.now().millisecondsSinceEpoch}_${filesDataModel.name}";
    try {
      String bucketLocation = "Prenew/temp/${fileName.replaceAll(' ', '_')}";
      Map<String, dynamic> response = await uploadMedia(bucketLocation, path: filesDataModel.path, bytes: filesDataModel.bytes, extension: filesDataModel.extension, name: fileName);
      if (response['status'] == 204 || response['status'] == 200) {
        returnReponse = filesDataModel.toJson();
        returnReponse.remove('bytes');
        returnReponse['tempId'] = filesDataModel.tempId;
        returnReponse['url'] = response['location'];
        returnReponse['status'] = 200;
        returnReponse['isUploaded'] = true;
      }
    } catch (e) {
      returnReponse = {"status": 401, "message": e.toString()};
    }
    return returnReponse;
  }

  Future<Map<String, dynamic>> uploadMedia(String bucketLocation, {String? path, Uint8List? bytes, String? extension, String? name}) async {
    try {
      if (session?.isValid() == false || session?.isValid() == null) {
        // IsolatedWorker().run(initialiseService, null).then((value) => uploadMedia(bucketLocation, path: path, extension: extension, bytes: bytes, name: name));
        if (kIsWeb) {
          await AwsManager().initialiseService(null).then((value) => uploadMedia(bucketLocation, path: path, extension: extension, bytes: bytes, name: name));
        } else {
          await AwsManager().initialiseService(null).then((value) => uploadMedia(bucketLocation, path: path, extension: extension, bytes: bytes, name: name));
          // await IsolatedWorker().run(AwsManager().initialiseService, null).then((value) => uploadMedia(bucketLocation, path: path, extension: extension, bytes: bytes, name: name));
        }
      }
      if (path != null || bytes != null) {
        final Uri uri = Uri.parse(s3Endpoint);
        final http.MultipartRequest request = http.MultipartRequest("POST", uri);
        // Location for upload document
        // String bucketLocation = "${Settings.subDomainName}/chatmedia/$name";

        // Policy And Creds for uploadation
        String accessKeyId = cognitoCredentials?.accessKeyId ?? '';
        String sessionToken = cognitoCredentials?.sessionToken ?? '';
        String secretAccessKey = cognitoCredentials?.secretAccessKey ?? '';
        int maxFileSize = kIsWeb ? bytes!.length : File(path!).lengthSync();
        String contentType = IISMethods().getMimeTypeString(path ?? "");
        // Policy
        final Policy policy = Policy.fromS3PresignedPost(bucketLocation, bucket, 15, accessKeyId, maxFileSize, sessionToken, contentType, region: region);
        String credential = policy.credential;
        String datetime = policy.datetime;

        final key = SigV4.calculateSigningKey(secretAccessKey, datetime, region, 's3');
        final signature = SigV4.calculateSignature(key, policy.encode());

        // Header for uplodation
        request.fields['key'] = policy.key;
        request.fields['X-Amz-Credential'] = credential;
        request.fields['X-Amz-Algorithm'] = 'AWS4-HMAC-SHA256';
        request.fields['X-Amz-Date'] = datetime;
        request.fields['Policy'] = policy.encode();
        request.fields['X-Amz-Signature'] = signature;
        request.fields['x-amz-security-token'] = sessionToken;
        //! Safe to remove this if your bucket has no ACL permissions
        request.fields['acl'] = 'public-read';
        request.fields['Content-Type'] = contentType;

        // In web path will not found
        if (kIsWeb) {
          var uploadFile = http.MultipartFile.fromBytes("file", bytes!, contentType: MediaType('application', '$extension'), filename: name);
          request.files.add(uploadFile);
        } else {
          var uploadFile = await http.MultipartFile.fromPath("file", path!, contentType: MediaType('application', '$extension'), filename: name);
          request.files.add(uploadFile);
        }

        http.StreamedResponse response = await request.send();
        Map<String, dynamic> returnResponse = <String, dynamic>{};
        if (response.statusCode == 204 || response.statusCode == 200) {
          returnResponse['location'] = "https://$bucket.s3-ap-south-1.amazonaws.com/$bucketLocation";
        }
        returnResponse['status'] = response.statusCode;
        returnResponse['message'] = response.reasonPhrase;

        return returnResponse;
      }
    } catch (e) {
      devPrint("-------------------> $e");
      if (kDebugMode) {
        devPrint("Aws Error -------------------->   $e");
      }
      return {"status": 401, "message": e.toString()};
    }
    return {"status": 401, "message": "Something went wrong..."};
  }
}
