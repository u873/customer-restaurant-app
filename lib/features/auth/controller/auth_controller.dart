import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/storage/shared_pref_service.dart';
import '../model/auth_response_model.dart';
import '../model/guest_signup_response_model.dart';
import '../model/signup_response_model.dart';
import '../model/user_model.dart';
import '../repository/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  UserModel? _user;

  UserModel? get user => _user;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String? _errorMessage;

  String? get errorMessage => _errorMessage;
  String? _successMessage;

  String? get successMessage => _successMessage;
  String? _customerId;

  String? get customerId => _customerId;
  String? _token;

  String? get token => _token;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;
  bool _isGuest = false;

  bool get isGuest => _isGuest;
  int? _guestCustomerNumericId;

  int? get guestCustomerNumericId => _guestCustomerNumericId;
  String? _guestToken;

  String? get guestToken => _guestToken;
  String? _guestCustomerUuid;

  String? get guestCustomerUuid => _guestCustomerUuid;
  bool _isSessionLoading = true;

  bool get isSessionLoading => _isSessionLoading;

  String? _guestName;
  String? _guestEmail;
  String? _guestPhone;

  String? get guestName => _guestName;

  String? get guestEmail => _guestEmail;

  String? get guestPhone => _guestPhone;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<bool> signup({
    required String email,
    required int restaurantId,
    required String cellNum,
    required String password,
    required String name,
  }) async {
    _setLoading(true);

    _errorMessage = null;
    _successMessage = null;

    try {
      final response = await _repository.signup(
        email: email,
        restaurantId: restaurantId,
        cellNum: cellNum,
        password: password,
        name: name,
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        final result = SignupResponseModel.fromJson(data);

        if (result.success) {
          _customerId = result.customerId;

          _successMessage = result.message.isNotEmpty
              ? result.message
              : "Signup successful";

          return true;
        }

        _errorMessage = result.message.isNotEmpty
            ? result.message
            : "Signup failed";

        return false;
      }

      _errorMessage = "Invalid server response";
      return false;
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String restaurantId,
    required String deviceId,
    required String email,
    required String orderResourceId,
    required String password,
  }) async {
    _setLoading(true);

    _errorMessage = null;
    _successMessage = null;

    try {
      final response = await _repository.login(
        restaurantId: restaurantId,
        deviceId: deviceId,
        email: email,
        orderResourceId: orderResourceId,
        password: password,
      );

      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final result = AuthResponseModel.fromJson(responseData);

        debugPrint("LOGIN RESPONSE DATA: ${result.data}");

        if (result.success) {
          if (result.data is Map<String, dynamic>) {
            _user = UserModel.fromJson(Map<String, dynamic>.from(result.data));
          }

          debugPrint("USER NAME: ${_user?.name}");
          debugPrint("USER EMAIL: ${_user?.email}");
          debugPrint("USER PHONE: ${_user?.phone}");
          String? token;

          if (result.data is Map<String, dynamic>) {
            token = result.data['token']?.toString();
          }
          if (token != null && token.isNotEmpty) {
            await SharedPrefService.clearGuestSession(
              clearSavedAddress: false,
            );

            _isGuest = false;
            _guestToken = null;
            _guestCustomerNumericId = null;
            _guestCustomerUuid = null;

            await _saveSession(token);
            _token = token;
            _isLoggedIn = true;

            _successMessage = result.message.isNotEmpty
                ? result.message
                : "Login successful";

            notifyListeners();
            return true;
          }
          _errorMessage = "Token not found";
          return false;
        }
        _errorMessage = result.message.isNotEmpty
            ? result.message
            : "Invalid email or password";

        return false;
      }
      _errorMessage = "Invalid server response";
      return false;
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> guestSignup({
    required String name,
    required String email,
    required int restaurantId,
    required String cellNum,
  }) async {
    _setLoading(true);

    _errorMessage = null;
    _successMessage = null;

    try {
      final response = await _repository.guestSignup(
        name: name,
        email: email,
        restaurantId: restaurantId,
        cellNum: cellNum,
      );

      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final result = GuestSignupResponseModel.fromJson(responseData);

        if (result.success && result.data != null) {
          final guestData = result.data!;
          _isGuest = true;
          // Guest numeric customer ID
          _guestCustomerNumericId = guestData.id;
          // Guest UUID
          _guestCustomerUuid = guestData.customerId;
          // Guest token
          _guestToken = guestData.token;
          // Guest should NOT be normal logged-in user
          _isLoggedIn = false;
          _token = null;
          _customerId = null;
          _user = null;
          await SharedPrefService.clearSession(
            clearSavedAddress: false,
          );

          await SharedPrefService.saveGuestStatus(true);
          if (guestData.token.isNotEmpty) {
            await SharedPrefService.saveGuestToken(guestData.token);
          }
          await SharedPrefService.saveGuestCustomerId(guestData.id);
          if (guestData.customerId.isNotEmpty) {
            await SharedPrefService.saveGuestCustomerUuid(guestData.customerId);
          }
          await SharedPrefService.saveGuestName(name);
          await SharedPrefService.saveGuestEmail(email);
          await SharedPrefService.saveGuestPhone(cellNum);

          _successMessage = result.message.isNotEmpty
              ? result.message
              : "Guest user created successfully";

          notifyListeners();

          return true;
        }

        _errorMessage = result.message.isNotEmpty
            ? result.message
            : "Guest signup failed";

        return false;
      }

      _errorMessage = "Invalid server response";
      return false;
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> socialLogin({
    required String email,
    required int restaurantId,
    required String socialAppId,
    required String name,
    required int orderResourceId,
    required String deviceId,
    required int loginTypeId,
  }) async {
    _setLoading(true);

    _errorMessage = null;
    _successMessage = null;

    try {
      final response = await _repository.socialLogin(
        email: email,
        restaurantId: restaurantId,
        socialAppId: socialAppId,
        name: name,
        orderResourceId: orderResourceId,
        deviceId: deviceId,
        loginTypeId: loginTypeId,
      );

      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final result = AuthResponseModel.fromJson(responseData);

        if (result.success) {
          if (result.data is Map<String, dynamic>) {
            final userData = Map<String, dynamic>.from(result.data);
            _user = UserModel.fromJson(userData);

            final token = userData['token']?.toString();

            if (token != null && token.isNotEmpty) {
              await SharedPrefService.clearGuestSession(
                  clearSavedAddress: false,
              );


              _isGuest = false;
              _guestToken = null;
              _guestCustomerNumericId = null;
              _guestCustomerUuid = null;

              await _saveSession(token);

              _token = token;
              _customerId = userData['customer_id']?.toString();
              _isLoggedIn = true;
              _successMessage = result.message.isNotEmpty
                  ? result.message
                  : "Login successful";

              notifyListeners();
              return true;
            }

            _errorMessage = "Token not found";
            return false;
          }

          _errorMessage = "Invalid user data";
          return false;
        }

        _errorMessage = result.message.isNotEmpty
            ? result.message
            : "Social login failed";

        return false;
      }

      _errorMessage = "Invalid server response";
      return false;
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyAccountOtp({
    required String customerId,
    required String otp,
  }) async {
    _setLoading(true);

    _errorMessage = null;
    _successMessage = null;

    try {
      final response = await _repository.verifyAccountOtp(
        customerId: customerId,
        otp: otp,
      );

      final result = AuthResponseModel.fromJson(response.data);

      if (result.success) {
        String? token;

        if (result.data is Map<String, dynamic>) {
          token = result.data['token']?.toString();
        }

        if (token != null && token.isNotEmpty) {
          // Clear guest if any
          await SharedPrefService.clearGuestSession(
            clearSavedAddress: false,
          );

          _isGuest = false;
          _guestToken = null;
          _guestCustomerNumericId = null;
          _guestCustomerUuid = null;

          await _saveSession(token);

          _token = token;
          _isLoggedIn = true;
        }

        _successMessage = result.message.isNotEmpty
            ? result.message
            : "OTP verified successfully";

        return true;
      }

      _errorMessage = result.message.isNotEmpty
          ? result.message
          : "Invalid OTP";

      return false;
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendOtp({
    required int restaurantId,
    required String email,
  }) async {
    _setLoading(true);

    _errorMessage = null;
    _successMessage = null;

    try {
      final response = await _repository.sendOtp(
        restaurantId: restaurantId,
        email: email,
      );

      final result = AuthResponseModel.fromJson(response.data);

      if (result.success) {
        _successMessage = result.message.isNotEmpty
            ? result.message
            : "OTP sent successfully";

        return true;
      }

      _errorMessage = result.message.isNotEmpty
          ? result.message
          : "Unable to send OTP";

      return false;
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyOtp({
    required String restaurantId,
    required String email,
    required String otp,
  }) async {
    _setLoading(true);

    _errorMessage = null;
    _successMessage = null;

    try {
      final response = await _repository.verifyOtp(
        restaurantId: restaurantId,
        email: email,
        otp: otp,
      );

      final result = AuthResponseModel.fromJson(response.data);

      if (result.success) {
        _successMessage = result.message.isNotEmpty
            ? result.message
            : "OTP verified successfully";

        return true;
      }

      _errorMessage = result.message.isNotEmpty
          ? result.message
          : "Invalid OTP";

      return false;
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resendAccountOtp({required String customerId}) async {
    _setLoading(true);

    _errorMessage = null;
    _successMessage = null;

    try {
      final response = await _repository.resendAccountOtp(
        customerId: customerId,
      );

      final result = AuthResponseModel.fromJson(response.data);

      if (result.success) {
        _successMessage = result.message.isNotEmpty
            ? result.message
            : "OTP resent successfully";

        return true;
      }

      _errorMessage = result.message.isNotEmpty
          ? result.message
          : "Unable to resend OTP";

      return false;
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword({
    required String restaurantId,
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _setLoading(true);

    _errorMessage = null;
    _successMessage = null;

    try {
      final response = await _repository.changePassword(
        restaurantId: restaurantId,
        email: email,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      final result = AuthResponseModel.fromJson(response.data);

      if (result.success) {
        _successMessage = result.message.isNotEmpty
            ? result.message
            : "Password changed successfully";

        return true;
      }

      _errorMessage = result.message.isNotEmpty
          ? result.message
          : "Unable to change password";

      return false;
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount({required String userId}) async {
    _setLoading(true);

    _errorMessage = null;
    _successMessage = null;

    try {
      final response = await _repository.deleteAccount(userId: userId);

      final result = AuthResponseModel.fromJson(response.data);

      if (result.success) {
        await logout();

        _successMessage = result.message.isNotEmpty
            ? result.message
            : "Account deleted successfully";

        return true;
      }

      _errorMessage = result.message.isNotEmpty
          ? result.message
          : "Unable to delete account";

      return false;
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _saveSession(String token) async {
    await SharedPrefService.saveToken(token);
    await SharedPrefService.saveLoginStatus(true);

    if (_user != null) {
      await SharedPrefService.saveCustomerUuid(_user!.customerId);

      await SharedPrefService.saveUserData(jsonEncode(_user!.toJson()));
    }
  }

  Future<void> loadSession() async {
    try {
      _token = await SharedPrefService.getToken();
      _customerId = await SharedPrefService.getCustomerUuid();
      final savedLoginStatus = await SharedPrefService.getLoginStatus();
      _isLoggedIn = savedLoginStatus && _token != null && _token!.isNotEmpty;

      final guestStatus = await SharedPrefService.getGuestStatus();

      if (guestStatus) {
        _isGuest = true;
        _guestToken = await SharedPrefService.getGuestToken();
        _guestCustomerNumericId = await SharedPrefService.getGuestCustomerId();
        _guestCustomerUuid = await SharedPrefService.getGuestCustomerUuid();
        _guestName = await SharedPrefService.getGuestName();
        _guestEmail = await SharedPrefService.getGuestEmail();
        _guestPhone = await SharedPrefService.getGuestPhone();
      } else {
        _isGuest = false;
        _guestToken = null;
        _guestCustomerNumericId = null;
        _guestCustomerUuid = null;
        _guestName = null;
        _guestEmail = null;
        _guestPhone = null;
      }

      final userData = await SharedPrefService.getUserData();

      if (userData != null && userData.isNotEmpty) {
        try {
          final decodedUser = jsonDecode(userData);

          if (decodedUser is Map<String, dynamic>) {
            _user = UserModel.fromJson(decodedUser);
          }
        } catch (e) {
          debugPrint("USER RESTORE ERROR: $e");

          _user = null;
        }
      }
      debugPrint("SESSION TOKEN: $_token");
      debugPrint("SESSION CUSTOMER UUID: $_customerId");
      debugPrint("SESSION LOGGED IN: $_isLoggedIn");
    } catch (_) {
      _token = null;
      _customerId = null;
      _user = null;
      _isLoggedIn = false;
      _isGuest = false;
      _guestToken = null;
      _guestCustomerNumericId = null;
      _guestCustomerUuid = null;
    } finally {
      _isSessionLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await SharedPrefService.clearSession();

    // Normal user
    _token = null;
    _customerId = null;
    _user = null;
    _isLoggedIn = false;
    // Guest user
    _isGuest = false;
    _guestToken = null;
    _guestCustomerNumericId = null;
    _guestCustomerUuid = null;
    _guestName = null;
    _guestEmail = null;
    _guestPhone = null;

    notifyListeners();
  }

  Future<void> handleTokenExpired() async {
    final guestSession = await SharedPrefService.getGuestStatus();

    if (guestSession) {
      await SharedPrefService.clearGuestSession();
    } else {
      await SharedPrefService.clearNormalSession();
    }

    _token = null;
    _customerId = null;
    _user = null;
    _isLoggedIn = false;

    _isGuest = false;
    _guestToken = null;
    _guestCustomerNumericId = null;
    _guestCustomerUuid = null;
    _guestName = null;
    _guestEmail = null;
    _guestPhone = null;

    _errorMessage = guestSession
        ? "Guest session has expired. Please continue as guest again."
        : "Your session has expired. Please login again.";

    notifyListeners();
  }

  void _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        _errorMessage =
            data['Message']?.toString() ??
            data['message']?.toString() ??
            "Something went wrong";
      } else {
        _errorMessage = "Server error: ${e.response?.statusCode}";
      }
    } else {
      _errorMessage = "Unable to connect to server";
    }
  }

  Future<bool> updateCustomer({
    required String name,
    required String dateBirth,
    required String gender,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      if (_user == null || _user!.customerId.isEmpty) {
        _errorMessage = "User information not found";
        return false;
      }

      final response = await _repository.updateCustomer(
        customerId: _user!.customerId,
        name: name,
        dateBirth: dateBirth,
        gender: gender,
      );

      final responseData = response.data;

      if (responseData is Map<String, dynamic> &&
          responseData['Success'] == true) {
        final data = responseData['Data'];

        if (data is Map<String, dynamic>) {
          final updatedUser = UserModel.fromJson(
            Map<String, dynamic>.from(data),
            fallbackToken: _user!.token,
          );

          _user = _user!.copyWith(
            id: updatedUser.id != 0 ? updatedUser.id : _user!.id,
            customerId: updatedUser.customerId.isNotEmpty
                ? updatedUser.customerId
                : _user!.customerId,
            name: updatedUser.name.isNotEmpty ? updatedUser.name.trim() : name,
            gender: updatedUser.gender ?? gender,
            dateBirth: updatedUser.dateBirth ?? dateBirth,
            token: _user!.token,
          );

          await _saveSession(_user!.token);

          _customerId = _user!.customerId;
          _token = _user!.token;

          _successMessage =
              responseData['ErrorMessage']?.toString() ??
              responseData['Message']?.toString() ??
              "Profile updated successfully";

          return true;
        }
      }

      _errorMessage = responseData is Map<String, dynamic>
          ? responseData['ErrorMessage']?.toString() ??
                responseData['Message']?.toString() ??
                "Profile update failed"
          : "Profile update failed";

      return false;
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
