import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letzeat/utils/constant.dart';
import 'package:letzeat/widgets/icon_button.dart';
import 'package:letzeat/widgets/item_card.dart';

class ViewAllItems extends StatefulWidget {
  const ViewAllItems({super.key});

  @override
  State<ViewAllItems> createState() => _ViewAllItemsState();
}

class _ViewAllItemsState extends State<ViewAllItems> {
  Query get allRecipies => FirebaseFirestore.instance.collection('recipes');
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
              'Quick & Easy',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            MyIconButton(icon: Iconsax.notification, pressed: () {}),
            const SizedBox(width: 15),
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
                          childAspectRatio: 0.65, // Keep items tall
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          final DocumentSnapshot documentSnapshot =
                              streamSnapshot.data!.docs[index];
                          return Padding(
                            padding: const EdgeInsets.all(5),
                            child: SizedBox(
                              height:
                                  260, // Set a fixed height to prevent overflow
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    ItemCard(
                                      documentSnapshot: documentSnapshot,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                        Flexible(
                                          child: Text(
                                            "${documentSnapshot['reviews'.toString()]} Reviews",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
