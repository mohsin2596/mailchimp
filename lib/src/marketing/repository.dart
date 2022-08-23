import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:mailchimp/src/marketing/constants.dart';
import 'package:mailchimp/src/marketing/enums/api_request_enum.dart';

import 'constants.dart';

class MarketingRepositories {
  String? apiKey;
  String? server;
  String? authString;
  String? encoded;
  Map<String, String>? headers;

  MarketingRepositories(this.apiKey, this.server) {
    String authString = "apikey:$apiKey";
    String encoded = base64.encode(utf8.encode(authString));
    headers = {
      "content-type": "application/json",
      "Authorization": "Basic $encoded",
    };
  }

  Future<dynamic> apiRequest(
      RequestType type, String endpoint, Map<String, dynamic> queryParameters,
      {int successCode = 200}) async {
    try {
      String base = baseUrl.replaceAll("<dc>", "$server");
      late Uri uri;
      if (type != RequestType.POST) {
        uri = Uri.https('$base', endpoint, queryParameters);
      } else {
        uri = Uri.https(
          '$base',
          endpoint,
        );
      }

      final response = type == RequestType.GET
          ? await get(uri, headers: headers)
          : type == RequestType.POST
              ? await post(uri,
                  headers: headers, body: jsonEncode(queryParameters))
              : type == RequestType.DELETE
                  ? await delete(uri, headers: headers)
                  : type == RequestType.PUT
                      ? await put(uri, headers: headers)
                      : await patch(uri, headers: headers);

      print(response.body);
      if (response.statusCode == successCode) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Error: " + e.toString());
    }

    return null;
  }

  Future<Map<String, dynamic>?> getRoot(
      List<String>? fields, List<String>? excludedFields) async {
    var queryParameters = {
      'fields': fields,
      'exclude_fields': excludedFields,
    };

    return apiRequest(
            RequestType.GET, '/3.0${Endpoint.get_root}', queryParameters)
        as FutureOr<Map<String, dynamic>?>;
  }

  Future<List<Map<String, dynamic>>> getAuthorizedApps(List<String>? fields,
      List<String>? excludedFields, int? count, int? offset) async {
    var queryParameters = {
      'fields': fields,
      'exclude_fields': excludedFields,
      'count': count,
      'offset': offset
    };

    return apiRequest(
            RequestType.GET, '/3.0${Endpoint.authorizedApps}', queryParameters)
        as Future<List<Map<String, dynamic>>>;
  }

  Future<Map<String, dynamic>?> getAuthorizedAppInfo(
      List<String>? fields, List<String>? excludedFields, String? appId) async {
    var queryParameters = {
      'fields': fields,
      'exclude_fields': excludedFields,
    };

    return apiRequest(
        RequestType.GET,
        '/3.0${Endpoint.getAuthorizedAppInfo(appId)}',
        queryParameters) as FutureOr<Map<String, dynamic>?>;
  }

  Future<List<Map<String, dynamic>>?> getAutomations(
      int? count,
      int? offset,
      List<String>? fields,
      List<String>? excludedFields,
      String? beforeCreateTime,
      String? sinceCreateTime,
      String? beforeStartTime,
      String? sinceStartTime,
      String status) async {
    var queryParameters = {
      'fields': fields,
      'count': count,
      'offset': offset,
      'exclude_fields': excludedFields,
      'before_create_time': beforeCreateTime,
      'since_create_time': sinceCreateTime,
      'before_start_time': beforeStartTime,
      'since_start_time': sinceStartTime,
      'status': status
    };

    return apiRequest(
            RequestType.GET, '/3.0${Endpoint.automations}', queryParameters)
        as FutureOr<List<Map<String, dynamic>>?>;
  }

  Future<Map<String, dynamic>?> addAutomation(Map<String, String> recipients,
      Map<String, String> triggerSettings, Map<String, String> settings) async {
    var queryParameters = {
      'recipients': recipients,
      'trigger_settings': triggerSettings,
      'settings': settings,
    };
    return apiRequest(
            RequestType.POST, '/3.0${Endpoint.automations}', queryParameters)
        as FutureOr<Map<String, dynamic>?>;
  }

  Future<Map<String, dynamic>?> getAutomationInfo(
      String id, List<String>? fields, List<String>? excludedFields) async {
    var queryParameters = {
      'fields': fields,
      'exclude_fields': excludedFields,
    };
    return apiRequest(RequestType.GET, '/3.0${Endpoint.getAutomationInfo(id)}',
        queryParameters) as FutureOr<Map<String, dynamic>?>;
  }

  Future<void> startAutomationEmails(String id) {
    return apiRequest(
        RequestType.POST, '/3.0${Endpoint.startAutomationEmails(id)}', {},
        successCode: 204);
  }

  Future<void> pauseAutomationEmails(String id) {
    return apiRequest(
        RequestType.POST, '/3.0${Endpoint.pauseAutomationEmails(id)}', {},
        successCode: 204);
  }

  Future<void> archiveAutomation(String id) {
    return apiRequest(
        RequestType.POST, '/3.0${Endpoint.archiveAutomation(id)}', {},
        successCode: 204);
  }

  Future<Map<String, dynamic>?> listAutomatedEmails(String id) async {
    return apiRequest(
            RequestType.GET, '/3.0${Endpoint.listAutomationEmails(id)}', {})
        as FutureOr<Map<String, dynamic>?>;
  }

  Future<Map<String, dynamic>?> getWorkflowEmailInfo(
      String id, String emailId) async {
    return apiRequest(
            RequestType.GET, '/3.0${Endpoint.workflowEmail(id, emailId)}', {})
        as FutureOr<Map<String, dynamic>?>;
  }

  Future<void> deleteWorkflowEmail(String id, String emailId) async {
    return apiRequest(
        RequestType.DELETE, '/3.0${Endpoint.workflowEmail(id, emailId)}', {},
        successCode: 204);
  }

  Future<Map<String, dynamic>?> updateWorkflowEmail(String id, String emailId,
      Map<String, dynamic> delay, Map<String, String> settings) async {
    var queryParameters = {
      'delay': delay,
      'settings': settings,
    };
    return apiRequest(
        RequestType.PATCH,
        '/3.0${Endpoint.workflowEmail(id, emailId)}',
        queryParameters) as FutureOr<Map<String, dynamic>?>;
  }

  Future<void> pauseAutomatedEmail(String id, String emailId) async {
    return apiRequest(RequestType.POST,
        '/3.0${Endpoint.pauseAutomatedEmail(id, emailId)}', {},
        successCode: 204);
  }

  Future<void> startAutomatedEmail(String id, String emailId) async {
    return apiRequest(RequestType.POST,
        '/3.0${Endpoint.startAutomatedEmail(id, emailId)}', {},
        successCode: 204);
  }

  Future<Map<String, dynamic>?> getAutomatedEmailSubscribers(
      String id, String emailId) async {
    return apiRequest(
        RequestType.GET, '/3.0${Endpoint.emailSubscribers(id, emailId)}', {},
        successCode: 200) as FutureOr<Map<String, dynamic>?>;
  }

  Future<Map<String, dynamic>> addEmailSubscriber(
      String id, String emailId, String emailAddress) async {
    var queryParameters = {'email_address': emailAddress};
    return apiRequest(RequestType.POST,
        '/3.0${Endpoint.emailSubscribers(id, emailId)}', queryParameters,
        successCode: 200) as FutureOr<Map<String, dynamic>>;
  }

  Future<Map<String, dynamic>> getEmailSubscriber(
      String id, String emailId, String subscriberHash) async {
    return apiRequest(RequestType.GET,
        '/3.0${Endpoint.getEmailSubscriber(id, emailId, subscriberHash)}', {},
        successCode: 200) as FutureOr<Map<String, dynamic>>;
  }

  Future<Map<String, dynamic>?> getRemovedSubscribers(String id) async {
    return apiRequest(
        RequestType.GET, '/3.0${Endpoint.removedSubscribers(id)}', {},
        successCode: 200) as FutureOr<Map<String, dynamic>?>;
  }

  Future<Map<String, dynamic>?> removeSubscriber(
      String id, String emailAddress) async {
    var queryParameters = {'email_address': emailAddress};
    return apiRequest(RequestType.POST,
        '/3.0${Endpoint.removedSubscribers(id)}', queryParameters,
        successCode: 200) as FutureOr<Map<String, dynamic>?>;
  }

  Future<Map<String, dynamic>?> getRemovedSubscriber(
      String id, String subscriberHash) async {
    return apiRequest(RequestType.GET,
        '/3.0${Endpoint.getRemovedSubscriber(id, subscriberHash)}', {},
        successCode: 200) as FutureOr<Map<String, dynamic>?>;
  }

  Future<Map<String, dynamic>?> getBatchRequests(List<String>? fields,
      List<String>? excludedFields, int? count, int? offset) async {
    var queryParameters = {
      'fields': fields,
      'exclude_fields': excludedFields,
      'count': count,
      'offset': offset
    };
    return apiRequest(
            RequestType.GET, '/3.0${Endpoint.batches}', queryParameters)
        as FutureOr<Map<String, dynamic>?>;
  }

  Future<Map<String, dynamic>?> startBatchOperations(
      String requestMethod,
      String path,
      int? count,
      int? offset,
      String jsonBody,
      String operationId) async {
    var queryParameters = {
      'operations': [
        {'method': requestMethod},
        {'path': path},
        {
          'params': {'count': count, 'offset': offset}
        },
        {'body': jsonBody},
        {'operation_id': operationId}
      ],
    };
    return apiRequest(
            RequestType.POST, '/3.0${Endpoint.batches}', queryParameters)
        as FutureOr<Map<String, dynamic>?>;
  }

  Future<Map<String, dynamic>?> getBatchOperationStatus(String batchId,
      List<String>? fields, List<String>? excludedFields) async {
    var queryParameters = {
      'fields': fields,
      'exclude_fields': excludedFields,
    };
    return apiRequest(
        RequestType.GET,
        '/3.0${Endpoint.batchOperation(batchId)}',
        queryParameters) as FutureOr<Map<String, dynamic>?>;
  }

  Future<void> deleteBatchRequest(String batchId) async {
    return apiRequest(
        RequestType.DELETE, '/3.0${Endpoint.batchOperation(batchId)}', {},
        successCode: 204);
  }

  Future<Map<String, dynamic>?> getBatchWebhooks(List<String>? fields,
      List<String>? excludedFields, int? count, int? offset) async {
    var queryParameters = {
      'fields': fields,
      'exclude_fields': excludedFields,
      'count': count,
      'offset': offset
    };
    return apiRequest(
            RequestType.GET, '/3.0${Endpoint.batchWebhooks}', queryParameters)
        as FutureOr<Map<String, dynamic>?>;
  }

  Future<Map<String, dynamic>?> addBatchWebhook(String url) async {
    var queryParameters = {'url': url};
    return apiRequest(
            RequestType.POST, '/3.0${Endpoint.batchWebhooks}', queryParameters)
        as FutureOr<Map<String, dynamic>?>;
  }

  Future<Map<String, dynamic>?> getBatchWebhookInfo(String? batchWebhookId,
      List<String>? fields, List<String>? excludedFields) async {
    var queryParameters = {
      'fields': fields,
      'exclude_fields': excludedFields,
    };
    return apiRequest(
        RequestType.GET,
        '/3.0${Endpoint.batchWebhookInfo(batchWebhookId)}',
        queryParameters) as FutureOr<Map<String, dynamic>?>;
  }

  Future<Map<String, dynamic>?> updateBatchWebhook(
      String? batchWebhookId, String? url) async {
    var queryParameters = {'url': url};
    return apiRequest(
        RequestType.PATCH,
        '/3.0${Endpoint.batchWebhookInfo(batchWebhookId)}',
        queryParameters) as FutureOr<Map<String, dynamic>?>;
  }

  Future<void> deleteBatchWebhook(String batchWebhookId) async {
    return apiRequest(RequestType.DELETE,
        '/3.0${Endpoint.batchWebhookInfo(batchWebhookId)}', {},
        successCode: 204);
  }

  Future<Map<String, dynamic>?> getCampaignFolders(List<String>? fields,
      List<String>? excludedFields, int? count, int? offset) async {
    var queryParameters = {
      'fields': fields,
      'exclude_fields': excludedFields,
      'count': count,
      'offset': offset
    };
    return apiRequest(
            RequestType.GET, '/3.0${Endpoint.campaignFolders}', queryParameters)
        as FutureOr<Map<String, dynamic>?>;
  }

  Future<Map<String, dynamic>?> addCampaignFolder(String name) async {
    var queryParameters = {'name': name};
    return apiRequest(RequestType.POST, '/3.0${Endpoint.campaignFolders}',
        queryParameters) as FutureOr<Map<String, dynamic>?>;
  }

  Future<Map<String, dynamic>?> getCampaignFolderInfo(String? folderId,
      List<String>? fields, List<String>? excludedFields) async {
    var queryParameters = {
      'fields': fields,
      'exclude_fields': excludedFields,
    };
    return apiRequest(
        RequestType.GET,
        '/3.0${Endpoint.campaignFolderInfo(folderId)}',
        queryParameters) as FutureOr<Map<String, dynamic>?>;
  }

  Future<Map<String, dynamic>?> updateCampaignFolder(
      String? folderId, String? name) async {
    var queryParameters = {'name': name};
    return apiRequest(
        RequestType.PATCH,
        '/3.0${Endpoint.campaignFolderInfo(folderId)}',
        queryParameters) as FutureOr<Map<String, dynamic>?>;
  }

  Future<void> deleteCampaignFolder(String folderId) async {
    return apiRequest(
        RequestType.DELETE, '/3.0${Endpoint.campaignFolderInfo(folderId)}', {},
        successCode: 204);
  }

  Future<Map<String, dynamic>?> getCampaigns(
      List<String>? fields,
      List<String>? excludedFields,
      int? count,
      int? offset,
      String type,
      String status,
      String? beforeSendTime,
      String? sinceSendTime,
      String? beforeCreateTime,
      String? sinceCreateTime,
      String? listId,
      String? folderId,
      String? memberId,
      String sortField,
      String sortDir) async {
    var queryParameters = {
      'fields': fields,
      'exclude_fields': excludedFields,
      'count': count,
      'offset': offset,
      'type': type,
      'status': status,
      'before_send_time': beforeSendTime,
      'since_send_time': sinceSendTime,
      'before_create_time': beforeCreateTime,
      'since_create_time': sinceCreateTime,
      'list_id': listId,
      'folder_id': folderId,
      'member_id': memberId,
      'sort_field': sortField,
      'sort_dir': sortDir
    };
    return apiRequest(
            RequestType.GET, '/3.0${Endpoint.campaigns}', queryParameters)
        as FutureOr<Map<String, dynamic>?>;
  }

  Future<Map<String, dynamic>?> addCampaign(
      String type,
      Map<String, dynamic> rssOpts,
      Map<String, dynamic> recipients,
      Map<String, dynamic> variateSettings,
      Map<String, dynamic> settings,
      Map<String, dynamic> tracking,
      Map<String, dynamic> socialCard,
      String contentType) async {
    var queryParameters = {
      "type": type,
      "recipients": recipients,
      "settings": settings,
      "variate_settings": variateSettings,
      "tracking": tracking,
      "rss_opts": rssOpts,
      "social_card": socialCard,
      "content_type": contentType
    };
    return apiRequest(
            RequestType.POST, '/3.0${Endpoint.campaigns}', queryParameters)
        as FutureOr<Map<String, dynamic>?>;
  }

  Future<Map<String, dynamic>?> getCampaignInfo(String campaignId,
      List<String>? fields, List<String>? excludedFields) async {
    var queryParameters = {
      'fields': fields,
      'exclude_fields': excludedFields,
    };
    return apiRequest(
        RequestType.GET,
        '/3.0${Endpoint.campaignInfo(campaignId)}',
        queryParameters) as FutureOr<Map<String, dynamic>?>;
  }

  Future<Map<String, dynamic>?> updateCampaign(
    String campaignId,
    Map<String, dynamic> rssOpts,
    Map<String, dynamic> recipients,
    Map<String, dynamic> variateSettings,
    Map<String, dynamic> settings,
    Map<String, dynamic> tracking,
    Map<String, dynamic> socialCard,
  ) async {
    var queryParameters = {
      "recipients": recipients,
      "settings": settings,
      "variate_settings": variateSettings,
      "tracking": tracking,
      "rss_opts": rssOpts,
      "social_card": socialCard,
    };
    return apiRequest(
        RequestType.PATCH,
        '/3.0${Endpoint.campaignInfo(campaignId)}',
        queryParameters) as FutureOr<Map<String, dynamic>?>;
  }

  Future<void> deleteCampaign(String campaignId) async {
    return apiRequest(
        RequestType.DELETE, '/3.0${Endpoint.campaignInfo(campaignId)}', {},
        successCode: 204);
  }

  Future<void> cancelCampaign(String campaignId) async {
    return apiRequest(
        RequestType.POST, '/3.0${Endpoint.cancelCampaign(campaignId)}', {},
        successCode: 204);
  }

  Future<void> sendCampaign(String campaignId) async {
    return apiRequest(
        RequestType.POST, '/3.0${Endpoint.sendCampaign(campaignId)}', {},
        successCode: 204);
  }

  Future<void> scheduleCampaign(String campaignId, String? scheduleTime,
      Map<String, dynamic> batchDelivery, bool? timewarp) async {
    var queryParamters = {
      "schedule_time": scheduleTime,
      "timewarp": timewarp,
      "batch_delivery": batchDelivery
    };
    return apiRequest(RequestType.POST,
        '/3.0${Endpoint.scheduleCampaign(campaignId)}', queryParamters,
        successCode: 204);
  }

  Future<void> unscheduleCampaign(String campaignId) async {
    return apiRequest(
        RequestType.POST, '/3.0${Endpoint.unscheduleCampaign(campaignId)}', {},
        successCode: 204);
  }

  Future<void> pauseRssCampaign(String campaignId) async {
    return apiRequest(
        RequestType.POST, '/3.0${Endpoint.paussRssCampaign(campaignId)}', {},
        successCode: 204);
  }

  Future<void> resumeRssCampaign(String campaignId) async {
    return apiRequest(
        RequestType.POST, '/3.0${Endpoint.resumeRssCampaign(campaignId)}', {},
        successCode: 204);
  }

  Future<Map<String, dynamic>?> replicateCampaign(String campaignId) async {
    return apiRequest(
      RequestType.POST,
      '/3.0${Endpoint.replicateCampaign(campaignId)}',
      {},
    ) as FutureOr<Map<String, dynamic>?>;
  }

  Future<void> sendTestEmail(
      String campaignId, List<String>? testEmails, String sendType) async {
    var queryParameters = {"test_emails": testEmails, "send_type": sendType};
    return apiRequest(RequestType.POST,
        '/3.0${Endpoint.replicateCampaign(campaignId)}', queryParameters,
        successCode: 204);
  }

  Future<Map<String, dynamic>?> resendCampaign(String campaignId) async {
    return apiRequest(
      RequestType.POST,
      '/3.0${Endpoint.resendCampaign(campaignId)}',
      {},
    ) as FutureOr<Map<String, dynamic>?>;
  }

  Future<Map<String, dynamic>?> getCampaignContent(
      String campaignId, List<String>? fields, List<String>? excludeFields) {
    var queryParameters = {
      'fields': fields,
      'exclude_fields': excludeFields,
    };
    return apiRequest(
      RequestType.GET,
      '/3.0${Endpoint.campaignContent(campaignId)}',
      queryParameters,
    ).then((value) => value as Map<String, dynamic>?);
  }

  Future<Map<String, dynamic>?> setCampaignContent(
      String? campaignId,
      Map<String, String> archive,
      Map<String, dynamic> template,
      String? plainText,
      String? html,
      String? url,
      List<Map<String, dynamic>?> variateContents) {
    var queryParameters = {
      "plain_text": plainText,
      "html": html,
      "url": url,
      "template": template,
      "archive": archive,
      "variate_contents": variateContents
    };
    return apiRequest(
      RequestType.PUT,
      '/3.0${Endpoint.campaignContent(campaignId)}',
      queryParameters,
    ).then((value) => value as Map<String, dynamic>?);
  }

  Future<Map<String, dynamic>?> getCampaignFeedback(
      String campaignId, List<String>? fields, List<String>? excludeFields) {
    var queryParameters = {
      'fields': fields,
      'exclude_fields': excludeFields,
    };
    return apiRequest(
      RequestType.GET,
      '/3.0${Endpoint.campaignFeedback(campaignId)}',
      queryParameters,
    ).then((value) => value as Map<String, dynamic>?);
  }

  Future<Map<String, dynamic>?> addCampaignFeedback(
      String campaignId, String message, int? blockId, bool? isComplete) {
    var queryParameters = {
      "block_id": blockId,
      "message": message,
      "is_complete": isComplete
    };
    return apiRequest(
      RequestType.POST,
      '/3.0${Endpoint.campaignFeedback(campaignId)}',
      queryParameters,
    ).then((value) => value as Map<String, dynamic>?);
  }

  Future<Map<String, dynamic>?> getCampaignFeedbackMessage(String campaignId,
      String feedbackId, List<String>? fields, List<String>? excludeFields) {
    var queryParameters = {
      'fields': fields,
      'exclude_fields': excludeFields,
    };
    return apiRequest(
      RequestType.GET,
      '/3.0${Endpoint.campaignFeedbackInfo(campaignId, feedbackId)}',
      queryParameters,
    ).then((value) => value as Map<String, dynamic>?);
  }

  Future<Map<String, dynamic>?> updateCampaignFeedback(String campaignId,
      String feedbackId, String? message, int? blockId, bool? isComplete) {
    var queryParameters = {
      "block_id": blockId,
      "message": message,
      "is_complete": isComplete
    };
    return apiRequest(
      RequestType.PATCH,
      '/3.0${Endpoint.campaignFeedbackInfo(campaignId, feedbackId)}',
      queryParameters,
    ).then((value) => value as Map<String, dynamic>?);
  }

  Future<void> deleteCampaignFeedback(
    String campaignId,
    String feedbackId,
  ) {
    return apiRequest(RequestType.DELETE,
        '/3.0${Endpoint.campaignFeedbackInfo(campaignId, feedbackId)}', {},
        successCode: 204);
  }
}
