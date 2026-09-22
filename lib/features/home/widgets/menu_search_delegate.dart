import 'package:customer_estaurant_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../menu/controller/menu_controller.dart';
import '../../menu/view/deal_screen.dart';
import '../../menu/view/product_detail_screen.dart';

class MenuSearchDelegate extends SearchDelegate {
  MenuSearchDelegate()
  : super(
    searchFieldLabel: "Search Food...",
    searchFieldStyle: TextStyle(
      color: Colors.white,
      fontSize: 14
    )
  );
  @override
  ThemeData appBarTheme(BuildContext context){
    return Theme.of(context).copyWith(
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: Colors.white,
        ),
        border: InputBorder.none,
      ),
        textTheme: TextTheme(
        bodyLarge: TextStyle(
        color: Colors.white,
    )
    )
    );
  }
  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final provider = context.read<MenuProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (query.trim().isNotEmpty) {
        provider.searchMenu(query);
      } else {
        provider.searchMenu('');
      }
    });

    if (query.trim().isEmpty) {
      return const Center(
        child: Text("Search food items..."),
      );
    }

    return const SearchResultList();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }
}

class SearchResultList extends StatelessWidget {
  const SearchResultList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MenuProvider>();
    final items = provider.searchResults;

    if (items.isEmpty) {
      return const Center(
        child: Text("No item found"),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return ListTile(
          leading: ClipOval(
            child: Image.network(
              item.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) {
                return const Icon(
                  Icons.fastfood,
                  size: 35,
                );
              },
            ),
          ),

          title: Text(item.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),),

          subtitle: Text(
            "Rs ${item.price}",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12
            ),
          ),

          onTap: () {
         //  Navigator.pop(context);
            if (item.isDeal == true) {
              Navigator.push(
                context,
                MaterialPageRoute(
                //  builder: (_) => DealScreen(
                    builder: (detailContext) => DealScreen(
                    item: item,
                    onClose: (){
                      Navigator.pop(detailContext);
                    },
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // builder: (_) => ProductDetailScreen(
                  builder: (detailContext) => ProductDetailScreen(
                    item: item,
                    onClose: (){
                      Navigator.pop(detailContext);
                    },
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}