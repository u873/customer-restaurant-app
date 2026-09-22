import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/address_controller.dart';
import '../model/customer_address.dart';

class CustomerAddressesScreen extends StatefulWidget {
  final VoidCallback onClose;
  final void Function(CustomerAddress address) onAddressSelected;
  final bool selectionOnly;
  final void Function(int addressTypeId, CustomerAddress? existingAddress)
  onOpenLocation;

  const CustomerAddressesScreen({
    super.key,
    required this.onClose,
    required this.onAddressSelected,
    this.selectionOnly = false,
    required this.onOpenLocation,
  });

  @override
  State<CustomerAddressesScreen> createState() =>
      _CustomerAddressesScreenState();
}

class _CustomerAddressesScreenState extends State<CustomerAddressesScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<AddressController>().getCustomerAddresses();
    });
  }

  CustomerAddress? _getAddressByType(
    List<CustomerAddress> addresses,
    int typeId,
  ) {
    try {
      return addresses.firstWhere((address) => address.addressTypeId == typeId);
    } catch (_) {
      return null;
    }
  }

  void _selectAddress(CustomerAddress address) {
    final controller = context.read<AddressController>();

    controller.selectAddress(address);
    widget.onAddressSelected(address);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddressController>();

    final home = _getAddressByType(controller.addresses, 3);
    final flat = _getAddressByType(controller.addresses, 4);
    final office = _getAddressByType(controller.addresses, 5);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: widget.onClose,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 17,
          ),
        ),
        title: const Text(
          "My Addresses",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: controller.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : controller.errorMessage != null
          ? _ErrorView(
              message: controller.errorMessage!,
              onRetry: controller.getCustomerAddresses,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
              children: [
                _AddressCard(
                  title: "Home",
                  icon: Icons.home_rounded,
                  address: home,
                  selected:
                      controller.selectedAddress?.addressId == home?.addressId,
                  selectionOnly: widget.selectionOnly,
                  onSelect: () {
                    if (home != null) {
                      _selectAddress(home);
                    } else {
                      widget.onOpenLocation(3, null);
                    }
                  },
                  onEdit: (!widget.selectionOnly && home != null)
                      ? () {
                          widget.onOpenLocation(3, home);
                        }
                      : null,
                ),
                _AddressCard(
                  title: "Flat",
                  icon: Icons.apartment_rounded,
                  address: flat,
                  selected:
                      controller.selectedAddress?.addressId == flat?.addressId,
                  selectionOnly: widget.selectionOnly,
                  onSelect: () {
                    if (flat != null) {
                      _selectAddress(flat);
                    } else {
                      widget.onOpenLocation(4, null);
                    }
                  },
                  onEdit: (!widget.selectionOnly && flat != null)
                      ? () {
                          widget.onOpenLocation(4, flat);
                        }
                      : null,
                ),
                _AddressCard(
                  title: "Office",
                  icon: Icons.business_rounded,
                  address: office,
                  selected:
                      controller.selectedAddress?.addressId ==
                      office?.addressId,
                  selectionOnly: widget.selectionOnly,
                  onSelect: () {
                    if (office != null) {
                      _selectAddress(office);
                    } else {
                      widget.onOpenLocation(5, null);
                    }
                  },
                  onEdit: (!widget.selectionOnly && office != null)
                      ? () {
                          widget.onOpenLocation(5, office);
                        }
                      : null,
                ),
              ],
            ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final CustomerAddress? address;
  final bool selected;
  final bool selectionOnly;
  final VoidCallback onSelect;
  final VoidCallback? onEdit;

  const _AddressCard({
    required this.title,
    required this.icon,
    required this.address,
    required this.selected,
    required this.selectionOnly,
    required this.onSelect,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = address == null;

    return GestureDetector(
      onTap: onSelect,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : isEmpty
                ? Colors.white12
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.foodCardBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (isEmpty)
                    Text(
                      "Tap to add $title address",
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                    )
                  else
                    Text(
                      address!.address1,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        height: 1.3,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isEmpty)
              const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.primary,
                size: 22,
              )
            else ...[
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              if (!selectionOnly && onEdit != null) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onEdit,
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white54,
                    size: 19,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white54, size: 40),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              "Retry",
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
