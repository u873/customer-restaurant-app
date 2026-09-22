import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../menu/controller/menu_controller.dart';

class BannerSlider extends StatelessWidget {
  const BannerSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MenuProvider>();

    if (provider.menuResponse == null) {
      return const SizedBox();
    }

    final banners = provider.menuResponse!.data.banners;

    if (banners.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12,),
      child: CarouselSlider.builder(
        itemCount: banners.length,

        itemBuilder: (context, index, realIndex,) {
          final banner = banners[index];
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xff292A2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),

              child: Image.network(
                banner.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,

                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.white38,
                      size: 35,
                    ),
                  );
                },
              ),
            ),
          );
        },

        options: CarouselOptions(
          height: 105,
          viewportFraction: 1,
          enlargeCenterPage: false,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 4),
          autoPlayAnimationDuration: const Duration(milliseconds: 500),
          enableInfiniteScroll: banners.length > 1,
        ),
      ),
    );
  }
}