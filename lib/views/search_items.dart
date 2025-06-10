import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letzeat/utils/constant.dart';
import 'package:letzeat/widgets/icon_button.dart';
import 'package:letzeat/widgets/item_card.dart';

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
                          childAspectRatio: 0.85,
                        ),
                        itemBuilder: (context, index) {
                          final DocumentSnapshot documentSnapshot =
                              streamSnapshot.data!.docs[index];
                          return Column(
                            children: [
                              ItemCard(documentSnapshot: documentSnapshot),
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.star1,
                                    size: 20,
                                    color: Colors.amberAccent,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "${documentSnapshot['rating']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    " / 5.0",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "${documentSnapshot['reviews'.toString()]} Reviews",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
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
