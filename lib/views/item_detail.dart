import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letzeat/provider/fav_provider.dart';
import 'package:letzeat/provider/quantity.dart';
import 'package:letzeat/widgets/icon_button.dart';
import 'package:letzeat/widgets/quantity.dart';
import 'package:provider/provider.dart';

class RecipeDetail extends StatefulWidget {
  final DocumentSnapshot<Object?> documentSnapshot;
  const RecipeDetail({super.key, required this.documentSnapshot});

  @override
  State<RecipeDetail> createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  @override
  Widget build(BuildContext context) {
    final provider = FavoriteProvider.of(context);
    final quantityProvider = Provider.of<QuantityProvider>(context);
    final List<String> ingredientsUrls =
        (widget.documentSnapshot['ingredients'] as List)
            .map((ingredient) => ingredient['img_url'] ?? '')
            .cast<String>()
            .toList();
    final List<String> ingredientsName =
        (widget.documentSnapshot['ingredients'] as List)
            .map((ingredient) => ingredient['name'] ?? '')
            .cast<String>()
            .toList();
    final List<int> ingredientsAmt =
        (widget.documentSnapshot['ingredients'] as List)
            .map((ingredient) => (ingredient['amt'] ?? 0) as int)
            .toList();

    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: startCookingSection(provider),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: widget.documentSnapshot['img_url'],
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.48,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            widget.documentSnapshot['img_url'],
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 10,
                    child: Row(
                      children: [
                        MyIconButton(
                          icon: Icons.arrow_back,
                          pressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.45,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 40,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.documentSnapshot['name'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Iconsax.flash_1, size: 20, color: Colors.grey),
                        Text(
                          "${widget.documentSnapshot['cal']}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          " . ",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.grey,
                          ),
                        ),
                        Icon(Iconsax.clock, size: 20, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(
                          "${widget.documentSnapshot['time']} min",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Iconsax.star1,
                          size: 20,
                          color: Colors.amberAccent,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "${widget.documentSnapshot['rating']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          " / 5.0",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "${widget.documentSnapshot['reviews'.toString()]} Reviews",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ingredients",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Total Servings: ",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        QuantityTool(
                          currentQuantity: quantityProvider.currentQuantity,
                          onAdd: () => quantityProvider.increment(),
                          onRemove: () => quantityProvider.decrement(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              children:
                                  ingredientsUrls
                                      .map(
                                        (e) => Container(
                                          margin: EdgeInsets.only(
                                            right: 10,
                                            bottom: 10,
                                          ),
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            image: DecorationImage(
                                              image: NetworkImage(e),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children:
                                  ingredientsName
                                      .map(
                                        (e) => Container(
                                          margin: EdgeInsets.only(
                                            right: 10,
                                            bottom: 10,
                                          ),
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              e,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                            const Spacer(),
                            Column(
                              children:
                                  ingredientsAmt
                                      .map(
                                        (e) => Container(
                                          margin: EdgeInsets.only(
                                            right: 10,
                                            bottom: 10,
                                          ),
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${e * quantityProvider.currentQuantity} g",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Column(
                      children: [
                        Text(
                          "Instructions",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "${widget.documentSnapshot['instructions']}",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 70),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  FloatingActionButton startCookingSection(FavoriteProvider provider) {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      onPressed: () {
        provider.toggleFavorite(widget.documentSnapshot.id);
      },
      child: Icon(
        provider.isFavorite(widget.documentSnapshot.id)
            ? Iconsax.heart5
            : Iconsax.heart,
        color:
            provider.isFavorite(widget.documentSnapshot.id)
                ? Colors.redAccent
                : Colors.black,
      ),
    );
  }
}
