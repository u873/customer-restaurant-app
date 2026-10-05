import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  // NORMAL USER SESSION
  static const String _tokenKey = 'token';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _customerUuidKey = 'customerUuid';
  static const String _userDataKey = 'userData';

  // GUEST SESSION
  static const String _guestTokenKey = 'guestToken';
  static const String _isGuestKey = 'isGuest';
  static const String _guestCustomerIdKey = 'guestCustomerId';
  static const String _guestCustomerUuidKey = 'guestCustomerUuid';
  static const String _guestNameKey = 'guestName';
  static const String _guestEmailKey = 'guestEmail';
  static const String _guestPhoneKey = 'guestPhone';

  // LOCAL ADDRESS
  static const String _addressIdKey = 'addressId';
  static const String _address1Key = 'address1';
  static const String _addressTypeIdKey = 'addressTypeId';
  static const String _addressTypeKey = 'addressType';
  static const String _townIdKey = 'townId';
  static const String _townBlockIdKey = 'townBlockId';
  static const String _latitudeKey = 'latitude';
  static const String _longitudeKey = 'longitude';
  static const String _isDefaultAddressKey = 'isDefaultAddress';

  // ADDRESS SYNC STATUS
  static const String _isAddressSyncedKey = 'isAddressSynced';

  // FIRST LAUNCH ADDRESS STATUS
  static const String _hasShownFirstAddressKey = 'hasShownFirstAddress';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveLoginStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  static Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> saveCustomerUuid(String customerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customerUuidKey, customerId);
  }

  static Future<String?> getCustomerUuid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_customerUuidKey);
  }

  static Future<void> saveGuestToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_guestTokenKey, token);
  }

  static Future<String?> getGuestToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_guestTokenKey);
  }

  static Future<void> saveGuestStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isGuestKey, value);
  }

  static Future<bool> getGuestStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isGuestKey) ?? false;
  }

  static Future<void> saveGuestName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_guestNameKey, name);
  }

  static Future<String?> getGuestName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_guestNameKey);
  }

  static Future<void> saveGuestEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_guestEmailKey, email);
  }

  static Future<String?> getGuestEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_guestEmailKey);
  }

  static Future<void> saveGuestPhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_guestPhoneKey, phone);
  }

  static Future<String?> getGuestPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_guestPhoneKey);
  }

  static Future<void> saveGuestCustomerId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_guestCustomerIdKey, id);
  }

  static Future<int?> getGuestCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_guestCustomerIdKey);
  }

  static Future<void> saveGuestCustomerUuid(String uuid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_guestCustomerUuidKey, uuid);
  }

  static Future<String?> getGuestCustomerUuid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_guestCustomerUuidKey);
  }

  static Future<void> saveAddress({
    required String addressId,
    required String address1,
    required int addressTypeId,
    required String addressType,
    required int townId,
    required int townBlockId,
    required String latitude,
    required String longitude,
    required int isDefault,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_addressIdKey, addressId);
    await prefs.setString(_address1Key, address1);
    await prefs.setInt(_addressTypeIdKey, addressTypeId);
    await prefs.setString(_addressTypeKey, addressType);
    await prefs.setInt(_townIdKey, townId);
    await prefs.setInt(_townBlockIdKey, townBlockId);
    await prefs.setString(_latitudeKey, latitude);
    await prefs.setString(_longitudeKey, longitude);
    await prefs.setInt(_isDefaultAddressKey, isDefault);

    // New/updated local address needs backend sync.
    await prefs.setBool(_isAddressSyncedKey, false);
  }

  static Future<String?> getAddressId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_addressIdKey);
  }

  static Future<String?> getAddress1() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_address1Key);
  }

  static Future<int?> getAddressTypeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_addressTypeIdKey);
  }

  static Future<String?> getAddressType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_addressTypeKey);
  }

  static Future<int?> getTownId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_townIdKey);
  }

  static Future<int?> getTownBlockId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_townBlockIdKey);
  }

  static Future<String?> getLatitude() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_latitudeKey);
  }

  static Future<String?> getLongitude() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_longitudeKey);
  }

  static Future<int?> getIsDefaultAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_isDefaultAddressKey);
  }

  static Future<void> saveAddressSynced(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isAddressSyncedKey, value);
  }

  static Future<bool> getAddressSynced() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isAddressSyncedKey) ?? false;
  }

  static Future<void> saveHasShownFirstAddress(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasShownFirstAddressKey, value);
  }

  static Future<bool> getHasShownFirstAddress() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_hasShownFirstAddressKey) ?? false;
  }

  static Future<void> clearAddress() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_addressIdKey);
    await prefs.remove(_address1Key);
    await prefs.remove(_addressTypeIdKey);
    await prefs.remove(_addressTypeKey);
    await prefs.remove(_townIdKey);
    await prefs.remove(_townBlockIdKey);
    await prefs.remove(_latitudeKey);
    await prefs.remove(_longitudeKey);
    await prefs.remove(_isDefaultAddressKey);
    await prefs.remove(_isAddressSyncedKey);

    // IMPORTANT:
    // _hasShownFirstAddressKey is NOT removed here.
    // First-launch status must survive logout/session clearing.
  }

  static Future<void> saveUserData(String userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, userData);
  }

  static Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userDataKey);
  }

  static Future<void> clearGuestSession({bool clearSavedAddress = true}) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_guestTokenKey);
    await prefs.remove(_isGuestKey);
    await prefs.remove(_guestCustomerIdKey);
    await prefs.remove(_guestCustomerUuidKey);
    await prefs.remove(_guestNameKey);
    await prefs.remove(_guestEmailKey);
    await prefs.remove(_guestPhoneKey);

    if (clearSavedAddress) {
      await clearAddress();
    }
  }

  static Future<void> clearNormalSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_customerUuidKey);
    await prefs.remove(_userDataKey);

    await prefs.setBool(_isLoggedInKey, false);

    await clearAddress();
  }

  static Future<void> clearSession({bool clearSavedAddress = true}) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_customerUuidKey);
    await prefs.remove(_userDataKey);

    await prefs.remove(_guestTokenKey);
    await prefs.remove(_isGuestKey);
    await prefs.remove(_guestCustomerIdKey);
    await prefs.remove(_guestCustomerUuidKey);
    await prefs.remove(_guestNameKey);
    await prefs.remove(_guestEmailKey);
    await prefs.remove(_guestPhoneKey);

    await prefs.setBool(_isLoggedInKey, false);

    if (clearSavedAddress) {
      await clearAddress();
    }

    // hasShownFirstAddress ko remove nahi karna.
  }
}
