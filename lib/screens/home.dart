import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../models/category_model.dart';
import '../services/notification_service.dart';

class CategoriesHome extends StatefulWidget {
  const CategoriesHome({super.key});

  @override
  State<CategoriesHome> createState() => _CategoriesHomeState();
}

class _CategoriesHomeState extends State<CategoriesHome> {
  final ApiService api = ApiService();
  List<Map<String, dynamic>> _allCategories = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _scheduleDailyRecipeNotification();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await api.loadCategoriesRaw();
      setState(() {
        _allCategories = cats;
        _filtered = cats;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _filter(String q) {
    setState(() {
      if (q.trim().isEmpty) {
        _filtered = _allCategories;
      } else {
        _filtered = _allCategories
            .where((c) => (c['strCategory'] ?? '')
            .toString()
            .toLowerCase()
            .contains(q.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _scheduleDailyRecipeNotification() async {
    try {
      final meal = await api.fetchRandomMeal();
      await NotificationService().scheduleDailyNotification(
        id: 0,
        title: 'Recipe of the Day',
        body: meal.name,
        time: const TimeOfDay(hour: 17, minute: 20),
      );
    } catch (e) {
      print('Failed to schedule notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: () async {
              final meal = await api.fetchRandomMeal();
              Navigator.pushNamed(context, '/detail', arguments: meal);
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filter,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.8),
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final cat = _filtered[i];
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                      context, '/categoryMeals',
                      arguments: cat['strCategory']),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CachedNetworkImage(
                            imageUrl: cat['strCategoryThumb'] ?? '',
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (c, s) =>
                            const Center(child: CircularProgressIndicator()),
                            errorWidget: (c, s, e) => const Icon(Icons.error),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(cat['strCategory'] ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
