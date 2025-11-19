import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/app_color.dart';
import '../../../core/app_extension.dart';
import '../../../core/app_style.dart';
import '../../business_logic/blocs/food/food_bloc.dart';
import '../../business_logic/blocs/theme/theme_bloc.dart';
import '../../data/model/food.dart';
import '../widget/counter_button.dart';
import '../widget/empty_widget.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      title: Text(
        "My Booking",
        style: Theme.of(context).textTheme.displayMedium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    final List<Food> cartFood = context.watch<FoodBloc>().getCartList;
    final double totalPrice = context.read<FoodBloc>().getTotalPrice;

    Widget cartListView() {
      return ListView.separated(
        padding: const EdgeInsets.all(30),
        shrinkWrap: true,
        itemCount: cartFood.length,
        itemBuilder: (_, index) {
          return Dismissible(
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                context.read<FoodBloc>().add(RemoveItemEvent(cartFood[index]));
              }
            },
            key: Key(cartFood[index].name),
            background: Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const FaIcon(FontAwesomeIcons.trash),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: context.read<ThemeBloc>().isLightTheme
                    ? Colors.white
                    : DarkThemeColor.primaryLight,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 20),
                  Image.asset(cartFood[index].image, scale: 10),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cartFood[index].name,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "\$${cartFood[index].price}",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Quantity: ${cartFood[index].quantity}",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      CounterButton(
                        onIncrementSelected: () => context
                            .read<FoodBloc>()
                            .add(IncreaseQuantityEvent(cartFood[index])),
                        onDecrementSelected: () => context
                            .read<FoodBloc>()
                            .add(DecreaseQuantityEvent(cartFood[index])),
                        size: const Size(24, 24),
                        padding: 0,
                        label: Text(
                          cartFood[index].quantity.toString(),
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                      Text(
                        "\$${context.read<FoodBloc>().pricePerEachItem(cartFood[index])}",
                        style: h2Style.copyWith(color: LightThemeColor.accent),
                      )
                    ],
                  )
                ],
              ),
            ).fadeAnimation(index * 0.6),
          );
        },
        separatorBuilder: (_, _) {
          return const Padding(padding: EdgeInsets.all(10));
        },
      );
    }

    Widget bottomAppBar() {
      return BottomAppBar(
        child: SizedBox(
          height: height * 0.32,
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Items Total",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            "\$${totalPrice - 5}",
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Service Fee",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            "\$${5.00}",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Booking Fee",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            "\$${2.00}",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(thickness: 4.0, height: 30.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Amount",
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          Text(
                            totalPrice == 5.0 ? "\$0.0" : "\$${totalPrice + 2}",
                            style: h2Style.copyWith(
                              color: LightThemeColor.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LightThemeColor.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Confirm Booking",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      bottomNavigationBar:
      cartFood.isNotEmpty ? bottomAppBar() : const SizedBox(),
      appBar: _appBar(context),
      body: EmptyWidget(
        title: "No Items Booked",
        subtitle: "Your booking list is empty",
        condition: cartFood.isNotEmpty,
        child: SingleChildScrollView(
          child: SizedBox(height: height * 0.5, child: cartListView()),
        ),
      ),
    );
  }
}