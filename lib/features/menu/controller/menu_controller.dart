import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../../core/services/location_service.dart';
import '../../branch/model/branch_response.dart';
import '../../branch/repo/branch_repo.dart';
import '../../cart/controller/cart_controller.dart';
import '../../delivery_charge/repo/delivery_charge_repo.dart';
import '../model/main_data_response.dart';
import '../repo/menu_repo.dart';

enum OrderType { delivery, pickup }

class MenuProvider extends ChangeNotifier {
  final MenuRepo _menuRepo = MenuRepo();
  final BranchRepo _branchRepo = BranchRepo();
  final LocationService _locationService = LocationService();
  final DeliveryChargeRepo _deliveryChargeRepo = DeliveryChargeRepo();

  int restaurantId = 1248;
  bool isLoading = true;
  MainDataResponse? menuResponse;
  BranchModel? nearestBranch;
  OrderType selectedOrderType = OrderType.delivery;
  int selectedCategoryIndex = 0;
  String selectedAddress = "";
  double? selectedLat;
  double? selectedLng;
  double deliveryCharge = 0.0;
  bool isDeliveryChargeLoading = false;
  List<Menu> searchResults = [];

  void startMenuLoading() {
    isLoading = true;
    searchResults.clear();
    selectedCategoryIndex = 0;
    notifyListeners();
  }

  void changeCategory(int index) {
    final categories = menuResponse?.data.restaurantBranchMenu ?? [];

    if (index < 0 || index > categories.length) {
      return;
    }

    if (selectedCategoryIndex == index) {
      return;
    }

    selectedCategoryIndex = index;
    notifyListeners();
  }

  void updateCategoryFromItem({required int itemIndex}) {
    final categories = menuResponse?.data.restaurantBranchMenu ?? [];

    if (categories.isEmpty) {
      return;
    }

    int currentIndex = 0;
    int runningCount = 0;

    for (int i = 0; i < categories.length; i++) {
      final itemCount = categories[i].menu.length;

      if (itemIndex < runningCount + itemCount) {
        currentIndex = i + 1;
        break;
      }

      runningCount += itemCount;
    }

    if (selectedCategoryIndex != currentIndex) {
      selectedCategoryIndex = currentIndex;

      notifyListeners();
    }
  }

  List<Menu> get selectedItems {
    final categories = menuResponse?.data.restaurantBranchMenu ?? [];

    if (categories.isEmpty) {
      return [];
    }

    if (selectedCategoryIndex == 0) {
      return categories.expand((category) => category.menu).toList();
    }

    final categoryIndex = selectedCategoryIndex - 1;

    if (categoryIndex < 0 || categoryIndex >= categories.length) {
      return [];
    }

    return categories[categoryIndex].menu;
  }

  void searchMenu(String query) {
    if (menuResponse == null) {
      return;
    }

    final search = query.trim().toLowerCase();

    if (search.isEmpty) {
      searchResults.clear();
      notifyListeners();
      return;
    }

    final allMenus = <Menu>[];

    for (final category in menuResponse!.data.restaurantBranchMenu) {
      allMenus.addAll(category.menu);
    }

    searchResults = allMenus.where((item) {
      final name = item.name.toLowerCase();
      final description = (item.description ?? "").toLowerCase();

      return name.contains(search) || description.contains(search);
    }).toList();

    notifyListeners();
  }

  Future<void> changeOrderType(
    OrderType type,
    int branchId,
    BuildContext context,
  ) async {
    selectedOrderType = type;

    notifyListeners();

    if (type == OrderType.pickup) {
      deliveryCharge = 0.0;

      await getMenu(branchId, 3);
    } else {
      await getMenu(branchId, 3);

      if (selectedLat != null && selectedLng != null) {
        final cartProvider = context.read<CartProvider>();

        await getDeliveryCharges(orderAmount: cartProvider.subtotal);
      }
    }

    final cartProvider = context.read<CartProvider>();

    await cartProvider.updatePricesForOrderType(
      orderType: type == OrderType.delivery ? "delivery" : "takeaway",
    );
  }

  Future<void> findNearestBranch() async {
    try {
      final position = await _locationService.getCurrentLocation();

      final response = await _branchRepo.getBranches();

      final branches = response.data;

      if (branches.isEmpty) {
        return;
      }

      branches.sort((a, b) {
        final distanceA = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          double.parse(a.latitude),
          double.parse(a.longitude),
        );

        final distanceB = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          double.parse(b.latitude),
          double.parse(b.longitude),
        );

        return distanceA.compareTo(distanceB);
      });

      nearestBranch = branches.first;
      notifyListeners();
    } catch (e) {}
  }

  void selectBranch(BranchModel branch) {
    nearestBranch = branch;

    notifyListeners();
  }

  Future<void> getMenu(int branchId, int orderResourceId) async {
    isLoading = true;

    searchResults.clear();
    selectedCategoryIndex = 0;
    notifyListeners();

    try {
      final response = await _menuRepo.getMenu(branchId, orderResourceId);
      menuResponse = response;
    } catch (e) {
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  Future<void> setDeliveryLocation({
    required String address,
    required double lat,
    required double lng,
    double? orderAmount,
  }) async {
    selectedAddress = address;
    selectedLat = lat;
    selectedLng = lng;
    notifyListeners();

    if (selectedOrderType == OrderType.delivery && orderAmount != null) {
      await getDeliveryCharges(orderAmount: orderAmount);
    }
  }

  Future<void> getDeliveryCharges({required double orderAmount}) async {
    final branchId = nearestBranch?.id ?? menuResponse?.data.id ?? 0;

    if (branchId == 0) {
      return;
    }

    if (selectedLat == null || selectedLng == null) {
      return;
    }

    isDeliveryChargeLoading = true;

    notifyListeners();

    try {
      final response = await _deliveryChargeRepo.getDeliveryCharges(
        branchId: branchId,
        latitude: selectedLat!,
        longitude: selectedLng!,
        orderAmount: orderAmount,
      );

      if (response.success) {
        deliveryCharge = response.deliveryCharge;
      } else {
        deliveryCharge = 0.0;
      }
    } catch (e) {
      deliveryCharge = 0.0;
    } finally {
      isDeliveryChargeLoading = false;

      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
