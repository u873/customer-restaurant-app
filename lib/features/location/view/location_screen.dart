import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../address/controller/address_controller.dart';
import '../../address/model/customer_address.dart';
import '../controller/location_controller.dart';

class LocationScreen extends StatefulWidget {
  final VoidCallback? onClose;
  final int addressTypeId;
  final CustomerAddress? existingAddress;
  final Future<void> Function()? onAddressSaved;

  const LocationScreen({
    super.key,
    this.onClose,
    required this.addressTypeId,
    this.existingAddress,
    this.onAddressSaved,
  });

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late final TextEditingController _searchController;
  late final TextEditingController _addressDetailsController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    _addressDetailsController = TextEditingController();
    _searchFocusNode = FocusNode();

    Future.microtask(() async {
      if (!mounted) return;

      final locationController = context.read<LocationController>();

      locationController.clearSuggestions();

      if (widget.existingAddress != null) {
        await locationController.setInitialLocation(
          latitude: widget.existingAddress!.latitude,
          longitude: widget.existingAddress!.longitude,
        );
      } else {
        await locationController.getCurrentLocation();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _addressDetailsController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  Future<void> _selectPlace(
    PlaceSuggestion suggestion,
    LocationController locationController,
  ) async {
    FocusScope.of(context).unfocus();

    await locationController.selectPlace(suggestion);

    if (!mounted) return;

    _searchController.clear();
    locationController.clearSuggestions();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
    final locationController = context.read<LocationController>();
    locationController.clearSuggestions();
    await locationController.searchLocation(query);
  }

  Future<void> _saveAddress() async {
    final locationController = context.read<LocationController>();
    final addressController = context.read<AddressController>();
    final manualDetails = _addressDetailsController.text.trim();
    final mapAddress = locationController.address.trim();

    final addressParts = <String>[];

    if (manualDetails.isNotEmpty) {
      addressParts.add(manualDetails);
    }

    if (mapAddress.isNotEmpty &&
        mapAddress != "Finding location" &&
        mapAddress != "Location not found") {
      addressParts.add(mapAddress);
    }

    final uniqueParts = <String>[];

    for (final part in addressParts) {
      final normalized = part.trim().toLowerCase();

      final alreadyExists = uniqueParts.any(
        (existing) => existing.trim().toLowerCase() == normalized,
      );

      if (!alreadyExists) {
        uniqueParts.add(part.trim());
      }
    }

    final finalAddress = uniqueParts.join(", ");

    if (finalAddress.isEmpty) {
      _showMessage("Please enter your address.");
      return;
    }

    final success = await addressController.addOrEditAddress(
      addressTypeId: widget.addressTypeId,
      existingAddress: widget.existingAddress,
      address: finalAddress,
      latitude: locationController.currentLatLng.latitude,
      longitude: locationController.currentLatLng.longitude,
    );

    if (!mounted) return;

    if (!success) {
      _showMessage(addressController.errorMessage ?? "Failed to save address.");
      return;
    }

    await widget.onAddressSaved?.call();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            message,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
  }

  BoxDecoration _floatingDecoration({double radius = 18}) {
    return BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border.withOpacity(0.8)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.28),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: Consumer<LocationController>(
        builder: (context, locationController, child) {
          return Stack(
            children: [
              Positioned.fill(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: locationController.currentLatLng,
                    zoom: 16,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  onMapCreated: locationController.setMapController,
                  onCameraMove: locationController.onCameraMove,
                  onCameraIdle: locationController.onCameraIdle,
                ),
              ),
              const Center(
                child: IgnorePointer(
                  child: Icon(Icons.location_pin, size: 48, color: Colors.red),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                  child: Container(
                    height: 54,
                    decoration: _floatingDecoration(radius: 17),
                    child: Row(
                      children: [
                        // Back
                        InkWell(
                          borderRadius: BorderRadius.circular(17),
                          onTap: () {
                            locationController.clearSuggestions();
                            FocusScope.of(context).unfocus();
                            widget.onClose?.call();
                          },
                          child: const SizedBox(
                            width: 52,
                            height: 54,
                            child: Icon(
                              Icons.arrow_back,
                              size: 24,
                              color: AppColors.iconPrimary,
                            ),
                          ),
                        ),

                        Container(
                          width: 1,
                          height: 24,
                          color: AppColors.border,
                        ),
                        // Search input
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            textInputAction: TextInputAction.search,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                            onChanged: (value) {
                              locationController.searchPlaces(value);
                            },
                            onSubmitted: (_) {
                              _performSearch();
                            },
                            decoration: const InputDecoration(
                              hintText: "Search your location",
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14.5,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 13,
                              ),
                            ),
                          ),
                        ),

                        // Search
                        InkWell(
                          borderRadius: BorderRadius.circular(17),
                          onTap: _performSearch,
                          child: SizedBox(
                            width: 52,
                            height: 54,
                            child: locationController.isSearching
                                ? const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.search,
                                    size: 24,
                                    color: AppColors.iconPrimary,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (locationController.suggestions.isNotEmpty)
                Positioned(
                  left: 66,
                  right: 66,
                  top: 76,
                  child: SafeArea(
                    top: false,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 230),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: locationController.suggestions.length,
                          separatorBuilder: (_, __) {
                            return Divider(height: 1, color: AppColors.border);
                          },
                          itemBuilder: (context, index) {
                            final suggestion =
                                locationController.suggestions[index];

                            return InkWell(
                              onTap: () {
                                _selectPlace(suggestion, locationController);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.12,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.location_on_outlined,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        suggestion.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          height: 1.3,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 14,
                bottom: 265,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      locationController.clearSuggestions();
                      await locationController.getCurrentLocation();
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: _floatingDecoration(radius: 15),
                      child: const Icon(
                        Icons.my_location,
                        size: 22,
                        color: AppColors.iconPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Consumer<AddressController>(
                  builder: (context, addressController, child) {
                    final isSaving = addressController.isSaving;

                    return Container(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.30),
                            blurRadius: 22,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Drag handle
                            Center(
                              child: Container(
                                width: 36,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.border,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),

                            const SizedBox(height: 13),

                            // Header
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    "Confirm your location",
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),

                                // Location icon
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: AppColors.primary,
                                    size: 19,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Selected address
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.place_outlined,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      locationController.address.isEmpty
                                          ? "Finding location..."
                                          : locationController.address,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 11),

                            // Manual details
                            TextField(
                              controller: _addressDetailsController,
                              maxLines: 2,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13.5,
                              ),
                              decoration: InputDecoration(
                                hintText: "House no, flat, street, building...",
                                hintStyle: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                                filled: true,
                                fillColor: AppColors.cardBackground,
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 13,
                                  vertical: 11,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Save
                            SizedBox(
                              width: double.infinity,
                              height: 49,
                              child: ElevatedButton(
                                onPressed: isSaving ? null : _saveAddress,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.textOnPrimary,
                                  disabledBackgroundColor: AppColors.primary
                                      .withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: AppColors.textOnPrimary,
                                        ),
                                      )
                                    : const Text(
                                        "Save Address",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
