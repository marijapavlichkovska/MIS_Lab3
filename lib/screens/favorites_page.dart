import 'package:flutter/material.dart';
import '../favorites_manager.dart';
import '../services/api_service.dart';
import '../models/meal_model.dart';
import '../widgets/meal_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final fav = FavoritesManager();
  final api = ApiService();

  List<Meal> _meals = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => loading = true);
    List<Meal> list = [];

    for (final id in fav.favorites) {
      final detail = await api.fetchMealDetail(id);
      list.add(Meal(
        id: detail.id,
        name: detail.name,
        thumbnail: detail.thumbnail,
      ));
    }

    setState(() {
      _meals = list;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorite Recipes")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : _meals.isEmpty
          ? const Center(child: Text("No favorites yet."))
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _meals.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, i) =>
            MealCard(meal: _meals[i]),
      ),
    );
  }
}
