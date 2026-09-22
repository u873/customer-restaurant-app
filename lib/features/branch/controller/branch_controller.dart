import 'package:flutter/material.dart';
import '../../../core/services/location_service.dart';
import '../repo/branch_repo.dart';

import '../model/branch_response.dart';
import 'package:geolocator/geolocator.dart';

class BranchController extends ChangeNotifier {
  final BranchRepo _branchRepo = BranchRepo();
  bool isLoading = false;
  BranchResponse? branchResponse;
  BranchModel? selectedBranch;

  Future<void> getBranches() async {
    isLoading = true;
    notifyListeners();

    try {
      final position = await LocationService().getCurrentLocation();
      branchResponse = await _branchRepo.getBranches();
      // Position position = await Geolocator.getCurrentPosition();
      findNearestBranch(position.latitude, position.longitude);
    } catch (e) {
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }

  void findNearestBranch(double userLat, double userLng) {
    if (branchResponse == null) return;

    double shortestDistance = double.infinity;

    for (var branch in branchResponse!.data) {
      double branchLat = double.parse(branch.latitude);
      double branchLng = double.parse(branch.longitude);

      double distance = Geolocator.distanceBetween(
        userLat,
        userLng,
        branchLat,
        branchLng,
      );

      if (distance < shortestDistance) {
        shortestDistance = distance;
        selectedBranch = branch;
      }
    }

    print("Nearest Branch : ${selectedBranch?.name}");
    print("Branch Id : ${selectedBranch?.id}");

    notifyListeners();
  }

  void selectBranch(BranchModel branch) {
    selectedBranch = branch;
    notifyListeners();
  }
}
