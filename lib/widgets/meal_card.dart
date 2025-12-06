import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/meal_model.dart';
import '../favorites_manager.dart';

class MealCard extends StatefulWidget {
  final Meal meal;
  const MealCard({super.key, required this.meal});

  @override
  State<MealCard> createState() => _MealCardState();
}
class _MealCardState extends State<MealCard> {
  final fav = FavoritesManager();

  Widget build(BuildContext context) {
    final isFav = fav.isFavorite(widget.meal.id);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(
                  context,
                  '/detail',
                  arguments: widget.meal.id,
                ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: CachedNetworkImage(
                      imageUrl: widget.meal.thumbnail,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Divider(),
                  Text(
                    widget.meal.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 6,
            top: 6,
            child: IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: Colors.red.shade900,
              ),
              onPressed: () {
                setState(() {
                  fav.toggleFavorite(widget.meal.id);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}