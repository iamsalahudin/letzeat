import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Each day maps to a map of meal type to a recipe map (or null)
  Map<String, Map<String, Map<String, dynamic>?>> mealPlan = {};

  // All available recipes from Firestore
  List<DocumentSnapshot> allRecipes = [];

  // All available meal plans from Firestore
  List<Map<String, dynamic>> savedMealPlans = [];

  bool _isLoading = false;
  bool _isSaving = false;

  // Only one meal plan in the database, always load the latest on page visit
  @override
  void initState() {
    super.initState();
    for (var day in weekDays) {
      mealPlan[day] = {for (var meal in dailyMeals) meal: null};
    }
    fetchRecipes();
    fetchAndLoadLatestMealPlan();
  }

  Future<void> fetchRecipes() async {
    setState(() {
      _isLoading = true;
    });
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('recipes').get();
    setState(() {
      allRecipes = snapshot.docs;
      _isLoading = false;
    });
  }

  Future<void> fetchAndLoadLatestMealPlan() async {
    setState(() {
      _isLoading = true;
    });
    final snapshot =
        await FirebaseFirestore.instance
            .collection('meal_plans')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();
    if (snapshot.docs.isNotEmpty) {
      final plan = snapshot.docs.first.data()['plan'] as Map<String, dynamic>;
      _loadMealPlan(plan);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _addMeal(String day, String mealType) async {
    // Set the category to the mealType (e.g., 'Breakfast', 'Lunch', 'Dinner')
    String selectedCategory = mealType;
    // Fetch filtered recipes for the selected meal type
    setState(() { _isLoading = true; });
    QuerySnapshot filteredRecipesSnapshot = await FirebaseFirestore.instance
        .collection('recipes')
        .where('category', isEqualTo: selectedCategory)
        .get();
    setState(() { _isLoading = false; });
    final filteredRecipes = filteredRecipesSnapshot.docs;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select a recipe for $mealType on $day'),
          content: SizedBox(
            height: 300,
            width: double.maxFinite,
            child: filteredRecipes.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  )
                : ListView.builder(
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final doc = filteredRecipes[index];
                      final docMap = doc.data() as Map<String, dynamic>;
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
        );
      },
    );
  }

  void _loadMealPlan(Map<String, dynamic> plan) {
    setState(() {
      for (final day in weekDays) {
        for (final mealType in dailyMeals) {
          final meal = plan[day]?[mealType];
          if (meal != null) {
            mealPlan[day]![mealType] = Map<String, dynamic>.from(meal);
          } else {
            mealPlan[day]![mealType] = null;
          }
        }
      }
    });
  }

  // Save the meal plan to Firestore in a new collection
  Future<void> _saveMealPlanToDatabase() async {
    setState(() {
      _isSaving = true;
    });
    final mealPlanData = <String, dynamic>{};
    for (final day in weekDays) {
      mealPlanData[day] = {};
      for (final mealType in dailyMeals) {
        final recipe = mealPlan[day]![mealType];
        if (recipe != null) {
          mealPlanData[day][mealType] = {
            'recipeId': recipe['recipeId'],
            'name': recipe['name'],
            'img_url': recipe['img_url'],
          };
        } else {
          mealPlanData[day][mealType] = null;
        }
      }
    }
    // Remove all previous plans and add only the latest
    final batch = FirebaseFirestore.instance.batch();
    final plansSnapshot =
        await FirebaseFirestore.instance.collection('meal_plans').get();
    for (final doc in plansSnapshot.docs) {
      batch.delete(doc.reference);
    }
    final newDoc = FirebaseFirestore.instance.collection('meal_plans').doc();
    batch.set(newDoc, {
      'createdAt': FieldValue.serverTimestamp(),
      'plan': mealPlanData,
    });
    await batch.commit();
    setState(() {
      _isSaving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meal plan saved to database!'),
        backgroundColor: Colors.green,
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
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: kBannerColor,
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                tooltip: 'Save Meal Plan',
                onPressed: _isSaving ? null : _saveMealPlanToDatabase,
              ),
            ],
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
                              Row(
                                children: [
                                  Text(
                                    day,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Column(
                                children:
                                    dailyMeals.map((mealType) {
                                      final recipe = meals[mealType];
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading:
                                            recipe != null
                                                ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
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
                                                : const Text(
                                                  'No meal selected',
                                                ),
                                        trailing: IconButton(
                                          icon: Icon(
                                            recipe == null
                                                ? Icons.add_circle
                                                : Icons.edit,
                                            color: kBannerColor,
                                          ),
                                          onPressed:
                                              () => _addMeal(day, mealType),
                                        ),
                                      );
                                    }).toList(),
                              ),
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
