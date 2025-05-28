import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letzeat/provider/fav_provider.dart';
import 'package:letzeat/utils/constant.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  @override
  Widget build(BuildContext context) {
    final provider = FavoriteProvider.of(context);
    final favoriteItems = provider.favoriteItems;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        centerTitle: true,
        title: Text('Favorites', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body:
          favoriteItems.isEmpty
              ? const Center(
                child: Text(
                  'No favorite items yet!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : ListView.builder(
                itemCount: favoriteItems.length,
                itemBuilder: (context, index) {
                  final items = favoriteItems[index];
                  return FutureBuilder<DocumentSnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection("recipes")
                            .doc(items)
                            .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Container(
                            margin: EdgeInsets.only(top: 20),
                            child: CircularProgressIndicator(
                              color: kPrimaryColor,
                            ),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Center(child: Text('Error loading favorites'));
                      }
                      var favoriteItem = snapshot.data!;
                      return Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white,
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          favoriteItem['img_url'],
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        favoriteItem['name'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(
                                            Iconsax.flash_1,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          Text(
                                            "${favoriteItem['cal']}",
                                            style: TextStyle(
                                              fontSize: 12,
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
                                          Icon(
                                            Iconsax.clock,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            "${favoriteItem['time']} min",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  IconButton(
                                    icon: Icon(
                                      Iconsax.trash,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      provider.toggleFavorite(favoriteItem);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
    );
  }
}
