import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/model.dart';

class StorageService {
  // --- Favorite Podcast Methods ---

  /// Saves a podcast to local storage as a favorite.
  Future<void> saveFavorite(Podcast podcast) async {
    final prefs = await SharedPreferences.getInstance();
    String podcastJson = jsonEncode(podcast.toJson());
    // We use a 'fav_' prefix to distinguish favorite keys.
    await prefs.setString('fav_${podcast.id.toString()}', podcastJson);
  }

  /// Removes a podcast from favorites.
  Future<void> removeFavorite(String podcastId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fav_$podcastId');
  }

  /// Retrieves all saved favorite podcasts.
  Future<List<Podcast>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('fav_'));
    List<Podcast> favoritePodcasts = [];
    for (String key in keys) {
      final podcastJson = prefs.getString(key);
      if (podcastJson != null) {
        favoritePodcasts.add(Podcast.fromJson(jsonDecode(podcastJson)));
      }
    }
    return favoritePodcasts;
  }

  /// Checks if a specific podcast is already in favorites.
  Future<bool> isFavorite(String podcastId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('fav_$podcastId');
  }

  /// Returns the number of favorite podcasts.
  Future<int> getFavoritesCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys().where((key) => key.startsWith('fav_')).length;
  }

  // --- Listened Podcast Methods ---

  /// Saves a podcast to the listened list.
  Future<void> addToListened(Podcast podcast) async {
    final prefs = await SharedPreferences.getInstance();
    String podcastJson = jsonEncode(podcast.toJson());
    // Use a 'listened_' prefix to distinguish listened keys.
    await prefs.setString('listened_${podcast.id.toString()}', podcastJson);
  }

  /// Retrieves all listened-to podcasts.
  Future<List<Podcast>> getListenedPodcasts() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('listened_'));
    List<Podcast> listenedPodcasts = [];
    for (String key in keys) {
      final podcastJson = prefs.getString(key);
      if (podcastJson != null) {
        listenedPodcasts.add(Podcast.fromJson(jsonDecode(podcastJson)));
      }
    }
    return listenedPodcasts;
  }

  /// Gets the count of unique listened podcasts.
  Future<int> getListenedCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys().where((key) => key.startsWith('listened_')).length;
  }
}