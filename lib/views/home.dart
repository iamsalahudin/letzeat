import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letzeat/utils/constant.dart';
import 'package:letzeat/views/view_all_items.dart';
import 'package:letzeat/widgets/banner.dart';
import 'package:letzeat/widgets/icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letzeat/widgets/item_card.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String category = 'All';
  // Firestore collection reference for categories
  final CollectionReference categoriesItems = FirebaseFirestore.instance
      .collection('categories');
  // Firestore collection reference for recipes
  Query get filteredRecipies => FirebaseFirestore.instance
      .collection('recipes')
      .where('category', isEqualTo: category);
  Query get allRecipies => FirebaseFirestore.instance.collection('recipes');
  Query get selectedRecipies =>
      category == 'All' ? allRecipies : filteredRecipies;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerParts(),
                    searchBar(),
                    const BannerToExplore(),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    categoriesSection(),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "Quick & Easy",
                          style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 0.1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ViewAllItems(),
                              ),
                            );
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(
                              color: kBannerColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    StreamBuilder(
                      stream: selectedRecipies.snapshots(),
                      builder: (
                        context,
                        AsyncSnapshot<QuerySnapshot> snapshot,
                      ) {
                        if (snapshot.hasData) {
                          final List<DocumentSnapshot> recipes =
                              snapshot.data?.docs ?? [];
                          return Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children:
                                    recipes
                                        .map(
                                          (e) => ItemCard(documentSnapshot: e),
                                        )
                                        .toList(),
                              ),
                            ),
                          );
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            color: kPrimaryColor,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> categoriesSection() {
    return StreamBuilder(
      stream: categoriesItems.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
        if (streamSnapshot.hasData) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                streamSnapshot.data!.docs.length,
                (Index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      category = streamSnapshot.data!.docs[Index]['name'];
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color:
                          category == streamSnapshot.data!.docs[Index]['name']
                              ? kPrimaryColor
                              : Colors.white,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 7,
                    ),
                    margin: EdgeInsets.only(right: 15),
                    child: Text(
                      streamSnapshot.data!.docs[Index]['name'],
                      style: TextStyle(
                        color:
                            category == streamSnapshot.data!.docs[Index]['name']
                                ? Colors.white
                                : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return Center(child: CircularProgressIndicator(color: kPrimaryColor));
      },
    );
  }

  Padding searchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 22),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          prefixIcon: Icon(Iconsax.search_normal, color: Colors.grey),
          fillColor: Colors.white,
          border: InputBorder.none,
          hintText: 'Search for recipes...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Row headerParts() {
    return Row(
      children: [
        const Text(
          'What are you\ncooking today?',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const Spacer(),
        MyIconButton(icon: Iconsax.notification, pressed: () {}),
      ],
    );
  }
}
