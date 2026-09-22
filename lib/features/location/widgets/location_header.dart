import 'package:customer_estaurant_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LocationHeader extends StatelessWidget {
  const LocationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child:
    Padding(padding: EdgeInsetsGeometry.fromLTRB(16, 12, 16, 8),
    child: Row(
        children: [
          InkWell(
        onTap: (){
          Navigator.pop(context);
    },
            child : Padding(padding: EdgeInsets.all(16),
      child: Icon(Icons.arrow_back_ios_new_rounded,
      color: AppColors.primary,
        size: 22,
      ),
    )
          ),
          Expanded(child: Center(
            child: Text("Select Location",
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),),
          )),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: (){

            },
            child: const Padding(padding: 
            EdgeInsetsGeometry.all(16),
            child: Icon(Icons.search,
            size: 24,
            color: AppColors.primary),
            ),
          )
      ],
    ),
    ),
    );
  }
}
