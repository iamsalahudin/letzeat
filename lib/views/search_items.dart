import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letzeat/utils/constant.dart';
import 'package:letzeat/widgets/icon_button.dart';
import 'package:letzeat/views/item_detail.dart';
import 'package:letzeat/widgets/universal_image.dart';

class SearchItems extends StatefulWidget {
  final query;
  const SearchItems({super.key, this.query});

  @override
  State<SearchItems> createState() => _SearchItemsState();
}

class _SearchItemsState extends State<SearchItems> {
  Query get allRecipies => FirebaseFirestore.instance
      .collection('recipes')
      .where('search_params', arrayContains: widget.query.toLowerCase());
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          automaticallyImplyLeading: false,
          elevation: 0,
          actions: [
            const SizedBox(width: 15),
            MyIconButton(
              icon: Icons.arrow_back_ios_new,
              pressed: () {
                Navigator.pop(context);
              },
            ),
            Spacer(),
            Text(
              widget.query,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            const SizedBox(width: 80),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 5),
            child: Column(
              children: [
                SizedBox(height: 10),
                StreamBuilder(
                  stream: allRecipies.snapshots(),
                  builder: (
                    context,
                    AsyncSnapshot<QuerySnapshot> streamSnapshot,
                  ) {
                    if (streamSnapshot.hasData) {
                      return GridView.builder(
                        itemCount: streamSnapshot.data!.docs.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          final DocumentSnapshot documentSnapshot =
                              streamSnapshot.data!.docs[index];
                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => RecipeDetail(
                                          documentSnapshot: documentSnapshot,
                                        ),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(18),
                                    ),
                                    child: UniversalImage(
                                      imageUrl: documentSnapshot['img_url'],
                                      width: double.infinity,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          documentSnapshot['name'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Iconsax.flash_1,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(width: 3),
                                            Text(
                                              "${documentSnapshot['cal']} kcal",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "  ·  ",
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
                                            SizedBox(width: 3),
                                            Text(
                                              "${documentSnapshot['time']} min",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Iconsax.star1,
                                              size: 16,
                                              color: Colors.amberAccent,
                                            ),
                                            SizedBox(width: 3),
                                            Text(
                                              "${documentSnapshot['rating']}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              " / 5.0",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Flexible(
                                              child: Text(
                                                "${documentSnapshot['reviews'.toString()]} Reviews",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
