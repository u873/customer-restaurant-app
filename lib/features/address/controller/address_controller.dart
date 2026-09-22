import 'dart:math';

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
    } catch (e, stackTrace) {
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
        // Old locally saved address clear karo
        await SharedPrefService.clearAddress();

        // Fresh addresses API se load karo
        await getCustomerAddresses();

        return true;
      }

      errorMessage = response.message;

      return false;
    } catch (_) {
      errorMessage = e.toString();

      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
