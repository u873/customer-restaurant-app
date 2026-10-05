import 'package:flutter/material.dart';

import '../../../core/storage/shared_pref_service.dart';
import '../model/customer_address.dart';
import '../repository/address_repo.dart';

class AddressController extends ChangeNotifier {
  final AddressRepo _addressRepo = AddressRepo();

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  List<CustomerAddress> addresses = [];
  CustomerAddress? selectedAddress;

  Future<void> getCustomerAddresses() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _addressRepo.getCustomerAddresses();

      if (response.success) {
        addresses = response.data;

        if (addresses.isNotEmpty) {
          if (selectedAddress != null) {
            final selected = addresses.where(
              (address) => address.addressId == selectedAddress!.addressId,
            );

            if (selected.isNotEmpty) {
              selectedAddress = selected.first;
            } else {
              selectedAddress = addresses.first;
            }
          } else {
            final defaultAddress = addresses.where(
              (address) => address.isDefault == 1,
            );

            if (defaultAddress.isNotEmpty) {
              selectedAddress = defaultAddress.first;
            } else {
              selectedAddress = addresses.first;
            }
          }
        } else {
          selectedAddress = null;
        }
      } else {
        errorMessage = response.message;
      }
    } catch (e) {
      errorMessage = "Failed to load addresses.";
    }

    isLoading = false;
    notifyListeners();
  }

  void selectAddress(CustomerAddress address) {
    selectedAddress = address;
    notifyListeners();
  }

  void clearSelectedAddress() {
    selectedAddress = null;
    notifyListeners();
  }

  Future<bool> syncLocalAddressToBackend() async {
    try {
      final addressSynced = await SharedPrefService.getAddressSynced();

      // Already synced, nothing to do.
      if (addressSynced) {
        return true;
      }

      // Read locally saved address.
      final address1 = await SharedPrefService.getAddress1();

      if (address1 == null || address1.trim().isEmpty) {
        return true;
      }

      final addressTypeId = await SharedPrefService.getAddressTypeId() ?? 3;

      final townId = await SharedPrefService.getTownId() ?? 11;

      final townBlockId = await SharedPrefService.getTownBlockId() ?? 104;

      final latitudeString = await SharedPrefService.getLatitude();

      final longitudeString = await SharedPrefService.getLongitude();

      final isDefault = await SharedPrefService.getIsDefaultAddress() ?? 1;

      final latitude = double.tryParse(latitudeString ?? '') ?? 0.0;

      final longitude = double.tryParse(longitudeString ?? '') ?? 0.0;

      // Backend API call.
      final response = await _addressRepo.addEditCustomerAddress(
        addressId: "",
        addressTypeId: addressTypeId,
        address: address1.trim(),
        townId: townId,
        townBlockId: townBlockId,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );

      if (!response.success || response.data == null) {
        errorMessage = response.message.isNotEmpty
            ? response.message
            : "Failed to sync delivery address.";

        return false;
      }

      final backendAddress = response.data!;

      // Save backend address data locally.
      await SharedPrefService.saveAddress(
        addressId: backendAddress.addressId.isNotEmpty
            ? backendAddress.addressId
            : backendAddress.id.toString(),
        address1: backendAddress.address1,
        addressTypeId: backendAddress.addressTypeId,
        addressType: backendAddress.addressType,
        townId: backendAddress.townId,
        townBlockId: backendAddress.townBlockId,
        latitude: backendAddress.latitude.toString(),
        longitude: backendAddress.longitude.toString(),
        isDefault: backendAddress.isDefault,
      );

      // saveAddress() resets this to false,
      // so explicitly mark it synced afterwards.
      await SharedPrefService.saveAddressSynced(true);

      // Use backend address as selected address.
      selectedAddress = backendAddress;

      // Add/update local controller list.
      final existingIndex = addresses.indexWhere(
        (item) => item.id == backendAddress.id,
      );

      if (existingIndex >= 0) {
        addresses[existingIndex] = backendAddress;
      } else {
        addresses = [...addresses, backendAddress];
      }

      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst("Exception: ", "");

      return false;
    }
  }

  Future<bool> addOrEditAddress({
    required int addressTypeId,
    required CustomerAddress? existingAddress,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _addressRepo.addEditCustomerAddress(
        addressId: existingAddress?.addressId ?? "",
        addressTypeId: addressTypeId,
        address: address,
        townId: existingAddress?.townId ?? 11,
        townBlockId: existingAddress?.townBlockId ?? 104,
        latitude: latitude,
        longitude: longitude,
        isDefault: existingAddress?.isDefault ?? 0,
      );

      if (response.success) {
        // Old locally saved address clear karo.
        await SharedPrefService.clearAddress();

        // Fresh addresses API se load karo.
        await getCustomerAddresses();

        return true;
      }

      errorMessage = response.message;

      return false;
    } catch (e) {
      errorMessage = e.toString().replaceFirst("Exception: ", "");

      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
