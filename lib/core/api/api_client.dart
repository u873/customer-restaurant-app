import 'package:dio/dio.dart';

import '../storage/shared_pref_service.dart';
import 'api_constants.dart';

class DioClient {
  late final Dio dio;

  DioClient({String? baseUrl}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final existingAuthorization = options.headers['Authorization'];

          if (existingAuthorization == null ||
              existingAuthorization.toString().isEmpty) {
            final token = await SharedPrefService.getToken();

            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          handler.next(options);
        },

        onResponse: (response, handler) {
          handler.next(response);
        },

        onError: (DioException error, handler) async {
          final statusCode = error.response?.statusCode;

          if (statusCode == 401) {
            final data = error.response?.data;

            String message = "";

            if (data is Map<String, dynamic>) {
              message =
                  data['Message']?.toString() ??
                  data['message']?.toString() ??
                  data['ErrorMessage']?.toString() ??
                  "";
            }

            final lowerMessage = message.toLowerCase();

            final isTokenError =
                lowerMessage.contains("token") ||
                lowerMessage.contains("expired");

            if (isTokenError) {
              final isGuest = await SharedPrefService.getGuestStatus();

              if (isGuest) {
                await SharedPrefService.clearGuestSession();
              } else {
                await SharedPrefService.clearNormalSession();
              }
            }
          }

          handler.next(error);
        },
      ),
    );
  }
}
