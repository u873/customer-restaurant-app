import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';


class AuthRepository {
  final DioClient dioV1;
  final DioClient dioV2;

  AuthRepository()
      : dioV1 = DioClient(
    baseUrl: ApiConstants.baseUrl,
  ),
        dioV2 = DioClient(
          baseUrl: ApiConstants.baseUrlV2,
        );


  Future<Response> signup({
    required String email,
    required int restaurantId,
    required String cellNum,
    required String password,
    required String name,
  }) async {
    return await dioV2.dio.post(
      ApiConstants.signup,
      data: {
        "email": email,
        "restaurant_id": restaurantId,
        "cell_num": cellNum,
        "password": password,
        "name": name,
      },
    );
  }


  Future<Response> login({
    required String restaurantId,
    required String deviceId,
    required String email,
    required String orderResourceId,
    required String password,
  }) async {
    return await dioV2.dio.post(
      ApiConstants.login,
      data: {
        "restaurant_id": restaurantId,
        "device_id": deviceId,
        "email": email,
        "order_resource_id": orderResourceId,
        "password": password,
      },
    );
  }

  Future<Response> socialLogin({
    required String email,
    required int restaurantId,
    required String socialAppId,
    required String name,
    required int orderResourceId,
    required String deviceId,
    required int loginTypeId,
  }) async {
    return await dioV2.dio.post(
      ApiConstants.saveSocialSideCustomer,
      data: {
        "email": email,
        "restaurant_id": restaurantId,
        "social_app_id": socialAppId,
        "name": name,
        "order_resource_id": orderResourceId,
        "device_id": deviceId,
        "login_type_id": loginTypeId,
      },
    );
  }
  Future<Response> verifyAccountOtp({
    required String customerId,
    required String otp,
  }) async {
    return await dioV2.dio.post(
      ApiConstants.verifyAccountOtp,
      data: {
        "customer_id": customerId,
        "otp": otp,
      },
    );
  }

  Future<Response> resendAccountOtp({
    required String customerId,
  }) async {
    return await dioV2.dio.post(
      ApiConstants.resendAccountOtp,
      data: {
        "customer_id": customerId,
      },
    );
  }

  Future<Response> sendOtp({
    required int restaurantId,
    required String email,
  }) async {
    return await dioV1.dio.post(
      ApiConstants.sendOtp,
      data: {
        "restaurant_id": restaurantId,
        "email": email,
      },
    );
  }
  Future<Response> verifyOtp({
    required String restaurantId,
    required String email,
    required String otp,
  }) async {
    return await dioV1.dio.post(
      ApiConstants.verifyOtp,
      data: {
        "restaurant_id": restaurantId,
        "email": email,
        "otp": otp,
      },
    );
  }

  Future<Response> changePassword({
    required String restaurantId,
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await dioV1.dio.post(
      ApiConstants.changePassword,
      data: {
        "restaurant_id": restaurantId,
        "email": email,
        "new_password": newPassword,
        "confirm_password": confirmPassword,
      },
    );
  }

  Future<Response> guestSignup({
    required String name,
    required String email,
    required int restaurantId,
    required String cellNum,
  }) async {
    return await dioV2.dio.post(
      ApiConstants.guestSignup,
      data: {
        "name": name,
        "email": email,
        "restaurant_id": restaurantId,
        "cell_num": cellNum,
      },
    );
  }


  Future<Response> deleteAccount({
    required String userId,
  }) async {
    return await dioV1.dio.post(
      ApiConstants.deleteAccount,
      data: {
        "user_id": userId,
      },
    );
  }
  Future<Response> updateCustomer({
    required String customerId,
    required String name,
    required String dateBirth,
    required String gender,
  }) async {
    try {
      final response = await dioV2.dio.post(
        ApiConstants.updateCustomer,
        data: {
          "customer_id": customerId,
          "name": name,
          "date_birth": dateBirth,
          "gender": gender,
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}