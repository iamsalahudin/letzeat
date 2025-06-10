import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:letzeat/utils/constant.dart';

class MealPlan extends StatefulWidget {
  const MealPlan({super.key});

  @override
  State<MealPlan> createState() => _MealPlanState();
}

class _MealPlanState extends State<MealPlan> {
  final List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<String> dailyMeals = ['Breakfast', 'Lunch', 'Dinner'];

  Map<String, Map<String, Map<String, dynamic>?>> mealPlan = {};
  List<DocumentSnapshot> allRecipes = [];

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    for (var day in weekDays) {
      mealPlan[day] = {for (var meal in dailyMeals) meal: null};
    }
    fetchRecipes();
    fetchMealPlanByUser();
  }

  Future<void> fetchRecipes() async {
    setState(() => _isLoading = true);
    final snapshot =
        await FirebaseFirestore.instance.collection('recipes').get();
    setState(() {
      allRecipes = snapshot.docs;
      _isLoading = false;
    });
  }

  Future<void> fetchMealPlanByUser() async {
    setState(() => _isLoading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('meal_plans')
              .doc(uid)
              .get();
      if (doc.exists && doc.data()?['plan'] != null) {
        _loadMealPlan(doc['plan']);
      }
    }

    setState(() => _isLoading = false);
  }

  void _loadMealPlan(Map<String, dynamic> plan) {
    setState(() {
      for (final day in weekDays) {
        for (final mealType in dailyMeals) {
          final meal = plan[day]?[mealType];
          mealPlan[day]![mealType] =
              meal != null ? Map<String, dynamic>.from(meal) : null;
        }
      }
    });
  }

  Future<void> _saveMealPlanToDatabase() async {
    setState(() => _isSaving = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not logged in")));
      setState(() => _isSaving = false);
      return;
    }

    final mealPlanData = <String, dynamic>{};
    for (final day in weekDays) {
      mealPlanData[day] = {};
      for (final mealType in dailyMeals) {
        final recipe = mealPlan[day]![mealType];
        mealPlanData[day][mealType] =
            recipe != null
                ? {
                  'recipeId': recipe['recipeId'],
                  'name': recipe['name'],
                  'img_url': recipe['img_url'],
                }
                : null;
      }
    }

    await FirebaseFirestore.instance.collection('meal_plans').doc(uid).set({
      'plan': mealPlanData,
    });

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meal plan saved!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addMeal(String day, String mealType) async {
    setState(() => _isLoading = true);

    final snapshot =
        await FirebaseFirestore.instance
            .collection('recipes')
            .where('category', isEqualTo: mealType)
            .get();

    final filteredRecipes = snapshot.docs;

    setState(() => _isLoading = false);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Select a recipe for $mealType on $day'),
            content: SizedBox(
              height: 300,
              width: 300, // Use a fixed width instead of double.infinity
              child:
                  filteredRecipes.isEmpty
                      ? const Center(child: Text("No recipes found"))
                      : ListView.builder(
                        itemCount: filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final doc = filteredRecipes[index];
                          final docMap = doc.data();
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                docMap['img_url'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(docMap['name']),
                            onTap: () {
                              setState(() {
                                mealPlan[day]![mealType] = {
                                  ...docMap,
                                  'recipeId': doc.id,
                                };
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Weekly Meal Plan'),
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: kBannerColor,
            actions: [
              IconButton(
                icon: const Icon(Icons.save, color: Colors.white),
                onPressed: _isSaving ? null : _saveMealPlanToDatabase,
              ),
            ],
            automaticallyImplyLeading: false,
          ),
          body:
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  )
                  : ListView.builder(
                    itemCount: weekDays.length,
                    itemBuilder: (context, index) {
                      final day = weekDays[index];
                      final meals = mealPlan[day]!;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                day,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...dailyMeals.map((mealType) {
                                final recipe = meals[mealType];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading:
                                      recipe != null
                                          ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              recipe['img_url'],
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                          : const Icon(
                                            Icons.fastfood,
                                            color: Colors.grey,
                                          ),
                                  title: Text(mealType),
                                  subtitle:
                                      recipe != null
                                          ? Text(recipe['name'])
                                          : const Text('No meal selected'),
                                  trailing: IconButton(
                                    icon: Icon(
                                      recipe == null
                                          ? Icons.add_circle
                                          : Icons.edit,
                                      color: kBannerColor,
                                    ),
                                    onPressed: () => _addMeal(day, mealType),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
        if (_isSaving)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: kPrimaryColor),
                  SizedBox(height: 16),
                  Text(
                    'Saving meal plan...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
