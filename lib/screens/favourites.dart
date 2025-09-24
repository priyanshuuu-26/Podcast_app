import 'package:flutter/material.dart';
import '../models/model.dart';
import '../services/storage_service.dart';
import '../widgets/podcast_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final StorageService _storageService = StorageService();
  late Future<List<Podcast>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favoritesFuture = _storageService.getFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Podcast>>(
      future: _favoritesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'You have no favorite podcasts yet.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final favorites = snapshot.data!;
        return ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final podcast = favorites[index];
            return PodcastCard(
              podcast: podcast,
              // When a favorite is toggled on this screen, reload the list
              onFavoriteChanged: _loadFavorites,
            );
          },
        );
      },
    );
  }
}