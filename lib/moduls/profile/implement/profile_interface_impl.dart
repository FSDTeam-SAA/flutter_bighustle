import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bighustle/core/api_handler/failure.dart';
import 'package:flutter_bighustle/core/api_handler/success.dart';
import 'package:flutter_bighustle/core/constants/api_endpoints.dart';
import 'package:flutter_bighustle/core/services/app_pigeon/app_pigeon.dart';
import '../model/delete_account_request_model.dart';
import '../interface/profile_interface.dart';
import '../model/notification_settings_request_model.dart';
import '../model/profile_response_model.dart';
import '../model/update_profile_request_model.dart';

final class ProfileInterfaceImpl extends ProfileInterface {
  final AppPigeon appPigeon;

  ProfileInterfaceImpl({required this.appPigeon});

  @override
  Future<Either<DataCRUDFailure, Success<ProfileResponseModel>>> getProfile() {
    return asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.get(ApiEndpoints.getCurrentProfile);
        final responseBody = response.data is Map
            ? Map<String, dynamic>.from(response.data)
            : <String, dynamic>{};
        final responseData = responseBody["data"];
        final payload = responseData is Map
            ? Map<String, dynamic>.from(responseData)
            : <String, dynamic>{};
        final profile = ProfileResponseModel.fromJson(payload);

        return Success(
          message: responseBody['message']?.toString() ?? 'Profile fetched',
          data: profile,
        );
      },
    );
  }

  @override
  Future<Either<DataCRUDFailure, Success<String>>> deleteAccount({
    required DeleteAccountRequestModel param,
  }) {
    return asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.delete(
          ApiEndpoints.deleteAccount,
          data: param.toJson(),
        );
        final responseBody = response.data is Map
            ? Map<String, dynamic>.from(response.data)
            : <String, dynamic>{};

        return Success(
          message:
              responseBody['message']?.toString() ??
              'Account deleted successfully',
          data: responseBody['data']?['email']?.toString() ?? '',
        );
      },
    );
  }

  @override
  Future<Either<DataCRUDFailure, Success<ProfileResponseModel>>>
  updateNotificationSettings({
    required NotificationSettingsRequestModel param,
  }) {
    return asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.put(
          ApiEndpoints.updateNotificationSettings,
          data: param.toJson(),
        );
        final responseBody = response.data is Map
            ? Map<String, dynamic>.from(response.data)
            : <String, dynamic>{};
        final responseData = responseBody["data"];
        final payload = responseData is Map
            ? Map<String, dynamic>.from(responseData)
            : <String, dynamic>{};
        final profile = ProfileResponseModel.fromJson(payload);

        return Success(
          message:
              responseBody['message']?.toString() ??
              'Settings updated successfully',
          data: profile,
        );
      },
    );
  }

  @override
  Future<Either<DataCRUDFailure, Success<ProfileResponseModel>>> updateProfile({
    required UpdateProfileRequestModel param,
  }) {
    return asyncTryCatch(
      tryFunc: () async {
        final formDataMap = Map<String, dynamic>.from(param.toJson());
        final avatarPath = param.avatarPath;
        if (avatarPath != null && avatarPath.isNotEmpty) {
          final normalizedPath = avatarPath.startsWith('file://')
              ? avatarPath.replaceFirst('file://', '')
              : avatarPath;
          if (!normalizedPath.startsWith('http') &&
              normalizedPath.contains('/')) {
            formDataMap['avatar'] = await MultipartFile.fromFile(
              normalizedPath,
              filename: normalizedPath.split('/').last,
            );
          }
        }
        final formData = FormData.fromMap(formDataMap);
        final response = await appPigeon.put(
          ApiEndpoints.editProfile,
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
        final responseBody = response.data is Map
            ? Map<String, dynamic>.from(response.data)
            : <String, dynamic>{};
        final responseData = responseBody["data"];
        final payload = responseData is Map
            ? Map<String, dynamic>.from(responseData)
            : <String, dynamic>{};
        final profile = ProfileResponseModel.fromJson(payload);

        return Success(
          message: responseBody['message']?.toString() ?? 'Profile updated',
          data: profile,
        );
      },
    );
  }
}
