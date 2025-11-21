import 'package:badges/badges.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/app_color.dart';
import '../../../core/app_extension.dart';
import '../../../core/services/auth_service.dart'; // ✅ import AuthService
import '../../business_logic/blocs/category/category_bloc.dart';
import '../../business_logic/blocs/food/food_bloc.dart' show FoodBloc;
import '../../business_logic/blocs/theme/theme_bloc.dart';
import '../../data/model/food.dart';
import '../../data/model/food_category.dart';
import '../widget/food_list_view.dart';
import '../widget/ai_floating_button.dart';

class FoodListScreen extends HookWidget {
  const FoodListScreen({super.key});

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const FaIcon(FontAwesomeIcons.dice),
        onPressed: () => context.read<ThemeBloc>().add(const ThemeEvent()),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_on_outlined, color: LightThemeColor.accent),
          Text("Location", style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Badge(
            badgeStyle: const BadgeStyle(badgeColor: LightThemeColor.accent),
            badgeContent: const Text("2", style: TextStyle(color: Colors.white)),
            position: BadgePosition.topStart(start: -3),
            child: const Icon(Icons.notifications_none, size: 30),
          ),
        )
      ],
    );
  }

  Widget _searchBar() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search food',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          contentPadding: EdgeInsets.all(20),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Morning";
    } else if (hour < 17) {
      return "Afternoon";
    } else {
      return "Evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = useState<String>("Food Hunter");

    // ✅ Load username once after widget mounts
    useEffect(() {
      Future.microtask(() async {
        final user = await AuthService.getCurrentUser();
        if (user != null && user['name'] != null) {
          username.value = user['name'];
        }
      });
      return null;
    }, []);

    final List<Food> foodList = context.watch<FoodBloc>().state.foodList;
    final List<FoodCategory> categories =
        context.watch<CategoryBloc>().state.foodCategories;
    final List<Food> filteredFood =
        context.watch<CategoryBloc>().state.foodList;

    return Scaffold(
      appBar: _appBar(context),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${_getGreeting()}, ${username.value}",
                style: Theme.of(context).textTheme.headlineSmall,
              ).fadeAnimation(0.2),
              Text(
                "What do you want to eat \ntoday",
                style: Theme.of(context).textTheme.displayLarge,
              ).fadeAnimation(0.4),
              _searchBar(),
              Text("Available for you",
                  style: Theme.of(context).textTheme.displaySmall),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (_, index) {
                      FoodCategory category = categories[index];
                      return GestureDetector(
                        onTap: () => context
                            .read<CategoryBloc>()
                            .add(CategoryEvent(category: category)),
                        child: Container(
                          width: 100,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: category.isSelected
                                ? LightThemeColor.accent
                                : Colors.transparent,
                            borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                          ),
                          child: Text(
                            category.type.name.toCapital,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, _) =>
                    const Padding(padding: EdgeInsets.only(right: 15)),
                  ),
                ),
              ),
              FoodListView(foods: filteredFood),
              Padding(
                padding: const EdgeInsets.only(top: 25, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Best food of the week",
                        style: Theme.of(context).textTheme.displaySmall),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text("See all",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(color: LightThemeColor.accent)),
                    ),
                  ],
                ),
              ),
              FoodListView(foods: foodList, isReversedList: true),
            ],
          ),
        ),
      ),
      floatingActionButton: const AIFloatingButton(),
    );
  }
}
