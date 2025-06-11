import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letzeat/provider/fav_provider.dart';
import 'package:letzeat/views/item_detail.dart';
import 'package:letzeat/widgets/universal_image.dart';

class ItemCard extends StatelessWidget {
  final DocumentSnapshot<Object?> documentSnapshot;
  const ItemCard({super.key, required this.documentSnapshot});

  @override
  Widget build(BuildContext context) {
    final provider = FavoriteProvider.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return RecipeDetail(documentSnapshot: documentSnapshot);
            },
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(right: 10),
        width: 230,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: documentSnapshot['img_url'],
                  child: UniversalImage(
                    imageUrl: documentSnapshot['img_url'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 160,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  documentSnapshot['name'],
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Iconsax.flash_1, size: 16, color: Colors.grey),
                    Text(
                      "${documentSnapshot['cal']}",
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
                    Icon(Iconsax.clock, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
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
              ],
            ),
            Positioned(
              top: 5,
              right: 5,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: InkWell(
                  onTap: () {
                    provider.toggleFavorite(documentSnapshot.id);
                  },
                  child: Icon(
                    provider.isFavorite(documentSnapshot.id)
                        ? Iconsax.heart5
                        : Iconsax.heart,
                    size: 20,
                    color:
                        provider.isFavorite(documentSnapshot.id)
                            ? Colors.redAccent
                            : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
