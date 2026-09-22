import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../branch/controller/branch_controller.dart';
import '../../menu/controller/menu_controller.dart';
import '../../../core/theme/app_colors.dart';

class BranchSelectionSheet extends StatefulWidget {
  const BranchSelectionSheet({super.key});

  @override
  State<BranchSelectionSheet> createState() => _BranchSelectionSheetState();
}

class _BranchSelectionSheetState extends State<BranchSelectionSheet> {
  bool isSelecting = false;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BranchController>();

    final branches = controller.branchResponse?.data ?? [];

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top handle
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 18),

          // Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select Branch",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      "Choose a branch to continue",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Branch list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: branches.length,
            itemBuilder: (context, index) {
              final branch = branches[index];

              final selected = controller.selectedBranch?.id == branch.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.foodCardBackground,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: selected ? 1.2 : 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: isSelecting
                        ? null
                        : () async {

                            setState(() {
                              isSelecting = true;
                            });

                            final menuProvider = context.read<MenuProvider>();

                            menuProvider.startMenuLoading();

                            controller.selectBranch(branch);
                            if (!context.mounted) {
                              return;
                            }

                            Navigator.pop(context);

                            await menuProvider.changeOrderType(
                              menuProvider.selectedOrderType,
                              branch.id,
                              context,
                            );
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      child: Row(
                        children: [
                          // Branch icon
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary.withOpacity(0.12)
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.store_outlined,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.iconSecondary,
                              size: 21,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Branch information
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  branch.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  branch.address,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Selection indicator
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.iconSecondary.withOpacity(0.55),
                                width: 1.5,
                              ),
                            ),
                            child: selected
                                ? Center(
                                    child: Container(
                                      width: 11,
                                      height: 11,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
